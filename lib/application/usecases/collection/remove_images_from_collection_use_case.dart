/// RemoveImagesFromCollectionUseCase
///
/// コレクションから画像の関連付けを解除するユースケース。
/// 物理画像ファイルには影響せず、データベース上の関連付けのみを削除する。
library;

import '../../../domain/entities/entry_id.dart';
import '../../../domain/repositories/collection_repository.dart';

/// コレクションから画像を解除するユースケース
class RemoveImagesFromCollectionUseCase {
  const RemoveImagesFromCollectionUseCase({
    required CollectionRepository repository,
  }) : _repository = repository;

  final CollectionRepository _repository;

  /// 指定コレクションから画像の関連付けを解除する。
  ///
  /// [collectionId] 対象コレクションの ID。
  /// [entryIds] 解除する画像の EntryId リスト。
  ///
  /// 物理ファイルは削除されず、DB 上の関連付け（CollectionImage）のみが
  /// 削除される。空リストの場合は何も実行しない。
  Future<void> execute(int collectionId, List<EntryId> entryIds) async {
    if (entryIds.isEmpty) return;
    await _repository.removeImages(collectionId, entryIds);
  }
}
