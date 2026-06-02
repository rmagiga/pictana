/// CollectionImages テーブル定義
library;

import 'package:drift/drift.dart';
import 'package:pictana/infrastructure/database/tables/collections_table.dart';

/// コレクション画像テーブル
///
/// コレクションと画像の関連付けを管理する中間テーブル。
/// 同一コレクション内での画像の重複登録を防止するユニーク制約を持つ。
/// コレクション削除時は CASCADE で関連レコードも自動削除される。
class CollectionImages extends Table {
  /// 主キー（自動インクリメント）
  IntColumn get id => integer().autoIncrement()();

  /// コレクション ID（外部キー、CASCADE 削除）
  IntColumn get collectionId =>
      integer().references(Collections, #id, onDelete: KeyAction.cascade)();

  /// 画像エントリ ID（EntryId の rawValue）
  TextColumn get entryId => text()();

  /// 並び順（デフォルト: 0）
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// 追加日時
  DateTimeColumn get addedAt => dateTime()();

  /// ユニーク制約: 同一コレクション内で同じ画像は1件のみ
  @override
  List<Set<Column>> get uniqueKeys => [
    {collectionId, entryId},
  ];
}
