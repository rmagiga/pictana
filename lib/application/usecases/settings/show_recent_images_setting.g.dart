// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'show_recent_images_setting.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 最近見た画像の表示設定を管理する Provider

@ProviderFor(ShowRecentImagesSetting)
final showRecentImagesSettingProvider = ShowRecentImagesSettingProvider._();

/// 最近見た画像の表示設定を管理する Provider
final class ShowRecentImagesSettingProvider
    extends $NotifierProvider<ShowRecentImagesSetting, bool> {
  /// 最近見た画像の表示設定を管理する Provider
  ShowRecentImagesSettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'showRecentImagesSettingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$showRecentImagesSettingHash();

  @$internal
  @override
  ShowRecentImagesSetting create() => ShowRecentImagesSetting();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$showRecentImagesSettingHash() =>
    r'ea2f969f697e1aa6c9c5f80b155ecc466138ee39';

/// 最近見た画像の表示設定を管理する Provider

abstract class _$ShowRecentImagesSetting extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
