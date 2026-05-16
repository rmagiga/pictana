/// LRU エビクション対象を決定する純粋関数。
///
/// [entries]: キャッシュエントリのリスト（id, sizeBytes, lastAccessedAt）
/// [currentTotal]: 現在の合計キャッシュサイズ（バイト）
/// [limit]: キャッシュサイズ上限（バイト）
///
/// 戻り値: 削除すべきエントリの ID リスト。
/// 最終アクセス日時が古い順に削除対象を選び、
/// 合計サイズが [limit] 以下になるまで繰り返す。
List<String> computeEvictionTargets({
  required List<({String id, int sizeBytes, DateTime lastAccessedAt})> entries,
  required int currentTotal,
  required int limit,
}) {
  if (currentTotal <= limit) return [];
  final sorted = [...entries]
    ..sort((a, b) => a.lastAccessedAt.compareTo(b.lastAccessedAt));
  final targets = <String>[];
  var remaining = currentTotal;
  for (final entry in sorted) {
    if (remaining <= limit) break;
    targets.add(entry.id);
    remaining -= entry.sizeBytes;
  }
  return targets;
}
