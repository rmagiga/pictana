/// お気に入りフォルダリストセクション ウィジェット
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/repository_providers.dart';
import '../../application/usecases/favorites/toggle_favorite_usecase.dart';
import '../../domain/entities/favorite_folder.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../providers/favorite_helper_providers.dart';
import '../providers/favorite_list_provider.dart';
import 'thumbnail_overlay.dart';

/// お気に入りフォルダリストセクション
///
/// ホーム画面に配置するセクションウィジェット。
/// - お気に入りフォルダを登録日時降順でコンパクトなリスト形式で表示
/// - 各項目にフォルダアイコン、名前、パス、お気に入り解除ボタンを配置
/// - 空リスト時はプレースホルダーを表示
/// - ローディング中は [CircularProgressIndicator]
/// - セクションヘッダーに「お気に入り」タイトル + 件数「N / 50」表示
/// - 右端の星アイコンタップまたは長押し/右クリックで削除を実行
/// - 削除実行時は楽観的にリストから除去し、Undo SnackBar を5秒間表示
class FavoriteListSection extends ConsumerWidget {
  /// お気に入りフォルダリストセクションを作成する
  const FavoriteListSection({super.key, required this.onFolderTap});

  /// フォルダタップ時のコールバック
  final void Function(FavoriteFolder folder) onFolderTap;

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
        // お気に入りリスト本体
        favoritesAsync.when(
          data: (favorites) => _buildList(context, ref, favorites),
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
  Widget _buildHeader(BuildContext context, AsyncValue<int> countAsync) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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

  /// リスト本体を構築する
  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<FavoriteFolder> favorites,
  ) {
    if (favorites.isEmpty) {
      return _buildEmptyPlaceholder(context);
    }

    final theme = Theme.of(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisExtent: 200,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final folder = favorites[index];
        return GestureDetector(
          onSecondaryTapUp: (details) => _showContextMenu(context, ref, details.globalPosition, folder),
          onLongPressStart: (details) => _showContextMenu(context, ref, details.globalPosition, folder),
          child: Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                InkWell(
                  onTap: () => onFolderTap(folder),
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox.expand(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 上半分: サムネイル画像
                        SizedBox(
                          height: 110,
                          width: double.infinity,
                          child: ThumbnailOverlay(
                            uri: folder.uri,
                            name: folder.name,
                          ),
                        ),
                        // 下半分: フォルダ情報
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  folder.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  folder.uri,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 右上のお気に入り解除ボタン（星アイコン）
                Positioned(
                  top: 6,
                  right: 6,
                  child: Tooltip(
                    message: 'お気に入り解除',
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _deleteFavorite(context, ref, folder),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 空リスト時のプレースホルダーを構築する
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
              Icons.folder_open_rounded,
              size: 48,
              color: onSurfaceVariant,
            ),
            const SizedBox(height: 12),
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

  /// コンテキストメニューを表示する
  Future<void> _showContextMenu(
    BuildContext context,
    WidgetRef ref,
    Offset position,
    FavoriteFolder folder,
  ) async {
    final renderBox = Overlay.of(context).context.findRenderObject() as RenderBox;
    final overlaySize = renderBox.size;

    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        overlaySize.width - position.dx,
        overlaySize.height - position.dy,
      ),
      items: [
        const PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline),
              SizedBox(width: 12),
              Text('お気に入りから削除'),
            ],
          ),
        ),
      ],
    );

    if (result == 'delete' && context.mounted) {
      _deleteFavorite(context, ref, folder);
    }
  }

  /// お気に入りを削除し、Undo SnackBar を表示する
  Future<void> _deleteFavorite(
    BuildContext context,
    WidgetRef ref,
    FavoriteFolder folder,
  ) async {
    final repository = ref.read(favoriteRepositoryProvider);
    final notifier = ref.read(favoriteListProvider.notifier);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;

    try {
      // お気に入りを削除
      await repository.removeFavorite(folder.uri);

      // リストを更新（即座に除去）
      await notifier.refresh();

      scaffoldMessenger.hideCurrentSnackBar();

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('「${folder.name}」をお気に入りから削除しました'),
          duration: _undoDuration,
          showCloseIcon: true,
          action: SnackBarAction(
            label: '元に戻す',
            onPressed: () async {
              await _undoDelete(repository, notifier, folder);
            },
          ),
        ),
      );
    } catch (e) {
      await notifier.refresh();
      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(content: const Text('削除に失敗しました'), backgroundColor: errorColor),
      );
    }
  }

  /// 削除を取り消し、フォルダを復元する
  Future<void> _undoDelete(
    FavoriteRepository repository,
    FavoriteList notifier,
    FavoriteFolder folder,
  ) async {
    try {
      await repository.addFavorite(uri: folder.uri, name: folder.name);
      await notifier.refresh();
    } catch (_) {}
  }
}
