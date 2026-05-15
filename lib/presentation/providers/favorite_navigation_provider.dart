/// お気に入りフォルダナビゲーション用 Provider 定義
///
/// NavigateToFavoriteUseCase の DI と、
/// ナビゲーション中のローディング状態を管理する。
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/providers/repository_providers.dart';
import '../../application/usecases/favorites/navigate_to_favorite_usecase.dart';

part 'favorite_navigation_provider.g.dart';

/// NavigateToFavoriteUseCase の Provider
///
/// FavoriteRepository と StorageRepository を注入して
/// ユースケースインスタンスを生成する。
@riverpod
NavigateToFavoriteUseCase navigateToFavoriteUseCase(
  NavigateToFavoriteUseCaseRef ref,
) {
  return NavigateToFavoriteUseCase(
    favoriteRepository: ref.watch(favoriteRepositoryProvider),
    storageRepository: ref.watch(storageRepositoryProvider),
  );
}

/// お気に入りフォルダナビゲーション中の状態
///
/// true の場合、ナビゲーション処理中であることを示す。
/// ローディングインジケーター表示・追加タップ無効化に使用する。
@Riverpod(keepAlive: true)
class FavoriteNavigationState extends _$FavoriteNavigationState {
  @override
  bool build() => false;

  /// ナビゲーション状態を設定する
  void setNavigating(bool value) {
    state = value;
  }
}
