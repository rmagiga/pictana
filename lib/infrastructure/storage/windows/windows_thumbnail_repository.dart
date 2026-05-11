/// Windows 向け ThumbnailRepository 実装 (設計書 §11)
///
/// サムネイル生成をワーカーIsolateで実行し、
/// ディスクキャッシュ（SQLite + ファイル）に保存する。
library;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/logging/app_logger.dart';
import '../../../domain/entities/image_entry.dart';
import '../../../domain/repositories/thumbnail_repository.dart';
import '../../database/app_database.dart';

/// Windows 向け ThumbnailRepository 実装
class WindowsThumbnailRepository implements ThumbnailRepository {
  WindowsThumbnailRepository({required AppDatabase database}) : _db = database;

  final AppDatabase _db;

  /// ディスクキャッシュのベースディレクトリ
  Directory? _cacheDir;

  // ---------------------------------------------------------------------------
  // ThumbnailRepository 実装
  // ---------------------------------------------------------------------------

  @override
  Future<Uint8List?> getThumbnail(
    ImageEntry entry, {
    ThumbnailSize size = ThumbnailSize.grid,
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

    // 2. Isolate でサムネイル生成
    final thumbnail = await _generateInIsolate(entry.uri, size.px);
    if (thumbnail == null) return null;

    // 3. ディスクへ保存
    await _saveToDisk(entry.uri, thumbnail);

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
  /// 注意: Windows では Background Isolate での dart:ui (画像デコーダー) 使用に制限があるため、
  /// (Exception: Failed to access the internal image decoder registry)
  /// 現在はメイン Isolate で実行しています。
  Future<Uint8List?> _generateInIsolate(String filePath, int targetSize) async {
    try {
      final bytes = await File(filePath).readAsBytes();

      // Flutter の codec でデコード
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: targetSize,
        targetHeight: targetSize,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();

      return byteData?.buffer.asUint8List();
    } catch (e) {
      appLogger.w('サムネイル生成エラー: $filePath', error: e);
      return null;
    }
  }

  /// サムネイルをディスクとDBへ保存する
  Future<void> _saveToDisk(String imageUri, Uint8List data) async {
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
        width: 256,
        height: 256,
      );
    } catch (e) {
      appLogger.w('サムネイルキャッシュ保存エラー', error: e);
    }
  }

  Future<Directory> _getCacheDir() async {
    if (_cacheDir != null) return _cacheDir!;
    final base = await getApplicationDocumentsDirectory();
    _cacheDir = Directory(p.join(base.path, 'optrig', 'thumbnails'));
    return _cacheDir!;
  }
}
