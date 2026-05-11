/// ギャラリー機能の Riverpod Provider 定義 (設計書 §14)
library;

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/providers/repository_providers.dart';
import '../../application/usecases/gallery/load_folder_images_usecase.dart';
import '../../application/usecases/gallery/load_thumbnail_usecase.dart';
import '../../application/usecases/gallery/sort_images_usecase.dart';
import '../../domain/entities/folder_entry.dart';
import '../../domain/entities/image_entry.dart';
import '../../domain/value_objects/sort_option.dart';

part 'gallery_providers.g.dart';

// ---------------------------------------------------------------------------
// UseCase Providers
// ---------------------------------------------------------------------------

@riverpod
LoadFolderImagesUseCase loadFolderImagesUseCase(LoadFolderImagesUseCaseRef ref) {
  return LoadFolderImagesUseCase(
    imageRepository: ref.watch(imageRepositoryProvider),
  );
}

@riverpod
LoadThumbnailUseCase loadThumbnailUseCase(LoadThumbnailUseCaseRef ref) {
  return LoadThumbnailUseCase(
    thumbnailRepository: ref.watch(thumbnailRepositoryProvider),
  );
}

@riverpod
SortImagesUseCase sortImagesUseCase(SortImagesUseCaseRef ref) {
  return SortImagesUseCase(database: ref.watch(appDatabaseProvider));
}

// ---------------------------------------------------------------------------
// State Providers
// ---------------------------------------------------------------------------

/// 現在選択されているフォルダ
@Riverpod(keepAlive: true)
class CurrentFolder extends _$CurrentFolder {
  @override
  FolderEntry? build() => null;

  void setFolder(FolderEntry folder) {
    state = folder;
  }
}

/// ギャラリーのソート設定
@Riverpod(keepAlive: true)
class GallerySortOption extends _$GallerySortOption {
  @override
  SortOption build() {
    _loadInitial();
    return SortOption.defaultOption;
  }

  Future<void> _loadInitial() async {
    final useCase = ref.read(sortImagesUseCaseProvider);
    state = await useCase.loadSortOption();
  }

  Future<void> updateOption(SortOption newOption) async {
    state = newOption;
    final useCase = ref.read(sortImagesUseCaseProvider);
    await useCase.saveSortOption(newOption);
  }
}

/// 指定フォルダの画像リスト (Stream ベースのインクリメンタル読み込み)
@riverpod
Stream<List<ImageEntry>> galleryImages(GalleryImagesRef ref) {
  final folder = ref.watch(currentFolderProvider);
  if (folder == null) return const Stream.empty();

  final sortOption = ref.watch(gallerySortOptionProvider);
  final useCase = ref.watch(loadFolderImagesUseCaseProvider);

  // キャンセル時のクリーンアップは Riverpod が自動で管理する
  return useCase.execute(folder: folder, sort: sortOption);
}

/// フォルダ内の画像総数
@riverpod
Future<int> galleryImageCount(GalleryImageCountRef ref) async {
  final folder = ref.watch(currentFolderProvider);
  if (folder == null) return 0;

  final useCase = ref.watch(loadFolderImagesUseCaseProvider);
  return useCase.count(folder: folder);
}
