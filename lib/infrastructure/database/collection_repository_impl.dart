/// CollectionRepository の Drift 実装
///
/// AppDatabase を利用してコレクションの永続化を行う。
/// gap-based sortOrder（間隔1000）による並び順管理を実装する。
/// DB エンティティ（Drift 生成クラス）から Domain エンティティへの変換を担当する。
library;

import 'package:drift/drift.dart';

import '../../domain/entities/collection.dart' as domain;
import '../../domain/entities/collection_image.dart' as domain;
import '../../domain/entities/entry_id.dart';
import '../../domain/repositories/collection_repository.dart';
import '../../domain/value_objects/collection_name.dart';
import 'app_database.dart';

/// sortOrder の初期間隔
const int _sortOrderInterval = 1000;

/// CollectionRepository の Drift 実装
///
/// [AppDatabase] の `collections` / `collectionImages` テーブルを操作し、
/// [CollectionRepository] インターフェースを実装する。
class CollectionRepositoryImpl implements CollectionRepository {
  final AppDatabase _db;

  /// コンストラクタ
  ///
  /// [db] アプリケーションデータベースインスタンス
  CollectionRepositoryImpl(this._db);

  // ==========================================================================
  // コレクション CRUD
  // ==========================================================================

  /// コレクション一覧を sortOrder 昇順で取得する
  ///
  /// imageCount は CollectionImages テーブルへの COUNT サブクエリで取得する。
  @override
  Future<List<domain.Collection>> getCollections() async {
    final imageCountExpr = _db.collectionImages.id.count();

    final query = _db.select(_db.collections).join([
      leftOuterJoin(
        _db.collectionImages,
        _db.collectionImages.collectionId.equalsExp(_db.collections.id),
      ),
    ]);

    query
      ..groupBy([_db.collections.id])
      ..addColumns([imageCountExpr])
      ..orderBy([OrderingTerm.asc(_db.collections.sortOrder)]);

    final rows = await query.get();
    return rows.map((row) {
      final collection = row.readTable(_db.collections);
      final count = row.read(imageCountExpr) ?? 0;
      return _toCollectionDomain(collection, count);
    }).toList();
  }

  /// コレクション一覧を sortOrder 昇順で監視する
  @override
  Stream<List<domain.Collection>> watchCollections() {
    final imageCountExpr = _db.collectionImages.id.count();

    final query = _db.select(_db.collections).join([
      leftOuterJoin(
        _db.collectionImages,
        _db.collectionImages.collectionId.equalsExp(_db.collections.id),
      ),
    ]);

    query
      ..groupBy([_db.collections.id])
      ..addColumns([imageCountExpr])
      ..orderBy([OrderingTerm.asc(_db.collections.sortOrder)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final collection = row.readTable(_db.collections);
        final count = row.read(imageCountExpr) ?? 0;
        return _toCollectionDomain(collection, count);
      }).toList();
    });
  }

  /// 指定 ID のコレクションを取得する
  @override
  Future<domain.Collection?> getCollectionById(int id) async {
    final row = await (_db.select(
      _db.collections,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;

    final count = await getImageCount(id);
    return _toCollectionDomain(row, count);
  }

  /// コレクションを新規作成する
  ///
  /// sortOrder は既存の最大値 + _sortOrderInterval で設定する。
  @override
  Future<domain.Collection> createCollection(CollectionName name) async {
    final now = DateTime.now();

    // 現在の最大 sortOrder を取得
    final maxSortOrder = await _getMaxCollectionSortOrder();
    final newSortOrder = maxSortOrder + _sortOrderInterval;

    final id = await _db
        .into(_db.collections)
        .insert(
          CollectionsCompanion.insert(
            name: name.value,
            sortOrder: Value(newSortOrder),
            createdAt: now,
            updatedAt: now,
          ),
        );

    return domain.Collection(
      id: id,
      name: name,
      imageCount: 0,
      sortOrder: newSortOrder,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// コレクションを削除する（関連する CollectionImage も CASCADE 削除）
  @override
  Future<void> deleteCollection(int id) async {
    await (_db.delete(_db.collections)..where((t) => t.id.equals(id))).go();
  }

  /// 複数コレクションを一括削除する
  @override
  Future<void> deleteCollections(List<int> ids) async {
    await (_db.delete(_db.collections)..where((t) => t.id.isIn(ids))).go();
  }

  /// コレクション名を変更する
  @override
  Future<domain.Collection> renameCollection(
    int id,
    CollectionName newName,
  ) async {
    final now = DateTime.now();
    await (_db.update(_db.collections)..where((t) => t.id.equals(id))).write(
      CollectionsCompanion(name: Value(newName.value), updatedAt: Value(now)),
    );

    final row = await (_db.select(
      _db.collections,
    )..where((t) => t.id.equals(id))).getSingle();
    final count = await getImageCount(id);
    return _toCollectionDomain(row, count);
  }

  /// コレクション名の重複チェック（自身を除外可能）
  @override
  Future<bool> isNameDuplicate(String name, {int? excludeId}) async {
    final query = _db.select(_db.collections)
      ..where((t) => t.name.equals(name.trim()));
    if (excludeId != null) {
      query.where((t) => t.id.equals(excludeId).not());
    }
    final result = await query.getSingleOrNull();
    return result != null;
  }

  /// コレクション一覧の並び順を更新する
  ///
  /// orderedIds の順序に従い、gap-based sortOrder を再割り当てする。
  @override
  Future<void> reorderCollections(List<int> orderedIds) async {
    await _db.batch((batch) {
      for (var i = 0; i < orderedIds.length; i++) {
        final newSortOrder = (i + 1) * _sortOrderInterval;
        batch.update(
          _db.collections,
          CollectionsCompanion(sortOrder: Value(newSortOrder)),
          where: ($CollectionsTable t) => t.id.equals(orderedIds[i]),
        );
      }
    });
  }

  // ==========================================================================
  // コレクション画像操作
  // ==========================================================================

  /// コレクションに画像を追加する（重複はスキップ）
  ///
  /// 戻り値は実際に追加された件数。
  /// sortOrder は既存の最大値 + _sortOrderInterval から連番で設定する。
  @override
  Future<int> addImages(int collectionId, List<EntryId> entryIds) async {
    if (entryIds.isEmpty) return 0;

    // 既に登録済みの entryId を取得
    final existingRows =
        await (_db.select(_db.collectionImages)..where(
              (t) =>
                  t.collectionId.equals(collectionId) &
                  t.entryId.isIn(entryIds.map((e) => e.rawValue).toList()),
            ))
            .get();
    final existingEntryIds = existingRows.map((r) => r.entryId).toSet();

    // 新規追加対象をフィルタ
    final newEntryIds = entryIds
        .where((e) => !existingEntryIds.contains(e.rawValue))
        .toList();

    if (newEntryIds.isEmpty) return 0;

    // 現在の最大 sortOrder を取得
    final maxSortOrder = await _getMaxImageSortOrder(collectionId);
    final now = DateTime.now();

    await _db.batch((batch) {
      for (var i = 0; i < newEntryIds.length; i++) {
        final sortOrder = maxSortOrder + (i + 1) * _sortOrderInterval;
        batch.insert(
          _db.collectionImages,
          CollectionImagesCompanion.insert(
            collectionId: collectionId,
            entryId: newEntryIds[i].rawValue,
            sortOrder: Value(sortOrder),
            addedAt: now,
          ),
        );
      }
    });

    return newEntryIds.length;
  }

  /// コレクションから画像を解除する
  @override
  Future<void> removeImages(int collectionId, List<EntryId> entryIds) async {
    if (entryIds.isEmpty) return;

    await (_db.delete(_db.collectionImages)..where(
          (t) =>
              t.collectionId.equals(collectionId) &
              t.entryId.isIn(entryIds.map((e) => e.rawValue).toList()),
        ))
        .go();
  }

  /// コレクション内の画像一覧を sortOrder 昇順で取得する
  @override
  Future<List<domain.CollectionImage>> getCollectionImages(
    int collectionId,
  ) async {
    final rows =
        await (_db.select(_db.collectionImages)
              ..where((t) => t.collectionId.equals(collectionId))
              ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
            .get();
    return rows.map(_toCollectionImageDomain).toList();
  }

  /// コレクション内の画像一覧を sortOrder 昇順で監視する
  @override
  Stream<List<domain.CollectionImage>> watchCollectionImages(int collectionId) {
    final query = _db.select(_db.collectionImages)
      ..where((t) => t.collectionId.equals(collectionId))
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);

    return query.watch().map((rows) {
      return rows.map(_toCollectionImageDomain).toList();
    });
  }

  /// コレクション内画像の並び順を更新する
  ///
  /// orderedEntryIds の順序に従い、gap-based sortOrder を再割り当てする。
  /// 一括移動時は相対順序を維持するアルゴリズムを使用する。
  ///
  /// アルゴリズム:
  /// 1. 選択画像を抽出（相対順序維持）
  /// 2. 残りのリストを構築
  /// 3. ドロップ位置に挿入
  /// 4. sortOrder を再計算して永続化
  @override
  Future<void> reorderImages(
    int collectionId,
    List<EntryId> orderedEntryIds,
  ) async {
    await _db.batch((batch) {
      for (var i = 0; i < orderedEntryIds.length; i++) {
        final newSortOrder = (i + 1) * _sortOrderInterval;
        batch.update(
          _db.collectionImages,
          CollectionImagesCompanion(sortOrder: Value(newSortOrder)),
          where: ($CollectionImagesTable t) =>
              t.collectionId.equals(collectionId) &
              t.entryId.equals(orderedEntryIds[i].rawValue),
        );
      }
    });
  }

  /// 指定画像が所属するコレクション一覧を取得する
  @override
  Future<List<domain.Collection>> getCollectionsForImage(
    EntryId entryId,
  ) async {
    // 該当画像を含むコレクション ID を取得
    final imageRows = await (_db.select(
      _db.collectionImages,
    )..where((t) => t.entryId.equals(entryId.rawValue))).get();

    if (imageRows.isEmpty) return [];

    final collectionIds = imageRows.map((r) => r.collectionId).toSet().toList();

    // 各コレクションを imageCount 付きで取得
    final imageCountExpr = _db.collectionImages.id.count();

    final query = _db.select(_db.collections).join([
      leftOuterJoin(
        _db.collectionImages,
        _db.collectionImages.collectionId.equalsExp(_db.collections.id),
      ),
    ]);

    query
      ..where(_db.collections.id.isIn(collectionIds))
      ..groupBy([_db.collections.id])
      ..addColumns([imageCountExpr])
      ..orderBy([OrderingTerm.asc(_db.collections.sortOrder)]);

    final rows = await query.get();
    return rows.map((row) {
      final collection = row.readTable(_db.collections);
      final count = row.read(imageCountExpr) ?? 0;
      return _toCollectionDomain(collection, count);
    }).toList();
  }

  /// 指定画像群の各コレクションへの所属状態を取得する
  ///
  /// 戻り値の Map は collectionId をキーとし、
  /// 対象画像群がすべてそのコレクションに所属している場合に true を返す。
  @override
  Future<Map<int, bool>> getImageMembership(
    List<EntryId> entryIds,
    List<int> collectionIds,
  ) async {
    if (entryIds.isEmpty || collectionIds.isEmpty) return {};

    final entryIdStrings = entryIds.map((e) => e.rawValue).toList();
    final totalEntries = entryIdStrings.length;

    final result = <int, bool>{};

    for (final collectionId in collectionIds) {
      // 該当コレクションに所属している対象画像の数をカウント
      final countExpr = _db.collectionImages.id.count();
      final query = _db.selectOnly(_db.collectionImages)
        ..addColumns([countExpr])
        ..where(
          _db.collectionImages.collectionId.equals(collectionId) &
              _db.collectionImages.entryId.isIn(entryIdStrings),
        );
      final row = await query.getSingle();
      final memberCount = row.read(countExpr) ?? 0;

      // 全画像が所属していれば true
      result[collectionId] = memberCount == totalEntries;
    }

    return result;
  }

  /// コレクション内の画像数を取得する
  @override
  Future<int> getImageCount(int collectionId) async {
    final countExpr = _db.collectionImages.id.count();
    final query = _db.selectOnly(_db.collectionImages)
      ..addColumns([countExpr])
      ..where(_db.collectionImages.collectionId.equals(collectionId));
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  // ==========================================================================
  // プライベートヘルパー
  // ==========================================================================

  /// コレクションの最大 sortOrder を取得する
  Future<int> _getMaxCollectionSortOrder() async {
    final maxExpr = _db.collections.sortOrder.max();
    final query = _db.selectOnly(_db.collections)..addColumns([maxExpr]);
    final row = await query.getSingle();
    return row.read(maxExpr) ?? 0;
  }

  /// 指定コレクション内の画像の最大 sortOrder を取得する
  Future<int> _getMaxImageSortOrder(int collectionId) async {
    final maxExpr = _db.collectionImages.sortOrder.max();
    final query = _db.selectOnly(_db.collectionImages)
      ..addColumns([maxExpr])
      ..where(_db.collectionImages.collectionId.equals(collectionId));
    final row = await query.getSingle();
    return row.read(maxExpr) ?? 0;
  }

  /// DB の Collection 行を Domain エンティティに変換する
  domain.Collection _toCollectionDomain(Collection row, int imageCount) {
    return domain.Collection(
      id: row.id,
      name: CollectionName.create(row.name),
      imageCount: imageCount,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  /// DB の CollectionImage 行を Domain エンティティに変換する
  domain.CollectionImage _toCollectionImageDomain(CollectionImage row) {
    return domain.CollectionImage(
      id: row.id,
      collectionId: row.collectionId,
      entryId: EntryId(
        rawValue: row.entryId,
        platformType: PlatformType.unknown,
      ),
      sortOrder: row.sortOrder,
      addedAt: row.addedAt,
    );
  }
}
