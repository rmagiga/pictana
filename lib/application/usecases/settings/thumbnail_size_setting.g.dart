// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thumbnail_size_setting.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// サムネイルサイズ設定を管理する Provider
///
/// 起動時に DB から設定を読み込み、変更時に永続化する。
/// DB 読み込み失敗時はデフォルト値 (medium: 256px) を使用する。

@ProviderFor(ThumbnailSizeSetting)
final thumbnailSizeSettingProvider = ThumbnailSizeSettingProvider._();

/// サムネイルサイズ設定を管理する Provider
///
/// 起動時に DB から設定を読み込み、変更時に永続化する。
/// DB 読み込み失敗時はデフォルト値 (medium: 256px) を使用する。
final class ThumbnailSizeSettingProvider
    extends $NotifierProvider<ThumbnailSizeSetting, ThumbnailSizeOption> {
  /// サムネイルサイズ設定を管理する Provider
  ///
  /// 起動時に DB から設定を読み込み、変更時に永続化する。
  /// DB 読み込み失敗時はデフォルト値 (medium: 256px) を使用する。
  ThumbnailSizeSettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'thumbnailSizeSettingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$thumbnailSizeSettingHash();

  @$internal
  @override
  ThumbnailSizeSetting create() => ThumbnailSizeSetting();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThumbnailSizeOption value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThumbnailSizeOption>(value),
    );
  }
}

String _$thumbnailSizeSettingHash() =>
    r'65fcc09dc4e15f3d1d5c983879187e8e69d65483';

/// サムネイルサイズ設定を管理する Provider
///
/// 起動時に DB から設定を読み込み、変更時に永続化する。
/// DB 読み込み失敗時はデフォルト値 (medium: 256px) を使用する。

abstract class _$ThumbnailSizeSetting extends $Notifier<ThumbnailSizeOption> {
  ThumbnailSizeOption build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ThumbnailSizeOption, ThumbnailSizeOption>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThumbnailSizeOption, ThumbnailSizeOption>,
              ThumbnailSizeOption,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
