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

import '../../application/usecases/gallery/search_controller.dart';
import '../../application/usecases/settings/thumbnail_size_setting.dart';
import '../../application/usecases/storage/storage_monitor.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/entities/entry_id.dart';
import '../../domain/entities/image_entry.dart';
import '../../domain/entities/storage_monitor_state.dart';
import '../../domain/value_objects/thumbnail_size_option.dart';
import '../../router/app_router.dart';
import '../providers/collection_image_list_provider.dart';
import '../providers/collection_list_provider.dart';
import '../providers/gallery_providers.dart';
import '../providers/grid_column_settings_provider.dart';
import '../providers/storage_providers.dart';
import '../providers/viewer_providers.dart';
import '../widgets/collection_select_dialog.dart';
import '../widgets/favorite_indicator.dart';
import '../widgets/gallery/fast_scroll_handler.dart';
import '../widgets/gallery/filter_chips_widget.dart';
import '../widgets/gallery/search_bar_widget.dart';
import '../widgets/image_grid_tile.dart';
import '../widgets/sort_menu.dart';
import '../widgets/storage_disconnect_banner.dart';
import '../widgets/gallery/density_slider_panel.dart';
import '../widgets/gallery/empty_result_message.dart';
import '../widgets/gallery/skeleton_grid.dart';

/// ギャラリーグリッド画面
///
/// 検索バー・種類フィルターチップ・高速スクロール（Windows）を統合し、
/// SearchController Provider の filteredImages を反映する。
/// 検索結果 0 件時は「検索結果がありません」メッセージを表示する。
class GalleryGridScreen extends HookConsumerWidget {
  const GalleryGridScreen({this.collectionId, super.key});

  final int? collectionId;

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
    final isCollection = collectionId != null;
    final folder = isCollection ? null : ref.watch(currentFolderProvider);
    final imagesAsync = isCollection
        ? ref.watch(collectionImageEntriesProvider(collectionId!))
        : ref.watch(galleryImagesProvider);
    
    // コレクション名を取得（コレクションモードの AppBar 表示用）
    final collectionsAsync = ref.watch(collectionListProvider);
    final collectionName = collectionsAsync.when(
      data: (collections) {
        final match = collections.where((c) => c.id == collectionId);
        return match.isNotEmpty ? match.first.name.value : 'コレクション';
      },
      loading: () => 'コレクション',
      error: (_, _) => 'コレクション',
    );

    final countAsync = isCollection
        ? AsyncValue.data(imagesAsync.value?.length ?? 0)
        : ref.watch(galleryImageCountProvider);
    final searchFilterState = ref.watch(searchControllerProvider);
    final isSyncing = isCollection ? false : ref.watch(gallerySyncStateProvider);

    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    // 高速スクロール用 ScrollController
    final scrollController = useScrollController();

    // 画像選択モード管理
    final isSelectionMode = useState(false);
    final selectedEntryIds = useState(<EntryId>{});

    // 自動スクロール済みフラグ
    final hasAutoScrolled = useRef(false);

    // フォルダ・コレクション変更時に自動スクロールフラグをリセット
    useEffect(() {
      hasAutoScrolled.value = false;
      return null;
    }, [folder?.uri, collectionId]);

    // 続き位置の取得
    final resumePositionAsync = isCollection
        ? ref.watch(folderResumePositionProvider('collection_$collectionId'))
        : (folder != null
            ? ref.watch(folderResumePositionProvider(folder.uri))
            : const AsyncValue<String?>.data(null));
    final resumeEntryId = resumePositionAsync.value;

    // 画像ロード完了時、1回だけ続き位置までスクロールする
    useEffect(() {
      if (resumeEntryId == null || hasAutoScrolled.value) return null;
      final images = imagesAsync.value;
      if (images == null || images.isEmpty) return null;

      final index = images.indexWhere(
        (img) => img.id.rawValue == resumeEntryId,
      );
      if (index >= 0) {
        hasAutoScrolled.value = true;
        Future.microtask(() {
          if (scrollController.hasClients) {
            final settings = ref.read(gridColumnSettingsProvider);
            final thumbnailSize = ref.read(thumbnailSizeSettingProvider);
            final crossAxisCount = ((screenWidth - 8) / (thumbnailSize.px + 4))
                .floor()
                .clamp(settings.minColumns, settings.maxColumns);
            final row = index ~/ crossAxisCount;
            final tileHeight =
                (scrollController.position.viewportDimension / crossAxisCount) +
                4.0;
            final offset = row * tileHeight;
            scrollController.jumpTo(
              offset.clamp(0.0, scrollController.position.maxScrollExtent),
            );
          }
        });
      }
      return null;
    }, [resumeEntryId, imagesAsync.value, screenWidth]);

    // 再接続後の再読み込み中フラグ
    final isReloading = useState(false);

    // 表示密度スライダー表示フラグ
    final showDensitySlider = useState(false);

    // ピンチジェスチャースケール保持用 useRef
    final lastScaleRef = useRef<double>(1.0);

    // ピンチ操作の連続変更防止用（クールダウン時間）useRef
    final lastChangeTimeRef = useRef<int>(0);

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

    // 最近見た画像から遷移した際の自動スクロール＆自動ビューア遷移
    final pendingEntryId = ref.watch(pendingViewerEntryIdProvider);
    useEffect(() {
      if (pendingEntryId == null) return null;
      final images = imagesAsync.value;
      if (images == null || images.isEmpty) return null;

      // 遷移処理を開始するため、持ち越しや二重動作を防ぐため即座にクリアする
      ref.read(pendingViewerEntryIdProvider.notifier).clear();

      final index = images.indexWhere(
        (img) => img.id.rawValue == pendingEntryId,
      );
      if (index >= 0) {
        Future.microtask(() {
          // 自動スクロール
          if (scrollController.hasClients) {
            final settings = ref.read(gridColumnSettingsProvider);
            final thumbnailSize = ref.read(thumbnailSizeSettingProvider);
            final crossAxisCount = ((screenWidth - 8) / (thumbnailSize.px + 4))
                .floor()
                .clamp(settings.minColumns, settings.maxColumns);
            final row = index ~/ crossAxisCount;
            // タイルの高さと余白（4.0）を考慮
            final tileHeight =
                (scrollController.position.viewportDimension / crossAxisCount) +
                4.0;
            final offset = row * tileHeight;
            scrollController.jumpTo(
              offset.clamp(0.0, scrollController.position.maxScrollExtent),
            );
          }

          // ビューアを起動
          if (context.mounted) {
            final collectionParam = isCollection ? '?collectionId=$collectionId' : '';
            context.push('${AppRoutes.imageViewer}/$index$collectionParam');
          }
        });
      }
      return null;
    }, [pendingEntryId, imagesAsync.value, screenWidth]);

    // Scaffold より外側の context でシステムナビゲーションバーの高さを取得する
    // （Scaffold の body 内では viewPadding.bottom が 0 になるため）
    final navBarHeight = MediaQuery.of(context).viewPadding.bottom;

    return PopScope(
      canPop: !isSelectionMode.value,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          if (isSelectionMode.value) {
            // 選択モード中の戻る操作で選択を解除する
            isSelectionMode.value = false;
            selectedEntryIds.value = {};
          } else {
            if (isCollection) {
              context.go(AppRoutes.collectionList);
            } else {
              context.go(AppRoutes.storageSelection);
            }
          }
        }
      },
      child: Scaffold(
        floatingActionButton: (() {
          // 選択モード中は FAB を非表示
          if (isSelectionMode.value) return null;
          if (resumeEntryId == null) return null;
          final images = imagesAsync.value;
          if (images == null || images.isEmpty) return null;
          final index = images.indexWhere(
            (img) => img.id.rawValue == resumeEntryId,
          );
          if (index < 0) return null;

          final targetImage = images[index];
          return FloatingActionButton.extended(
            onPressed: () {
              final collectionParam = isCollection ? '?collectionId=$collectionId' : '';
              context.push('${AppRoutes.imageViewer}/$index$collectionParam');
            },
            icon: const Icon(Icons.play_arrow),
            label: Text('続きから読む (${targetImage.name})'),
          );
        })(),
        appBar: isSelectionMode.value
            ? _buildSelectionModeAppBar(
                context,
                ref,
                selectedEntryIds,
                isSelectionMode,
              )
            : AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  tooltip: isCollection ? 'コレクション一覧に戻る' : 'フォルダ選択に戻る',
                  onPressed: () => context.go(isCollection ? AppRoutes.collectionList : AppRoutes.storageSelection),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(isCollection ? collectionName : (folder?.name ?? 'Pictana Gallery')),
                    if (countAsync.value != null)
                      Text(
                        '${countAsync.value} items',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
                actions: isCollection
                    ? [
                        // 表示密度変更ボタン
                        IconButton(
                          icon: const Icon(Icons.grid_view),
                          tooltip: '表示密度（列数）を変更',
                          onPressed: () {
                            showDensitySlider.value = !showDensitySlider.value;
                          },
                        ),
                      ]
                    : [
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
                              ref
                                  .read(searchControllerProvider.notifier)
                                  .toggleSearchBar();
                            },
                          ),
                        // 表示密度変更ボタン
                        IconButton(
                          icon: const Icon(Icons.grid_view),
                          tooltip: '表示密度（列数）を変更',
                          onPressed: () {
                            showDensitySlider.value = !showDensitySlider.value;
                          },
                        ),
                        // ソートメニュー
                        const SortMenu(),
                        // コレクション一覧ボタン
                        IconButton(
                          icon: const Icon(Icons.collections_bookmark_outlined),
                          tooltip: 'コレクション',
                          onPressed: () {
                            context.push(AppRoutes.collectionList);
                          },
                        ),
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
            if (!isCollection) const StorageDisconnectBanner(), // USB切断時のみ表示される（コレクションモードでは表示しない）
            if (isSyncing) const LinearProgressIndicator(minHeight: 2),
            // 表示密度調整スライダー
            if (showDensitySlider.value) const DensitySliderPanel(),
            // 検索バーウィジェット (Req 11.1, 11.5)
            // 展開時のみ表示
            if (!isCollection && searchFilterState.isSearchBarExpanded)
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
            if (!isCollection && searchFilterState.isSearchBarExpanded)
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
                  // コレクションモードの時は検索フィルタを適用しない
                  final filteredImages = isCollection ? images : ref.watch(filteredImagesProvider);
 
                  // コレクション画像なし、または検索結果 0 件時のメッセージ表示
                  if (filteredImages.isEmpty) {
                    if (isCollection) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo_library_outlined,
                                size: 64,
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '画像が登録されていません',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'フォルダ画像一覧から画像を追加してください',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return EmptyResultMessage(
                      isFiltered:
                          searchFilterState.query.isNotEmpty ||
                          searchFilterState.selectedMimeType != null,
                    );
                  }
 
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      // ユーザー設定の現在の列数を使用
                      final settings = ref.watch(gridColumnSettingsProvider);
                      final thumbnailSize = ref.watch(thumbnailSizeSettingProvider);
                      final crossAxisCount = (constraints.maxWidth / (thumbnailSize.px + 4))
                          .floor()
                          .clamp(settings.minColumns, settings.maxColumns);
 
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
                        padding: EdgeInsets.only(
                          left: 4,
                          right: 4,
                          top: 4,
                          bottom: 4 + navBarHeight,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: filteredImages.length,
                        itemBuilder: (context, index) {
                          final image = filteredImages[index];
                          final isSelected = selectedEntryIds.value.contains(
                            image.id,
                          );
 
                          return _SelectableImageGridTile(
                            key: ValueKey(image.uri),
                            image: image,
                            isSelectionMode: isSelectionMode.value,
                            isSelected: isSelected,
                            onTap: () {
                              if (isSelectionMode.value) {
                                // 選択モード中: 選択トグル
                                final newSet = Set<EntryId>.from(
                                  selectedEntryIds.value,
                                );
                                if (isSelected) {
                                  newSet.remove(image.id);
                                  // 全解除で選択モード終了
                                  if (newSet.isEmpty) {
                                    isSelectionMode.value = false;
                                  }
                                } else {
                                  newSet.add(image.id);
                                }
                                selectedEntryIds.value = newSet;
                              } else {
                                // 通常モード: ビューア遷移
                                final collectionParam = isCollection ? '?collectionId=$collectionId' : '';
                                context.push('${AppRoutes.imageViewer}/$index$collectionParam');
                              }
                            },
                            onLongPress: () {
                              if (!isSelectionMode.value) {
                                // 長押しで選択モード開始
                                isSelectionMode.value = true;
                                selectedEntryIds.value = {image.id};
                              }
                            },
                          );
                        },
                      );

                      // スケールジェスチャー（ピンチイン・アウト）によるサムネイルサイズの段階的増減
                      final gestureWrapper = GestureDetector(
                        onScaleStart: (details) {
                          lastScaleRef.value = 1.0;
                        },
                        onScaleUpdate: (details) {
                          if (details.pointerCount < 2) return; // 2本指のピンチのみ
                          final currentScale = details.scale;
                          if (currentScale == 1.0) return;

                          // 連続変化を防ぐクールダウン制御（250ms間隔）
                          final now = DateTime.now().millisecondsSinceEpoch;
                          if (now - lastChangeTimeRef.value < 250) return;

                          // しきい値（例: 1.35倍で拡大、0.74倍で縮小）
                          const double thresholdRatio = 1.35;
                          final currentSize = ref.read(thumbnailSizeSettingProvider);
                          final lastScale = lastScaleRef.value;

                          bool isChanged = false;
                          ThumbnailSizeOption? targetSize;

                          if (currentScale / lastScale >= thresholdRatio) {
                            // ピンチアウト (拡大) = サムネイルサイズを大きくする
                            if (currentSize.index < ThumbnailSizeOption.values.length - 1) {
                              targetSize = ThumbnailSizeOption.values[currentSize.index + 1];
                              lastScaleRef.value = currentScale;
                              isChanged = true;
                            }
                          } else if (currentScale / lastScale <=
                              1.0 / thresholdRatio) {
                            // ピンチイン (縮小) = サムネイルサイズを小さくする
                            if (currentSize.index > 0) {
                              targetSize = ThumbnailSizeOption.values[currentSize.index - 1];
                              lastScaleRef.value = currentScale;
                              isChanged = true;
                            }
                          }

                          if (isChanged && targetSize != null && targetSize != currentSize) {
                            lastChangeTimeRef.value = now;
                            ref
                                .read(thumbnailSizeSettingProvider.notifier)
                                .update(targetSize);
                          }
                        },
                        child: gridView,
                      );

                      // Windows: FastScrollHandler でマウスホイール高速スクロール (Req 13.1)
                      if (Platform.isWindows) {
                        return FastScrollHandler(
                          scrollController: scrollController,
                          child: gestureWrapper,
                        );
                      }

                      return gestureWrapper;
                    },
                  );
                },
                loading: () => SkeletonGrid(navBarHeight: navBarHeight),
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



  /// 選択モードの AppBar を構築する (Requirement 4.1, 13.1)
  ///
  /// 選択件数と「コレクションに追加」または「解除」アクションボタンを表示する。
  /// キャンセルボタンで選択モードを終了する。
  PreferredSizeWidget _buildSelectionModeAppBar(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<Set<EntryId>> selectedEntryIds,
    ValueNotifier<bool> isSelectionMode,
  ) {
    final selectedCount = selectedEntryIds.value.length;
    final isCollection = collectionId != null;

    return AppBar(
      // キャンセルボタン
      leading: IconButton(
        icon: const Icon(Icons.close),
        tooltip: 'キャンセル',
        onPressed: () {
          isSelectionMode.value = false;
          selectedEntryIds.value = {};
        },
      ),
      // 選択件数表示
      title: Text('$selectedCount件選択'),
      actions: [
        if (isCollection)
          // コレクションから解除ボタン
          IconButton(
            icon: const Icon(Icons.link_off),
            tooltip: 'コレクションから解除',
            onPressed: selectedCount > 0
                ? () => _onRemoveFromCollection(
                    context,
                    ref,
                    selectedEntryIds,
                    isSelectionMode,
                  )
                : null,
          )
        else
          // コレクションに追加ボタン (Requirement 4.1, 13.1)
          IconButton(
            icon: const Icon(Icons.collections_bookmark_outlined),
            tooltip: 'コレクションに追加',
            onPressed: selectedCount > 0
                ? () => _onAddToCollection(
                    context,
                    ref,
                    selectedEntryIds,
                    isSelectionMode,
                  )
                : null,
          ),
      ],
    );
  }

  /// コレクションから解除アクションを実行する
  Future<void> _onRemoveFromCollection(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<Set<EntryId>> selectedEntryIds,
    ValueNotifier<bool> isSelectionMode,
  ) async {
    final entryIds = selectedEntryIds.value.toList();
    final selectedCount = entryIds.length;
    if (selectedCount == 0 || collectionId == null) return;

    // 確認ダイアログを表示
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('画像の解除'),
        content: Text(
          '$selectedCount件の画像をこのコレクションから解除しますか？\n'
          '※ 画像ファイルは削除されません',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('解除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final useCase = ref.read(removeImagesFromCollectionUseCaseProvider);
      await useCase.execute(collectionId!, entryIds);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$selectedCount枚の画像をコレクションから解除しました'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // 選択モードを終了する
      isSelectionMode.value = false;
      selectedEntryIds.value = {};
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('画像の解除に失敗しました'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// コレクションに追加アクションを実行する (Requirement 4.1, 4.8, 4.10, 13.1)
  ///
  /// 選択中の画像 EntryId リストで CollectionSelectDialog を表示し、
  /// 追加完了時に SnackBar で件数を通知する。
  /// 100枚以上の場合はローディングインジケータを表示する。
  Future<void> _onAddToCollection(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<Set<EntryId>> selectedEntryIds,
    ValueNotifier<bool> isSelectionMode,
  ) async {
    final entryIds = selectedEntryIds.value.toList();

    // CollectionSelectDialog を表示する
    final addedCount = await showCollectionSelectDialog(context, entryIds);

    if (addedCount != null && context.mounted) {
      // 追加完了通知 (Requirement 4.8)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$addedCount枚の画像をコレクションに追加しました'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );

      // 選択モードを終了する
      isSelectionMode.value = false;
      selectedEntryIds.value = {};
    }
  }


}

/// 選択モード対応の画像グリッドタイルウィジェット
///
/// 通常モードでは ImageGridTile をそのまま表示し、
/// 選択モードでは長押し開始と選択状態のオーバーレイを追加する。
class _SelectableImageGridTile extends ConsumerStatefulWidget {
  const _SelectableImageGridTile({
    super.key,
    required this.image,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  final ImageEntry image;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  ConsumerState<_SelectableImageGridTile> createState() =>
      _SelectableImageGridTileState();
}

class _SelectableImageGridTileState
    extends ConsumerState<_SelectableImageGridTile> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        // ベースとなる画像タイル
        ImageGridTile(
          image: widget.image,
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
        ),
        // 選択状態のオーバーレイ
        if (widget.isSelected)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        // 選択チェックマーク
        if (widget.isSelectionMode)
          Positioned(
            top: 4,
            left: 4,
            child: IgnorePointer(
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surface.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                    width: 2,
                  ),
                ),
                child: widget.isSelected
                    ? Icon(
                        Icons.check,
                        size: 16,
                        color: theme.colorScheme.onPrimary,
                      )
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}
