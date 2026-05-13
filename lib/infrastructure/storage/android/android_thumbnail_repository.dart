/// Android SAF 向け ThumbnailRepository 実装 (設計書 §AndroidThumbnailRepository)
///
/// サムネイル取得の優先順位:
/// 1. メモリキャッシュ (Map) → 即座に返却
/// 2. DB キャッシュ (Drift) → メモリキャッシュに格納して返却
/// 3. ネイティブ生成 (SafPlatformChannel) → メモリ + DB に保存して返却
///
/// ネイティブ側で ContentResolver.loadThumbnail() + BitmapFactory フォールバックを実行し、
/// JPEG (quality=80) のバイト配列を返す。
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/logging/app_logger.dart';
import '../../../domain/entities/image_entry.dart';
import '../../../domain/repositories/thumbnail_repository.dart';
import '../../database/app_database.dart';
import 'saf_platform_channel.dart';

/// Android SAF 向け ThumbnailRepository 実装
class AndroidThumbnailRepository implements ThumbnailRepository {
  AndroidThumbnailRepository({
    required AppDatabase database,
    required SafPlatformChannel channel,
  }) : _db = database,
       _channel = channel;

  final AppDatabase _db;
  final SafPlatformChannel _channel;

  /// メモリキャッシュ（URI → サムネイルバイト）
  ///
  /// アクセス順序を保持するため LinkedHashMap として動作する Map を使用。
  /// [_cacheSizeLimit] を超えた場合は古いエントリから削除する。
  final Map<String, Uint8List> _memoryCache = {};

  /// メモリキャッシュの現在のバイトサイズ合計
  int _memoryCacheBytes = 0;

  /// メモリキャッシュのサイズ上限（デフォルト: 50MB）
  int _memoryCacheSizeLimit = 50 * 1024 * 1024;

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
    final cacheKey = _buildCacheKey(entry.uri, size);

    // 1. メモリキャッシュ確認
    final memoryCached = _memoryCache[cacheKey];
    if (memoryCached != null) {
      return memoryCached;
    }

    // 2. DB キャッシュ確認
    final dbCached = await _db.getThumbnailCache(cacheKey);
    if (dbCached != null) {
      final cacheFile = File(dbCached.cachePath);
      if (await cacheFile.exists()) {
        try {
          final bytes = await cacheFile.readAsBytes();
          _putMemoryCache(cacheKey, bytes);
          return bytes;
        } catch (_) {
          // キャッシュファイルが壊れていれば再生成
          await _db.invalidateThumbnailCache(cacheKey);
        }
      } else {
        // ファイルが存在しない場合は DB エントリを削除
        await _db.invalidateThumbnailCache(cacheKey);
      }
    }

    // 3. ネイティブ生成
    final thumbnail = await _generateFromNative(entry.uri, size);
    if (thumbnail == null) return null;

    // メモリ + DB に保存
    _putMemoryCache(cacheKey, thumbnail);
    await _saveToDisk(cacheKey, thumbnail, size);

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
    // メモリキャッシュクリア
    _memoryCache.clear();
    _memoryCacheBytes = 0;

    // DB キャッシュクリア
    await _db.clearThumbnailCache();

    // ディスクキャッシュクリア
    final dir = await _getCacheDir();
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  @override
  Future<void> invalidate(ImageEntry entry) async {
    // grid と large の両方のキャッシュを無効化
    for (final size in ThumbnailSize.values) {
      final cacheKey = _buildCacheKey(entry.uri, size);

      // メモリキャッシュから削除
      final removed = _memoryCache.remove(cacheKey);
      if (removed != null) {
        _memoryCacheBytes -= removed.lengthInBytes;
      }

      // DB + ディスクから削除
      final cached = await _db.getThumbnailCache(cacheKey);
      if (cached != null) {
        await _db.invalidateThumbnailCache(cacheKey);
        try {
          await File(cached.cachePath).delete();
        } catch (_) {}
      }
    }
  }

  @override
  Future<void> setCacheSizeLimit(int limitBytes) async {
    _memoryCacheSizeLimit = limitBytes;
    _evictMemoryCacheIfNeeded();
  }

  // ---------------------------------------------------------------------------
  // private ヘルパー
  // ---------------------------------------------------------------------------

  /// キャッシュキーを生成する
  ///
  /// URI + サイズの組み合わせで一意に識別する。
  String _buildCacheKey(String uri, ThumbnailSize size) {
    return '${uri}::${size.px}';
  }

  /// ネイティブチャネル経由でサムネイルを生成する
  ///
  /// 生成失敗時は null を返す（例外を投げない）。
  Future<Uint8List?> _generateFromNative(
    String contentUri,
    ThumbnailSize size,
  ) async {
    try {
      return await _channel.getThumbnail(contentUri, size.px, size.px);
    } catch (e) {
      appLogger.w('サムネイルネイティブ生成エラー: $contentUri', error: e);
      return null;
    }
  }

  /// メモリキャッシュにエントリを追加する
  ///
  /// サイズ上限を超えた場合は古いエントリから削除する。
  void _putMemoryCache(String key, Uint8List data) {
    // 既存エントリがあれば先に削除
    final existing = _memoryCache.remove(key);
    if (existing != null) {
      _memoryCacheBytes -= existing.lengthInBytes;
    }

    _memoryCache[key] = data;
    _memoryCacheBytes += data.lengthInBytes;

    _evictMemoryCacheIfNeeded();
  }

  /// メモリキャッシュのサイズ上限を超えている場合、古いエントリを削除する
  void _evictMemoryCacheIfNeeded() {
    while (_memoryCacheBytes > _memoryCacheSizeLimit &&
        _memoryCache.isNotEmpty) {
      final oldestKey = _memoryCache.keys.first;
      final removed = _memoryCache.remove(oldestKey);
      if (removed != null) {
        _memoryCacheBytes -= removed.lengthInBytes;
      }
    }
  }

  /// サムネイルをディスクと DB へ保存する
  Future<void> _saveToDisk(
    String cacheKey,
    Uint8List data,
    ThumbnailSize size,
  ) async {
    try {
      final dir = await _getCacheDir();
      await dir.create(recursive: true);

      // ファイル名はキャッシュキーのハッシュ値
      final hash = cacheKey.hashCode.toRadixString(16);
      final cacheFile = File(p.join(dir.path, '$hash.jpg'));
      await cacheFile.writeAsBytes(data);

      await _db.upsertThumbnailCache(
        imageUri: cacheKey,
        cachePath: cacheFile.path,
        width: size.px,
        height: size.px,
      );
    } catch (e) {
      appLogger.w('サムネイルキャッシュ保存エラー', error: e);
    }
  }

  /// キャッシュディレクトリを取得する
  Future<Directory> _getCacheDir() async {
    if (_cacheDir != null) return _cacheDir!;
    final base = await getApplicationCacheDirectory();
    _cacheDir = Directory(p.join(base.path, 'thumbnails'));
    return _cacheDir!;
  }
}
