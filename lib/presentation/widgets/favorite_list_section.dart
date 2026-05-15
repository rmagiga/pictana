/// お気に入りフォルダ一覧セクション ウィジェット
///
/// ストレージ選択画面に配置し、お気に入り登録済みフォルダを
/// 登録日時降順で一覧表示する。空リスト時はプレースホルダーを表示する。
/// スワイプ削除（モバイル）・削除ボタン（デスクトップ）・Undo 機能を提供する。
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/repository_providers.dart';
import '../../application/usecases/favorites/toggle_favorite_usecase.dart';
import '../../domain/entities/favorite_folder.dart';
import '../providers/favorite_helper_providers.dart';
import '../providers/favorite_list_provider.dart';

/// お気に入りフォルダ一覧セクション
///
/// ストレージ選択画面に配置するセクションウィジェット。
/// - 登録日時降順でお気に入りフォルダを表示
/// - フォルダ名が60文字を超える場合は省略記号で切り詰め
/// - 空リスト時はプレースホルダーメッセージを表示
/// - 件数表示「N / 50」フォーマット
/// - スワイプ削除（モバイル）・削除ボタン（デスクトップ）
/// - 削除後に Undo SnackBar を5秒間表示
class FavoriteListSection extends ConsumerWidget {
  /// お気に入りフォルダ一覧セクションを作成する
  ///
  /// [onFolderTap] はフォルダ項目タップ時のコールバック。
  /// 選択されたフォルダの情報を受け取り、ナビゲーション処理を行う。
  const FavoriteListSection({super.key, required this.onFolderTap});

  /// フォルダ項目タップ時のコールバック
  final void Function(FavoriteFolder folder) onFolderTap;

  /// フォルダ名の最大表示文字数
  static const int maxNameLength = 60;

  /// Undo SnackBar の表示時間
  static const Duration undoDuration = Duration(seconds: 5);

  /// 現在のプラットフォームがデスクトップかどうかを判定する
  static bool _isDesktop() {
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

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
  ///
  /// タイトル「お気に入り」と件数表示「N / 50」を横並びで表示する。
  Widget _buildHeader(BuildContext context, AsyncValue<int> countAsync) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'お気に入り',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          countAsync.when(
            data: (count) => Text(
              '$count / ${ToggleFavoriteUseCase.maxFavorites}',
              style: theme.textTheme.bodySmall?.copyWith(
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

  /// お気に入りリスト本体を構築する
  ///
  /// 空リスト時はプレースホルダーメッセージを表示し、
  /// データがある場合は ListView でフォルダ項目を表示する。
  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<FavoriteFolder> favorites,
  ) {
    if (favorites.isEmpty) {
      return _buildEmptyPlaceholder(context);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final folder = favorites[index];
        return _buildDismissibleItem(context, ref, folder, index);
      },
    );
  }

  /// 空リスト時のプレースホルダーを構築する
  Widget _buildEmptyPlaceholder(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Center(
        child: Text(
          'お気に入りフォルダはありません',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  /// Dismissible でラップしたフォルダ項目を構築する
  ///
  /// モバイルではスワイプ削除、デスクトップでは削除ボタンを提供する。
  Widget _buildDismissibleItem(
    BuildContext context,
    WidgetRef ref,
    FavoriteFolder folder,
    int index,
  ) {
    return Dismissible(
      key: ValueKey(folder.uri),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(context),
      confirmDismiss: (_) async {
        // スワイプ完了時に削除を実行
        await _deleteFavorite(context, ref, folder, index);
        // Dismissible 自体のアニメーションは使わず、Provider の refresh で更新する
        return false;
      },
      child: _buildFolderItem(context, ref, folder),
    );
  }

  /// スワイプ時の背景（赤色 + 削除アイコン）を構築する
  Widget _buildDismissBackground(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.error,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
    );
  }

  /// フォルダ項目を構築する
  ///
  /// フォルダ名が [maxNameLength] 文字を超える場合は
  /// 先頭60文字に省略記号（…）を付加して表示する。
  /// デスクトップ環境では trailing に削除ボタンを表示する。
  Widget _buildFolderItem(
    BuildContext context,
    WidgetRef ref,
    FavoriteFolder folder,
  ) {
    final displayName = truncateName(folder.name);

    return ListTile(
      leading: const Icon(Icons.folder_outlined),
      title: Text(displayName, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: _isDesktop()
          ? IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: '削除',
              onPressed: () => _deleteFavorite(context, ref, folder, null),
            )
          : null,
      onTap: () => onFolderTap(folder),
    );
  }

  /// お気に入りを削除し、Undo SnackBar を表示する
  ///
  /// 削除処理を実行し、成功時は Undo アクション付き SnackBar を5秒間表示する。
  /// Undo 実行時は元の位置にフォルダを復元する。
  /// 削除失敗時はエラーメッセージを表示し、リストを復元する。
  Future<void> _deleteFavorite(
    BuildContext context,
    WidgetRef ref,
    FavoriteFolder folder,
    int? index,
  ) async {
    final repository = ref.read(favoriteRepositoryProvider);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;

    try {
      // お気に入りを削除
      await repository.removeFavorite(folder.uri);

      // リストを更新
      await ref.read(favoriteListProvider.notifier).refresh();

      // 既存の SnackBar を閉じてから新しいものを表示
      scaffoldMessenger.hideCurrentSnackBar();

      // Undo SnackBar を表示
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text('お気に入りから削除しました'),
          duration: undoDuration,
          action: SnackBarAction(
            label: '元に戻す',
            onPressed: () async {
              await _undoDelete(ref, folder);
            },
          ),
        ),
      );
    } catch (e) {
      // 削除失敗時はエラーメッセージを表示し、リストを復元
      await ref.read(favoriteListProvider.notifier).refresh();

      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('削除に失敗しました: $e'), backgroundColor: errorColor),
      );
    }
  }

  /// 削除を取り消し、フォルダを元の位置に復元する
  ///
  /// 削除されたフォルダを再登録し、お気に入りリストを更新する。
  Future<void> _undoDelete(WidgetRef ref, FavoriteFolder folder) async {
    final repository = ref.read(favoriteRepositoryProvider);

    try {
      // フォルダを再登録
      await repository.addFavorite(uri: folder.uri, name: folder.name);

      // リストを更新
      await ref.read(favoriteListProvider.notifier).refresh();
    } catch (e) {
      // Undo 失敗時は静かに失敗（リストは次回 refresh で最新状態になる）
    }
  }

  /// フォルダ名を切り詰める
  ///
  /// [name] が60文字以下であればそのまま返し、
  /// 60文字を超える場合は先頭60文字に省略記号（…）を付加する。
  static String truncateName(String name) {
    if (name.length > maxNameLength) {
      return '${name.substring(0, maxNameLength)}…';
    }
    return name;
  }
}
