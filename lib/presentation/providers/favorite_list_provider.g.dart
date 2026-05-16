// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// お気に入りフォルダ一覧を管理する Provider
///
/// アプリ起動時にお気に入り一覧を読み込み、
/// お気に入りの追加・削除後に refresh() で再取得する。

@ProviderFor(FavoriteList)
final favoriteListProvider = FavoriteListProvider._();

/// お気に入りフォルダ一覧を管理する Provider
///
/// アプリ起動時にお気に入り一覧を読み込み、
/// お気に入りの追加・削除後に refresh() で再取得する。
final class FavoriteListProvider
    extends $AsyncNotifierProvider<FavoriteList, List<FavoriteFolder>> {
  /// お気に入りフォルダ一覧を管理する Provider
  ///
  /// アプリ起動時にお気に入り一覧を読み込み、
  /// お気に入りの追加・削除後に refresh() で再取得する。
  FavoriteListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteListHash();

  @$internal
  @override
  FavoriteList create() => FavoriteList();
}

String _$favoriteListHash() => r'ffbd5a857cc21329954d52bfd7b71e44a6601fef';

/// お気に入りフォルダ一覧を管理する Provider
///
/// アプリ起動時にお気に入り一覧を読み込み、
/// お気に入りの追加・削除後に refresh() で再取得する。

abstract class _$FavoriteList extends $AsyncNotifier<List<FavoriteFolder>> {
  FutureOr<List<FavoriteFolder>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<FavoriteFolder>>, List<FavoriteFolder>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<FavoriteFolder>>,
                List<FavoriteFolder>
              >,
              AsyncValue<List<FavoriteFolder>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
