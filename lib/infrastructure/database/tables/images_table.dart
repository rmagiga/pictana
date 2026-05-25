/// Images テーブル定義
library;

import 'package:drift/drift.dart';

/// 画像メタデータテーブル
@DataClassName('ImageTableData')
class Images extends Table {
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

  /// 最終更新時刻 (エポックミリ秒)
  IntColumn get modified => integer()();

  /// ファイルサイズ (バイト)
  IntColumn get size => integer()();

  /// MIMEタイプ
  TextColumn get mimeType => text()();

  /// 画像の幅 (px, null許容)
  IntColumn get width => integer().nullable()();

  /// 画像の高さ (px, null許容)
  IntColumn get height => integer().nullable()();

  /// 撮影日時 (EXIF)
  DateTimeColumn get exifDateTime => dateTime().nullable()();

  /// カメラ機種名 (EXIF)
  TextColumn get exifCamera => text().nullable()();

  /// GPS 緯度 (EXIF)
  RealColumn get exifGpsLatitude => real().nullable()();

  /// GPS 経度 (EXIF)
  RealColumn get exifGpsLongitude => real().nullable()();

  /// インデックス作成/更新日時
  DateTimeColumn get indexedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {entryId};
}
