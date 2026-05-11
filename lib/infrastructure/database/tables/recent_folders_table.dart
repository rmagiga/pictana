/// RecentFolders テーブル定義 (設計書 §13.1)
library;

import 'package:drift/drift.dart';

/// 最近開いたフォルダ履歴テーブル
class RecentFolders extends Table {
  /// 主キー（自動インクリメント）
  IntColumn get id => integer().autoIncrement()();

  /// フォルダ URI
  TextColumn get uri => text()();

  /// フォルダ表示名
  TextColumn get name => text()();

  /// プラットフォーム種別 ("android" / "windows")
  TextColumn get platformType => text()();

  /// 最終アクセス日時
  DateTimeColumn get lastOpenedAt => dateTime()();
}
