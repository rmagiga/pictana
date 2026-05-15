// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$favoriteListHash() => r'ffbd5a857cc21329954d52bfd7b71e44a6601fef';

/// お気に入りフォルダ一覧を管理する Provider
///
/// アプリ起動時にお気に入り一覧を読み込み、
/// お気に入りの追加・削除後に refresh() で再取得する。
///
/// Copied from [FavoriteList].
@ProviderFor(FavoriteList)
final favoriteListProvider =
    AsyncNotifierProvider<FavoriteList, List<FavoriteFolder>>.internal(
      FavoriteList.new,
      name: r'favoriteListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$favoriteListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FavoriteList = AsyncNotifier<List<FavoriteFolder>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
