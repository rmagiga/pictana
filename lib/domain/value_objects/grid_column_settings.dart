/// グリッド列数設定 Value Object
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'grid_column_settings.freezed.dart';

/// グリッド列数設定
///
/// 設定画面で指定された最小・最大列数を保持する。
/// お気に入りグリッドの列数計算に使用される。
@freezed
abstract class GridColumnSettings with _$GridColumnSettings {
  const factory GridColumnSettings({
    /// 最小列数（デフォルト: 3）
    @Default(3) int minColumns,

    /// 最大列数（デフォルト: 12）
    @Default(12) int maxColumns,
  }) = _GridColumnSettings;
}
