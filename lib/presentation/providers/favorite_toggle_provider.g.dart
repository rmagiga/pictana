// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_toggle_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$favoriteToggleHash() => r'dae9c2bacacc36db959a58fa6cb391a85b60f8a9';

/// お気に入りトグル操作を管理する Provider
///
/// 楽観的UI更新により、ユーザー操作に対して即座にフィードバックを返す。
/// - toggle() 呼び出し時に即座に optimisticIsFavorite を反転
/// - 処理中（isProcessing == true）は追加の toggle を無視
/// - バックエンド処理失敗時に optimisticIsFavorite をロールバック
///
/// Copied from [FavoriteToggle].
@ProviderFor(FavoriteToggle)
final favoriteToggleProvider =
    NotifierProvider<FavoriteToggle, FavoriteToggleState>.internal(
      FavoriteToggle.new,
      name: r'favoriteToggleProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$favoriteToggleHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FavoriteToggle = Notifier<FavoriteToggleState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
