/// CacheManagerImpl ユニットテスト
///
/// LRU エビクション実行・削除失敗スキップ・上限変更時の動作を検証する。
/// AppDatabase の生成コードに依存しないよう、CacheManagerImpl のエビクション
/// ロジックをテスト用クラスで再現して検証する。
///
/// Requirements: 9.3, 9.4, 9.6
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pictana/domain/value_objects/cache_eviction.dart';

/// キャッシュエントリの情報（CacheManagerImpl の CacheEntry と同一構造）
typedef CacheEntry = ({String id, int sizeBytes, DateTime lastAccessedAt});

/// テスト用 CacheManager
///
/// CacheManagerImpl の evictIfNeeded ロジックを再現する。
/// DB・ファイルシステムに依存せず、エビクションロジックのみを検証する。
class TestableCacheManager {
  TestableCacheManager({
    required this.mockedEntries,
    this.failingIds = const {},
  });

  final List<CacheEntry> mockedEntries;
  final Set<String> failingIds;

  /// 削除が成功した ID を記録する
  final List<String> deletedIds = [];

  /// 削除が試行された ID を記録する（失敗含む）
  final List<String> attemptedIds = [];

  /// キャッシュエントリ一覧を取得する（モック）
  Future<List<CacheEntry>> getCacheEntries() async => mockedEntries;

  /// 現在のキャッシュ合計サイズを計算する（バイト）。
  int computeTotalSize(List<CacheEntry> entries) {
    var total = 0;
    for (final entry in entries) {
      total += entry.sizeBytes;
    }
    return total;
  }

  /// エントリを削除する（モック）
  ///
  /// [failingIds] に含まれる ID の場合は FileSystemException をスローする。
  Future<void> deleteEntry(String id) async {
    attemptedIds.add(id);
    if (failingIds.contains(id)) {
      throw const FileSystemException('テスト用削除失敗');
    }
    deletedIds.add(id);
  }

  /// CacheManagerImpl.evictIfNeeded と同一のロジック。
  ///
  /// キャッシュ使用量が [limit] を超過している場合にエビクションを実行する。
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
        // 削除失敗はスキップして続行 (Req 9.6)
        continue;
      }
    }

    return deletedCount;
  }
}

void main() {
  group('CacheManagerImpl', () {
    group('evictIfNeeded - 上限以下の場合（エビクション不要）', () {
      test('キャッシュ使用量が上限未満の場合は 0 を返す', () async {
        final entries = <CacheEntry>[
          (id: 'img1', sizeBytes: 100, lastAccessedAt: DateTime(2024, 1, 1)),
          (id: 'img2', sizeBytes: 100, lastAccessedAt: DateTime(2024, 1, 2)),
          (id: 'img3', sizeBytes: 100, lastAccessedAt: DateTime(2024, 1, 3)),
        ];

        final manager = TestableCacheManager(mockedEntries: entries);

        final result = await manager.evictIfNeeded(500);

        expect(result, 0);
        expect(manager.attemptedIds, isEmpty);
      });

      test('キャッシュ使用量が上限と等しい場合は 0 を返す', () async {
        final entries = <CacheEntry>[
          (id: 'img1', sizeBytes: 250, lastAccessedAt: DateTime(2024, 1, 1)),
          (id: 'img2', sizeBytes: 250, lastAccessedAt: DateTime(2024, 1, 2)),
        ];

        final manager = TestableCacheManager(mockedEntries: entries);

        final result = await manager.evictIfNeeded(500);

        expect(result, 0);
        expect(manager.attemptedIds, isEmpty);
      });

      test('エントリが空の場合は 0 を返す', () async {
        final manager = TestableCacheManager(mockedEntries: []);

        final result = await manager.evictIfNeeded(500);

        expect(result, 0);
        expect(manager.attemptedIds, isEmpty);
      });
    });

    group('evictIfNeeded - エビクション実行 (Req 9.3)', () {
      test('上限超過時に LRU 順で削除し、削除数を返す', () async {
        // 合計 600B、上限 400B → 200B 超過
        // 最古の img1 (200B) を削除すれば 400B で上限以下
        final entries = <CacheEntry>[
          (
            id: 'img1',
            sizeBytes: 200,
            lastAccessedAt: DateTime(2024, 1, 1), // 最古
          ),
          (id: 'img2', sizeBytes: 200, lastAccessedAt: DateTime(2024, 1, 2)),
          (
            id: 'img3',
            sizeBytes: 200,
            lastAccessedAt: DateTime(2024, 1, 3), // 最新
          ),
        ];

        final manager = TestableCacheManager(mockedEntries: entries);

        final result = await manager.evictIfNeeded(400);

        expect(result, 1);
        expect(manager.deletedIds, ['img1']);
      });

      test('複数エントリを LRU 順で削除する', () async {
        // 合計 1000B、上限 300B
        // img1(100) 削除 → 900 > 300
        // img2(200) 削除 → 700 > 300
        // img3(300) 削除 → 400 > 300
        // img4(400) 削除 → 0 <= 300
        final entries = <CacheEntry>[
          (
            id: 'img1',
            sizeBytes: 100,
            lastAccessedAt: DateTime(2024, 1, 1), // 最古
          ),
          (id: 'img2', sizeBytes: 200, lastAccessedAt: DateTime(2024, 1, 2)),
          (id: 'img3', sizeBytes: 300, lastAccessedAt: DateTime(2024, 1, 3)),
          (
            id: 'img4',
            sizeBytes: 400,
            lastAccessedAt: DateTime(2024, 1, 4), // 最新
          ),
        ];

        final manager = TestableCacheManager(mockedEntries: entries);

        final result = await manager.evictIfNeeded(300);

        expect(result, 4);
        expect(manager.deletedIds, ['img1', 'img2', 'img3', 'img4']);
      });
    });

    group('evictIfNeeded - エビクション後のサイズ検証 (Req 9.4)', () {
      test('エビクション後の残りサイズが上限以下になる', () async {
        // 合計 500B、上限 250B
        // img1(150B) 削除 → 350B > 250B
        // img2(150B) 削除 → 200B <= 250B → 停止
        final entries = <CacheEntry>[
          (id: 'img1', sizeBytes: 150, lastAccessedAt: DateTime(2024, 1, 1)),
          (id: 'img2', sizeBytes: 150, lastAccessedAt: DateTime(2024, 1, 2)),
          (id: 'img3', sizeBytes: 200, lastAccessedAt: DateTime(2024, 1, 3)),
        ];

        final manager = TestableCacheManager(mockedEntries: entries);

        final result = await manager.evictIfNeeded(250);

        expect(result, 2);
        expect(manager.deletedIds, ['img1', 'img2']);

        // 残りサイズを検証: 500 - 150 - 150 = 200 <= 250
        final totalSize = entries.fold<int>(0, (sum, e) => sum + e.sizeBytes);
        final deletedSize = entries
            .where((e) => manager.deletedIds.contains(e.id))
            .fold<int>(0, (sum, e) => sum + e.sizeBytes);
        final remainingSize = totalSize - deletedSize;
        expect(remainingSize, lessThanOrEqualTo(250));
      });

      test('上限が 0 の場合は全エントリを削除対象にする', () async {
        final entries = <CacheEntry>[
          (id: 'img1', sizeBytes: 100, lastAccessedAt: DateTime(2024, 1, 1)),
          (id: 'img2', sizeBytes: 200, lastAccessedAt: DateTime(2024, 1, 2)),
        ];

        final manager = TestableCacheManager(mockedEntries: entries);

        final result = await manager.evictIfNeeded(0);

        expect(result, 2);
        expect(manager.deletedIds.length, 2);
      });
    });

    group('evictIfNeeded - LRU 順序の検証', () {
      test('エントリが lastAccessedAt 古い順で削除される', () async {
        // 意図的にリスト内の順序と lastAccessedAt 順を異なるようにする
        final entries = <CacheEntry>[
          (
            id: 'img_newest',
            sizeBytes: 100,
            lastAccessedAt: DateTime(2024, 6, 1), // 最新
          ),
          (
            id: 'img_oldest',
            sizeBytes: 100,
            lastAccessedAt: DateTime(2024, 1, 1), // 最古
          ),
          (
            id: 'img_middle',
            sizeBytes: 100,
            lastAccessedAt: DateTime(2024, 3, 1), // 中間
          ),
        ];

        final manager = TestableCacheManager(mockedEntries: entries);

        // 合計 300B、上限 150B → 150B 超過 → 2 エントリ削除
        final result = await manager.evictIfNeeded(150);

        expect(result, 2);
        // 古い順: img_oldest → img_middle
        expect(manager.deletedIds, ['img_oldest', 'img_middle']);
      });

      test('同一 lastAccessedAt のエントリも正しく処理される', () async {
        final sameTime = DateTime(2024, 1, 1);
        final entries = <CacheEntry>[
          (id: 'img1', sizeBytes: 100, lastAccessedAt: sameTime),
          (id: 'img2', sizeBytes: 100, lastAccessedAt: sameTime),
          (
            id: 'img3',
            sizeBytes: 100,
            lastAccessedAt: DateTime(2024, 6, 1), // 最新
          ),
        ];

        final manager = TestableCacheManager(mockedEntries: entries);

        // 合計 300B、上限 100B → 200B 超過 → 2 エントリ削除
        final result = await manager.evictIfNeeded(100);

        expect(result, 2);
        // img1 と img2 が削除される（同一時刻なので img3 は残る）
        expect(manager.deletedIds.length, 2);
        expect(manager.deletedIds, isNot(contains('img3')));
      });
    });

    group('evictIfNeeded - 削除失敗スキップ (Req 9.6)', () {
      test('削除失敗時はスキップして次のエントリの削除を続行する', () async {
        // 合計 400B、上限 100B
        // computeEvictionTargets: img1(100)→300>100, img2(100)→200>100,
        //   img3(100)→100<=100 → 停止。削除対象は img1, img2, img3。
        // img1 は削除失敗 → スキップ → img2, img3 は成功
        final entries = <CacheEntry>[
          (
            id: 'img1',
            sizeBytes: 100,
            lastAccessedAt: DateTime(2024, 1, 1), // 最古 - 削除失敗
          ),
          (id: 'img2', sizeBytes: 100, lastAccessedAt: DateTime(2024, 1, 2)),
          (id: 'img3', sizeBytes: 100, lastAccessedAt: DateTime(2024, 1, 3)),
          (
            id: 'img4',
            sizeBytes: 100,
            lastAccessedAt: DateTime(2024, 1, 4), // 最新
          ),
        ];

        final manager = TestableCacheManager(
          mockedEntries: entries,
          failingIds: {'img1'},
        );

        final result = await manager.evictIfNeeded(100);

        // img1 は失敗、img2 と img3 が成功（img4 は削除対象外）
        expect(result, 2);
        expect(manager.attemptedIds, ['img1', 'img2', 'img3']);
        expect(manager.deletedIds, isNot(contains('img1')));
        expect(manager.deletedIds, containsAll(['img2', 'img3']));
      });

      test('複数の削除失敗があっても処理を続行する', () async {
        final entries = <CacheEntry>[
          (
            id: 'img1',
            sizeBytes: 100,
            lastAccessedAt: DateTime(2024, 1, 1), // 削除失敗
          ),
          (
            id: 'img2',
            sizeBytes: 100,
            lastAccessedAt: DateTime(2024, 1, 2), // 削除失敗
          ),
          (
            id: 'img3',
            sizeBytes: 100,
            lastAccessedAt: DateTime(2024, 1, 3), // 削除成功
          ),
        ];

        final manager = TestableCacheManager(
          mockedEntries: entries,
          failingIds: {'img1', 'img2'},
        );

        // 合計 300B、上限 50B → 全エントリが削除対象
        final result = await manager.evictIfNeeded(50);

        // img1, img2 は失敗、img3 のみ成功
        expect(result, 1);
        expect(manager.attemptedIds, ['img1', 'img2', 'img3']);
        expect(manager.deletedIds, ['img3']);
      });

      test('全ての削除が失敗した場合は 0 を返す', () async {
        final entries = <CacheEntry>[
          (id: 'img1', sizeBytes: 200, lastAccessedAt: DateTime(2024, 1, 1)),
          (id: 'img2', sizeBytes: 200, lastAccessedAt: DateTime(2024, 1, 2)),
        ];

        final manager = TestableCacheManager(
          mockedEntries: entries,
          failingIds: {'img1', 'img2'},
        );

        final result = await manager.evictIfNeeded(100);

        expect(result, 0);
        expect(manager.attemptedIds, ['img1', 'img2']);
        expect(manager.deletedIds, isEmpty);
      });

      test('削除失敗後も残りのエントリを全て試行する', () async {
        // 中間のエントリが失敗するケース
        final entries = <CacheEntry>[
          (
            id: 'img1',
            sizeBytes: 100,
            lastAccessedAt: DateTime(2024, 1, 1), // 成功
          ),
          (
            id: 'img2',
            sizeBytes: 100,
            lastAccessedAt: DateTime(2024, 1, 2), // 失敗
          ),
          (
            id: 'img3',
            sizeBytes: 100,
            lastAccessedAt: DateTime(2024, 1, 3), // 成功
          ),
          (
            id: 'img4',
            sizeBytes: 100,
            lastAccessedAt: DateTime(2024, 1, 4), // 失敗
          ),
          (
            id: 'img5',
            sizeBytes: 100,
            lastAccessedAt: DateTime(2024, 1, 5), // 成功
          ),
        ];

        final manager = TestableCacheManager(
          mockedEntries: entries,
          failingIds: {'img2', 'img4'},
        );

        // 合計 500B、上限 0B → 全エントリが削除対象
        final result = await manager.evictIfNeeded(0);

        expect(result, 3); // img1, img3, img5 が成功
        expect(manager.attemptedIds, ['img1', 'img2', 'img3', 'img4', 'img5']);
        expect(manager.deletedIds, ['img1', 'img3', 'img5']);
      });
    });

    group('computeTotalSize', () {
      test('空リストの場合は 0 を返す', () {
        final manager = TestableCacheManager(mockedEntries: []);
        final result = manager.computeTotalSize([]);
        expect(result, 0);
      });

      test('全エントリのサイズ合計を正しく計算する', () {
        final manager = TestableCacheManager(mockedEntries: []);
        final entries = <CacheEntry>[
          (id: 'a', sizeBytes: 100, lastAccessedAt: DateTime(2024, 1, 1)),
          (id: 'b', sizeBytes: 250, lastAccessedAt: DateTime(2024, 1, 2)),
          (id: 'c', sizeBytes: 350, lastAccessedAt: DateTime(2024, 1, 3)),
        ];
        final result = manager.computeTotalSize(entries);
        expect(result, 700);
      });

      test('単一エントリのサイズを正しく返す', () {
        final manager = TestableCacheManager(mockedEntries: []);
        final entries = <CacheEntry>[
          (id: 'single', sizeBytes: 1024, lastAccessedAt: DateTime(2024, 1, 1)),
        ];
        final result = manager.computeTotalSize(entries);
        expect(result, 1024);
      });
    });
  });
}
