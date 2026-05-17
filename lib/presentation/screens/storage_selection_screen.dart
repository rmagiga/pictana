/// ホーム画面（旧 StorageSelection 画面）
///
/// アプリのホーム画面として機能し、お気に入りフォルダ一覧を表示する。
/// AppBar のフォルダ選択ボタンからシステムフォルダ選択ダイアログを起動する。
/// お気に入りが0件の場合は中央にオンボーディング用のフォルダ選択ボタンを表示する。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/logging/app_logger.dart';
import '../../router/app_router.dart';
import '../providers/favorite_list_provider.dart';
import '../providers/gallery_providers.dart';
import '../providers/storage_providers.dart';
import '../widgets/favorite_grid_section.dart';
import '../widgets/favorite_navigation_handler.dart';

/// ホーム画面
///
/// - AppBar にフォルダ選択アイコンボタンを配置
/// - body: お気に入りグリッド（FavoriteGridSection）
/// - お気に入り0件時: 中央にオンボーディングボタンを表示
class StorageSelectionScreen extends ConsumerWidget {
  const StorageSelectionScreen({super.key});

  /// フォルダ選択処理
  Future<void> _selectFolder(BuildContext context, WidgetRef ref) async {
    try {
      final useCase = ref.read(selectStorageUseCaseProvider);
      final folder = await useCase.execute();

      if (folder != null) {
        // 選択されたフォルダをセットしてギャラリーへ
        ref.read(currentFolderProvider.notifier).setFolder(folder);
        if (context.mounted) {
          context.go(AppRoutes.galleryGrid);
        }
      }
    } catch (e) {
      appLogger.e('フォルダ選択エラー', error: e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('フォルダの選択に失敗しました。再度お試しください。')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteListProvider);
    final hasFavorites = (favoritesAsync.value ?? []).isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pictana'),
        centerTitle: true,
        actions: [
          // フォルダ選択ボタン
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'フォルダを選択',
            onPressed: () => _selectFolder(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: '設定',
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: hasFavorites
          ? SingleChildScrollView(
              padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
              child: FavoriteNavigationHandler(
                child: FavoriteGridSection(
                  onFolderTap: (folder) =>
                      handleFavoriteNavigation(context, ref, folder),
                ),
              ),
            )
          : _buildOnboarding(context, ref),
    );
  }

  /// お気に入りが0件の場合のオンボーディング画面
  ///
  /// 中央にフォルダアイコンと説明テキスト、フォルダ選択ボタンを表示する。
  Widget _buildOnboarding(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open, size: 80, color: onSurfaceVariant),
            const SizedBox(height: 24),
            Text(
              'フォルダを選択して画像を閲覧しましょう',
              style: theme.textTheme.titleMedium?.copyWith(
                color: onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _selectFolder(context, ref),
              icon: const Icon(Icons.folder_open),
              label: const Text('フォルダを選択'),
            ),
          ],
        ),
      ),
    );
  }
}
