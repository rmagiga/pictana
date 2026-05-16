// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grid_column_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// グリッド列数設定を管理する Provider
///
/// `setMinColumns` で min を設定すると、max >= min + 2 を自動調整する。
/// `setMaxColumns` で max を設定する。
/// DB 読み込み失敗時はデフォルト値 (3, 12) を使用する。

@ProviderFor(GridColumnSettingsNotifier)
final gridColumnSettingsProvider = GridColumnSettingsNotifierProvider._();

/// グリッド列数設定を管理する Provider
///
/// `setMinColumns` で min を設定すると、max >= min + 2 を自動調整する。
/// `setMaxColumns` で max を設定する。
/// DB 読み込み失敗時はデフォルト値 (3, 12) を使用する。
final class GridColumnSettingsNotifierProvider
    extends $NotifierProvider<GridColumnSettingsNotifier, GridColumnSettings> {
  /// グリッド列数設定を管理する Provider
  ///
  /// `setMinColumns` で min を設定すると、max >= min + 2 を自動調整する。
  /// `setMaxColumns` で max を設定する。
  /// DB 読み込み失敗時はデフォルト値 (3, 12) を使用する。
  GridColumnSettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gridColumnSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gridColumnSettingsNotifierHash();

  @$internal
  @override
  GridColumnSettingsNotifier create() => GridColumnSettingsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GridColumnSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GridColumnSettings>(value),
    );
  }
}

String _$gridColumnSettingsNotifierHash() =>
    r'a999f7e79cd589929d869ef4e137389040fbfac1';

/// グリッド列数設定を管理する Provider
///
/// `setMinColumns` で min を設定すると、max >= min + 2 を自動調整する。
/// `setMaxColumns` で max を設定する。
/// DB 読み込み失敗時はデフォルト値 (3, 12) を使用する。

abstract class _$GridColumnSettingsNotifier
    extends $Notifier<GridColumnSettings> {
  GridColumnSettings build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<GridColumnSettings, GridColumnSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GridColumnSettings, GridColumnSettings>,
              GridColumnSettings,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
