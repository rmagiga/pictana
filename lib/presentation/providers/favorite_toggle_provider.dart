/// お気に入りトグル操作 Provider（楽観的UI更新対応）
///
/// トグル操作時に即座にアイコン状態を切り替え（楽観的UI更新）、
/// バックエンド処理失敗時にはロールバックを行う。
/// 処理中ロックにより連続タップによる状態不整合を防止する。
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/providers/repository_providers.dart';
import '../../application/usecases/favorites/toggle_favorite_usecase.dart';
import 'favorite_list_provider.dart';
import 'favorite_toggle_state.dart';

part 'favorite_toggle_provider.g.dart';

/// お気に入りトグル操作を管理する Provider
///
/// 楽観的UI更新により、ユーザー操作に対して即座にフィードバックを返す。
/// - toggle() 呼び出し時に即座に optimisticIsFavorite を反転
/// - 処理中（isProcessing == true）は追加の toggle を無視
/// - バックエンド処理失敗時に optimisticIsFavorite をロールバック
@Riverpod(keepAlive: true)
class FavoriteToggle extends _$FavoriteToggle {
  @override
  FavoriteToggleState build() {
    return const FavoriteToggleState();
  }

  /// お気に入り状態をトグルする
  ///
  /// [uri] 対象フォルダの URI
  /// [name] 対象フォルダの表示名
  ///
  /// 処理中の場合は即座にリターンし、連続タップを防止する。
  /// 楽観的UI更新により、バックエンド処理完了前にアイコン状態を切り替える。
  Future<void> toggle({required String uri, required String name}) async {
    // 処理中ロック: 追加の toggle を無視
    if (state.isProcessing) return;

    final repository = ref.read(favoriteRepositoryProvider);

    // 現在のお気に入り状態を取得
    final currentIsFavorite = await repository.isFavorite(uri);

    // 楽観的UI更新: 即座に状態を反転
    final optimisticValue = !currentIsFavorite;
    state = state.copyWith(
      isProcessing: true,
      optimisticIsFavorite: optimisticValue,
      targetUri: uri,
      errorMessage: null,
    );

    try {
      // バックエンド処理を実行
      final useCase = ToggleFavoriteUseCase(repository: repository);
      await useCase.execute(uri: uri, name: name);

      // 成功: 処理中フラグを解除し、楽観的状態をリセット
      // DB が最新化されるため楽観的状態は不要
      state = state.copyWith(
        isProcessing: false,
        optimisticIsFavorite: null,
        targetUri: null,
      );

      // お気に入り一覧を再取得して最新状態に更新
      ref.read(favoriteListProvider.notifier).refresh();
    } on Exception catch (e) {
      // エラー時ロールバック: optimisticIsFavorite を元に戻す
      state = state.copyWith(
        isProcessing: false,
        optimisticIsFavorite: currentIsFavorite,
        targetUri: uri,
        errorMessage: e.toString(),
      );
    }
  }
}
