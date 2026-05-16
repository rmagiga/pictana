/// CacheManager 実装 - LRU エビクションロジック (Req 9.3, 9.4, 9.6)
///
/// サムネイルキャッシュの容量管理を担当する。
/// キャッシュ使用量が上限を超過した場合、最終アクセス日時が古い順に
/// エントリを削除し、使用量を上限以下に抑える。
library;

import 'dart:io';

import '../../../core/logging/app_logger.dart';
import '../../../domain/value_objects/cache_eviction.dart';
import '../../database/app_database.dart';

/// キャッシュエントリの情報
typedef CacheEntry = ({String id, int sizeBytes, DateTime lastAccessedAt});

/// キャッシュ管理クラス
///
/// [computeEvictionTargets] 純粋関数を使用して LRU エビクション対象を決定し、
/// ディスク上のキャッシュファイルと DB レコードを削除する。
class CacheManagerImpl {
  CacheManagerImpl({required AppDatabase database}) : _db = database;

  final AppDatabase _db;

  /// キャッシュエントリ一覧を取得する。
  ///
  /// DB の ThumbnailCaches テーブルから全エントリを取得し、
  /// 各ファイルのサイズを計測して返す。
  Future<List<CacheEntry>> getCacheEntries() async {
    final rows = await _db.getAllThumbnailCaches();
    final entries = <CacheEntry>[];

    for (final row in rows) {
      final file = File(row.cachePath);
      try {
        if (await file.exists()) {
          final size = await file.length();
          entries.add((
            id: row.imageUri,
            sizeBytes: size,
            lastAccessedAt: row.updatedAt,
          ));
        }
      } catch (_) {
        // ファイルアクセス失敗時はスキップ
      }
    }

    return entries;
  }

  /// 現在のキャッシュ合計サイズを計算する（バイト）。
  int computeTotalSize(List<CacheEntry> entries) {
    var total = 0;
    for (final entry in entries) {
      total += entry.sizeBytes;
    }
    return total;
  }

  /// キャッシュ使用量が [limit] を超過している場合にエビクションを実行する。
  ///
  /// [computeEvictionTargets] 純粋関数で削除対象を決定し、
  /// 各エントリを削除する。削除失敗時はスキップして続行する (Req 9.6)。
  ///
  /// 戻り値: 実際に削除されたエントリ数。
  Future<int> evictIfNeeded(int limit) async {
    final entries = await getCacheEntries();
    final currentTotal = computeTotalSize(entries);

    if (currentTotal <= limit) return 0;

    final targets = computeEvictionTargets(
      entries: entries,
      currentTotal: currentTotal,
      limit: limit,
    );

    var deletedCount = 0;
    for (final id in targets) {
      try {
        await deleteEntry(id);
        deletedCount++;
      } catch (e) {
        // 削除失敗はログに記録してスキップ (Req 9.6)
        appLogger.w('キャッシュエントリ削除失敗: $id', error: e);
        continue;
      }
    }

    return deletedCount;
  }

  /// 指定されたキャッシュエントリを削除する。
  ///
  /// DB レコードとディスク上のファイルの両方を削除する。
  /// ファイル削除に失敗した場合は例外をスローする。
  Future<void> deleteEntry(String id) async {
    // DB からキャッシュパスを取得
    final cached = await _db.getThumbnailCache(id);
    if (cached == null) return;

    // ディスク上のファイルを削除
    final file = File(cached.cachePath);
    if (await file.exists()) {
      await file.delete();
    }

    // DB レコードを削除
    await _db.invalidateThumbnailCache(id);
  }
}
