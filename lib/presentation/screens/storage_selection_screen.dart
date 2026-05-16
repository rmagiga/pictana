/// StorageSelection画面（リデザイン版）
///
/// ユーザーが明示的に開くフォルダを選択する画面。
/// お気に入りフォルダ一覧をレスポンシブグリッドで表示し、
/// FAB（Floating Action Button）でフォルダ選択を行う。
/// 空状態時はプレースホルダーを中央表示する。
/// Android セーフエリア対応を含む。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/logging/app_logger.dart';
import '../../router/app_router.dart';
import '../providers/gallery_providers.dart';
import '../providers/storage_providers.dart';
import '../widgets/favorite_grid_section.dart';
import '../widgets/favorite_navigation_handler.dart';

/// ストレージ選択画面
///
/// - Scaffold + FAB パターン
/// - body: お気に入りグリッド（FavoriteGridSection）
/// - FAB: filled extended FAB、folder-open アイコン、ラベル「フォルダを選択」
/// - FAB 位置: bottom-right、16dp margin、elevation 6dp
/// - Android セーフエリア対応: viewPadding.bottom を考慮
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
    final viewPadding = MediaQuery.viewPaddingOf(context);
    // ジェスチャーナビゲーション時の追加パディング
    final bottomSafeArea = viewPadding.bottom;
    final hasGestureNav = bottomSafeArea > 0;
    final fabBottomMargin = hasGestureNav ? bottomSafeArea + 24.0 : 16.0;

    return Scaffold(
      appBar: AppBar(title: const Text('フォルダを選択'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.only(
          top: 16.0,
          // グリッド下部: ナビゲーションバー高さ + FAB 分の余白
          bottom: bottomSafeArea + 80.0,
        ),
        child: FavoriteNavigationHandler(
          child: FavoriteGridSection(
            onFolderTap: (folder) =>
                handleFavoriteNavigation(context, ref, folder),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: fabBottomMargin),
        child: FloatingActionButton.extended(
          onPressed: () => _selectFolder(context, ref),
          elevation: 6,
          icon: const Icon(Icons.folder_open),
          label: const Text('フォルダを選択'),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
