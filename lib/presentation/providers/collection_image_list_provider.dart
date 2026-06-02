/// コレクション画像一覧 Provider
///
/// GetCollectionImagesUseCase を利用してコレクション画像一覧を Stream で監視する。
/// sortOrder 昇順で表示され、DB の変更に応じてリアルタイムに更新される。
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/usecases/collection/get_collection_images_use_case.dart';
import '../../domain/entities/collection_image.dart';

part 'collection_image_list_provider.g.dart';

// ---------------------------------------------------------------------------
// Stream Provider
// ---------------------------------------------------------------------------

/// コレクション画像一覧を sortOrder 昇順でリアルタイム監視する Stream Provider
///
/// [collectionId] 対象コレクションの ID
/// DB のコレクション画像データが変更されると自動的に最新の一覧を emit する。
@riverpod
Stream<List<CollectionImage>> collectionImageList(Ref ref, int collectionId) {
  final useCase = ref.watch(getCollectionImagesUseCaseProvider);
  return useCase.execute(collectionId);
}
