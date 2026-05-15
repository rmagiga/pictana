/// FavoriteRepository Interface
///
/// 責務:
/// - お気に入りフォルダの CRUD 操作
/// - お気に入り状態の確認
/// - お気に入り件数の取得
///
/// 実装は Infrastructure 層（Drift）が提供する。
/// Domain/Application 層はこの Interface のみに依存する。
library;

import '../entities/favorite_folder.dart';

/// お気に入りフォルダリポジトリインターフェース
abstract interface class FavoriteRepository {
  /// お気に入り一覧を登録日時降順で取得する
  Future<List<FavoriteFolder>> getFavorites();

  /// お気に入りの登録件数を取得する
  Future<int> getFavoriteCount();

  /// 指定URIがお気に入り登録済みか確認する
  Future<bool> isFavorite(String uri);

  /// お気に入りに登録する（URI重複時は上書き更新）
  Future<FavoriteFolder> addFavorite({
    required String uri,
    required String name,
  });

  /// お気に入りから削除する
  Future<void> removeFavorite(String uri);

  /// 指定URIのお気に入りフォルダを取得する
  Future<FavoriteFolder?> getFavoriteByUri(String uri);
}
