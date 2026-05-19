/// ギャラリーグリッド画面 (設計書 §18.3)
///
/// SearchBarWidget・FilterChipsWidget・FastScrollHandler を統合し、
/// 検索・フィルター・高速スクロール機能を提供する。
/// StorageMonitor と連携し、再接続検知時にフォルダ内容を自動再読み込みする。
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../application/usecases/gallery/search_controller.dart';
import '../../application/usecases/storage/storage_monitor.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/entities/image_entry.dart';
import '../../domain/entities/storage_monitor_state.dart';
import '../../router/app_router.dart';
import '../providers/gallery_providers.dart';
import '../providers/grid_column_settings_provider.dart';
import '../providers/storage_providers.dart';
import '../widgets/favorite_indicator.dart';
import '../widgets/gallery/fast_scroll_handler.dart';
import '../widgets/gallery/filter_chips_widget.dart';
import '../widgets/gallery/search_bar_widget.dart';
import '../widgets/image_grid_tile.dart';
import '../widgets/sort_menu.dart';
import '../widgets/storage_disconnect_banner.dart';

/// ギャラリーグリッド画面
///
/// 検索バー・種類フィルターチップ・高速スクロール（Windows）を統合し、
/// SearchController Provider の filteredImages を反映する。
/// 検索結果 0 件時は「検索結果がありません」メッセージを表示する。
class GalleryGridScreen extends HookConsumerWidget {
  const GalleryGridScreen({super.key});

  /// フォルダ選択ダイアログを起動し、選択後にギャラリーを切り替える
  Future<void> _selectFolder(BuildContext context, WidgetRef ref) async {
    try {
      final useCase = ref.read(selectStorageUseCaseProvider);
      final folder = await useCase.execute();

      if (folder != null) {
        ref.read(currentFolderProvider.notifier).setFolder(folder);
        // ギャラリーを再読み込み
        ref.invalidate(galleryImagesProvider);
        ref.invalidate(galleryImageCountProvider);
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
    final folder = ref.watch(currentFolderProvider);
    final imagesAsync = ref.watch(galleryImagesProvider);
    final countAsync = ref.watch(galleryImageCountProvider);
    final searchFilterState = ref.watch(searchControllerProvider);

    // 高速スクロール用 ScrollController
    final scrollController = useScrollController();

    // 再接続後の再読み込み中フラグ
    final isReloading = useState(false);

    // ストレージ再接続検知時にフォルダ内容を自動再読み込み (Req 15.2, 15.3, 15.4)
    ref.listen<StorageMonitorState>(storageMonitorProvider, (previous, next) {
      // バナーが表示中 → 非表示に変化 = 再接続検知
      if (previous != null &&
          previous.isBannerVisible &&
          !next.isBannerVisible &&
          !next.maxRetryReached) {
        // galleryImagesProvider を invalidate して再読み込みをトリガー (Req 15.3)
        ref.invalidate(galleryImagesProvider);
        ref.invalidate(galleryImageCountProvider);
        isReloading.value = true;
      }
    });

    // 再読み込み失敗時はバナー再表示 + リトライ再開 (Req 15.4)
    ref.listen<AsyncValue<List<ImageEntry>>>(galleryImagesProvider, (
      previous,
      next,
    ) {
      if (!isReloading.value) return;

      // ローディング中は待機
      if (next.isLoading) return;

      // 結果が確定したのでフラグをリセット
      isReloading.value = false;

      if (next.hasError) {
        // 再読み込み失敗: バナー再表示 + リトライ再開
        final monitorState = ref.read(storageMonitorProvider);
        if (monitorState.disconnectedRoot != null) {
          ref
              .read(storageMonitorProvider.notifier)
              .startRetryPolling(monitorState.disconnectedRoot!);
        }
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          context.go(AppRoutes.storageSelection);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'フォルダ選択に戻る',
            onPressed: () => context.go(AppRoutes.storageSelection),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(folder?.name ?? 'Pictana Gallery'),
              if (countAsync.value != null)
                Text(
                  '${countAsync.value} items',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
          actions: [
            // フォルダ選択ボタン
            IconButton(
              icon: const Icon(Icons.folder_open),
              tooltip: 'フォルダを選択',
              onPressed: () => _selectFolder(context, ref),
            ),
            // お気に入りトグルボタン
            if (folder != null)
              FavoriteIndicator(uri: folder.uri, name: folder.name),
            // 検索アイコンボタン (Req 11.1)
            // 折りたたみ時のみ AppBar に表示
            if (!searchFilterState.isSearchBarExpanded)
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: '検索',
                onPressed: () {
                  ref.read(searchControllerProvider.notifier).toggleSearchBar();
                },
              ),
            // ソートメニュー
            const SortMenu(),
            // 設定ボタン
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                context.push(AppRoutes.settings);
              },
            ),
          ],
        ),
        body: Column(
          children: [
            const StorageDisconnectBanner(), // USB切断時のみ表示される
            // 検索バーウィジェット (Req 11.1, 11.5)
            // 展開時のみ表示
            if (searchFilterState.isSearchBarExpanded)
              SearchBarWidget(
                isExpanded: true,
                onToggle: () {
                  ref.read(searchControllerProvider.notifier).toggleSearchBar();
                },
                onQueryChanged: (query) {
                  ref
                      .read(searchControllerProvider.notifier)
                      .updateQuery(query);
                },
                onClear: () {
                  ref.read(searchControllerProvider.notifier).clearAll();
                },
              ),
            // 種類フィルターチップ (Req 12.1, 12.5)
            // 検索バーが展開されている場合のみ表示
            if (searchFilterState.isSearchBarExpanded)
              FilterChipsWidget(
                selectedMimeType: searchFilterState.selectedMimeType,
                onMimeTypeSelected: (mimeType) {
                  ref
                      .read(searchControllerProvider.notifier)
                      .updateMimeTypeFilter(mimeType);
                },
              ),
            Expanded(
              child: imagesAsync.when(
                data: (images) {
                  // SearchController の filteredImages を適用 (Req 11.2, 12.2)
                  final filteredImages = ref.watch(filteredImagesProvider);

                  // 検索結果 0 件時のメッセージ表示 (Req 11.5, 12.5)
                  if (filteredImages.isEmpty) {
                    return _buildEmptyResultMessage(
                      context,
                      isFiltered:
                          searchFilterState.query.isNotEmpty ||
                          searchFilterState.selectedMimeType != null,
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      // 画面幅と設定値に応じて列数を動的に変更
                      final settings = ref.watch(gridColumnSettingsProvider);
                      final crossAxisCount = (constraints.maxWidth / 150)
                          .floor()
                          .clamp(settings.minColumns, settings.maxColumns)
                          .toInt();

                      final gridView = GridView.builder(
                        controller: scrollController,
                        // Windows: FastScrollHandler がスクロールを制御するため
                        // ポインターシグナルによるスクロールを無効化 (Req 13.1)
                        physics: Platform.isWindows
                            ? const FastScrollPhysics()
                            : null,
                        // スクロール時にキーボードを閉じる（Android 向け）
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.all(4),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: filteredImages.length,
                        itemBuilder: (context, index) {
                          final image = filteredImages[index];
                          return ImageGridTile(
                            key: ValueKey(image.uri),
                            image: image,
                            onTap: () {
                              context.push('${AppRoutes.imageViewer}/$index');
                            },
                          );
                        },
                      );

                      // Windows: FastScrollHandler でマウスホイール高速スクロール (Req 13.1)
                      if (Platform.isWindows) {
                        return FastScrollHandler(
                          scrollController: scrollController,
                          child: gridView,
                        );
                      }

                      return gridView;
                    },
                  );
                },
                loading: () => _buildSkeletonGrid(context, ref),
                error: (e, st) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      const Text('画像の読み込みに失敗しました'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.go(AppRoutes.storageSelection),
                        child: const Text('フォルダを選び直す'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 検索結果 0 件時のメッセージウィジェットを構築する
  ///
  /// [isFiltered] が true の場合は検索/フィルター適用中のメッセージを表示し、
  /// false の場合はフォルダ内に画像がない旨のメッセージを表示する。
  Widget _buildEmptyResultMessage(
    BuildContext context, {
    required bool isFiltered,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFiltered ? Icons.search_off : Icons.image_not_supported_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            isFiltered ? '検索結果がありません' : '画像が見つかりません。',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (isFiltered) ...[
            const SizedBox(height: 8),
            Text(
              '検索条件を変更してください',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 初回ローディング時のスケルトングリッドを構築する (Req 4.4)
  ///
  /// 実際のグリッドと同じレイアウト（列数・スペーシング）で
  /// Card 形状のダミータイルを Skeletonizer で表示する。
  Widget _buildSkeletonGrid(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final settings = ref.watch(gridColumnSettingsProvider);
        final crossAxisCount = (constraints.maxWidth / 150)
            .floor()
            .clamp(settings.minColumns, settings.maxColumns)
            .toInt();

        return Skeletonizer(
          enabled: true,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(4),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 16,
            itemBuilder: (context, index) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: const SizedBox.expand(),
              );
            },
          ),
        );
      },
    );
  }
}
