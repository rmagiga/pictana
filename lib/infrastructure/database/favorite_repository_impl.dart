/// FavoriteRepository の Drift 実装
///
/// AppDatabase を利用してお気に入りフォルダの永続化を行う。
/// DB エンティティ（Drift 生成クラス）から Domain エンティティへの変換を担当する。
library;

import 'package:drift/drift.dart';

import '../../domain/entities/favorite_folder.dart' as domain;
import '../../domain/repositories/favorite_repository.dart';
import 'app_database.dart';

/// お気に入りフォルダリポジトリの Drift 実装
///
/// [AppDatabase] の `favoriteFolders` テーブルを操作し、
/// [FavoriteRepository] インターフェースを実装する。
class FavoriteRepositoryImpl implements FavoriteRepository {
  final AppDatabase _db;

  /// コンストラクタ
  ///
  /// [db] アプリケーションデータベースインスタンス
  FavoriteRepositoryImpl(this._db);

  /// お気に入り一覧を登録日時降順で取得する
  @override
  Future<List<domain.FavoriteFolder>> getFavorites() async {
    final rows = await (_db.select(
      _db.favoriteFolders,
    )..orderBy([(t) => OrderingTerm.desc(t.registeredAt)])).get();
    return rows.map(_toDomain).toList();
  }

  /// お気に入りの登録件数を取得する
  @override
  Future<int> getFavoriteCount() async {
    final count = _db.favoriteFolders.id.count();
    final query = _db.selectOnly(_db.favoriteFolders)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// 指定URIがお気に入り登録済みか確認する
  @override
  Future<bool> isFavorite(String uri) async {
    final query = _db.select(_db.favoriteFolders)
      ..where((t) => t.uri.equals(uri));
    final result = await query.getSingleOrNull();
    return result != null;
  }

  /// お気に入りに登録する（URI重複時は上書き更新）
  ///
  /// URI が既に存在する場合は名前と登録日時を更新する（upsert）。
  /// 新規登録の場合は新しいレコードを作成する。
  @override
  Future<domain.FavoriteFolder> addFavorite({
    required String uri,
    required String name,
  }) async {
    final now = DateTime.now();
    await _db
        .into(_db.favoriteFolders)
        .insert(
          FavoriteFoldersCompanion.insert(
            uri: uri,
            name: name,
            registeredAt: now,
          ),
          onConflict: DoUpdate(
            (old) => FavoriteFoldersCompanion(
              name: Value(name),
              registeredAt: Value(now),
            ),
            target: [_db.favoriteFolders.uri],
          ),
        );

    // upsert 後のレコードを取得して返す
    final row = await (_db.select(
      _db.favoriteFolders,
    )..where((t) => t.uri.equals(uri))).getSingle();
    return _toDomain(row);
  }

  /// お気に入りから削除する
  @override
  Future<void> removeFavorite(String uri) async {
    await (_db.delete(
      _db.favoriteFolders,
    )..where((t) => t.uri.equals(uri))).go();
  }

  /// 指定URIのお気に入りフォルダを取得する
  @override
  Future<domain.FavoriteFolder?> getFavoriteByUri(String uri) async {
    final row = await (_db.select(
      _db.favoriteFolders,
    )..where((t) => t.uri.equals(uri))).getSingleOrNull();
    if (row == null) return null;
    return _toDomain(row);
  }

  /// DB エンティティから Domain エンティティへ変換する
  domain.FavoriteFolder _toDomain(FavoriteFolder row) {
    return domain.FavoriteFolder(
      id: row.id,
      uri: row.uri,
      name: row.name,
      registeredAt: row.registeredAt,
    );
  }
}
