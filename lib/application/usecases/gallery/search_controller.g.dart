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
/// [SearchController] の状態と画像リストを監視し、
/// `applySearchFilter` 純粋関数でフィルタリングした結果を返す。

@ProviderFor(filteredImages)
final filteredImagesProvider = FilteredImagesFamily._();

/// 検索フィルターを適用した画像リストを返す computed Provider
///
/// [SearchController] の状態と画像リストを監視し、
/// `applySearchFilter` 純粋関数でフィルタリングした結果を返す。

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
  /// [SearchController] の状態と画像リストを監視し、
  /// `applySearchFilter` 純粋関数でフィルタリングした結果を返す。
  FilteredImagesProvider._({
    required FilteredImagesFamily super.from,
    required List<ImageEntry> super.argument,
  }) : super(
         retry: null,
         name: r'filteredImagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filteredImagesHash();

  @override
  String toString() {
    return r'filteredImagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<ImageEntry>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<ImageEntry> create(Ref ref) {
    final argument = this.argument as List<ImageEntry>;
    return filteredImages(ref, images: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ImageEntry> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ImageEntry>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredImagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filteredImagesHash() => r'de93088bcda6cf27ebdbd7a07958269ad0350d87';

/// 検索フィルターを適用した画像リストを返す computed Provider
///
/// [SearchController] の状態と画像リストを監視し、
/// `applySearchFilter` 純粋関数でフィルタリングした結果を返す。

final class FilteredImagesFamily extends $Family
    with $FunctionalFamilyOverride<List<ImageEntry>, List<ImageEntry>> {
  FilteredImagesFamily._()
    : super(
        retry: null,
        name: r'filteredImagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 検索フィルターを適用した画像リストを返す computed Provider
  ///
  /// [SearchController] の状態と画像リストを監視し、
  /// `applySearchFilter` 純粋関数でフィルタリングした結果を返す。

  FilteredImagesProvider call({required List<ImageEntry> images}) =>
      FilteredImagesProvider._(argument: images, from: this);

  @override
  String toString() => r'filteredImagesProvider';
}
