/// LRU エビクション後のサイズ不変条件 プロパティベーステスト
///
/// glados を使用して、computeEvictionTargets 関数の正当性プロパティを検証する。
///
/// テスト対象:
/// - Property 4: LRU エビクション後のサイズ不変条件
///
/// 検証内容:
/// - 削除対象を全て除去した後の合計サイズ <= limit（可能な場合）
/// - currentTotal <= limit の場合、targets は空
/// - 返される全 ID が入力エントリに存在する
/// - targets は lastAccessedAt の古い順に並ぶ
// Feature: image-viewer-enhancements, Property 4: LRU エビクション後のサイズ不変条件
@Tags(['property-test', 'image-viewer-enhancements'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, tearDown, test;
import 'package:pictana/domain/value_objects/cache_eviction.dart';

/// テスト用キャッシュエントリ
class CacheEntry {
  const CacheEntry({
    required this.id,
    required this.sizeBytes,
    required this.lastAccessedAt,
  });

  final String id;
  final int sizeBytes;
  final DateTime lastAccessedAt;

  /// computeEvictionTargets に渡すレコード形式に変換
  ({String id, int sizeBytes, DateTime lastAccessedAt}) toRecord() =>
      (id: id, sizeBytes: sizeBytes, lastAccessedAt: lastAccessedAt);

  @override
  String toString() =>
      'CacheEntry(id: $id, sizeBytes: $sizeBytes, lastAccessedAt: $lastAccessedAt)';
}

/// テスト入力データ
class EvictionInput {
  const EvictionInput({
    required this.entries,
    required this.currentTotal,
    required this.limit,
  });

  final List<CacheEntry> entries;
  final int currentTotal;
  final int limit;

  @override
  String toString() =>
      'EvictionInput(entries: ${entries.length} items, currentTotal: $currentTotal, limit: $limit)';
}

/// カスタムジェネレーター
extension CacheEvictionGenerators on Any {
  /// 正のサイズを持つキャッシュエントリを生成
  Generator<CacheEntry> get cacheEntry => combine3(
    any.intInRange(0, 10000),
    any.intInRange(1, 1000),
    any.intInRange(0, 100000),
    (int idSeed, int sizeBytes, int timestampOffset) => CacheEntry(
      id: 'entry_$idSeed',
      sizeBytes: sizeBytes,
      lastAccessedAt: DateTime(
        2024,
        1,
        1,
      ).add(Duration(seconds: timestampOffset)),
    ),
  );

  /// エビクションテスト入力を生成（currentTotal がエントリサイズ合計と一致）
  Generator<EvictionInput> get evictionInput =>
      any.listWithLengthInRange(1, 20, any.cacheEntry).bind((entries) {
        final totalSize = entries.fold<int>(0, (sum, e) => sum + e.sizeBytes);
        // limit は 1 〜 totalSize * 2 の範囲で生成
        return any
            .intInRange(1, totalSize * 2 + 1)
            .map(
              (limit) => EvictionInput(
                entries: entries,
                currentTotal: totalSize,
                limit: limit,
              ),
            );
      });

  /// currentTotal > limit となるエビクション入力を生成
  Generator<EvictionInput> get evictionInputOverLimit =>
      any.listWithLengthInRange(1, 20, any.cacheEntry).bind((entries) {
        final totalSize = entries.fold<int>(0, (sum, e) => sum + e.sizeBytes);
        if (totalSize <= 1) {
          // サイズが小さすぎる場合は limit = 0 にして超過を保証
          return any.always(
            EvictionInput(entries: entries, currentTotal: totalSize, limit: 0),
          );
        }
        // limit は 0 〜 totalSize - 1 の範囲で生成（必ず超過）
        return any
            .intInRange(0, totalSize)
            .map(
              (limit) => EvictionInput(
                entries: entries,
                currentTotal: totalSize,
                limit: limit,
              ),
            );
      });

  /// currentTotal <= limit となるエビクション入力を生成
  Generator<EvictionInput> get evictionInputUnderLimit =>
      any.listWithLengthInRange(0, 20, any.cacheEntry).bind((entries) {
        final totalSize = entries.fold<int>(0, (sum, e) => sum + e.sizeBytes);
        // limit は totalSize 以上で生成
        return any
            .intInRange(totalSize, totalSize + 10000)
            .map(
              (limit) => EvictionInput(
                entries: entries,
                currentTotal: totalSize,
                limit: limit,
              ),
            );
      });
}

void main() {
  // ===========================================================================
  // Property 4: LRU エビクション後のサイズ不変条件
  // ===========================================================================
  group('Feature: image-viewer-enhancements, Property 4: LRU エビクション後のサイズ不変条件', () {
    /// **Validates: Requirements 9.3, 9.4**
    ///
    /// 削除対象を全て除去した後の合計サイズが limit 以下になる。
    Glados(any.evictionInputOverLimit).test('削除対象を全て除去した後の残りサイズは limit 以下になる', (
      input,
    ) {
      final records = input.entries.map((e) => e.toRecord()).toList();
      final targets = computeEvictionTargets(
        entries: records,
        currentTotal: input.currentTotal,
        limit: input.limit,
      );

      // 削除対象のサイズ合計を計算
      final removedSize = input.entries
          .where((e) => targets.contains(e.id))
          .fold<int>(0, (sum, e) => sum + e.sizeBytes);
      final remainingSize = input.currentTotal - removedSize;

      expect(
        remainingSize <= input.limit,
        isTrue,
        reason: '残りサイズ ($remainingSize) が limit (${input.limit}) を超えている',
      );
    });

    /// **Validates: Requirements 9.3**
    ///
    /// currentTotal <= limit の場合、削除対象は空リスト。
    Glados(
      any.evictionInputUnderLimit,
    ).test('currentTotal <= limit の場合は targets が空', (input) {
      final records = input.entries.map((e) => e.toRecord()).toList();
      final targets = computeEvictionTargets(
        entries: records,
        currentTotal: input.currentTotal,
        limit: input.limit,
      );

      expect(
        targets,
        isEmpty,
        reason:
            'currentTotal (${input.currentTotal}) <= limit (${input.limit}) なのに targets が空でない: $targets',
      );
    });

    /// **Validates: Requirements 9.3, 9.4**
    ///
    /// 返される全 ID が入力エントリに存在する。
    Glados(any.evictionInput).test('返される全 ID が入力エントリに存在する', (input) {
      final records = input.entries.map((e) => e.toRecord()).toList();
      final targets = computeEvictionTargets(
        entries: records,
        currentTotal: input.currentTotal,
        limit: input.limit,
      );

      final validIds = input.entries.map((e) => e.id).toSet();
      for (final targetId in targets) {
        expect(
          validIds.contains(targetId),
          isTrue,
          reason: 'targets に含まれる ID "$targetId" が入力エントリに存在しない',
        );
      }
    });

    /// **Validates: Requirements 9.4**
    ///
    /// targets は lastAccessedAt の古い順（昇順）に並ぶ。
    Glados(
      any.evictionInputOverLimit,
    ).test('targets は lastAccessedAt の古い順に並ぶ', (input) {
      final records = input.entries.map((e) => e.toRecord()).toList();
      final targets = computeEvictionTargets(
        entries: records,
        currentTotal: input.currentTotal,
        limit: input.limit,
      );

      if (targets.length <= 1) return;

      // targets の各 ID に対応する lastAccessedAt を取得
      final entryMap = {for (final e in input.entries) e.id: e.lastAccessedAt};
      for (var i = 0; i < targets.length - 1; i++) {
        final currentTime = entryMap[targets[i]]!;
        final nextTime = entryMap[targets[i + 1]]!;
        expect(
          currentTime.compareTo(nextTime) <= 0,
          isTrue,
          reason:
              'targets[$i] (${targets[i]}, $currentTime) が targets[${i + 1}] (${targets[i + 1]}, $nextTime) より新しい',
        );
      }
    });
  });
}
