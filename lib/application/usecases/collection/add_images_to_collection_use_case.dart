/// AddImagesToCollectionUseCase
///
/// 複数コレクションへの画像追加ユースケース。
/// 指定された全コレクションに対して画像を追加し、
/// 既に所属している画像はスキップして実際に追加された合計件数を返す。
library;

import '../../../domain/entities/entry_id.dart';
import '../../../domain/repositories/collection_repository.dart';

/// 複数コレクションへの画像追加ユースケース
///
/// 責務:
/// - 複数コレクションへの画像一括追加
/// - 重複画像のスキップ（リポジトリ層で処理）
/// - 追加件数の集計・返却
class AddImagesToCollectionUseCase {
  const AddImagesToCollectionUseCase({required CollectionRepository repository})
    : _repository = repository;

  final CollectionRepository _repository;

  /// 指定コレクション群に画像を追加する。
  ///
  /// [collectionIds] には追加先のコレクション ID リストを渡す。
  /// [entryIds] には追加する画像の EntryId リストを渡す。
  ///
  /// 各コレクションについて、既に所属している画像はスキップされる。
  /// 戻り値は全コレクションで実際に追加された件数の合計。
  Future<int> execute({
    required List<int> collectionIds,
    required List<EntryId> entryIds,
  }) async {
    var totalAdded = 0;

    for (final collectionId in collectionIds) {
      final added = await _repository.addImages(collectionId, entryIds);
      totalAdded += added;
    }

    return totalAdded;
  }
}
