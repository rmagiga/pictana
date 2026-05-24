/// RecentImages テーブル定義
library;

import 'package:drift/drift.dart';

/// 最近開いた画像履歴テーブル
class RecentImages extends Table {
  /// 画像の識別子 (EntryId)
  TextColumn get entryId => text()();

  /// アクセス用 URI 文字列
  TextColumn get uri => text()();

  /// 所属フォルダの URI
  TextColumn get folderUri => text()();

  /// ファイル名
  TextColumn get name => text()();

  /// 拡張子 (小文字、ドットなし)
  TextColumn get extension => text()();

  /// ファイルサイズ (バイト)
  IntColumn get size => integer()();

  /// MIMEタイプ
  TextColumn get mimeType => text()();

  /// 画像の幅 (px, null許容)
  IntColumn get width => integer().nullable()();

  /// 画像の高さ (px, null許容)
  IntColumn get height => integer().nullable()();

  /// プラットフォーム種別 ("android" / "windows")
  TextColumn get platformType => text()();

  /// 最終アクセス日時
  DateTimeColumn get lastViewedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {entryId};
}
