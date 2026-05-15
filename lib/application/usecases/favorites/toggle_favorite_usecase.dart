/// ToggleFavoriteUseCase
///
/// お気に入り登録/解除のトグル操作を実行するユースケース。
/// 現在の状態に応じて登録または解除を切り替える。
/// 登録時は上限チェック（50件）を実行し、超過時は例外をスローする。
library;

import '../../../core/errors/favorite_exceptions.dart';
import '../../../domain/repositories/favorite_repository.dart';

/// お気に入り登録/解除のトグル操作を実行するユースケース
class ToggleFavoriteUseCase {
  const ToggleFavoriteUseCase({required FavoriteRepository repository})
    : _repository = repository;

  final FavoriteRepository _repository;

  /// お気に入り登録上限件数
  static const int maxFavorites = 50;

  /// 現在の状態に応じて登録または解除を実行する。
  ///
  /// - 未登録の場合: 上限チェック後にお気に入りに登録する
  /// - 登録済みの場合: お気に入りから解除する
  ///
  /// 登録時に上限（50件）に達している場合は
  /// [FavoriteLimitExceededException] をスローする。
  ///
  /// 戻り値: 登録された場合は `true`、解除された場合は `false`
  Future<bool> execute({required String uri, required String name}) async {
    final isFavorite = await _repository.isFavorite(uri);

    if (isFavorite) {
      // 登録済み → 解除
      await _repository.removeFavorite(uri);
      return false;
    } else {
      // 未登録 → 上限チェック後に登録
      final currentCount = await _repository.getFavoriteCount();
      if (currentCount >= maxFavorites) {
        throw FavoriteLimitExceededException(
          currentCount: currentCount,
          maxCount: maxFavorites,
        );
      }
      await _repository.addFavorite(uri: uri, name: name);
      return true;
    }
  }
}
