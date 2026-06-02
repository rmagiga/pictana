/// GetCollectionsUseCase
///
/// コレクション一覧を Stream で監視するユースケース。
/// sortOrder 昇順かつ imageCount 付きのコレクション一覧をリアルタイムで返す。
library;

import '../../../domain/entities/collection.dart';
import '../../../domain/repositories/collection_repository.dart';

/// コレクション一覧を監視するユースケース
class GetCollectionsUseCase {
  const GetCollectionsUseCase({required CollectionRepository repository})
    : _repository = repository;

  final CollectionRepository _repository;

  /// コレクション一覧を sortOrder 昇順で監視する Stream を返す
  ///
  /// Stream は DB の変更に応じて最新のコレクション一覧を emit する。
  /// 各コレクションには imageCount が含まれる。
  Stream<List<Collection>> execute() {
    return _repository.watchCollections();
  }
}
