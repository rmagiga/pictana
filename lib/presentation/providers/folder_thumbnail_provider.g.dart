// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_thumbnail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$getFolderThumbnailsHash() =>
    r'4417c6b67bdb88ce96e0a1111262982077b16a64';

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

/// 個別フォルダのサムネイルを最大4枚取得する Family Provider
///
/// [FavoriteFolder] を引数に取り、以下のフローでサムネイルリストを返す:
/// 1. メモリキャッシュをチェック（ヒット時は即座に返す）
/// 2. キャッシュミス時は [GetFolderThumbnailsUseCase] を実行
/// 3. 取得結果をキャッシュに保存
/// 4. 結果を返す（空リストの場合もそのまま返す）
///
/// Copied from [getFolderThumbnails].
@ProviderFor(getFolderThumbnails)
const getFolderThumbnailsProvider = GetFolderThumbnailsFamily();

/// 個別フォルダのサムネイルを最大4枚取得する Family Provider
///
/// [FavoriteFolder] を引数に取り、以下のフローでサムネイルリストを返す:
/// 1. メモリキャッシュをチェック（ヒット時は即座に返す）
/// 2. キャッシュミス時は [GetFolderThumbnailsUseCase] を実行
/// 3. 取得結果をキャッシュに保存
/// 4. 結果を返す（空リストの場合もそのまま返す）
///
/// Copied from [getFolderThumbnails].
class GetFolderThumbnailsFamily extends Family<AsyncValue<List<Uint8List?>>> {
  /// 個別フォルダのサムネイルを最大4枚取得する Family Provider
  ///
  /// [FavoriteFolder] を引数に取り、以下のフローでサムネイルリストを返す:
  /// 1. メモリキャッシュをチェック（ヒット時は即座に返す）
  /// 2. キャッシュミス時は [GetFolderThumbnailsUseCase] を実行
  /// 3. 取得結果をキャッシュに保存
  /// 4. 結果を返す（空リストの場合もそのまま返す）
  ///
  /// Copied from [getFolderThumbnails].
  const GetFolderThumbnailsFamily();

  /// 個別フォルダのサムネイルを最大4枚取得する Family Provider
  ///
  /// [FavoriteFolder] を引数に取り、以下のフローでサムネイルリストを返す:
  /// 1. メモリキャッシュをチェック（ヒット時は即座に返す）
  /// 2. キャッシュミス時は [GetFolderThumbnailsUseCase] を実行
  /// 3. 取得結果をキャッシュに保存
  /// 4. 結果を返す（空リストの場合もそのまま返す）
  ///
  /// Copied from [getFolderThumbnails].
  GetFolderThumbnailsProvider call(FavoriteFolder folder) {
    return GetFolderThumbnailsProvider(folder);
  }

  @override
  GetFolderThumbnailsProvider getProviderOverride(
    covariant GetFolderThumbnailsProvider provider,
  ) {
    return call(provider.folder);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'getFolderThumbnailsProvider';
}

/// 個別フォルダのサムネイルを最大4枚取得する Family Provider
///
/// [FavoriteFolder] を引数に取り、以下のフローでサムネイルリストを返す:
/// 1. メモリキャッシュをチェック（ヒット時は即座に返す）
/// 2. キャッシュミス時は [GetFolderThumbnailsUseCase] を実行
/// 3. 取得結果をキャッシュに保存
/// 4. 結果を返す（空リストの場合もそのまま返す）
///
/// Copied from [getFolderThumbnails].
class GetFolderThumbnailsProvider
    extends AutoDisposeFutureProvider<List<Uint8List?>> {
  /// 個別フォルダのサムネイルを最大4枚取得する Family Provider
  ///
  /// [FavoriteFolder] を引数に取り、以下のフローでサムネイルリストを返す:
  /// 1. メモリキャッシュをチェック（ヒット時は即座に返す）
  /// 2. キャッシュミス時は [GetFolderThumbnailsUseCase] を実行
  /// 3. 取得結果をキャッシュに保存
  /// 4. 結果を返す（空リストの場合もそのまま返す）
  ///
  /// Copied from [getFolderThumbnails].
  GetFolderThumbnailsProvider(FavoriteFolder folder)
    : this._internal(
        (ref) => getFolderThumbnails(ref as GetFolderThumbnailsRef, folder),
        from: getFolderThumbnailsProvider,
        name: r'getFolderThumbnailsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$getFolderThumbnailsHash,
        dependencies: GetFolderThumbnailsFamily._dependencies,
        allTransitiveDependencies:
            GetFolderThumbnailsFamily._allTransitiveDependencies,
        folder: folder,
      );

  GetFolderThumbnailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.folder,
  }) : super.internal();

  final FavoriteFolder folder;

  @override
  Override overrideWith(
    FutureOr<List<Uint8List?>> Function(GetFolderThumbnailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GetFolderThumbnailsProvider._internal(
        (ref) => create(ref as GetFolderThumbnailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        folder: folder,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Uint8List?>> createElement() {
    return _GetFolderThumbnailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetFolderThumbnailsProvider && other.folder == folder;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, folder.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GetFolderThumbnailsRef on AutoDisposeFutureProviderRef<List<Uint8List?>> {
  /// The parameter `folder` of this provider.
  FavoriteFolder get folder;
}

class _GetFolderThumbnailsProviderElement
    extends AutoDisposeFutureProviderElement<List<Uint8List?>>
    with GetFolderThumbnailsRef {
  _GetFolderThumbnailsProviderElement(super.provider);

  @override
  FavoriteFolder get folder => (origin as GetFolderThumbnailsProvider).folder;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
