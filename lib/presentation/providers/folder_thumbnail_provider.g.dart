// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_thumbnail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$getFolderThumbnailHash() =>
    r'6143a641435da7f074a04639872fec771c816352';

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

/// 個別フォルダのサムネイルを取得する Family Provider
///
/// [FavoriteFolder] を引数に取り、以下のフローでサムネイルを返す:
/// 1. メモリキャッシュをチェック（ヒット時は即座に返す）
/// 2. キャッシュミス時は [GetFolderThumbnailUseCase] を実行
/// 3. 取得結果をキャッシュに保存
/// 4. 結果を返す（null の場合もそのまま返す）
///
/// Copied from [getFolderThumbnail].
@ProviderFor(getFolderThumbnail)
const getFolderThumbnailProvider = GetFolderThumbnailFamily();

/// 個別フォルダのサムネイルを取得する Family Provider
///
/// [FavoriteFolder] を引数に取り、以下のフローでサムネイルを返す:
/// 1. メモリキャッシュをチェック（ヒット時は即座に返す）
/// 2. キャッシュミス時は [GetFolderThumbnailUseCase] を実行
/// 3. 取得結果をキャッシュに保存
/// 4. 結果を返す（null の場合もそのまま返す）
///
/// Copied from [getFolderThumbnail].
class GetFolderThumbnailFamily extends Family<AsyncValue<Uint8List?>> {
  /// 個別フォルダのサムネイルを取得する Family Provider
  ///
  /// [FavoriteFolder] を引数に取り、以下のフローでサムネイルを返す:
  /// 1. メモリキャッシュをチェック（ヒット時は即座に返す）
  /// 2. キャッシュミス時は [GetFolderThumbnailUseCase] を実行
  /// 3. 取得結果をキャッシュに保存
  /// 4. 結果を返す（null の場合もそのまま返す）
  ///
  /// Copied from [getFolderThumbnail].
  const GetFolderThumbnailFamily();

  /// 個別フォルダのサムネイルを取得する Family Provider
  ///
  /// [FavoriteFolder] を引数に取り、以下のフローでサムネイルを返す:
  /// 1. メモリキャッシュをチェック（ヒット時は即座に返す）
  /// 2. キャッシュミス時は [GetFolderThumbnailUseCase] を実行
  /// 3. 取得結果をキャッシュに保存
  /// 4. 結果を返す（null の場合もそのまま返す）
  ///
  /// Copied from [getFolderThumbnail].
  GetFolderThumbnailProvider call(FavoriteFolder folder) {
    return GetFolderThumbnailProvider(folder);
  }

  @override
  GetFolderThumbnailProvider getProviderOverride(
    covariant GetFolderThumbnailProvider provider,
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
  String? get name => r'getFolderThumbnailProvider';
}

/// 個別フォルダのサムネイルを取得する Family Provider
///
/// [FavoriteFolder] を引数に取り、以下のフローでサムネイルを返す:
/// 1. メモリキャッシュをチェック（ヒット時は即座に返す）
/// 2. キャッシュミス時は [GetFolderThumbnailUseCase] を実行
/// 3. 取得結果をキャッシュに保存
/// 4. 結果を返す（null の場合もそのまま返す）
///
/// Copied from [getFolderThumbnail].
class GetFolderThumbnailProvider extends AutoDisposeFutureProvider<Uint8List?> {
  /// 個別フォルダのサムネイルを取得する Family Provider
  ///
  /// [FavoriteFolder] を引数に取り、以下のフローでサムネイルを返す:
  /// 1. メモリキャッシュをチェック（ヒット時は即座に返す）
  /// 2. キャッシュミス時は [GetFolderThumbnailUseCase] を実行
  /// 3. 取得結果をキャッシュに保存
  /// 4. 結果を返す（null の場合もそのまま返す）
  ///
  /// Copied from [getFolderThumbnail].
  GetFolderThumbnailProvider(FavoriteFolder folder)
    : this._internal(
        (ref) => getFolderThumbnail(ref as GetFolderThumbnailRef, folder),
        from: getFolderThumbnailProvider,
        name: r'getFolderThumbnailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$getFolderThumbnailHash,
        dependencies: GetFolderThumbnailFamily._dependencies,
        allTransitiveDependencies:
            GetFolderThumbnailFamily._allTransitiveDependencies,
        folder: folder,
      );

  GetFolderThumbnailProvider._internal(
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
    FutureOr<Uint8List?> Function(GetFolderThumbnailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GetFolderThumbnailProvider._internal(
        (ref) => create(ref as GetFolderThumbnailRef),
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
  AutoDisposeFutureProviderElement<Uint8List?> createElement() {
    return _GetFolderThumbnailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetFolderThumbnailProvider && other.folder == folder;
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
mixin GetFolderThumbnailRef on AutoDisposeFutureProviderRef<Uint8List?> {
  /// The parameter `folder` of this provider.
  FavoriteFolder get folder;
}

class _GetFolderThumbnailProviderElement
    extends AutoDisposeFutureProviderElement<Uint8List?>
    with GetFolderThumbnailRef {
  _GetFolderThumbnailProviderElement(super.provider);

  @override
  FavoriteFolder get folder => (origin as GetFolderThumbnailProvider).folder;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
