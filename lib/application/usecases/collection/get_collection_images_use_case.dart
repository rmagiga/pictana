/// GetCollectionImagesUseCase
///
/// コレクション内の画像一覧を Stream で監視するユースケース。
/// sortOrder 昇順でソートされた画像リストをリアルタイムで配信する。
///
/// Validates: Requirements 8.1, 8.2
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/collection_image.dart';
import '../../providers/repository_providers.dart';

part 'get_collection_images_use_case.g.dart';

/// コレクション画像一覧を Stream で監視するユースケース
@riverpod
class GetCollectionImagesUseCase extends _$GetCollectionImagesUseCase {
  @override
  GetCollectionImagesUseCase build() {
    return this;
  }

  /// コレクション内の画像一覧を sortOrder 昇順で監視する
  ///
  /// [collectionId] 対象コレクションの ID
  /// 戻り値は sortOrder 昇順でソートされた [CollectionImage] リストの Stream
  Stream<List<CollectionImage>> execute(int collectionId) {
    final repository = ref.read(collectionRepositoryProvider);
    return repository.watchCollectionImages(collectionId);
  }
}
