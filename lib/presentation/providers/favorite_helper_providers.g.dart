// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_helper_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isFolderFavoriteHash() => r'e6d9478f0637112f39460fe8562cd8452b652011';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// 指定フォルダ URI がお気に入り登録済みか判定する Provider
///
/// [uri] に対してリポジトリの isFavorite を呼び出し、
/// 登録済みであれば true を返す。
///
/// Copied from [isFolderFavorite].
@ProviderFor(isFolderFavorite)
const isFolderFavoriteProvider = IsFolderFavoriteFamily();

/// 指定フォルダ URI がお気に入り登録済みか判定する Provider
///
/// [uri] に対してリポジトリの isFavorite を呼び出し、
/// 登録済みであれば true を返す。
///
/// Copied from [isFolderFavorite].
class IsFolderFavoriteFamily extends Family<AsyncValue<bool>> {
  /// 指定フォルダ URI がお気に入り登録済みか判定する Provider
  ///
  /// [uri] に対してリポジトリの isFavorite を呼び出し、
  /// 登録済みであれば true を返す。
  ///
  /// Copied from [isFolderFavorite].
  const IsFolderFavoriteFamily();

  /// 指定フォルダ URI がお気に入り登録済みか判定する Provider
  ///
  /// [uri] に対してリポジトリの isFavorite を呼び出し、
  /// 登録済みであれば true を返す。
  ///
  /// Copied from [isFolderFavorite].
  IsFolderFavoriteProvider call(String uri) {
    return IsFolderFavoriteProvider(uri);
  }

  @override
  IsFolderFavoriteProvider getProviderOverride(
    covariant IsFolderFavoriteProvider provider,
  ) {
    return call(provider.uri);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'isFolderFavoriteProvider';
}

/// 指定フォルダ URI がお気に入り登録済みか判定する Provider
///
/// [uri] に対してリポジトリの isFavorite を呼び出し、
/// 登録済みであれば true を返す。
///
/// Copied from [isFolderFavorite].
class IsFolderFavoriteProvider extends AutoDisposeFutureProvider<bool> {
  /// 指定フォルダ URI がお気に入り登録済みか判定する Provider
  ///
  /// [uri] に対してリポジトリの isFavorite を呼び出し、
  /// 登録済みであれば true を返す。
  ///
  /// Copied from [isFolderFavorite].
  IsFolderFavoriteProvider(String uri)
    : this._internal(
        (ref) => isFolderFavorite(ref as IsFolderFavoriteRef, uri),
        from: isFolderFavoriteProvider,
        name: r'isFolderFavoriteProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$isFolderFavoriteHash,
        dependencies: IsFolderFavoriteFamily._dependencies,
        allTransitiveDependencies:
            IsFolderFavoriteFamily._allTransitiveDependencies,
        uri: uri,
      );

  IsFolderFavoriteProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.uri,
  }) : super.internal();

  final String uri;

  @override
  Override overrideWith(
    FutureOr<bool> Function(IsFolderFavoriteRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsFolderFavoriteProvider._internal(
        (ref) => create(ref as IsFolderFavoriteRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        uri: uri,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _IsFolderFavoriteProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsFolderFavoriteProvider && other.uri == uri;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, uri.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IsFolderFavoriteRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `uri` of this provider.
  String get uri;
}

class _IsFolderFavoriteProviderElement
    extends AutoDisposeFutureProviderElement<bool>
    with IsFolderFavoriteRef {
  _IsFolderFavoriteProviderElement(super.provider);

  @override
  String get uri => (origin as IsFolderFavoriteProvider).uri;
}

String _$favoriteCountHash() => r'355a1114bd90c1a014c92da8d7ffa4b525a2de52';

/// 現在のお気に入り登録件数を返す Provider
///
/// お気に入りリストの件数表示（例: 「3 / 50」）に使用する。
///
/// Copied from [favoriteCount].
@ProviderFor(favoriteCount)
final favoriteCountProvider = AutoDisposeFutureProvider<int>.internal(
  favoriteCount,
  name: r'favoriteCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$favoriteCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FavoriteCountRef = AutoDisposeFutureProviderRef<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
