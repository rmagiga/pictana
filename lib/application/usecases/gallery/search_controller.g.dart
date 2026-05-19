// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 検索・フィルター状態を管理する Provider
///
/// - [updateQuery]: 300ms デバウンス付きでクエリを更新
/// - [updateMimeTypeFilter]: MIME type フィルターを即時更新
/// - [clearAll]: 全フィルターをリセット

@ProviderFor(SearchController)
final searchControllerProvider = SearchControllerProvider._();

/// 検索・フィルター状態を管理する Provider
///
/// - [updateQuery]: 300ms デバウンス付きでクエリを更新
/// - [updateMimeTypeFilter]: MIME type フィルターを即時更新
/// - [clearAll]: 全フィルターをリセット
final class SearchControllerProvider
    extends $NotifierProvider<SearchController, SearchFilterState> {
  /// 検索・フィルター状態を管理する Provider
  ///
  /// - [updateQuery]: 300ms デバウンス付きでクエリを更新
  /// - [updateMimeTypeFilter]: MIME type フィルターを即時更新
  /// - [clearAll]: 全フィルターをリセット
  SearchControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchControllerHash();

  @$internal
  @override
  SearchController create() => SearchController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchFilterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchFilterState>(value),
    );
  }
}

String _$searchControllerHash() => r'944ac88e2cda0da2ac7fd706e97681fa5e9fdbfa';

/// 検索・フィルター状態を管理する Provider
///
/// - [updateQuery]: 300ms デバウンス付きでクエリを更新
/// - [updateMimeTypeFilter]: MIME type フィルターを即時更新
/// - [clearAll]: 全フィルターをリセット

abstract class _$SearchController extends $Notifier<SearchFilterState> {
  SearchFilterState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SearchFilterState, SearchFilterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchFilterState, SearchFilterState>,
              SearchFilterState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// 検索フィルターを適用した画像リストを返す computed Provider
///
/// galleryImagesProvider を直接 watch し、family 引数を使用しない。

@ProviderFor(filteredImages)
final filteredImagesProvider = FilteredImagesProvider._();

/// 検索フィルターを適用した画像リストを返す computed Provider
///
/// galleryImagesProvider を直接 watch し、family 引数を使用しない。

final class FilteredImagesProvider
    extends
        $FunctionalProvider<
          List<ImageEntry>,
          List<ImageEntry>,
          List<ImageEntry>
        >
    with $Provider<List<ImageEntry>> {
  /// 検索フィルターを適用した画像リストを返す computed Provider
  ///
  /// galleryImagesProvider を直接 watch し、family 引数を使用しない。
  FilteredImagesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredImagesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredImagesHash();

  @$internal
  @override
  $ProviderElement<List<ImageEntry>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<ImageEntry> create(Ref ref) {
    return filteredImages(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ImageEntry> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ImageEntry>>(value),
    );
  }
}

String _$filteredImagesHash() => r'3f818a384010e31f115633a0b619b6984927a44a';
