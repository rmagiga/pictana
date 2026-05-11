// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$loadFolderImagesUseCaseHash() =>
    r'e87b05193e4a98553bf1244ffbbdb5bb5738d2c5';

/// See also [loadFolderImagesUseCase].
@ProviderFor(loadFolderImagesUseCase)
final loadFolderImagesUseCaseProvider =
    AutoDisposeProvider<LoadFolderImagesUseCase>.internal(
      loadFolderImagesUseCase,
      name: r'loadFolderImagesUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$loadFolderImagesUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LoadFolderImagesUseCaseRef =
    AutoDisposeProviderRef<LoadFolderImagesUseCase>;
String _$loadThumbnailUseCaseHash() =>
    r'974fe0c5a8444d2dc309cdf81d15d3a75c9f6bdb';

/// See also [loadThumbnailUseCase].
@ProviderFor(loadThumbnailUseCase)
final loadThumbnailUseCaseProvider =
    AutoDisposeProvider<LoadThumbnailUseCase>.internal(
      loadThumbnailUseCase,
      name: r'loadThumbnailUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$loadThumbnailUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LoadThumbnailUseCaseRef = AutoDisposeProviderRef<LoadThumbnailUseCase>;
String _$sortImagesUseCaseHash() => r'81cf94301bfe9bda592b7a7f0f910806396de095';

/// See also [sortImagesUseCase].
@ProviderFor(sortImagesUseCase)
final sortImagesUseCaseProvider =
    AutoDisposeProvider<SortImagesUseCase>.internal(
      sortImagesUseCase,
      name: r'sortImagesUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sortImagesUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SortImagesUseCaseRef = AutoDisposeProviderRef<SortImagesUseCase>;
String _$galleryImagesHash() => r'9621308c130a7a21a7cb97ecc974fff973abb36a';

/// 指定フォルダの画像リスト (Stream ベースのインクリメンタル読み込み)
///
/// Copied from [galleryImages].
@ProviderFor(galleryImages)
final galleryImagesProvider =
    AutoDisposeStreamProvider<List<ImageEntry>>.internal(
      galleryImages,
      name: r'galleryImagesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$galleryImagesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GalleryImagesRef = AutoDisposeStreamProviderRef<List<ImageEntry>>;
String _$galleryImageCountHash() => r'2f15fa7a0f7b254ce1dacb07e87f9763d10d74bd';

/// フォルダ内の画像総数
///
/// Copied from [galleryImageCount].
@ProviderFor(galleryImageCount)
final galleryImageCountProvider = AutoDisposeFutureProvider<int>.internal(
  galleryImageCount,
  name: r'galleryImageCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$galleryImageCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GalleryImageCountRef = AutoDisposeFutureProviderRef<int>;
String _$currentFolderHash() => r'27c4075bb80b7056df73f680cf076192af218d8e';

/// 現在選択されているフォルダ
///
/// Copied from [CurrentFolder].
@ProviderFor(CurrentFolder)
final currentFolderProvider =
    NotifierProvider<CurrentFolder, FolderEntry?>.internal(
      CurrentFolder.new,
      name: r'currentFolderProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentFolderHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CurrentFolder = Notifier<FolderEntry?>;
String _$gallerySortOptionHash() => r'936083cd81d466c8e79ba9a4cc7d6951407847b2';

/// ギャラリーのソート設定
///
/// Copied from [GallerySortOption].
@ProviderFor(GallerySortOption)
final gallerySortOptionProvider =
    NotifierProvider<GallerySortOption, SortOption>.internal(
      GallerySortOption.new,
      name: r'gallerySortOptionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$gallerySortOptionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GallerySortOption = Notifier<SortOption>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
