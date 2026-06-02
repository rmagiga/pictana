/// ReorderCollectionsUseCase
///
/// コレクション一覧の並び順を更新するユースケース。
/// 引数で受け取った ID 順序をリポジトリに委譲し、
/// gap-based sortOrder の割り当てはリポジトリ実装に任せる。
library;

import '../../../domain/repositories/collection_repository.dart';

/// コレクション一覧並び替えユースケース
class ReorderCollectionsUseCase {
  const ReorderCollectionsUseCase({required CollectionRepository repository})
    : _repository = repository;

  final CollectionRepository _repository;

  /// コレクション一覧の並び順を更新する。
  ///
  /// [orderedIds] は並び替え後のコレクション ID リスト（表示順）。
  /// リポジトリが gap-based sortOrder を再計算して永続化する。
  ///
  /// 空リストの場合は何も実行しない。
  Future<void> execute(List<int> orderedIds) async {
    if (orderedIds.isEmpty) return;
    await _repository.reorderCollections(orderedIds);
  }
}
