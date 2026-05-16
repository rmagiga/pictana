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

String _$appDatabaseHash() => r'96b544ff7ce456f0fc1edbdafdf332306a9affed';

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

String _$storageRepositoryHash() => r'6fa427749aa908312017468c97b93393b1d65fe4';

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

String _$imageRepositoryHash() => r'da6293f2584e0b4f6947a37e3d17d3e1b89351bb';

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
    r'cedab62dc343c7d6962b240447c1ae1fa5bd9a31';

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
    r'2d40dd54d51bace99f8598036f9eeb01b2dc208b';

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

String _$exifProcessorHash() => r'4f5145aefe522a3970516ea586a3b2095082feae';
