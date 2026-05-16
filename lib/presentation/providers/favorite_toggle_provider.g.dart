// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_toggle_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// お気に入りトグル操作を管理する Provider
///
/// 楽観的UI更新により、ユーザー操作に対して即座にフィードバックを返す。
/// - toggle() 呼び出し時に即座に optimisticIsFavorite を反転
/// - 処理中（isProcessing == true）は追加の toggle を無視
/// - バックエンド処理失敗時に optimisticIsFavorite をロールバック

@ProviderFor(FavoriteToggle)
final favoriteToggleProvider = FavoriteToggleProvider._();

/// お気に入りトグル操作を管理する Provider
///
/// 楽観的UI更新により、ユーザー操作に対して即座にフィードバックを返す。
/// - toggle() 呼び出し時に即座に optimisticIsFavorite を反転
/// - 処理中（isProcessing == true）は追加の toggle を無視
/// - バックエンド処理失敗時に optimisticIsFavorite をロールバック
final class FavoriteToggleProvider
    extends $NotifierProvider<FavoriteToggle, FavoriteToggleState> {
  /// お気に入りトグル操作を管理する Provider
  ///
  /// 楽観的UI更新により、ユーザー操作に対して即座にフィードバックを返す。
  /// - toggle() 呼び出し時に即座に optimisticIsFavorite を反転
  /// - 処理中（isProcessing == true）は追加の toggle を無視
  /// - バックエンド処理失敗時に optimisticIsFavorite をロールバック
  FavoriteToggleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteToggleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteToggleHash();

  @$internal
  @override
  FavoriteToggle create() => FavoriteToggle();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FavoriteToggleState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FavoriteToggleState>(value),
    );
  }
}

String _$favoriteToggleHash() => r'b0f44b758accfd8c8f3f80777385fd5ed57395c1';

/// お気に入りトグル操作を管理する Provider
///
/// 楽観的UI更新により、ユーザー操作に対して即座にフィードバックを返す。
/// - toggle() 呼び出し時に即座に optimisticIsFavorite を反転
/// - 処理中（isProcessing == true）は追加の toggle を無視
/// - バックエンド処理失敗時に optimisticIsFavorite をロールバック

abstract class _$FavoriteToggle extends $Notifier<FavoriteToggleState> {
  FavoriteToggleState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FavoriteToggleState, FavoriteToggleState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FavoriteToggleState, FavoriteToggleState>,
              FavoriteToggleState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
