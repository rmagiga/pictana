/// Drift Database定義 (設計書 §13)
library;

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/app_settings_table.dart';
import 'tables/favorite_folders_table.dart';
import 'tables/recent_folders_table.dart';
import 'tables/thumbnail_cache_table.dart';
import 'tables/images_table.dart';
import '../../domain/value_objects/sort_option.dart';
import '../../domain/repositories/image_repository.dart';

part 'app_database.g.dart';

/// アプリ全体で使用するDriftデータベース
@DriftDatabase(
  tables: [RecentFolders, ThumbnailCaches, AppSettings, FavoriteFolders, Images],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement('CREATE INDEX IF NOT EXISTS idx_folder_name ON images (folder_uri, name)');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_folder_modified ON images (folder_uri, modified)');
      await customStatement('CREATE INDEX IF NOT EXISTS idx_folder_size ON images (folder_uri, size)');
    },
    onUpgrade: (m, from, to) async {
      // v1 → v2: お気に入りフォルダテーブルを追加
      if (from < 2) {
        await m.createTable(favoriteFolders);
      }
      // v2 → v3: 画像メタデータテーブルを追加
      if (from < 3) {
        await m.createTable(images);
        await customStatement('CREATE INDEX IF NOT EXISTS idx_folder_name ON images (folder_uri, name)');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_folder_modified ON images (folder_uri, modified)');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_folder_size ON images (folder_uri, size)');
      }
    },
  );

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
  }) => into(recentFolders).insertOnConflictUpdate(
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
    final row = await (select(
      appSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  /// 設定値を保存する
  Future<void> setSetting(String key, String value) => into(
    appSettings,
  ).insertOnConflictUpdate(AppSettingsCompanion.insert(key: key, value: value));

  /// 全設定を取得する（Map形式）
  Future<Map<String, String>> getAllSettings() async {
    final rows = await select(appSettings).get();
    return {for (final r in rows) r.key: r.value};
  }

  // --- ThumbnailCache クエリ ---

  /// 指定URIのサムネイルキャッシュを取得する
  Future<ThumbnailCache?> getThumbnailCache(String imageUri) => (select(
    thumbnailCaches,
  )..where((t) => t.imageUri.equals(imageUri))).getSingleOrNull();

  /// サムネイルキャッシュを保存する
  Future<void> upsertThumbnailCache({
    required String imageUri,
    required String cachePath,
    required int width,
    required int height,
  }) {
    final now = DateTime.now();
    return into(thumbnailCaches).insert(
      ThumbnailCachesCompanion.insert(
        imageUri: imageUri,
        cachePath: cachePath,
        width: width,
        height: height,
        updatedAt: now,
      ),
      onConflict: DoUpdate(
        (old) => ThumbnailCachesCompanion(
          cachePath: Value(cachePath),
          width: Value(width),
          height: Value(height),
          updatedAt: Value(now),
        ),
        target: [thumbnailCaches.imageUri],
      ),
    );
  }

  /// 全サムネイルキャッシュエントリを取得する
  Future<List<ThumbnailCache>> getAllThumbnailCaches() =>
      select(thumbnailCaches).get();

  /// 全サムネイルキャッシュを削除する
  Future<int> clearThumbnailCache() => delete(thumbnailCaches).go();

  /// 指定 URI のサムネイルキャッシュを無効化する
  Future<int> invalidateThumbnailCache(String imageUri) =>
      (delete(thumbnailCaches)..where((t) => t.imageUri.equals(imageUri))).go();

  // --- RecentFolders 追加クエリ ---

  /// 指定 URI の最近開いたフォルダを削除する
  Future<int> deleteRecentFolderByUri(String uri) =>
      (delete(recentFolders)..where((t) => t.uri.equals(uri))).go();

  /// 指定プラットフォーム種別の最近開いたフォルダ数を取得する
  Future<int> countRecentFoldersByPlatform(String platformType) async {
    final count = recentFolders.uri.count();
    final query = selectOnly(recentFolders)
      ..addColumns([count])
      ..where(recentFolders.platformType.equals(platformType));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  // --- Images クエリ ---

  /// 指定フォルダ内の画像エントリをソート・フィルタした結果をStreamで監視する
  Stream<List<ImageTableData>> watchImagesInFolder({
    required String folderUri,
    required SortOption sort,
    required ImageFilter filter,
  }) {
    final query = select(images)..where((t) => t.folderUri.equals(folderUri));

    // フィルター: nameQuery (部分一致)
    if (filter.nameQuery != null && filter.nameQuery!.trim().isNotEmpty) {
      final nameLower = '%${filter.nameQuery!.trim().toLowerCase()}%';
      query.where((t) => t.name.lower().like(nameLower));
    }

    // フィルター: mimeTypes
    if (filter.mimeTypes != null && filter.mimeTypes!.isNotEmpty) {
      final mimes = filter.mimeTypes!.map((m) => m.name).toList();
      query.where((t) => t.mimeType.isIn(mimes));
    }

    // ソート
    final asc = sort.isAscending;
    query.orderBy([
      (t) => switch (sort.field) {
            SortField.name =>
              asc ? OrderingTerm.asc(t.name) : OrderingTerm.desc(t.name),
            SortField.date =>
              asc ? OrderingTerm.asc(t.modified) : OrderingTerm.desc(t.modified),
            SortField.size =>
              asc ? OrderingTerm.asc(t.size) : OrderingTerm.desc(t.size),
            SortField.type =>
              asc ? OrderingTerm.asc(t.extension) : OrderingTerm.desc(t.extension),
          }
    ]);

    return query.watch();
  }

  /// 指定ページの画像リストを返す (一括・ページネーション用)
  Future<List<ImageTableData>> getImagePage({
    required String folderUri,
    required int page,
    required int pageSize,
    required SortOption sort,
    required ImageFilter filter,
  }) async {
    final query = select(images)..where((t) => t.folderUri.equals(folderUri));

    // フィルター: nameQuery
    if (filter.nameQuery != null && filter.nameQuery!.trim().isNotEmpty) {
      final nameLower = '%${filter.nameQuery!.trim().toLowerCase()}%';
      query.where((t) => t.name.lower().like(nameLower));
    }

    // フィルター: mimeTypes
    if (filter.mimeTypes != null && filter.mimeTypes!.isNotEmpty) {
      final mimes = filter.mimeTypes!.map((m) => m.name).toList();
      query.where((t) => t.mimeType.isIn(mimes));
    }

    // ソート
    final asc = sort.isAscending;
    query.orderBy([
      (t) => switch (sort.field) {
            SortField.name =>
              asc ? OrderingTerm.asc(t.name) : OrderingTerm.desc(t.name),
            SortField.date =>
              asc ? OrderingTerm.asc(t.modified) : OrderingTerm.desc(t.modified),
            SortField.size =>
              asc ? OrderingTerm.asc(t.size) : OrderingTerm.desc(t.size),
            SortField.type =>
              asc ? OrderingTerm.asc(t.extension) : OrderingTerm.desc(t.extension),
          }
    ]);

    query.limit(pageSize, offset: page * pageSize);
    return query.get();
  }

  /// フォルダ内の画像総数を返す
  Future<int> countImages({
    required String folderUri,
    required ImageFilter filter,
  }) async {
    final countExp = images.entryId.count();
    final query = selectOnly(images)
      ..addColumns([countExp])
      ..where(images.folderUri.equals(folderUri));

    // フィルター: nameQuery
    if (filter.nameQuery != null && filter.nameQuery!.trim().isNotEmpty) {
      final nameLower = '%${filter.nameQuery!.trim().toLowerCase()}%';
      query.where(images.name.lower().like(nameLower));
    }

    // フィルター: mimeTypes
    if (filter.mimeTypes != null && filter.mimeTypes!.isNotEmpty) {
      final mimes = filter.mimeTypes!.map((m) => m.name).toList();
      query.where(images.mimeType.isIn(mimes));
    }

    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  /// 画像エントリを複数 upsert する
  Future<void> upsertImages(List<ImageTableData> list) async {
    await batch((batch) {
      batch.insertAll(
        images,
        list.map((item) => ImagesCompanion.insert(
          entryId: item.entryId,
          uri: item.uri,
          folderUri: item.folderUri,
          name: item.name,
          extension: item.extension,
          modified: item.modified,
          size: item.size,
          mimeType: item.mimeType,
          width: Value(item.width),
          height: Value(item.height),
          indexedAt: DateTime.now(),
        )),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  /// 同期時に指定したフォルダ内のアクティブでない（削除された）画像を消す
  Future<void> deleteImagesNotIn(String folderUri, List<String> activeEntryIds) async {
    await (delete(images)
          ..where((t) => t.folderUri.equals(folderUri) & t.entryId.isNotIn(activeEntryIds)))
        .go();
  }

  /// 指定フォルダ内の画像を全て削除する
  Future<void> deleteImagesInFolder(String folderUri) =>
      (delete(images)..where((t) => t.folderUri.equals(folderUri))).go();
}

/// データベースファイルへの接続を開く
QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'pictana.db'));
    return NativeDatabase.createInBackground(file);
  });
}
