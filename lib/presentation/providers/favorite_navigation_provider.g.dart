// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_navigation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// NavigateToFavoriteUseCase の Provider
///
/// FavoriteRepository と StorageRepository を注入して
/// ユースケースインスタンスを生成する。

@ProviderFor(navigateToFavoriteUseCase)
final navigateToFavoriteUseCaseProvider = NavigateToFavoriteUseCaseProvider._();

/// NavigateToFavoriteUseCase の Provider
///
/// FavoriteRepository と StorageRepository を注入して
/// ユースケースインスタンスを生成する。

final class NavigateToFavoriteUseCaseProvider
    extends
        $FunctionalProvider<
          NavigateToFavoriteUseCase,
          NavigateToFavoriteUseCase,
          NavigateToFavoriteUseCase
        >
    with $Provider<NavigateToFavoriteUseCase> {
  /// NavigateToFavoriteUseCase の Provider
  ///
  /// FavoriteRepository と StorageRepository を注入して
  /// ユースケースインスタンスを生成する。
  NavigateToFavoriteUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'navigateToFavoriteUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$navigateToFavoriteUseCaseHash();

  @$internal
  @override
  $ProviderElement<NavigateToFavoriteUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NavigateToFavoriteUseCase create(Ref ref) {
    return navigateToFavoriteUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NavigateToFavoriteUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NavigateToFavoriteUseCase>(value),
    );
  }
}

String _$navigateToFavoriteUseCaseHash() =>
    r'1f5bab823cb6669483f754993403ba9f0979ce07';

/// お気に入りフォルダナビゲーション中の状態
///
/// true の場合、ナビゲーション処理中であることを示す。
/// ローディングインジケーター表示・追加タップ無効化に使用する。

@ProviderFor(FavoriteNavigationState)
final favoriteNavigationStateProvider = FavoriteNavigationStateProvider._();

/// お気に入りフォルダナビゲーション中の状態
///
/// true の場合、ナビゲーション処理中であることを示す。
/// ローディングインジケーター表示・追加タップ無効化に使用する。
final class FavoriteNavigationStateProvider
    extends $NotifierProvider<FavoriteNavigationState, bool> {
  /// お気に入りフォルダナビゲーション中の状態
  ///
  /// true の場合、ナビゲーション処理中であることを示す。
  /// ローディングインジケーター表示・追加タップ無効化に使用する。
  FavoriteNavigationStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteNavigationStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteNavigationStateHash();

  @$internal
  @override
  FavoriteNavigationState create() => FavoriteNavigationState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$favoriteNavigationStateHash() =>
    r'578c4f9e774016fb0d66da7fc52f2af8dcb4f014';

/// お気に入りフォルダナビゲーション中の状態
///
/// true の場合、ナビゲーション処理中であることを示す。
/// ローディングインジケーター表示・追加タップ無効化に使用する。

abstract class _$FavoriteNavigationState extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
