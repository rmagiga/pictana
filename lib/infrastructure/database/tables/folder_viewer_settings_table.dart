import 'package:drift/drift.dart';

/// フォルダごとの表示設定テーブル
@DataClassName('FolderViewerSettingTableData')
class FolderViewerSettings extends Table {
  /// フォルダの一意なURI
  TextColumn get folderUri => text()();

  /// 表示モード ('single', 'double', 'scroll')
  TextColumn get displayMode => text().withDefault(const Constant('single'))();

  /// めくり方向が右から左 (RTL, 和書/漫画形式) かどうか
  BoolColumn get isRightToLeft => boolean().withDefault(const Constant(true))();

  /// 最初の1ページを表紙（単一）として扱うかどうか
  BoolColumn get hasCoverPage => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {folderUri};
}
