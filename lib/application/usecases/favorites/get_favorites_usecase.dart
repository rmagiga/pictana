/// GetFavoritesUseCase
///
/// お気に入りフォルダ一覧を取得するユースケース。
/// 登録日時降順でお気に入り一覧を返す。
/// 件数取得メソッドを提供する。
library;

import '../../../domain/entities/favorite_folder.dart';
import '../../../domain/repositories/favorite_repository.dart';

/// お気に入りフォルダ一覧を取得するユースケース
class GetFavoritesUseCase {
  const GetFavoritesUseCase({required FavoriteRepository repository})
    : _repository = repository;

  final FavoriteRepository _repository;

  /// 登録日時降順でお気に入り一覧を返す
  Future<List<FavoriteFolder>> execute() {
    return _repository.getFavorites();
  }

  /// 現在の登録件数を返す
  Future<int> count() {
    return _repository.getFavoriteCount();
  }
}
