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
LoadFolderImagesUseCase loadFolderImagesUseCase(
  LoadFolderImagesUseCaseRef ref,
) {
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
  /// ユーザーが updateOption() で明示的に変更したかどうかのフラグ。
  /// _loadInitial() の非同期完了時にユーザー設定を上書きしないためのガード。
  bool _userHasUpdated = false;

  @override
  SortOption build() {
    _userHasUpdated = false;
    _loadInitial();
    return SortOption.defaultOption;
  }

  Future<void> _loadInitial() async {
    final useCase = ref.read(sortImagesUseCaseProvider);
    final loaded = await useCase.loadSortOption();
    // ユーザーが既に updateOption() で変更していた場合は DB 値で上書きしない
    if (!_userHasUpdated) {
      state = loaded;
    }
  }

  Future<void> updateOption(SortOption newOption) async {
    _userHasUpdated = true;
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

  // リポジトリから取得した Stream の各 emit をソートして返す。
  // ソートオプション変更時は provider 全体が再構築されるため、
  // 新しい sortOption が確実に適用される。
  return useCase.execute(folder: folder, sort: sortOption).map((images) {
    final sorted = List<ImageEntry>.of(images);
    _sortImageEntries(sorted, sortOption);
    return sorted;
  });
}

/// Provider レベルでのソート適用（リポジトリ側のソートに加えて二重保証）
void _sortImageEntries(List<ImageEntry> entries, SortOption sort) {
  final asc = sort.isAscending;
  entries.sort(
    (a, b) => switch (sort.field) {
      SortField.name =>
        asc ? a.name.compareTo(b.name) : b.name.compareTo(a.name),
      SortField.date =>
        asc
            ? a.modifiedAt.compareTo(b.modifiedAt)
            : b.modifiedAt.compareTo(a.modifiedAt),
      SortField.size =>
        asc ? a.size.compareTo(b.size) : b.size.compareTo(a.size),
      SortField.type =>
        asc
            ? a.extension.compareTo(b.extension)
            : b.extension.compareTo(a.extension),
    },
  );
}

/// フォルダ内の画像総数
@riverpod
Future<int> galleryImageCount(GalleryImageCountRef ref) async {
  final folder = ref.watch(currentFolderProvider);
  if (folder == null) return 0;

  final useCase = ref.watch(loadFolderImagesUseCaseProvider);
  return useCase.count(folder: folder);
}
