// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_helper_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 指定フォルダ URI がお気に入り登録済みか判定する Provider
///
/// [uri] に対してリポジトリの isFavorite を呼び出し、
/// 登録済みであれば true を返す。

@ProviderFor(isFolderFavorite)
final isFolderFavoriteProvider = IsFolderFavoriteFamily._();

/// 指定フォルダ URI がお気に入り登録済みか判定する Provider
///
/// [uri] に対してリポジトリの isFavorite を呼び出し、
/// 登録済みであれば true を返す。

final class IsFolderFavoriteProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// 指定フォルダ URI がお気に入り登録済みか判定する Provider
  ///
  /// [uri] に対してリポジトリの isFavorite を呼び出し、
  /// 登録済みであれば true を返す。
  IsFolderFavoriteProvider._({
    required IsFolderFavoriteFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isFolderFavoriteProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isFolderFavoriteHash();

  @override
  String toString() {
    return r'isFolderFavoriteProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return isFolderFavorite(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IsFolderFavoriteProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isFolderFavoriteHash() => r'e6d9478f0637112f39460fe8562cd8452b652011';

/// 指定フォルダ URI がお気に入り登録済みか判定する Provider
///
/// [uri] に対してリポジトリの isFavorite を呼び出し、
/// 登録済みであれば true を返す。

final class IsFolderFavoriteFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  IsFolderFavoriteFamily._()
    : super(
        retry: null,
        name: r'isFolderFavoriteProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 指定フォルダ URI がお気に入り登録済みか判定する Provider
  ///
  /// [uri] に対してリポジトリの isFavorite を呼び出し、
  /// 登録済みであれば true を返す。

  IsFolderFavoriteProvider call(String uri) =>
      IsFolderFavoriteProvider._(argument: uri, from: this);

  @override
  String toString() => r'isFolderFavoriteProvider';
}

/// 現在のお気に入り登録件数を返す Provider
///
/// お気に入りリストの件数表示（例: 「3 / 50」）に使用する。

@ProviderFor(favoriteCount)
final favoriteCountProvider = FavoriteCountProvider._();

/// 現在のお気に入り登録件数を返す Provider
///
/// お気に入りリストの件数表示（例: 「3 / 50」）に使用する。

final class FavoriteCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// 現在のお気に入り登録件数を返す Provider
  ///
  /// お気に入りリストの件数表示（例: 「3 / 50」）に使用する。
  FavoriteCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoriteCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoriteCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return favoriteCount(ref);
  }
}

String _$favoriteCountHash() => r'355a1114bd90c1a014c92da8d7ffa4b525a2de52';
