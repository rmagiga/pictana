// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grid_column_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gridColumnSettingsNotifierHash() =>
    r'87534f9fb6116939e92c1577dd53dd24349281d5';

/// グリッド列数設定を管理する Provider
///
/// `setMinColumns` で min を設定すると、max >= min + 2 を自動調整する。
/// `setMaxColumns` で max を設定する。
/// DB 読み込み失敗時はデフォルト値 (3, 12) を使用する。
///
/// Copied from [GridColumnSettingsNotifier].
@ProviderFor(GridColumnSettingsNotifier)
final gridColumnSettingsNotifierProvider =
    NotifierProvider<GridColumnSettingsNotifier, GridColumnSettings>.internal(
      GridColumnSettingsNotifier.new,
      name: r'gridColumnSettingsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$gridColumnSettingsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GridColumnSettingsNotifier = Notifier<GridColumnSettings>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
