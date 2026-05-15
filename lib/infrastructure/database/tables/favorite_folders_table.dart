/// FavoriteFolders テーブル定義
library;

import 'package:drift/drift.dart';

/// お気に入りフォルダテーブル
///
/// ユーザーが明示的にブックマークしたフォルダを永続化する。
/// URI にユニーク制約を設け、同一フォルダの重複登録を防止する。
class FavoriteFolders extends Table {
  /// 主キー（自動インクリメント）
  IntColumn get id => integer().autoIncrement()();

  /// フォルダ URI（ユニーク制約）
  TextColumn get uri => text().unique()();

  /// フォルダ表示名
  TextColumn get name => text()();

  /// お気に入り登録日時
  DateTimeColumn get registeredAt => dateTime()();
}
