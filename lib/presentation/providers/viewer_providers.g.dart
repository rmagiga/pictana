// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'viewer_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$loadImageUseCaseHash() => r'3b2b18f666ec36c1b5d3a23d560a3a78371dd357';

/// See also [loadImageUseCase].
@ProviderFor(loadImageUseCase)
final loadImageUseCaseProvider = AutoDisposeProvider<LoadImageUseCase>.internal(
  loadImageUseCase,
  name: r'loadImageUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$loadImageUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LoadImageUseCaseRef = AutoDisposeProviderRef<LoadImageUseCase>;
String _$preloadAdjacentImagesUseCaseHash() =>
    r'4ef82b131459f845935d03575d482a1944032f16';

/// See also [preloadAdjacentImagesUseCase].
@ProviderFor(preloadAdjacentImagesUseCase)
final preloadAdjacentImagesUseCaseProvider =
    AutoDisposeProvider<PreloadAdjacentImagesUseCase>.internal(
      preloadAdjacentImagesUseCase,
      name: r'preloadAdjacentImagesUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$preloadAdjacentImagesUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PreloadAdjacentImagesUseCaseRef =
    AutoDisposeProviderRef<PreloadAdjacentImagesUseCase>;
String _$imageMetadataHash() => r'69a60779a7ff6e11237e8a0f8175f59a8a0f6376';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// 指定された画像のメタデータを取得する Provider
///
/// Copied from [imageMetadata].
@ProviderFor(imageMetadata)
const imageMetadataProvider = ImageMetadataFamily();

/// 指定された画像のメタデータを取得する Provider
///
/// Copied from [imageMetadata].
class ImageMetadataFamily extends Family<AsyncValue<ImageEntry>> {
  /// 指定された画像のメタデータを取得する Provider
  ///
  /// Copied from [imageMetadata].
  const ImageMetadataFamily();

  /// 指定された画像のメタデータを取得する Provider
  ///
  /// Copied from [imageMetadata].
  ImageMetadataProvider call(ImageEntry entry) {
    return ImageMetadataProvider(entry);
  }

  @override
  ImageMetadataProvider getProviderOverride(
    covariant ImageMetadataProvider provider,
  ) {
    return call(provider.entry);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'imageMetadataProvider';
}

/// 指定された画像のメタデータを取得する Provider
///
/// Copied from [imageMetadata].
class ImageMetadataProvider extends AutoDisposeFutureProvider<ImageEntry> {
  /// 指定された画像のメタデータを取得する Provider
  ///
  /// Copied from [imageMetadata].
  ImageMetadataProvider(ImageEntry entry)
    : this._internal(
        (ref) => imageMetadata(ref as ImageMetadataRef, entry),
        from: imageMetadataProvider,
        name: r'imageMetadataProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$imageMetadataHash,
        dependencies: ImageMetadataFamily._dependencies,
        allTransitiveDependencies:
            ImageMetadataFamily._allTransitiveDependencies,
        entry: entry,
      );

  ImageMetadataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.entry,
  }) : super.internal();

  final ImageEntry entry;

  @override
  Override overrideWith(
    FutureOr<ImageEntry> Function(ImageMetadataRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ImageMetadataProvider._internal(
        (ref) => create(ref as ImageMetadataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        entry: entry,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ImageEntry> createElement() {
    return _ImageMetadataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ImageMetadataProvider && other.entry == entry;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, entry.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ImageMetadataRef on AutoDisposeFutureProviderRef<ImageEntry> {
  /// The parameter `entry` of this provider.
  ImageEntry get entry;
}

class _ImageMetadataProviderElement
    extends AutoDisposeFutureProviderElement<ImageEntry>
    with ImageMetadataRef {
  _ImageMetadataProviderElement(super.provider);

  @override
  ImageEntry get entry => (origin as ImageMetadataProvider).entry;
}

String _$imageBytesHash() => r'0836062e0ad2976cee7f81699feca01fead66002';

/// 指定された画像のバイト列を取得する Provider
/// 取得中はローディングになり、成功すると Uint8List を返す。
/// 同時に同じ画像が要求された場合はキャッシュを共有する。
///
/// Copied from [imageBytes].
@ProviderFor(imageBytes)
const imageBytesProvider = ImageBytesFamily();

/// 指定された画像のバイト列を取得する Provider
/// 取得中はローディングになり、成功すると Uint8List を返す。
/// 同時に同じ画像が要求された場合はキャッシュを共有する。
///
/// Copied from [imageBytes].
class ImageBytesFamily extends Family<AsyncValue<Uint8List>> {
  /// 指定された画像のバイト列を取得する Provider
  /// 取得中はローディングになり、成功すると Uint8List を返す。
  /// 同時に同じ画像が要求された場合はキャッシュを共有する。
  ///
  /// Copied from [imageBytes].
  const ImageBytesFamily();

  /// 指定された画像のバイト列を取得する Provider
  /// 取得中はローディングになり、成功すると Uint8List を返す。
  /// 同時に同じ画像が要求された場合はキャッシュを共有する。
  ///
  /// Copied from [imageBytes].
  ImageBytesProvider call(ImageEntry entry) {
    return ImageBytesProvider(entry);
  }

  @override
  ImageBytesProvider getProviderOverride(
    covariant ImageBytesProvider provider,
  ) {
    return call(provider.entry);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'imageBytesProvider';
}

/// 指定された画像のバイト列を取得する Provider
/// 取得中はローディングになり、成功すると Uint8List を返す。
/// 同時に同じ画像が要求された場合はキャッシュを共有する。
///
/// Copied from [imageBytes].
class ImageBytesProvider extends AutoDisposeFutureProvider<Uint8List> {
  /// 指定された画像のバイト列を取得する Provider
  /// 取得中はローディングになり、成功すると Uint8List を返す。
  /// 同時に同じ画像が要求された場合はキャッシュを共有する。
  ///
  /// Copied from [imageBytes].
  ImageBytesProvider(ImageEntry entry)
    : this._internal(
        (ref) => imageBytes(ref as ImageBytesRef, entry),
        from: imageBytesProvider,
        name: r'imageBytesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$imageBytesHash,
        dependencies: ImageBytesFamily._dependencies,
        allTransitiveDependencies: ImageBytesFamily._allTransitiveDependencies,
        entry: entry,
      );

  ImageBytesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.entry,
  }) : super.internal();

  final ImageEntry entry;

  @override
  Override overrideWith(
    FutureOr<Uint8List> Function(ImageBytesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ImageBytesProvider._internal(
        (ref) => create(ref as ImageBytesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        entry: entry,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Uint8List> createElement() {
    return _ImageBytesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ImageBytesProvider && other.entry == entry;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, entry.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ImageBytesRef on AutoDisposeFutureProviderRef<Uint8List> {
  /// The parameter `entry` of this provider.
  ImageEntry get entry;
}

class _ImageBytesProviderElement
    extends AutoDisposeFutureProviderElement<Uint8List>
    with ImageBytesRef {
  _ImageBytesProviderElement(super.provider);

  @override
  ImageEntry get entry => (origin as ImageBytesProvider).entry;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
