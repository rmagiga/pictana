/// ThumbnailCache テーブル定義 (設計書 §13.1)
library;

import 'package:drift/drift.dart';

/// サムネイルキャッシュメタデータテーブル
class ThumbnailCaches extends Table {
  /// 主キー（自動インクリメント）
  IntColumn get id => integer().autoIncrement()();

  /// 元画像 URI
  TextColumn get imageUri => text().unique()();

  /// ディスクキャッシュのファイルパス
  TextColumn get cachePath => text()();

  /// サムネイル幅 (px)
  IntColumn get width => integer()();

  /// サムネイル高さ (px)
  IntColumn get height => integer()();

  /// キャッシュ更新日時
  DateTimeColumn get updatedAt => dateTime()();
}
