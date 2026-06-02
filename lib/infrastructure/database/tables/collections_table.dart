/// Collections テーブル定義
library;

import 'package:drift/drift.dart';

/// コレクションテーブル
///
/// ユーザーが作成した仮想フォルダ（コレクション）を管理する。
/// 物理フォルダの境界を超えて画像を論理的にグループ化する。
class Collections extends Table {
  /// 主キー（自動インクリメント）
  IntColumn get id => integer().autoIncrement()();

  /// コレクション名（ユニーク制約、1〜50文字）
  TextColumn get name => text().withLength(min: 1, max: 50).unique()();

  /// 並び順（デフォルト: 0）
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// 作成日時
  DateTimeColumn get createdAt => dateTime()();

  /// 更新日時
  DateTimeColumn get updatedAt => dateTime()();
}
