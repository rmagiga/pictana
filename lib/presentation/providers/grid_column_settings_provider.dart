/// グリッド列数設定 Provider
///
/// AppDatabase の getSetting/setSetting を使用して永続化。
/// キー: 'grid_min_columns', 'grid_max_columns'
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/providers/repository_providers.dart';
import '../../domain/value_objects/grid_column_settings.dart';

part 'grid_column_settings_provider.g.dart';

/// グリッド列数設定を管理する Provider
///
/// `setMinColumns` で min を設定すると、max >= min + 2 を自動調整する。
/// `setMaxColumns` で max を設定する。
/// DB 読み込み失敗時はデフォルト値 (3, 12) を使用する。
@Riverpod(keepAlive: true)
class GridColumnSettingsNotifier extends _$GridColumnSettingsNotifier {
  static const _kMinColumnsKey = 'grid_min_columns';
  static const _kMaxColumnsKey = 'grid_max_columns';

  @override
  GridColumnSettings build() {
    _loadInitial();
    return const GridColumnSettings();
  }

  Future<void> _loadInitial() async {
    try {
      final db = ref.read(appDatabaseProvider);
      final minStr = await db.getSetting(_kMinColumnsKey);
      final maxStr = await db.getSetting(_kMaxColumnsKey);

      final min = minStr != null ? (int.tryParse(minStr) ?? 3) : 3;
      final max = maxStr != null ? (int.tryParse(maxStr) ?? 12) : 12;

      // DB から読み込んだ値でも制約を保証する
      final adjustedMax = max >= min + 2 ? max : min + 2;
      state = GridColumnSettings(minColumns: min, maxColumns: adjustedMax);
    } catch (_) {
      // DB 読み込み失敗時はデフォルト値を維持
    }
  }

  /// 最小列数を設定する
  ///
  /// max >= min + 2 の制約を自動調整し、DB に保存する。
  Future<void> setMinColumns(int min) async {
    final currentMax = state.maxColumns;
    final adjustedMax = currentMax >= min + 2 ? currentMax : min + 2;

    state = GridColumnSettings(minColumns: min, maxColumns: adjustedMax);

    try {
      final db = ref.read(appDatabaseProvider);
      await db.setSetting(_kMinColumnsKey, min.toString());
      if (adjustedMax != currentMax) {
        await db.setSetting(_kMaxColumnsKey, adjustedMax.toString());
      }
    } catch (_) {
      // DB 書き込み失敗時はメモリ上の設定は適用済み
    }
  }

  /// 最大列数を設定する
  ///
  /// max >= min + 2 の制約を保証し、DB に保存する。
  /// max が min + 2 未満の場合は min + 2 に調整する。
  Future<void> setMaxColumns(int max) async {
    final currentMin = state.minColumns;
    final adjustedMax = max >= currentMin + 2 ? max : currentMin + 2;

    state = state.copyWith(maxColumns: adjustedMax);

    try {
      final db = ref.read(appDatabaseProvider);
      await db.setSetting(_kMaxColumnsKey, adjustedMax.toString());
    } catch (_) {
      // DB 書き込み失敗時はメモリ上の設定は適用済み
    }
  }
}
