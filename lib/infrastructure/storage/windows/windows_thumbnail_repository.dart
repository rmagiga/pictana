/// Windows 向け ThumbnailRepository 実装 (設計書 §11)
///
/// サムネイル生成をワーカーIsolateで実行し、
/// ディスクキャッシュ（SQLite + ファイル）に保存する。
library;

import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/utils/cancel_token.dart';
import '../../../core/utils/cancelable_task_queue.dart';
import '../../../core/logging/app_logger.dart';
import '../../../domain/entities/image_entry.dart';
import '../../../domain/repositories/thumbnail_repository.dart';
import '../../../domain/value_objects/thumbnail_size_option.dart';
import '../../database/app_database.dart';
import '../common/exif_processor_impl.dart';

/// Windows 向け ThumbnailRepository 実装
class WindowsThumbnailRepository implements ThumbnailRepository {
  WindowsThumbnailRepository({required AppDatabase database})
      : _db = database,
        _taskQueue = CancelableTaskQueue(3); // 同時実行数を3に制限

  final AppDatabase _db;
  final CancelableTaskQueue _taskQueue;

  /// ディスクキャッシュのベースディレクトリ
  Directory? _cacheDir;

  // ---------------------------------------------------------------------------
  // ThumbnailRepository 実装
  // ---------------------------------------------------------------------------

  @override
  Future<Uint8List?> getThumbnail(
    ImageEntry entry, {
    ThumbnailSizeOption size = ThumbnailSizeOption.medium,
    CancelToken? cancelToken,
  }) async {
    // 1. DB キャッシュ確認
    final cached = await _db.getThumbnailCache(entry.uri);
    if (cached != null) {
      final cacheFile = File(cached.cachePath);
      if (await cacheFile.exists()) {
        try {
          return await cacheFile.readAsBytes();
        } catch (_) {
          // キャッシュファイルが壊れていれば再生成
          await _db.invalidateThumbnailCache(entry.uri);
        }
      }
    }

    if (cancelToken?.isCancelled == true) return null;

    // 2. Isolate でサムネイル生成 (キュー経由で並列実行数を制限)
    final thumbnail = await _taskQueue.run(() async {
      if (cancelToken?.isCancelled == true) return null;
      return _generateInIsolate(entry.uri, size.px);
    }, token: cancelToken);

    if (thumbnail == null) return null;

    if (cancelToken?.isCancelled == true) return null;

    // 3. ディスクへ保存
    await _saveToDisk(entry.uri, thumbnail, size);

    return thumbnail;
  }

  @override
  Future<int> getCacheSize() async {
    final dir = await _getCacheDir();
    if (!await dir.exists()) return 0;

    var total = 0;
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        try {
          total += await entity.length();
        } catch (_) {}
      }
    }
    return total;
  }

  @override
  Future<void> clearCache() async {
    await _db.clearThumbnailCache();
    final dir = await _getCacheDir();
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  @override
  Future<void> invalidate(ImageEntry entry) async {
    final cached = await _db.getThumbnailCache(entry.uri);
    if (cached != null) {
      await _db.invalidateThumbnailCache(entry.uri);
      try {
        await File(cached.cachePath).delete();
      } catch (_) {}
    }
  }

  @override
  Future<void> setCacheSizeLimit(int limitBytes) async {
    // Phase 5 でキャッシュ上限管理を実装（LRU eviction）
    appLogger.i('setCacheSizeLimit: $limitBytes bytes (Phase 5 で実装)');
  }

  // ---------------------------------------------------------------------------
  // private ヘルパー
  // ---------------------------------------------------------------------------

  /// サムネイルを生成する
  ///
  /// UIスレッドのフリーズを回避するため、Isolate.runを用いた
  /// バックグラウンドIsolateで画像のリサイズデコード処理を実行します。
  Future<Uint8List?> _generateInIsolate(String filePath, int targetSize) async {
    try {
      return await Isolate.run(() async {
        final fileBytes = await File(filePath).readAsBytes();

        // 対応案3: EXIF 埋め込みサムネイルの優先抽出
        List<int>? decodableBytes;
        try {
          final exif = ExifProcessorImpl();
          decodableBytes = exif.extractThumbnail(fileBytes);
        } catch (_) {
          // EXIF抽出失敗時は無視してオリジナル画像を使用
        }

        // EXIFサムネイルがない場合はオリジナル画像データを使用
        decodableBytes ??= fileBytes;

        // Flutter の codec でデコード
        final codec = await ui.instantiateImageCodec(
          Uint8List.fromList(decodableBytes),
          targetWidth: targetSize,
          targetHeight: targetSize,
        );
        final frame = await codec.getNextFrame();
        final image = frame.image;
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        image.dispose();

        return byteData?.buffer.asUint8List();
      });
    } catch (e) {
      appLogger.w('サムネイル生成エラー: $filePath', error: e);
      return null;
    }
  }

  /// サムネイルをディスクとDBへ保存する
  Future<void> _saveToDisk(
    String imageUri,
    Uint8List data,
    ThumbnailSizeOption size,
  ) async {
    try {
      final dir = await _getCacheDir();
      await dir.create(recursive: true);

      // ファイル名は URI のハッシュ値
      final hash = imageUri.hashCode.toRadixString(16);
      final cacheFile = File(p.join(dir.path, '$hash.png'));
      await cacheFile.writeAsBytes(data);

      await _db.upsertThumbnailCache(
        imageUri: imageUri,
        cachePath: cacheFile.path,
        width: size.px,
        height: size.px,
      );
    } catch (e) {
      appLogger.w('サムネイルキャッシュ保存エラー', error: e);
    }
  }

  Future<Directory> _getCacheDir() async {
    if (_cacheDir != null) return _cacheDir!;
    final base = await getApplicationDocumentsDirectory();
    _cacheDir = Directory(p.join(base.path, 'pictana', 'thumbnails'));
    return _cacheDir!;
  }
}
