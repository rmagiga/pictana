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
import 'package:path/path.dart' as p;
import 'package:desktop_drop/desktop_drop.dart';

import '../../core/logging/app_logger.dart';
import '../../core/utils/datetime_utils.dart';
import '../../domain/entities/folder_entry.dart';
import '../../domain/entities/image_entry.dart';
import '../../router/app_router.dart';
import '../../application/providers/repository_providers.dart';
import '../../application/usecases/settings/show_recent_images_setting.dart';
import '../providers/favorite_list_provider.dart';
import '../providers/favorite_navigation_provider.dart';
import '../providers/gallery_providers.dart';
import '../providers/storage_providers.dart';
import '../providers/viewer_providers.dart';
import '../widgets/favorite_list_section.dart';
import '../widgets/favorite_navigation_handler.dart';
import '../widgets/image_grid_tile.dart';
import '../widgets/thumbnail_overlay.dart';
import '../../application/usecases/favorites/toggle_favorite_usecase.dart';
import '../providers/favorite_helper_providers.dart';
import '../providers/favorite_toggle_provider.dart';
import '../providers/favorite_toggle_state.dart';

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
  bool _isDragging = false;

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
    ref.listen<FavoriteToggleState>(favoriteToggleProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        final isLimit = next.errorMessage!.contains('FavoriteLimitExceededException');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isLimit
                  ? 'お気に入り登録上限（${ToggleFavoriteUseCase.maxFavorites}件）に達しました。'
                  : 'お気に入り登録に失敗しました。',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    final favoritesAsync = ref.watch(favoriteListProvider);
    final recentFoldersAsync = ref.watch(recentFoldersListProvider);
    final recentImagesAsync = ref.watch(recentImagesListProvider);
    final showRecentImages = ref.watch(showRecentImagesSettingProvider);

    final favorites = favoritesAsync.value ?? [];
    final recentFolders = recentFoldersAsync.value ?? [];
    final recentImages = recentImagesAsync.value ?? [];

    final hasFavorites = favorites.isNotEmpty;
    final hasRecentFolders = recentFolders.isNotEmpty;
    final hasRecentImages = recentImages.isNotEmpty;

    final hasContent = hasFavorites || hasRecentFolders || (showRecentImages && hasRecentImages);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pictana'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: '設定',
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: FavoriteNavigationHandler(
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
                // 主CTA（フォルダを開く）
                _buildPrimaryCTA(context),

                if (!hasContent)
                  _buildEmptyState(context)
                else ...[
                  // 最近開いたフォルダセクション
                  if (hasRecentFolders)
                    _buildRecentFolders(context, recentFolders),

                  // お気に入りフォルダセクション
                  if (hasFavorites)
                    FavoriteListSection(
                      onFolderTap: (folder) =>
                          handleFavoriteNavigation(context, ref, folder),
                    ),

                  // 最近見た画像セクション
                  if (showRecentImages && hasRecentImages)
                    _buildRecentImages(context, recentImages),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 主CTA「フォルダを開く」エリアの構築
  Widget _buildPrimaryCTA(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = Platform.isWindows;

    Widget child = Material(
      color: _isDragging
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2)
          : theme.colorScheme.primaryContainer.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _selectFolder(context),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isDragging
                  ? theme.colorScheme.primary
                  : theme.colorScheme.primary.withValues(alpha: 0.2),
              width: _isDragging ? 2.5 : 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.folder_open_rounded,
                size: 40,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'フォルダを開く',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isDesktop
                    ? '画像が含まれるフォルダを選択、またはここにドラッグ＆ドロップして表示します'
                    : '画像が含まれるフォルダを選択してギャラリーを表示します',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );

    if (isDesktop) {
      child = DropTarget(
        onDragEntered: (details) {
          setState(() {
            _isDragging = true;
          });
        },
        onDragExited: (details) {
          setState(() {
            _isDragging = false;
          });
        },
        onDragDone: (details) async {
          setState(() {
            _isDragging = false;
          });
          if (details.files.isNotEmpty) {
            final file = details.files.first;
            final path = file.path;
            final isDir = await FileSystemEntity.isDirectory(path);
            if (isDir) {
              try {
                final storageRepo = ref.read(storageRepositoryProvider);
                final folder = storageRepo.restoreFolderFromUri(
                  uri: path,
                  name: p.basename(path).isEmpty ? path : p.basename(path),
                );
                // 選択されたフォルダをセットしてギャラリーへ
                ref.read(currentFolderProvider.notifier).setFolder(folder);
                if (context.mounted) {
                  context.go(AppRoutes.galleryGrid);
                }
              } catch (e) {
                appLogger.e('ドラッグ＆ドロップフォルダ設定エラー', error: e);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('フォルダの読み込みに失敗しました。')),
                  );
                }
              }
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('フォルダのみドロップ可能です。')),
                );
              }
            }
          }
        },
        child: child,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: child,
    );
  }

  /// 空状態のメッセージ表示
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 32.0),
      child: Center(
        child: Text(
          '履歴やお気に入りはありません。\n上の「フォルダを開く」から画像フォルダを選択してください。',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// 最近開いたフォルダリスト UI の構築
  Widget _buildRecentFolders(
    BuildContext context,
    List<FolderEntry> folders,
  ) {
    final theme = Theme.of(context);
    final displayFolders = folders.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            '最近開いたフォルダ',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 215, // 高さを拡張してサムネイルとスクロールバーを綺麗に収める
          child: Scrollbar(
            controller: _foldersScrollController,
            thumbVisibility: true,
            notificationPredicate: (notification) => notification.depth == 0,
            child: ListView.builder(
              controller: _foldersScrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              itemCount: displayFolders.length,
              itemBuilder: (context, index) {
                final folder = displayFolders[index];
                final relativeTime = folder.lastOpenedAt != null
                    ? formatRelativeTime(folder.lastOpenedAt!)
                    : '';
                final imageCountText = folder.imageCountLabel;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias, // サムネイルが角丸にクリップされるように指定
                  child: Stack(
                    children: [
                      InkWell(
                        onTap: () => _handleRecentFolderNavigation(context, folder),
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 180,
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
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            imageCountText.isNotEmpty ? imageCountText : '— 枚',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                          if (relativeTime.isNotEmpty)
                                            Text(
                                              relativeTime,
                                              style: theme.textTheme.labelSmall?.copyWith(
                                                color: theme.colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // お気に入り登録/解除ボタン（閉じるボタンの左）
                      Positioned(
                        top: 6,
                        right: 36,
                        child: Consumer(
                          builder: (context, ref, child) {
                            final toggleState = ref.watch(favoriteToggleProvider);
                            final actualFavoriteAsync = ref.watch(isFolderFavoriteProvider(folder.uri));

                            final optimistic = toggleState.targetUri == folder.uri
                                ? toggleState.optimisticIsFavorite
                                : null;
                            final isFavorite = optimistic ??
                                actualFavoriteAsync.whenOrNull(data: (value) => value) ??
                                false;

                            final label = isFavorite ? 'お気に入り解除' : 'お気に入り登録';

                            return Tooltip(
                              message: label,
                              child: Material(
                                color: Colors.black.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(14),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () => ref
                                      .read(favoriteToggleProvider.notifier)
                                      .toggle(uri: folder.uri, name: folder.name),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Icon(
                                      isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                                      size: 16,
                                      color: isFavorite ? Colors.amber : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // 右上の閉じるボタン（画像の上で見えやすいよう半透明背景）
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Material(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => _deleteRecentFolder(folder),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: Colors.white,
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
    final displayImages = images.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            '最近見た画像',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 110, // スクロールバーの分少し高さを確保
          child: Scrollbar(
            controller: _imagesScrollController,
            thumbVisibility: true,
            notificationPredicate: (notification) => notification.depth == 0,
            child: ListView.builder(
              controller: _imagesScrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              itemCount: displayImages.length,
              itemBuilder: (context, index) {
                final image = displayImages[index];
                return Container(
                  width: 80,
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
                              top: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: () => _deleteRecentImage(image),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(2.0),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 12,
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
}
