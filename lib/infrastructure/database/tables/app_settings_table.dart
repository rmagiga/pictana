/// AppSettings テーブル定義 (設計書 §13.1, §5.6)
library;

import 'package:drift/drift.dart';

/// アプリ設定テーブル（key-value store）
class AppSettings extends Table {
  /// 設定キー（主キー）
  TextColumn get key => text()();

  /// 設定値（JSON文字列）
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// 設定キー定数
class AppSettingKeys {
  const AppSettingKeys._();

  /// テーマ設定: "dark" / "light" / "system"
  static const theme = 'theme';

  /// グリッド列数: 整数文字列
  static const gridColumns = 'grid_columns';

  /// サムネイルサイズ: "small" / "medium" / "large"
  static const thumbnailSize = 'thumbnail_size';

  /// デフォルトソート順: "name_asc" / "name_desc" / "date_asc" / ...
  static const defaultSort = 'default_sort';

  /// キャッシュ上限 (MB): 整数文字列
  static const cacheSizeLimitMb = 'cache_size_limit_mb';
}
