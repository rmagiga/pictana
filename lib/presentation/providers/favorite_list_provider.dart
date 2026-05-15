/// お気に入りフォルダ一覧 Provider
///
/// GetFavoritesUseCase を利用してお気に入り一覧を管理する。
/// keepAlive: true でアプリ起動中は状態を保持し、
/// refresh() で一覧を再取得する。
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/providers/repository_providers.dart';
import '../../application/usecases/favorites/get_favorites_usecase.dart';
import '../../domain/entities/favorite_folder.dart';

part 'favorite_list_provider.g.dart';

/// お気に入りフォルダ一覧を管理する Provider
///
/// アプリ起動時にお気に入り一覧を読み込み、
/// お気に入りの追加・削除後に refresh() で再取得する。
@Riverpod(keepAlive: true)
class FavoriteList extends _$FavoriteList {
  @override
  Future<List<FavoriteFolder>> build() async {
    final useCase = _createUseCase();
    return useCase.execute();
  }

  /// お気に入り一覧を再取得する
  ///
  /// お気に入りの登録・解除後に呼び出して一覧を最新状態に更新する。
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final useCase = _createUseCase();
      return useCase.execute();
    });
  }

  /// GetFavoritesUseCase のインスタンスを生成する
  GetFavoritesUseCase _createUseCase() {
    final repository = ref.watch(favoriteRepositoryProvider);
    return GetFavoritesUseCase(repository: repository);
  }
}
