// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_thumbnail_cache_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// フォルダサムネイルのメモリキャッシュを管理する Provider
///
/// [LinkedHashMap] を使用した LRU キャッシュで、
/// アクセス時にエントリを末尾に移動し、上限超過時は
/// 先頭（最も古い）エントリを削除する。
///
/// 単一サムネイル（レガシー）と複数サムネイル（リスト）の
/// 両方のキャッシュをサポートする。

@ProviderFor(FolderThumbnailCache)
final folderThumbnailCacheProvider = FolderThumbnailCacheProvider._();

/// フォルダサムネイルのメモリキャッシュを管理する Provider
///
/// [LinkedHashMap] を使用した LRU キャッシュで、
/// アクセス時にエントリを末尾に移動し、上限超過時は
/// 先頭（最も古い）エントリを削除する。
///
/// 単一サムネイル（レガシー）と複数サムネイル（リスト）の
/// 両方のキャッシュをサポートする。
final class FolderThumbnailCacheProvider
    extends $NotifierProvider<FolderThumbnailCache, Map<String, Uint8List>> {
  /// フォルダサムネイルのメモリキャッシュを管理する Provider
  ///
  /// [LinkedHashMap] を使用した LRU キャッシュで、
  /// アクセス時にエントリを末尾に移動し、上限超過時は
  /// 先頭（最も古い）エントリを削除する。
  ///
  /// 単一サムネイル（レガシー）と複数サムネイル（リスト）の
  /// 両方のキャッシュをサポートする。
  FolderThumbnailCacheProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'folderThumbnailCacheProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$folderThumbnailCacheHash();

  @$internal
  @override
  FolderThumbnailCache create() => FolderThumbnailCache();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, Uint8List> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, Uint8List>>(value),
    );
  }
}

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

abstract class _$FolderThumbnailCache
    extends $Notifier<Map<String, Uint8List>> {
  Map<String, Uint8List> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<Map<String, Uint8List>, Map<String, Uint8List>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, Uint8List>, Map<String, Uint8List>>,
              Map<String, Uint8List>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
