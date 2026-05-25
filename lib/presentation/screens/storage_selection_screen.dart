/// ホーム画面（旧 StorageSelection 画面）
///
/// アプリのホーム画面として機能し、お気に入りフォルダ一覧を表示する。
/// AppBar のフォルダ選択ボタンからシステムフォルダ選択ダイアログを起動する。
/// お気に入りが0件の場合は中央にオンボーディング用のフォルダ選択ボタンを表示する。
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/logging/app_logger.dart';
import '../../domain/entities/folder_entry.dart';
import '../../domain/entities/image_entry.dart';
import '../../router/app_router.dart';
import '../../application/providers/repository_providers.dart';
import '../providers/favorite_list_provider.dart';
import '../providers/favorite_navigation_provider.dart';
import '../providers/gallery_providers.dart';
import '../providers/storage_providers.dart';
import '../providers/viewer_providers.dart';
import '../widgets/favorite_grid_section.dart';
import '../widgets/favorite_navigation_handler.dart';
import '../widgets/image_grid_tile.dart';

/// ホーム画面
///
/// - AppBar にフォルダ選択アイコンボタンを配置
/// - body: お気に入りグリッド（FavoriteGridSection）
/// - お気に入り0件時: 中央にオンボーディングボタンを表示
class StorageSelectionScreen extends ConsumerStatefulWidget {
  const StorageSelectionScreen({super.key});

  @override
  ConsumerState<StorageSelectionScreen> createState() => _StorageSelectionScreenState();
}

class _StorageSelectionScreenState extends ConsumerState<StorageSelectionScreen> {
  late final ScrollController _mainScrollController;
  late final ScrollController _foldersScrollController;
  late final ScrollController _imagesScrollController;

  @override
  void initState() {
    super.initState();
    _mainScrollController = ScrollController();
    _foldersScrollController = ScrollController();
    _imagesScrollController = ScrollController();
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    _foldersScrollController.dispose();
    _imagesScrollController.dispose();
    super.dispose();
  }

  /// フォルダ選択処理
  Future<void> _selectFolder(BuildContext context) async {
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

  /// 最近開いたフォルダのナビゲーション処理
  Future<void> _handleRecentFolderNavigation(
    BuildContext context,
    FolderEntry folder,
  ) async {
    final navigationNotifier = ref.read(favoriteNavigationStateProvider.notifier);
    if (ref.read(favoriteNavigationStateProvider)) return;

    navigationNotifier.setNavigating(true);
    try {
      final useCase = ref.read(navigateToRecentFolderUseCaseProvider);
      final folderEntry = await useCase.execute(folder: folder);
      if (!context.mounted) return;

      ref.read(currentFolderProvider.notifier).setFolder(folderEntry);
      context.go(AppRoutes.galleryGrid);
    } catch (e) {
      if (!context.mounted) return;
      // フォルダにアクセスできない場合の確認ダイアログ
      final deleteConfirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('フォルダにアクセスできません'),
          content: Text(
            '「${folder.name}」を開けませんでした。\n'
            'ストレージが切断されているか、削除されている可能性があります。\n\n'
            '履歴から削除しますか？\n(詳細: $e)',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('削除'),
            ),
          ],
        ),
      );
      if (deleteConfirm == true && context.mounted) {
        await ref.read(recentFoldersListProvider.notifier).removeRecent(folder.uri);
      }
    } finally {
      navigationNotifier.setNavigating(false);
    }
  }

  /// 最近開いたフォルダを履歴から削除する
  Future<void> _deleteRecentFolder(FolderEntry folder) async {
    await ref.read(recentFoldersListProvider.notifier).removeRecent(folder.uri);
  }

  /// 最近見た画像を履歴から削除する
  Future<void> _deleteRecentImage(ImageEntry image) async {
    await ref.read(recentImagesListProvider.notifier).removeRecent(image.id.rawValue);
  }

  @override
  Widget build(BuildContext context) {
    final favoritesAsync = ref.watch(favoriteListProvider);
    final recentFoldersAsync = ref.watch(recentFoldersListProvider);
    final recentImagesAsync = ref.watch(recentImagesListProvider);

    final favorites = favoritesAsync.value ?? [];
    final recentFolders = recentFoldersAsync.value ?? [];
    final recentImages = recentImagesAsync.value ?? [];

    final hasFavorites = favorites.isNotEmpty;
    final hasRecentFolders = recentFolders.isNotEmpty;
    final hasRecentImages = recentImages.isNotEmpty;

    final hasContent = hasFavorites || hasRecentFolders || hasRecentImages;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pictana'),
        centerTitle: true,
        actions: [
          // フォルダ選択ボタン
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'フォルダを選択',
            onPressed: () => _selectFolder(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: '設定',
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: hasContent
          ? FavoriteNavigationHandler(
              child: Scrollbar(
                controller: _mainScrollController,
                child: SingleChildScrollView(
                  controller: _mainScrollController,
                  padding: EdgeInsets.only(
                    top: 8.0,
                    bottom: 24.0 + MediaQuery.of(context).viewPadding.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 最近開いたフォルダセクション
                      if (hasRecentFolders)
                        _buildRecentFolders(context, recentFolders),

                      // 最近見た画像セクション
                      if (hasRecentImages)
                        _buildRecentImages(context, recentImages),

                      // お気に入りフォルダセクション
                      if (hasFavorites) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Text(
                            'お気に入りフォルダ',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        FavoriteGridSection(
                          onFolderTap: (folder) =>
                              handleFavoriteNavigation(context, ref, folder),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            )
          : _buildOnboarding(context),
    );
  }

  /// 最近開いたフォルダリスト UI の構築
  Widget _buildRecentFolders(
    BuildContext context,
    List<FolderEntry> folders,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text('最近開いたフォルダ', style: theme.textTheme.titleMedium),
        ),
        SizedBox(
          height: 112, // スクロールバーの分少し高さを確保
          child: Scrollbar(
            controller: _foldersScrollController,
            thumbVisibility: true,
            notificationPredicate: (notification) => notification.depth == 0,
            child: ListView.builder(
              controller: _foldersScrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              itemCount: folders.length,
              itemBuilder: (context, index) {
                final folder = folders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      InkWell(
                        onTap: () => _handleRecentFolderNavigation(context, folder),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 140,
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder,
                                size: 36,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                folder.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _deleteRecentFolder(folder),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  /// 最近見た画像リスト UI の構築
  Widget _buildRecentImages(
    BuildContext context,
    List<ImageEntry> images,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text('最近見た画像', style: theme.textTheme.titleMedium),
        ),
        SizedBox(
          height: 144, // スクロールバーの分少し高さを確保 (130dp -> 144dp)
          child: Scrollbar(
            controller: _imagesScrollController,
            thumbVisibility: true,
            notificationPredicate: (notification) => notification.depth == 0,
            child: ListView.builder(
              controller: _imagesScrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final image = images[index];
                return Container(
                  width: 100,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: ImageGridTile(
                                  image: image,
                                  onTap: () async {
                                    final database = ref.read(appDatabaseProvider);
                                    final dbImage = await database.getImageByEntryId(
                                      image.id.rawValue,
                                    );
                                    final folderUri = dbImage?.folderUri ?? '';
                                    if (folderUri.isNotEmpty && context.mounted) {
                                      final storageRepo = ref.read(storageRepositoryProvider);
                                      final restoredFolder = storageRepo.restoreFolderFromUri(
                                        uri: folderUri,
                                        name: folderUri.split(Platform.pathSeparator).last,
                                      );
                                      // ビューア自動遷移用 ID をセット
                                      ref
                                          .read(pendingViewerEntryIdProvider.notifier)
                                          .set(image.id.rawValue);
                                      ref
                                          .read(currentFolderProvider.notifier)
                                          .setFolder(restoredFolder);
                                      context.go(AppRoutes.galleryGrid);
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('画像のフォルダ情報が見つかりません。'),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _deleteRecentImage(image),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(128),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4.0),
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        image.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  /// お気に入りが0件の場合のオンボーディング画面
  Widget _buildOnboarding(BuildContext context) {
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
              onPressed: () => _selectFolder(context),
              icon: const Icon(Icons.folder_open),
              label: const Text('フォルダを選択'),
            ),
          ],
        ),
      ),
    );
  }
}
