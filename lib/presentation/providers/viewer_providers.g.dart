// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'viewer_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(loadImageUseCase)
final loadImageUseCaseProvider = LoadImageUseCaseProvider._();

final class LoadImageUseCaseProvider
    extends
        $FunctionalProvider<
          LoadImageUseCase,
          LoadImageUseCase,
          LoadImageUseCase
        >
    with $Provider<LoadImageUseCase> {
  LoadImageUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadImageUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadImageUseCaseHash();

  @$internal
  @override
  $ProviderElement<LoadImageUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoadImageUseCase create(Ref ref) {
    return loadImageUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoadImageUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoadImageUseCase>(value),
    );
  }
}

String _$loadImageUseCaseHash() => r'81449f72c0f2b9b5f78ad5bab3fdf65ab00e1580';

@ProviderFor(preloadAdjacentImagesUseCase)
final preloadAdjacentImagesUseCaseProvider =
    PreloadAdjacentImagesUseCaseProvider._();

final class PreloadAdjacentImagesUseCaseProvider
    extends
        $FunctionalProvider<
          PreloadAdjacentImagesUseCase,
          PreloadAdjacentImagesUseCase,
          PreloadAdjacentImagesUseCase
        >
    with $Provider<PreloadAdjacentImagesUseCase> {
  PreloadAdjacentImagesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preloadAdjacentImagesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preloadAdjacentImagesUseCaseHash();

  @$internal
  @override
  $ProviderElement<PreloadAdjacentImagesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PreloadAdjacentImagesUseCase create(Ref ref) {
    return preloadAdjacentImagesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PreloadAdjacentImagesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PreloadAdjacentImagesUseCase>(value),
    );
  }
}

String _$preloadAdjacentImagesUseCaseHash() =>
    r'c26c80909b8a4d030ba451d04654fdc7a4c36001';

@ProviderFor(recordRecentImageUseCase)
final recordRecentImageUseCaseProvider = RecordRecentImageUseCaseProvider._();

final class RecordRecentImageUseCaseProvider
    extends
        $FunctionalProvider<
          RecordRecentImageUseCase,
          RecordRecentImageUseCase,
          RecordRecentImageUseCase
        >
    with $Provider<RecordRecentImageUseCase> {
  RecordRecentImageUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recordRecentImageUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recordRecentImageUseCaseHash();

  @$internal
  @override
  $ProviderElement<RecordRecentImageUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecordRecentImageUseCase create(Ref ref) {
    return recordRecentImageUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecordRecentImageUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecordRecentImageUseCase>(value),
    );
  }
}

String _$recordRecentImageUseCaseHash() =>
    r'ffa65f44090f1ad8403bf657cc3f2b238932bac1';

@ProviderFor(getRecentImagesUseCase)
final getRecentImagesUseCaseProvider = GetRecentImagesUseCaseProvider._();

final class GetRecentImagesUseCaseProvider
    extends
        $FunctionalProvider<
          GetRecentImagesUseCase,
          GetRecentImagesUseCase,
          GetRecentImagesUseCase
        >
    with $Provider<GetRecentImagesUseCase> {
  GetRecentImagesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getRecentImagesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getRecentImagesUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetRecentImagesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetRecentImagesUseCase create(Ref ref) {
    return getRecentImagesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetRecentImagesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetRecentImagesUseCase>(value),
    );
  }
}

String _$getRecentImagesUseCaseHash() =>
    r'877da260b77a9fa605a120ee0d038e617bcf147c';

/// 指定された画像のメタデータを取得する Provider

@ProviderFor(imageMetadata)
final imageMetadataProvider = ImageMetadataFamily._();

/// 指定された画像のメタデータを取得する Provider

final class ImageMetadataProvider
    extends
        $FunctionalProvider<
          AsyncValue<ImageEntry>,
          ImageEntry,
          FutureOr<ImageEntry>
        >
    with $FutureModifier<ImageEntry>, $FutureProvider<ImageEntry> {
  /// 指定された画像のメタデータを取得する Provider
  ImageMetadataProvider._({
    required ImageMetadataFamily super.from,
    required ImageEntry super.argument,
  }) : super(
         retry: null,
         name: r'imageMetadataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$imageMetadataHash();

  @override
  String toString() {
    return r'imageMetadataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ImageEntry> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ImageEntry> create(Ref ref) {
    final argument = this.argument as ImageEntry;
    return imageMetadata(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ImageMetadataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$imageMetadataHash() => r'cb4a377dad1f4497bd97ecc4f3dd7484e313f1e1';

/// 指定された画像のメタデータを取得する Provider

final class ImageMetadataFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ImageEntry>, ImageEntry> {
  ImageMetadataFamily._()
    : super(
        retry: null,
        name: r'imageMetadataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 指定された画像のメタデータを取得する Provider

  ImageMetadataProvider call(ImageEntry entry) =>
      ImageMetadataProvider._(argument: entry, from: this);

  @override
  String toString() => r'imageMetadataProvider';
}

/// 指定された画像のバイト列を取得する Provider
/// 取得中はローディングになり、成功すると Uint8List を返す。
/// 同時に同じ画像が要求された場合はキャッシュを共有する。

@ProviderFor(imageBytes)
final imageBytesProvider = ImageBytesFamily._();

/// 指定された画像のバイト列を取得する Provider
/// 取得中はローディングになり、成功すると Uint8List を返す。
/// 同時に同じ画像が要求された場合はキャッシュを共有する。

final class ImageBytesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Uint8List>,
          Uint8List,
          FutureOr<Uint8List>
        >
    with $FutureModifier<Uint8List>, $FutureProvider<Uint8List> {
  /// 指定された画像のバイト列を取得する Provider
  /// 取得中はローディングになり、成功すると Uint8List を返す。
  /// 同時に同じ画像が要求された場合はキャッシュを共有する。
  ImageBytesProvider._({
    required ImageBytesFamily super.from,
    required ImageEntry super.argument,
  }) : super(
         retry: null,
         name: r'imageBytesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$imageBytesHash();

  @override
  String toString() {
    return r'imageBytesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Uint8List> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Uint8List> create(Ref ref) {
    final argument = this.argument as ImageEntry;
    return imageBytes(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ImageBytesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$imageBytesHash() => r'e52c8feaeca3b645baede4bdd17b1bff467269b9';

/// 指定された画像のバイト列を取得する Provider
/// 取得中はローディングになり、成功すると Uint8List を返す。
/// 同時に同じ画像が要求された場合はキャッシュを共有する。

final class ImageBytesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Uint8List>, ImageEntry> {
  ImageBytesFamily._()
    : super(
        retry: null,
        name: r'imageBytesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 指定された画像のバイト列を取得する Provider
  /// 取得中はローディングになり、成功すると Uint8List を返す。
  /// 同時に同じ画像が要求された場合はキャッシュを共有する。

  ImageBytesProvider call(ImageEntry entry) =>
      ImageBytesProvider._(argument: entry, from: this);

  @override
  String toString() => r'imageBytesProvider';
}

/// 指定された画像のバイト列から EXIF 回転角度を抽出する Provider。
///
/// 画像バイト列を取得し、ExifProcessorImpl で Orientation タグを解析して
/// 回転角度 (0, 90, 180, 270) を返す。
/// ImageEntry に既に exifRotation が設定されている場合はそれを優先する。

@ProviderFor(imageExifRotation)
final imageExifRotationProvider = ImageExifRotationFamily._();

/// 指定された画像のバイト列から EXIF 回転角度を抽出する Provider。
///
/// 画像バイト列を取得し、ExifProcessorImpl で Orientation タグを解析して
/// 回転角度 (0, 90, 180, 270) を返す。
/// ImageEntry に既に exifRotation が設定されている場合はそれを優先する。

final class ImageExifRotationProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// 指定された画像のバイト列から EXIF 回転角度を抽出する Provider。
  ///
  /// 画像バイト列を取得し、ExifProcessorImpl で Orientation タグを解析して
  /// 回転角度 (0, 90, 180, 270) を返す。
  /// ImageEntry に既に exifRotation が設定されている場合はそれを優先する。
  ImageExifRotationProvider._({
    required ImageExifRotationFamily super.from,
    required ImageEntry super.argument,
  }) : super(
         retry: null,
         name: r'imageExifRotationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$imageExifRotationHash();

  @override
  String toString() {
    return r'imageExifRotationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as ImageEntry;
    return imageExifRotation(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ImageExifRotationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$imageExifRotationHash() => r'eabdef51a6e4ab0eeb021bcc8b2c3645344a9af6';

/// 指定された画像のバイト列から EXIF 回転角度を抽出する Provider。
///
/// 画像バイト列を取得し、ExifProcessorImpl で Orientation タグを解析して
/// 回転角度 (0, 90, 180, 270) を返す。
/// ImageEntry に既に exifRotation が設定されている場合はそれを優先する。

final class ImageExifRotationFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, ImageEntry> {
  ImageExifRotationFamily._()
    : super(
        retry: null,
        name: r'imageExifRotationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 指定された画像のバイト列から EXIF 回転角度を抽出する Provider。
  ///
  /// 画像バイト列を取得し、ExifProcessorImpl で Orientation タグを解析して
  /// 回転角度 (0, 90, 180, 270) を返す。
  /// ImageEntry に既に exifRotation が設定されている場合はそれを優先する。

  ImageExifRotationProvider call(ImageEntry entry) =>
      ImageExifRotationProvider._(argument: entry, from: this);

  @override
  String toString() => r'imageExifRotationProvider';
}

/// 最近見た画像リストの状態管理プロバイダ

@ProviderFor(RecentImagesList)
final recentImagesListProvider = RecentImagesListProvider._();

/// 最近見た画像リストの状態管理プロバイダ
final class RecentImagesListProvider
    extends $AsyncNotifierProvider<RecentImagesList, List<ImageEntry>> {
  /// 最近見た画像リストの状態管理プロバイダ
  RecentImagesListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentImagesListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentImagesListHash();

  @$internal
  @override
  RecentImagesList create() => RecentImagesList();
}

String _$recentImagesListHash() => r'97b494d3e33d297e3d1665cd654718ca77167e91';

/// 最近見た画像リストの状態管理プロバイダ

abstract class _$RecentImagesList extends $AsyncNotifier<List<ImageEntry>> {
  FutureOr<List<ImageEntry>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<ImageEntry>>, List<ImageEntry>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ImageEntry>>, List<ImageEntry>>,
              AsyncValue<List<ImageEntry>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
