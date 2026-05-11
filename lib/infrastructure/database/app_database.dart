/// Drift Database定義 (設計書 §13)
library;

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/app_settings_table.dart';
import 'tables/recent_folders_table.dart';
import 'tables/thumbnail_cache_table.dart';

part 'app_database.g.dart';

/// アプリ全体で使用するDriftデータベース
@DriftDatabase(tables: [RecentFolders, ThumbnailCaches, AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  // --- RecentFolders クエリ ---

  /// 最近開いたフォルダ一覧（最新順 上限20件）
  Future<List<RecentFolder>> getRecentFolders({int limit = 20}) =>
      (select(recentFolders)
            ..orderBy([(t) => OrderingTerm.desc(t.lastOpenedAt)])
            ..limit(limit))
          .get();

  /// フォルダを最近開いたフォルダに追加/更新する
  Future<void> upsertRecentFolder({
    required String uri,
    required String name,
    required String platformType,
  }) =>
      into(recentFolders).insertOnConflictUpdate(
        RecentFoldersCompanion.insert(
          uri: uri,
          name: name,
          platformType: platformType,
          lastOpenedAt: DateTime.now(),
        ),
      );

  // --- AppSettings クエリ ---

  /// 設定値を取得する
  Future<String?> getSetting(String key) async {
    final row = await (select(appSettings)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  /// 設定値を保存する
  Future<void> setSetting(String key, String value) =>
      into(appSettings).insertOnConflictUpdate(
        AppSettingsCompanion.insert(key: key, value: value),
      );

  /// 全設定を取得する（Map形式）
  Future<Map<String, String>> getAllSettings() async {
    final rows = await select(appSettings).get();
    return {for (final r in rows) r.key: r.value};
  }

  // --- ThumbnailCache クエリ ---

  /// 指定URIのサムネイルキャッシュを取得する
  Future<ThumbnailCache?> getThumbnailCache(String imageUri) =>
      (select(thumbnailCaches)..where((t) => t.imageUri.equals(imageUri))).getSingleOrNull();

  /// サムネイルキャッシュを保存する
  Future<void> upsertThumbnailCache({
    required String imageUri,
    required String cachePath,
    required int width,
    required int height,
  }) =>
      into(thumbnailCaches).insertOnConflictUpdate(
        ThumbnailCachesCompanion.insert(
          imageUri: imageUri,
          cachePath: cachePath,
          width: width,
          height: height,
          updatedAt: DateTime.now(),
        ),
      );

  /// 全サムネイルキャッシュを削除する
  Future<int> clearThumbnailCache() => delete(thumbnailCaches).go();

  /// 指定 URI のサムネイルキャッシュを無効化する
  Future<int> invalidateThumbnailCache(String imageUri) =>
      (delete(thumbnailCaches)..where((t) => t.imageUri.equals(imageUri))).go();
}

/// データベースファイルへの接続を開く
QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'optrig.db'));
    return NativeDatabase.createInBackground(file);
  });
}
