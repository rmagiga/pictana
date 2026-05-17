// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(loadFolderImagesUseCase)
final loadFolderImagesUseCaseProvider = LoadFolderImagesUseCaseProvider._();

final class LoadFolderImagesUseCaseProvider
    extends
        $FunctionalProvider<
          LoadFolderImagesUseCase,
          LoadFolderImagesUseCase,
          LoadFolderImagesUseCase
        >
    with $Provider<LoadFolderImagesUseCase> {
  LoadFolderImagesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadFolderImagesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadFolderImagesUseCaseHash();

  @$internal
  @override
  $ProviderElement<LoadFolderImagesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LoadFolderImagesUseCase create(Ref ref) {
    return loadFolderImagesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadFolderImagesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadFolderImagesUseCase>(value),
    );
  }
}

String _$loadFolderImagesUseCaseHash() =>
    r'64c99e587446443a04bd1084d980dd36c63af5b3';

@ProviderFor(loadThumbnailUseCase)
final loadThumbnailUseCaseProvider = LoadThumbnailUseCaseProvider._();

final class LoadThumbnailUseCaseProvider
    extends
        $FunctionalProvider<
          LoadThumbnailUseCase,
          LoadThumbnailUseCase,
          LoadThumbnailUseCase
        >
    with $Provider<LoadThumbnailUseCase> {
  LoadThumbnailUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadThumbnailUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadThumbnailUseCaseHash();

  @$internal
  @override
  $ProviderElement<LoadThumbnailUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LoadThumbnailUseCase create(Ref ref) {
    return loadThumbnailUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadThumbnailUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadThumbnailUseCase>(value),
    );
  }
}

String _$loadThumbnailUseCaseHash() =>
    r'1f1f4d12d4f2e90cb0488b7eac5bc56724a37a29';

@ProviderFor(sortImagesUseCase)
final sortImagesUseCaseProvider = SortImagesUseCaseProvider._();

final class SortImagesUseCaseProvider
    extends
        $FunctionalProvider<
          SortImagesUseCase,
          SortImagesUseCase,
          SortImagesUseCase
        >
    with $Provider<SortImagesUseCase> {
  SortImagesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sortImagesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sortImagesUseCaseHash();

  @$internal
  @override
  $ProviderElement<SortImagesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SortImagesUseCase create(Ref ref) {
    return sortImagesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SortImagesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SortImagesUseCase>(value),
    );
  }
}

String _$sortImagesUseCaseHash() => r'1a0a55342c784fb78ec4e9e35480f07b6a4af5a6';

/// 現在選択されているフォルダ

@ProviderFor(CurrentFolder)
final currentFolderProvider = CurrentFolderProvider._();

/// 現在選択されているフォルダ
final class CurrentFolderProvider
    extends $NotifierProvider<CurrentFolder, FolderEntry?> {
  /// 現在選択されているフォルダ
  CurrentFolderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentFolderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentFolderHash();

  @$internal
  @override
  CurrentFolder create() => CurrentFolder();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FolderEntry? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FolderEntry?>(value),
    );
  }
}

String _$currentFolderHash() => r'27c4075bb80b7056df73f680cf076192af218d8e';

/// 現在選択されているフォルダ

abstract class _$CurrentFolder extends $Notifier<FolderEntry?> {
  FolderEntry? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FolderEntry?, FolderEntry?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FolderEntry?, FolderEntry?>,
              FolderEntry?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// ギャラリーのソート設定

@ProviderFor(GallerySortOption)
final gallerySortOptionProvider = GallerySortOptionProvider._();

/// ギャラリーのソート設定
final class GallerySortOptionProvider
    extends $NotifierProvider<GallerySortOption, SortOption> {
  /// ギャラリーのソート設定
  GallerySortOptionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gallerySortOptionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gallerySortOptionHash();

  @$internal
  @override
  GallerySortOption create() => GallerySortOption();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SortOption value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SortOption>(value),
    );
  }
}

String _$gallerySortOptionHash() => r'e6374feada9b25b95aff251abda8631d08c540fe';

/// ギャラリーのソート設定

abstract class _$GallerySortOption extends $Notifier<SortOption> {
  SortOption build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SortOption, SortOption>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SortOption, SortOption>,
              SortOption,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// 指定フォルダの画像リスト (Stream ベースのインクリメンタル読み込み)

@ProviderFor(galleryImages)
final galleryImagesProvider = GalleryImagesProvider._();

/// 指定フォルダの画像リスト (Stream ベースのインクリメンタル読み込み)

final class GalleryImagesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ImageEntry>>,
          List<ImageEntry>,
          Stream<List<ImageEntry>>
        >
    with $FutureModifier<List<ImageEntry>>, $StreamProvider<List<ImageEntry>> {
  /// 指定フォルダの画像リスト (Stream ベースのインクリメンタル読み込み)
  GalleryImagesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'galleryImagesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$galleryImagesHash();

  @$internal
  @override
  $StreamProviderElement<List<ImageEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ImageEntry>> create(Ref ref) {
    return galleryImages(ref);
  }
}

String _$galleryImagesHash() => r'6971f452709aa77a0d579a5f08d8de301860633e';

/// フォルダ内の画像総数

@ProviderFor(galleryImageCount)
final galleryImageCountProvider = GalleryImageCountProvider._();

/// フォルダ内の画像総数

final class GalleryImageCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// フォルダ内の画像総数
  GalleryImageCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'galleryImageCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$galleryImageCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return galleryImageCount(ref);
  }
}

String _$galleryImageCountHash() => r'd5a2463f1a5b0127497780755ab34a1c34f3ea93';
