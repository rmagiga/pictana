// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_navigation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$navigateToFavoriteUseCaseHash() =>
    r'7e0942c936f4a625c3fe5a89c59d38d9a5b0cb01';

/// NavigateToFavoriteUseCase の Provider
///
/// FavoriteRepository と StorageRepository を注入して
/// ユースケースインスタンスを生成する。
///
/// Copied from [navigateToFavoriteUseCase].
@ProviderFor(navigateToFavoriteUseCase)
final navigateToFavoriteUseCaseProvider =
    AutoDisposeProvider<NavigateToFavoriteUseCase>.internal(
      navigateToFavoriteUseCase,
      name: r'navigateToFavoriteUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$navigateToFavoriteUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NavigateToFavoriteUseCaseRef =
    AutoDisposeProviderRef<NavigateToFavoriteUseCase>;
String _$favoriteNavigationStateHash() =>
    r'578c4f9e774016fb0d66da7fc52f2af8dcb4f014';

/// お気に入りフォルダナビゲーション中の状態
///
/// true の場合、ナビゲーション処理中であることを示す。
/// ローディングインジケーター表示・追加タップ無効化に使用する。
///
/// Copied from [FavoriteNavigationState].
@ProviderFor(FavoriteNavigationState)
final favoriteNavigationStateProvider =
    NotifierProvider<FavoriteNavigationState, bool>.internal(
      FavoriteNavigationState.new,
      name: r'favoriteNavigationStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$favoriteNavigationStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FavoriteNavigationState = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
