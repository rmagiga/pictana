/// DeleteCollectionUseCase
///
/// 単一または複数のコレクションを削除するユースケース。
/// CASCADE 削除により、関連する CollectionImage も自動的に削除される。
/// 物理画像ファイルは保持される（データベース上の関連付けのみ削除）。
library;

import '../../../domain/repositories/collection_repository.dart';

/// 単一/複数コレクション削除ユースケース
class DeleteCollectionUseCase {
  const DeleteCollectionUseCase({required CollectionRepository repository})
    : _repository = repository;

  final CollectionRepository _repository;

  /// 指定された ID のコレクションを削除する。
  ///
  /// [ids] に含まれる全てのコレクションとその関連付け（CollectionImage）を
  /// データベースから削除する。物理画像ファイルは保持される。
  ///
  /// 単一削除の場合は要素数1のリストを渡す。
  /// 空リストの場合は何も実行しない。
  Future<void> execute(List<int> ids) async {
    if (ids.isEmpty) return;
    await _repository.deleteCollections(ids);
  }
}
