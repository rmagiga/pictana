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

import '../../../core/logging/app_logger.dart';
import '../../../domain/entities/image_entry.dart';
import '../../../domain/repositories/thumbnail_repository.dart';
import '../../database/app_database.dart';

/// Worker Isolate へのメッセージ
class _ThumbnailRequest {
  const _ThumbnailRequest({
    required this.filePath,
    required this.targetSize,
    required this.sendPort,
  });
  final String filePath;
  final int targetSize;
  final SendPort sendPort;
}

/// ワーカー Isolate エントリポイント（decode & resize）
@pragma('vm:entry-point')
void _thumbnailWorker(_ThumbnailRequest req) async {
  try {
    final bytes = await File(req.filePath).readAsBytes();

    // Flutter の codec でデコード
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: req.targetSize,
      targetHeight: req.targetSize,
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    req.sendPort.send(byteData?.buffer.asUint8List());
  } catch (e) {
    req.sendPort.send(null);
  }
}

/// Windows 向け ThumbnailRepository 実装
class WindowsThumbnailRepository implements ThumbnailRepository {
  WindowsThumbnailRepository({required AppDatabase database})
      : _db = database;

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

  /// Isolate でサムネイルを生成する
  Future<Uint8List?> _generateInIsolate(
    String filePath,
    int targetSize,
  ) async {
    final receivePort = ReceivePort();
    try {
      await Isolate.spawn(
        _thumbnailWorker,
        _ThumbnailRequest(
          filePath: filePath,
          targetSize: targetSize,
          sendPort: receivePort.sendPort,
        ),
        onError: receivePort.sendPort,
      );
      final result = await receivePort.first;
      if (result is Uint8List) return result;
      return null;
    } catch (e) {
      appLogger.w('サムネイル生成 Isolate エラー: $filePath', error: e);
      return null;
    } finally {
      receivePort.close();
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
