// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swipe_direction_setting.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// スワイプ方向設定を管理する Provider
///
/// デフォルト値は [SwipeDirection.horizontal]（左右スワイプ）。
/// 設定変更時に DB へ永続化し、次回起動時に復元する。

@ProviderFor(SwipeDirectionSetting)
final swipeDirectionSettingProvider = SwipeDirectionSettingProvider._();

/// スワイプ方向設定を管理する Provider
///
/// デフォルト値は [SwipeDirection.horizontal]（左右スワイプ）。
/// 設定変更時に DB へ永続化し、次回起動時に復元する。
final class SwipeDirectionSettingProvider
    extends $NotifierProvider<SwipeDirectionSetting, SwipeDirection> {
  /// スワイプ方向設定を管理する Provider
  ///
  /// デフォルト値は [SwipeDirection.horizontal]（左右スワイプ）。
  /// 設定変更時に DB へ永続化し、次回起動時に復元する。
  SwipeDirectionSettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'swipeDirectionSettingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$swipeDirectionSettingHash();

  @$internal
  @override
  SwipeDirectionSetting create() => SwipeDirectionSetting();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SwipeDirection value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SwipeDirection>(value),
    );
  }
}

String _$swipeDirectionSettingHash() =>
    r'73d628fe6986b3652bf72e8ee986bc977d5bae2f';

/// スワイプ方向設定を管理する Provider
///
/// デフォルト値は [SwipeDirection.horizontal]（左右スワイプ）。
/// 設定変更時に DB へ永続化し、次回起動時に復元する。

abstract class _$SwipeDirectionSetting extends $Notifier<SwipeDirection> {
  SwipeDirection build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SwipeDirection, SwipeDirection>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SwipeDirection, SwipeDirection>,
              SwipeDirection,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
