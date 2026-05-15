/// お気に入りフォルダグリッドセクション ウィジェット
///
/// ストレージ選択画面に配置し、お気に入り登録済みフォルダを
/// 登録日時降順でグリッド形式に表示する。
/// 画面幅に応じてレスポンシブに列数を調整し、
/// 空リスト時はプレースホルダー、ローディング中はインジケーターを表示する。
/// 長押し/右クリックによるコンテキストメニューから削除操作を実行し、
/// Undo SnackBar による復元機能を提供する。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/repository_providers.dart';
import '../../application/usecases/favorites/toggle_favorite_usecase.dart';
import '../../core/utils/grid_utils.dart';
import '../../domain/entities/favorite_folder.dart';
import '../providers/favorite_helper_providers.dart';
import '../providers/favorite_list_provider.dart';
import 'folder_card.dart';

/// お気に入りフォルダグリッドセクション
///
/// ストレージ選択画面に配置するセクションウィジェット。
/// - 登録日時降順でお気に入りフォルダをグリッド表示
/// - 画面幅に応じたレスポンシブ列数（2/3/4列）
/// - 空リスト時はプレースホルダー（フォルダアイコン + メッセージ）
/// - ローディング中は [CircularProgressIndicator]
/// - セクションヘッダーに「お気に入り」タイトル + 件数「N / 50」表示
/// - 長押し/右クリックでコンテキストメニュー（削除）を表示
/// - 削除実行時は楽観的にグリッドから除去し、Undo SnackBar を5秒間表示
class FavoriteGridSection extends ConsumerWidget {
  /// お気に入りフォルダグリッドセクションを作成する
  ///
  /// [onFolderTap] はフォルダカードタップ時のコールバック。
  /// 選択されたフォルダの情報を受け取り、ナビゲーション処理を行う。
  const FavoriteGridSection({super.key, required this.onFolderTap});

  /// フォルダカードタップ時のコールバック
  final void Function(FavoriteFolder folder) onFolderTap;

  /// グリッドアイテム間の間隔
  static const double _gridSpacing = 8.0;

  /// グリッドの左右パディング
  static const double _horizontalPadding = 16.0;

  /// 空状態のフォルダアイコンサイズ
  static const double _emptyIconSize = 64.0;

  /// Undo SnackBar の表示時間
  static const Duration _undoDuration = Duration(seconds: 5);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteListProvider);
    final countAsync = ref.watch(favoriteCountProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // セクションヘッダー
        _buildHeader(context, countAsync),
        const SizedBox(height: 8),
        // お気に入りグリッド本体
        favoritesAsync.when(
          data: (favorites) => _buildGrid(context, ref, favorites),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'お気に入りの読み込みに失敗しました',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
      ],
    );
  }

  /// セクションヘッダーを構築する
  ///
  /// タイトル「お気に入り」と件数表示「N / 50」を横並びで表示する。
  /// 件数データの取得に失敗した場合は件数表示を非表示にする。
  Widget _buildHeader(BuildContext context, AsyncValue<int> countAsync) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Row(
        children: [
          Text(
            'お気に入り',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          countAsync.when(
            data: (count) => Text(
              '$count / ${ToggleFavoriteUseCase.maxFavorites}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// グリッド本体を構築する
  ///
  /// 空リスト時はプレースホルダーを表示し、
  /// データがある場合は [GridView.builder] でフォルダカードを表示する。
  Widget _buildGrid(
    BuildContext context,
    WidgetRef ref,
    List<FavoriteFolder> favorites,
  ) {
    if (favorites.isEmpty) {
      return _buildEmptyPlaceholder(context);
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final crossAxisCount = calculateGridColumns(screenWidth);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: _gridSpacing,
        mainAxisSpacing: _gridSpacing,
        childAspectRatio: 1.0,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final folder = favorites[index];
        return FolderCard(
          folder: folder,
          onTap: () => onFolderTap(folder),
          onDelete: () => _deleteFavorite(context, ref, folder),
        );
      },
    );
  }

  /// 空リスト時のプレースホルダーを構築する
  ///
  /// フォルダアイコンと「お気に入りフォルダはありません」メッセージを
  /// 中央揃えで表示する。
  Widget _buildEmptyPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_open,
              size: _emptyIconSize,
              color: onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'お気に入りフォルダはありません',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// お気に入りを削除し、Undo SnackBar を表示する
  ///
  /// 削除処理を実行し、成功時は Undo アクション付き SnackBar を5秒間表示する。
  /// Undo 実行時はフォルダを復元しグリッドに再表示する。
  /// 削除失敗時はグリッドを復元しエラー SnackBar を表示する。
  Future<void> _deleteFavorite(
    BuildContext context,
    WidgetRef ref,
    FavoriteFolder folder,
  ) async {
    final repository = ref.read(favoriteRepositoryProvider);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;

    try {
      // お気に入りを削除
      await repository.removeFavorite(folder.uri);

      // リストを更新（グリッドから即座に除去）
      await ref.read(favoriteListProvider.notifier).refresh();

      // 既存の SnackBar を閉じてから新しいものを表示
      scaffoldMessenger.hideCurrentSnackBar();

      // Undo SnackBar を表示（5秒間）
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text('お気に入りから削除しました'),
          duration: _undoDuration,
          action: SnackBarAction(
            label: '元に戻す',
            onPressed: () async {
              await _undoDelete(ref, folder);
            },
          ),
        ),
      );
    } catch (e) {
      // 削除失敗時はグリッドを復元しエラー SnackBar を表示
      await ref.read(favoriteListProvider.notifier).refresh();

      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(content: const Text('削除に失敗しました'), backgroundColor: errorColor),
      );
    }
  }

  /// 削除を取り消し、フォルダを復元する
  ///
  /// 削除されたフォルダを再登録し、お気に入りリストを更新してグリッドに再表示する。
  Future<void> _undoDelete(WidgetRef ref, FavoriteFolder folder) async {
    final repository = ref.read(favoriteRepositoryProvider);

    try {
      // フォルダを再登録
      await repository.addFavorite(uri: folder.uri, name: folder.name);

      // リストを更新（グリッドに再表示）
      await ref.read(favoriteListProvider.notifier).refresh();
    } catch (e) {
      // Undo 失敗時は静かに失敗（次回 refresh で最新状態になる）
    }
  }
}
