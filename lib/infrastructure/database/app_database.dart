/// Drift Database定義 (設計書 §13)
library;

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/app_settings_table.dart';
import 'tables/collection_images_table.dart';
import 'tables/collections_table.dart';
import 'tables/favorite_folders_table.dart';
import 'tables/recent_folders_table.dart';
import 'tables/recent_images_table.dart';
import 'tables/thumbnail_cache_table.dart';
import 'tables/images_table.dart';
import 'tables/folder_viewer_settings_table.dart';
import '../../domain/value_objects/sort_option.dart';
import '../../domain/repositories/image_repository.dart';

part 'app_database.g.dart';

/// アプリ全体で使用するDriftデータベース
@DriftDatabase(
  tables: [
    RecentFolders,
    RecentImages,
    ThumbnailCaches,
    AppSettings,
    FavoriteFolders,
    Images,
    FolderViewerSettings,
    Collections,
    CollectionImages,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_folder_name ON images (folder_uri, name)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_folder_modified ON images (folder_uri, modified)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_folder_size ON images (folder_uri, size)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_collection_images_collection_sort '
        'ON collection_images (collection_id, sort_order)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_collection_images_entry '
        'ON collection_images (entry_id)',
      );
    },
    onUpgrade: (m, from, to) async {
      // v1 → v2: お気に入りフォルダテーブルを追加
      if (from < 2) {
        await m.createTable(favoriteFolders);
      }
      // v2 → v3: 画像メタデータテーブルを追加
      if (from < 3) {
        await m.createTable(images);
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_folder_name ON images (folder_uri, name)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_folder_modified ON images (folder_uri, modified)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_folder_size ON images (folder_uri, size)',
        );
      }
      // v3 → v4: 最近開いた画像履歴テーブルを追加
      if (from < 4) {
        await m.createTable(recentImages);
      }
      // v4 → v5: EXIF列の追加
      if (from < 5) {
        await m.addColumn(images, images.exifDateTime);
        await m.addColumn(images, images.exifCamera);
        await m.addColumn(images, images.exifGpsLatitude);
        await m.addColumn(images, images.exifGpsLongitude);
      }
      // v5 → v6: フォルダ別ビューア設定テーブルの追加
      if (from < 6) {
        await m.createTable(folderViewerSettings);
      }
      // v6 → v7: コレクション管理テーブルの追加
      if (from < 7) {
        await m.createTable(collections);
        await m.createTable(collectionImages);
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_collection_images_collection_sort '
          'ON collection_images (collection_id, sort_order)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_collection_images_entry '
          'ON collection_images (entry_id)',
        );
      }
    },
    beforeOpen: (details) async {
      // マイグレーション不整合の修復:
      // user_version が更新済みだがテーブル作成に失敗したケースに対応する。
      // Drift は onUpgrade 呼び出し前に user_version を書き換えるため、
      // 途中でクラッシュするとテーブルが存在しないまま再度 onUpgrade が
      // スキップされる問題を修復する。
      await customStatement('''
        CREATE TABLE IF NOT EXISTS collections (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          sort_order INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          CHECK (LENGTH(name) >= 1 AND LENGTH(name) <= 50)
        )
      ''');
      await customStatement('''
        CREATE TABLE IF NOT EXISTS collection_images (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          collection_id INTEGER NOT NULL REFERENCES collections (id) ON DELETE CASCADE,
          entry_id TEXT NOT NULL,
          sort_order INTEGER NOT NULL DEFAULT 0,
          added_at INTEGER NOT NULL,
          UNIQUE (collection_id, entry_id)
        )
      ''');
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_collection_images_collection_sort '
        'ON collection_images (collection_id, sort_order)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_collection_images_entry '
        'ON collection_images (entry_id)',
      );
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
  }) async {
    final existing =
        await (select(recentFolders)
              ..where((t) => t.uri.equals(uri))
              ..limit(1))
            .getSingleOrNull();

    if (existing != null) {
      await (update(
        recentFolders,
      )..where((t) => t.id.equals(existing.id))).write(
        RecentFoldersCompanion(
          name: Value(name),
          lastOpenedAt: Value(DateTime.now()),
        ),
      );
    } else {
      await into(recentFolders).insert(
        RecentFoldersCompanion.insert(
          uri: uri,
          name: name,
          platformType: platformType,
          lastOpenedAt: DateTime.now(),
        ),
      );
    }
  }

  // --- RecentImages クエリ ---

  /// 最近開いた画像一覧（最新順 上限20件）
  Future<List<RecentImage>> getRecentImages({int limit = 20}) =>
      (select(recentImages)
            ..orderBy([(t) => OrderingTerm.desc(t.lastViewedAt)])
            ..limit(limit))
          .get();

  /// 画像を最近開いた画像に追加/更新する
  Future<void> upsertRecentImage({
    required String entryId,
    required String uri,
    required String folderUri,
    required String name,
    required String extension,
    required int size,
    required String mimeType,
    int? width,
    int? height,
    required String platformType,
  }) => into(recentImages).insertOnConflictUpdate(
    RecentImagesCompanion.insert(
      entryId: entryId,
      uri: uri,
      folderUri: folderUri,
      name: name,
      extension: extension,
      size: size,
      mimeType: mimeType,
      width: Value(width),
      height: Value(height),
      platformType: platformType,
      lastViewedAt: DateTime.now(),
    ),
  );

  /// 指定 EntryId の最近開いた画像を削除する
  Future<int> deleteRecentImageByEntryId(String entryId) =>
      (delete(recentImages)..where((t) => t.entryId.equals(entryId))).go();

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
      },
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
      },
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
        list.map(
          (item) => ImagesCompanion.insert(
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
            exifDateTime: Value(item.exifDateTime),
            exifCamera: Value(item.exifCamera),
            exifGpsLatitude: Value(item.exifGpsLatitude),
            exifGpsLongitude: Value(item.exifGpsLongitude),
            indexedAt: DateTime.now(),
          ),
        ),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  /// 指定した画像の EXIF 情報を更新する
  Future<void> updateExif({
    required String entryId,
    DateTime? exifDateTime,
    String? exifCamera,
    double? exifGpsLatitude,
    double? exifGpsLongitude,
  }) async {
    await (update(images)..where((t) => t.entryId.equals(entryId))).write(
      ImagesCompanion(
        exifDateTime: Value(exifDateTime),
        exifCamera: Value(exifCamera),
        exifGpsLatitude: Value(exifGpsLatitude),
        exifGpsLongitude: Value(exifGpsLongitude),
      ),
    );
  }

  /// EXIF 情報が未解析（かつ特定のフォルダ内）の画像を取得する
  Future<List<ImageTableData>> getImagesMissingExif(String folderUri) =>
      (select(images)..where(
            (t) =>
                t.folderUri.equals(folderUri) &
                t.exifDateTime.isNull() &
                t.exifCamera.isNull() &
                t.exifGpsLatitude.isNull() &
                t.exifGpsLongitude.isNull(),
          ))
          .get();

  /// 同期時に指定したフォルダ内のアクティブでない（削除された）画像を消す
  Future<void> deleteImagesNotIn(
    String folderUri,
    List<String> activeEntryIds,
  ) async {
    await (delete(images)..where(
          (t) =>
              t.folderUri.equals(folderUri) & t.entryId.isNotIn(activeEntryIds),
        ))
        .go();
  }

  /// 指定フォルダ内の画像を全て削除する
  Future<void> deleteImagesInFolder(String folderUri) =>
      (delete(images)..where((t) => t.folderUri.equals(folderUri))).go();

  /// 指定 EntryId の画像メタデータを取得する
  Future<ImageTableData?> getImageByEntryId(String entryId) => (select(
    images,
  )..where((t) => t.entryId.equals(entryId))).getSingleOrNull();

  // --- FolderViewerSettings クエリ ---

  /// 指定フォルダの設定を取得する
  Future<FolderViewerSettingTableData?> getFolderViewerSetting(
    String folderUri,
  ) => (select(
    folderViewerSettings,
  )..where((t) => t.folderUri.equals(folderUri))).getSingleOrNull();

  /// フォルダ設定を保存する（Upsert）
  Future<void> upsertFolderViewerSetting({
    required String folderUri,
    required String displayMode,
    required bool isRightToLeft,
    required bool hasCoverPage,
  }) => into(folderViewerSettings).insertOnConflictUpdate(
    FolderViewerSettingsCompanion.insert(
      folderUri: folderUri,
      displayMode: Value(displayMode),
      isRightToLeft: Value(isRightToLeft),
      hasCoverPage: Value(hasCoverPage),
    ),
  );

  /// 画像の解像度（幅・高さ）を更新する
  Future<void> updateImageSize({
    required String entryId,
    required int width,
    required int height,
  }) async {
    await (update(images)..where((t) => t.entryId.equals(entryId))).write(
      ImagesCompanion(width: Value(width), height: Value(height)),
    );
  }
}

/// データベースファイルへの接続を開く
QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'pictana.db'));
    return NativeDatabase.createInBackground(file);
  });
}
