// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_thumbnail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 個別フォルダのサムネイルを最大4枚取得する Family Provider
///
/// [FavoriteFolder] を引数に取り、以下のフローでサムネイルリストを返す:
/// 1. メモリキャッシュをチェック（ヒット時は即座に返す）
/// 2. キャッシュミス時は [GetFolderThumbnailsUseCase] を実行
/// 3. 取得結果をキャッシュに保存
/// 4. 結果を返す（空リストの場合もそのまま返す）

@ProviderFor(getFolderThumbnails)
final getFolderThumbnailsProvider = GetFolderThumbnailsFamily._();

/// 個別フォルダのサムネイルを最大4枚取得する Family Provider
///
/// [FavoriteFolder] を引数に取り、以下のフローでサムネイルリストを返す:
/// 1. メモリキャッシュをチェック（ヒット時は即座に返す）
/// 2. キャッシュミス時は [GetFolderThumbnailsUseCase] を実行
/// 3. 取得結果をキャッシュに保存
/// 4. 結果を返す（空リストの場合もそのまま返す）

final class GetFolderThumbnailsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Uint8List?>>,
          List<Uint8List?>,
          FutureOr<List<Uint8List?>>
        >
    with $FutureModifier<List<Uint8List?>>, $FutureProvider<List<Uint8List?>> {
  /// 個別フォルダのサムネイルを最大4枚取得する Family Provider
  ///
  /// [FavoriteFolder] を引数に取り、以下のフローでサムネイルリストを返す:
  /// 1. メモリキャッシュをチェック（ヒット時は即座に返す）
  /// 2. キャッシュミス時は [GetFolderThumbnailsUseCase] を実行
  /// 3. 取得結果をキャッシュに保存
  /// 4. 結果を返す（空リストの場合もそのまま返す）
  GetFolderThumbnailsProvider._({
    required GetFolderThumbnailsFamily super.from,
    required FavoriteFolder super.argument,
  }) : super(
         retry: null,
         name: r'getFolderThumbnailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$getFolderThumbnailsHash();

  @override
  String toString() {
    return r'getFolderThumbnailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Uint8List?>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Uint8List?>> create(Ref ref) {
    final argument = this.argument as FavoriteFolder;
    return getFolderThumbnails(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GetFolderThumbnailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getFolderThumbnailsHash() =>
    r'4417c6b67bdb88ce96e0a1111262982077b16a64';

/// 個別フォルダのサムネイルを最大4枚取得する Family Provider
///
/// [FavoriteFolder] を引数に取り、以下のフローでサムネイルリストを返す:
/// 1. メモリキャッシュをチェック（ヒット時は即座に返す）
/// 2. キャッシュミス時は [GetFolderThumbnailsUseCase] を実行
/// 3. 取得結果をキャッシュに保存
/// 4. 結果を返す（空リストの場合もそのまま返す）

final class GetFolderThumbnailsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Uint8List?>>, FavoriteFolder> {
  GetFolderThumbnailsFamily._()
    : super(
        retry: null,
        name: r'getFolderThumbnailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 個別フォルダのサムネイルを最大4枚取得する Family Provider
  ///
  /// [FavoriteFolder] を引数に取り、以下のフローでサムネイルリストを返す:
  /// 1. メモリキャッシュをチェック（ヒット時は即座に返す）
  /// 2. キャッシュミス時は [GetFolderThumbnailsUseCase] を実行
  /// 3. 取得結果をキャッシュに保存
  /// 4. 結果を返す（空リストの場合もそのまま返す）

  GetFolderThumbnailsProvider call(FavoriteFolder folder) =>
      GetFolderThumbnailsProvider._(argument: folder, from: this);

  @override
  String toString() => r'getFolderThumbnailsProvider';
}
