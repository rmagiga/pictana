// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// AppDatabase シングルトン

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

/// AppDatabase シングルトン

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  /// AppDatabase シングルトン
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'59cce38d45eeaba199eddd097d8e149d66f9f3e1';

/// StorageRepository Provider

@ProviderFor(storageRepository)
final storageRepositoryProvider = StorageRepositoryProvider._();

/// StorageRepository Provider

final class StorageRepositoryProvider
    extends
        $FunctionalProvider<
          StorageRepository,
          StorageRepository,
          StorageRepository
        >
    with $Provider<StorageRepository> {
  /// StorageRepository Provider
  StorageRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storageRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storageRepositoryHash();

  @$internal
  @override
  $ProviderElement<StorageRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StorageRepository create(Ref ref) {
    return storageRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StorageRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StorageRepository>(value),
    );
  }
}

String _$storageRepositoryHash() => r'ad034ce392ca7a787b1212ca03545eaa870e45ab';

/// ImageRepository Provider

@ProviderFor(imageRepository)
final imageRepositoryProvider = ImageRepositoryProvider._();

/// ImageRepository Provider

final class ImageRepositoryProvider
    extends
        $FunctionalProvider<ImageRepository, ImageRepository, ImageRepository>
    with $Provider<ImageRepository> {
  /// ImageRepository Provider
  ImageRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'imageRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$imageRepositoryHash();

  @$internal
  @override
  $ProviderElement<ImageRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ImageRepository create(Ref ref) {
    return imageRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImageRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ImageRepository>(value),
    );
  }
}

String _$imageRepositoryHash() => r'd1ba35447aaa4b4e0601a16edc9ab0c3fb8f5aa4';

/// ThumbnailRepository Provider

@ProviderFor(thumbnailRepository)
final thumbnailRepositoryProvider = ThumbnailRepositoryProvider._();

/// ThumbnailRepository Provider

final class ThumbnailRepositoryProvider
    extends
        $FunctionalProvider<
          ThumbnailRepository,
          ThumbnailRepository,
          ThumbnailRepository
        >
    with $Provider<ThumbnailRepository> {
  /// ThumbnailRepository Provider
  ThumbnailRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'thumbnailRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$thumbnailRepositoryHash();

  @$internal
  @override
  $ProviderElement<ThumbnailRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ThumbnailRepository create(Ref ref) {
    return thumbnailRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThumbnailRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThumbnailRepository>(value),
    );
  }
}

String _$thumbnailRepositoryHash() =>
    r'05aa09988f01cae1ac1dd069c988974e1107d7dd';

/// FavoriteRepository Provider
///
/// お気に入りフォルダの永続化を担当するリポジトリの DI 定義。
/// [AppDatabase] を注入して [FavoriteRepositoryImpl] を生成する。

@ProviderFor(favoriteRepository)
final favoriteRepositoryProvider = FavoriteRepositoryProvider._();

/// FavoriteRepository Provider
///
/// お気に入りフォルダの永続化を担当するリポジトリの DI 定義。
/// [AppDatabase] を注入して [FavoriteRepositoryImpl] を生成する。

final class FavoriteRepositoryProvider
    extends
        $FunctionalProvider<
          FavoriteRepository,
          FavoriteRepository,
          FavoriteRepository
        >
    with $Provider<FavoriteRepository> {
  /// FavoriteRepository Provider
  ///
  /// お気に入りフォルダの永続化を担当するリポジトリの DI 定義。
  /// [AppDatabase] を注入して [FavoriteRepositoryImpl] を生成する。
  FavoriteRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteRepositoryHash();

  @$internal
  @override
  $ProviderElement<FavoriteRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FavoriteRepository create(Ref ref) {
    return favoriteRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FavoriteRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FavoriteRepository>(value),
    );
  }
}

String _$favoriteRepositoryHash() =>
    r'df0fb9e397ab443c96abef72358ac1b0c3c092a7';

/// ExifProcessor Provider
///
/// EXIF Orientation タグの解析と回転角度変換を担当するプロセッサの DI 定義。

@ProviderFor(exifProcessor)
final exifProcessorProvider = ExifProcessorProvider._();

/// ExifProcessor Provider
///
/// EXIF Orientation タグの解析と回転角度変換を担当するプロセッサの DI 定義。

final class ExifProcessorProvider
    extends $FunctionalProvider<ExifProcessor, ExifProcessor, ExifProcessor>
    with $Provider<ExifProcessor> {
  /// ExifProcessor Provider
  ///
  /// EXIF Orientation タグの解析と回転角度変換を担当するプロセッサの DI 定義。
  ExifProcessorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exifProcessorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exifProcessorHash();

  @$internal
  @override
  $ProviderElement<ExifProcessor> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ExifProcessor create(Ref ref) {
    return exifProcessor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExifProcessor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExifProcessor>(value),
    );
  }
}

String _$exifProcessorHash() => r'b172776d16e69666f3f3c3bca9563a6bc730fd0b';
