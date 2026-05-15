// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appDatabaseHash() => r'96b544ff7ce456f0fc1edbdafdf332306a9affed';

/// AppDatabase シングルトン
///
/// Copied from [appDatabase].
@ProviderFor(appDatabase)
final appDatabaseProvider = Provider<AppDatabase>.internal(
  appDatabase,
  name: r'appDatabaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppDatabaseRef = ProviderRef<AppDatabase>;
String _$storageRepositoryHash() => r'6fa427749aa908312017468c97b93393b1d65fe4';

/// StorageRepository Provider
///
/// Copied from [storageRepository].
@ProviderFor(storageRepository)
final storageRepositoryProvider = Provider<StorageRepository>.internal(
  storageRepository,
  name: r'storageRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$storageRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StorageRepositoryRef = ProviderRef<StorageRepository>;
String _$imageRepositoryHash() => r'da6293f2584e0b4f6947a37e3d17d3e1b89351bb';

/// ImageRepository Provider
///
/// Copied from [imageRepository].
@ProviderFor(imageRepository)
final imageRepositoryProvider = Provider<ImageRepository>.internal(
  imageRepository,
  name: r'imageRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$imageRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ImageRepositoryRef = ProviderRef<ImageRepository>;
String _$thumbnailRepositoryHash() =>
    r'cedab62dc343c7d6962b240447c1ae1fa5bd9a31';

/// ThumbnailRepository Provider
///
/// Copied from [thumbnailRepository].
@ProviderFor(thumbnailRepository)
final thumbnailRepositoryProvider = Provider<ThumbnailRepository>.internal(
  thumbnailRepository,
  name: r'thumbnailRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$thumbnailRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ThumbnailRepositoryRef = ProviderRef<ThumbnailRepository>;
String _$favoriteRepositoryHash() =>
    r'2d40dd54d51bace99f8598036f9eeb01b2dc208b';

/// FavoriteRepository Provider
///
/// お気に入りフォルダの永続化を担当するリポジトリの DI 定義。
/// [AppDatabase] を注入して [FavoriteRepositoryImpl] を生成する。
///
/// Copied from [favoriteRepository].
@ProviderFor(favoriteRepository)
final favoriteRepositoryProvider = Provider<FavoriteRepository>.internal(
  favoriteRepository,
  name: r'favoriteRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$favoriteRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FavoriteRepositoryRef = ProviderRef<FavoriteRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
