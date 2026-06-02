/// コレクション一覧 Provider
///
/// GetCollectionsUseCase を利用してコレクション一覧を Stream で監視する。
/// sortOrder 昇順で表示され、DB の変更に応じてリアルタイムに更新される。
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/providers/repository_providers.dart';
import '../../application/usecases/collection/add_images_to_collection_use_case.dart';
import '../../application/usecases/collection/create_collection_use_case.dart';
import '../../application/usecases/collection/delete_collection_use_case.dart';
import '../../application/usecases/collection/get_collections_use_case.dart';
import '../../application/usecases/collection/remove_images_from_collection_use_case.dart';
import '../../application/usecases/collection/rename_collection_use_case.dart';
import '../../application/usecases/collection/reorder_collection_images_use_case.dart';
import '../../application/usecases/collection/reorder_collections_use_case.dart';
import '../../domain/entities/collection.dart';

part 'collection_list_provider.g.dart';

// ---------------------------------------------------------------------------
// UseCase Provider
// ---------------------------------------------------------------------------

/// GetCollectionsUseCase の DI Provider
@riverpod
GetCollectionsUseCase getCollectionsUseCase(Ref ref) {
  final repository = ref.watch(collectionRepositoryProvider);
  return GetCollectionsUseCase(repository: repository);
}

/// CreateCollectionUseCase の DI Provider
@riverpod
CreateCollectionUseCase createCollectionUseCase(Ref ref) {
  final repository = ref.watch(collectionRepositoryProvider);
  return CreateCollectionUseCase(repository: repository);
}

/// RenameCollectionUseCase の DI Provider
@riverpod
RenameCollectionUseCase renameCollectionUseCase(Ref ref) {
  final repository = ref.watch(collectionRepositoryProvider);
  return RenameCollectionUseCase(repository: repository);
}

/// AddImagesToCollectionUseCase の DI Provider
@riverpod
AddImagesToCollectionUseCase addImagesToCollectionUseCase(Ref ref) {
  final repository = ref.watch(collectionRepositoryProvider);
  return AddImagesToCollectionUseCase(repository: repository);
}

/// RemoveImagesFromCollectionUseCase の DI Provider
@riverpod
RemoveImagesFromCollectionUseCase removeImagesFromCollectionUseCase(Ref ref) {
  final repository = ref.watch(collectionRepositoryProvider);
  return RemoveImagesFromCollectionUseCase(repository: repository);
}

/// DeleteCollectionUseCase の DI Provider
@riverpod
DeleteCollectionUseCase deleteCollectionUseCase(Ref ref) {
  final repository = ref.watch(collectionRepositoryProvider);
  return DeleteCollectionUseCase(repository: repository);
}

/// ReorderCollectionsUseCase の DI Provider
@riverpod
ReorderCollectionsUseCase reorderCollectionsUseCase(Ref ref) {
  final repository = ref.watch(collectionRepositoryProvider);
  return ReorderCollectionsUseCase(repository: repository);
}

/// ReorderCollectionImagesUseCase の DI Provider
@riverpod
ReorderCollectionImagesUseCase reorderCollectionImagesUseCase(Ref ref) {
  final repository = ref.watch(collectionRepositoryProvider);
  return ReorderCollectionImagesUseCase(repository: repository);
}

// ---------------------------------------------------------------------------
// Stream Provider
// ---------------------------------------------------------------------------

/// コレクション一覧を sortOrder 昇順でリアルタイム監視する Stream Provider
///
/// DB のコレクションデータが変更されると自動的に最新の一覧を emit する。
/// 各コレクションには imageCount（登録画像数）が含まれる。
@riverpod
Stream<List<Collection>> collectionList(Ref ref) {
  final useCase = ref.watch(getCollectionsUseCaseProvider);
  return useCase.execute();
}
