/// ReorderCollectionImagesUseCase
///
/// コレクション内画像の並び替えユースケース。
/// ユーザーが指定した順序（相対順序維持アルゴリズム）で
/// コレクション内画像の sortOrder を更新する。
///
/// Repository が gap-based sortOrder の割り当てを担当するため、
/// UseCase はバリデーションとリポジトリ呼び出しに専念する。
library;

import '../../../domain/entities/entry_id.dart';
import '../../../domain/repositories/collection_repository.dart';

/// コレクション内画像の並び替えユースケース
///
/// 責務:
/// - 入力バリデーション（空リストチェック）
/// - リポジトリへの並び替え委譲
/// - 相対順序維持: 選択画像間の元の並び順を保持したまま挿入位置に移動
class ReorderCollectionImagesUseCase {
  const ReorderCollectionImagesUseCase({
    required CollectionRepository repository,
  }) : _repository = repository;

  final CollectionRepository _repository;

  /// コレクション内画像の並び順を更新する。
  ///
  /// [collectionId] 対象コレクションの ID。
  /// [orderedEntryIds] 新しい並び順を示す EntryId のリスト。
  /// リスト内の順序がそのまま表示順序となる。
  ///
  /// 複数画像の一括移動時は、呼び出し元が相対順序を維持した状態で
  /// [orderedEntryIds] を構築する。Repository が gap-based sortOrder を
  /// 再計算して永続化する。
  ///
  /// 空リストの場合は何も実行しない。
  Future<void> execute(int collectionId, List<EntryId> orderedEntryIds) async {
    if (orderedEntryIds.isEmpty) return;
    await _repository.reorderImages(collectionId, orderedEntryIds);
  }
}
