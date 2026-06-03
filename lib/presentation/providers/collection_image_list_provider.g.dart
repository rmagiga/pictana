// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_image_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// コレクション画像一覧を sortOrder 昇順でリアルタイム監視する Stream Provider
///
/// [collectionId] 対象コレクションの ID
/// DB のコレクション画像データが変更されると自動的に最新の一覧を emit する。

@ProviderFor(collectionImageList)
final collectionImageListProvider = CollectionImageListFamily._();

/// コレクション画像一覧を sortOrder 昇順でリアルタイム監視する Stream Provider
///
/// [collectionId] 対象コレクションの ID
/// DB のコレクション画像データが変更されると自動的に最新の一覧を emit する。

final class CollectionImageListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CollectionImage>>,
          List<CollectionImage>,
          Stream<List<CollectionImage>>
        >
    with
        $FutureModifier<List<CollectionImage>>,
        $StreamProvider<List<CollectionImage>> {
  /// コレクション画像一覧を sortOrder 昇順でリアルタイム監視する Stream Provider
  ///
  /// [collectionId] 対象コレクションの ID
  /// DB のコレクション画像データが変更されると自動的に最新の一覧を emit する。
  CollectionImageListProvider._({
    required CollectionImageListFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'collectionImageListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$collectionImageListHash();

  @override
  String toString() {
    return r'collectionImageListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<CollectionImage>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<CollectionImage>> create(Ref ref) {
    final argument = this.argument as int;
    return collectionImageList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CollectionImageListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$collectionImageListHash() =>
    r'3511aba0deb40fc78517d2ec301b5b101bcf17c6';

/// コレクション画像一覧を sortOrder 昇順でリアルタイム監視する Stream Provider
///
/// [collectionId] 対象コレクションの ID
/// DB のコレクション画像データが変更されると自動的に最新の一覧を emit する。

final class CollectionImageListFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<CollectionImage>>, int> {
  CollectionImageListFamily._()
    : super(
        retry: null,
        name: r'collectionImageListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// コレクション画像一覧を sortOrder 昇順でリアルタイム監視する Stream Provider
  ///
  /// [collectionId] 対象コレクションの ID
  /// DB のコレクション画像データが変更されると自動的に最新の一覧を emit する。

  CollectionImageListProvider call(int collectionId) =>
      CollectionImageListProvider._(argument: collectionId, from: this);

  @override
  String toString() => r'collectionImageListProvider';
}

/// コレクション画像エントリリストを非同期に取得・変換する Provider
///
/// [collectionId] 対象コレクションの ID

@ProviderFor(collectionImageEntries)
final collectionImageEntriesProvider = CollectionImageEntriesFamily._();

/// コレクション画像エントリリストを非同期に取得・変換する Provider
///
/// [collectionId] 対象コレクションの ID

final class CollectionImageEntriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ImageEntry>>,
          List<ImageEntry>,
          FutureOr<List<ImageEntry>>
        >
    with $FutureModifier<List<ImageEntry>>, $FutureProvider<List<ImageEntry>> {
  /// コレクション画像エントリリストを非同期に取得・変換する Provider
  ///
  /// [collectionId] 対象コレクションの ID
  CollectionImageEntriesProvider._({
    required CollectionImageEntriesFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'collectionImageEntriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$collectionImageEntriesHash();

  @override
  String toString() {
    return r'collectionImageEntriesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ImageEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ImageEntry>> create(Ref ref) {
    final argument = this.argument as int;
    return collectionImageEntries(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CollectionImageEntriesProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$collectionImageEntriesHash() =>
    r'06ce37286f884b3d8347f23e4dce819e56022332';

/// コレクション画像エントリリストを非同期に取得・変換する Provider
///
/// [collectionId] 対象コレクションの ID

final class CollectionImageEntriesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ImageEntry>>, int> {
  CollectionImageEntriesFamily._()
    : super(
        retry: null,
        name: r'collectionImageEntriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// コレクション画像エントリリストを非同期に取得・変換する Provider
  ///
  /// [collectionId] 対象コレクションの ID

  CollectionImageEntriesProvider call(int collectionId) =>
      CollectionImageEntriesProvider._(argument: collectionId, from: this);

  @override
  String toString() => r'collectionImageEntriesProvider';
}
