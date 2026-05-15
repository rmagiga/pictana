/// お気に入りフォルダへのナビゲーション処理ハンドラー
///
/// お気に入りリストのフォルダタップ時に以下の処理を実行する:
/// - ローディングインジケーター表示・追加タップ無効化
/// - NavigateToFavoriteUseCase によるアクセス確認
/// - 成功時: ギャラリー画面へ遷移
/// - 失敗時: アクセス不可ダイアログ表示（削除/保持の選択肢）
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers/repository_providers.dart';
import '../../core/errors/favorite_exceptions.dart';
import '../../domain/entities/favorite_folder.dart';
import '../../router/app_router.dart';
import '../providers/favorite_list_provider.dart';
import '../providers/favorite_navigation_provider.dart';
import '../providers/gallery_providers.dart';

/// お気に入りフォルダへのナビゲーション処理を提供するウィジェット
///
/// [FavoriteGridSection] の onFolderTap コールバックとして使用する
/// ナビゲーションロジックを子ウィジェットに提供する。
/// ローディング中はオーバーレイインジケーターを表示し、
/// 追加タップを無効化する。
class FavoriteNavigationHandler extends ConsumerWidget {
  /// ナビゲーションハンドラーを作成する
  const FavoriteNavigationHandler({super.key, required this.child});

  /// 子ウィジェット
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNavigating = ref.watch(favoriteNavigationStateProvider);

    return Stack(
      fit: StackFit.passthrough,
      children: [
        // 子ウィジェット（ナビゲーション中はタップ無効化）
        AbsorbPointer(absorbing: isNavigating, child: child),
        // ローディングオーバーレイ
        if (isNavigating)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x33000000),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}

/// お気に入りフォルダタップ時のナビゲーション処理を実行する
///
/// [context] と [ref] は呼び出し元のウィジェットから取得する。
/// [folder] はタップされたお気に入りフォルダ。
///
/// 処理フロー:
/// 1. ローディング状態を有効化
/// 2. NavigateToFavoriteUseCase でアクセス確認
/// 3. 成功: currentFolderProvider にフォルダを設定し、ギャラリー画面へ遷移
/// 4. FolderAccessException: アクセス不可ダイアログを表示
/// 5. ローディング状態を無効化
Future<void> handleFavoriteNavigation(
  BuildContext context,
  WidgetRef ref,
  FavoriteFolder folder,
) async {
  final navigationNotifier = ref.read(favoriteNavigationStateProvider.notifier);

  // 既にナビゲーション中の場合は無視
  if (ref.read(favoriteNavigationStateProvider)) return;

  navigationNotifier.setNavigating(true);

  try {
    final useCase = ref.read(navigateToFavoriteUseCaseProvider);
    final folderEntry = await useCase.execute(favorite: folder);

    if (!context.mounted) return;

    // 成功: フォルダを設定してギャラリー画面へ遷移
    ref.read(currentFolderProvider.notifier).setFolder(folderEntry);
    context.go(AppRoutes.galleryGrid);
  } on FolderAccessException catch (e) {
    if (!context.mounted) return;

    // アクセス不可ダイアログを表示
    await _showFolderAccessErrorDialog(context, ref, folder, e);
  } catch (e) {
    if (!context.mounted) return;

    // 予期しないエラー
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('フォルダへの遷移に失敗しました: $e')));
  } finally {
    navigationNotifier.setNavigating(false);
  }
}

/// フォルダアクセス不可時のダイアログを表示する
///
/// ユーザーに以下の選択肢を提示する:
/// - 「削除」: お気に入りリストから該当フォルダを削除し、リストを更新
/// - 「保持」: ダイアログを閉じ、お気に入りリスト画面に留まる
Future<void> _showFolderAccessErrorDialog(
  BuildContext context,
  WidgetRef ref,
  FavoriteFolder folder,
  FolderAccessException exception,
) async {
  final result = await showDialog<_AccessErrorAction>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      title: const Text('フォルダにアクセスできません'),
      content: Text(
        '「${folder.name}」にアクセスできません。\n'
        'フォルダが削除されたか、ストレージが切断されている可能性があります。\n\n'
        'お気に入りリストから削除しますか？',
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(dialogContext).pop(_AccessErrorAction.keep),
          child: const Text('保持'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(dialogContext).pop(_AccessErrorAction.remove),
          child: const Text('削除'),
        ),
      ],
    ),
  );

  if (!context.mounted) return;

  if (result == _AccessErrorAction.remove) {
    // お気に入りから削除してリストを更新
    final repository = ref.read(favoriteRepositoryProvider);
    await repository.removeFavorite(folder.uri);
    ref.read(favoriteListProvider.notifier).refresh();
  }
}

/// アクセスエラーダイアログのアクション
enum _AccessErrorAction {
  /// お気に入りリストから削除
  remove,

  /// お気に入りリストに保持
  keep,
}
