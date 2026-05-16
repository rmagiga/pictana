// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_thumbnail_cache_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$folderThumbnailCacheHash() =>
    r'6e92501abe2ca8c08f24710a6ce29a3167d4d3e0';

/// フォルダサムネイルのメモリキャッシュを管理する Provider
///
/// [LinkedHashMap] を使用した LRU キャッシュで、
/// アクセス時にエントリを末尾に移動し、上限超過時は
/// 先頭（最も古い）エントリを削除する。
///
/// 単一サムネイル（レガシー）と複数サムネイル（リスト）の
/// 両方のキャッシュをサポートする。
///
/// Copied from [FolderThumbnailCache].
@ProviderFor(FolderThumbnailCache)
final folderThumbnailCacheProvider =
    NotifierProvider<FolderThumbnailCache, Map<String, Uint8List>>.internal(
      FolderThumbnailCache.new,
      name: r'folderThumbnailCacheProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$folderThumbnailCacheHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FolderThumbnailCache = Notifier<Map<String, Uint8List>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
