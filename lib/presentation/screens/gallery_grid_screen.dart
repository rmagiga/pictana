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
import '../../domain/entities/entry_id.dart';
import '../../domain/entities/image_entry.dart';
import '../../domain/entities/storage_monitor_state.dart';
import '../../router/app_router.dart';
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
    final isSyncing = ref.watch(gallerySyncStateProvider);

    // 高速スクロール用 ScrollController
    final scrollController = useScrollController();

    // 画像選択モード管理
    final isSelectionMode = useState(false);
    final selectedEntryIds = useState(<EntryId>{});

    // 自動スクロール済みフラグ
    final hasAutoScrolled = useRef(false);

    // フォルダ変更時に自動スクロールフラグをリセット
    useEffect(() {
      hasAutoScrolled.value = false;
      return null;
    }, [folder?.uri]);

    // 続き位置の取得
    final resumePositionAsync = folder != null
        ? ref.watch(folderResumePositionProvider(folder.uri))
        : const AsyncValue<String?>.data(null);
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
            final crossAxisCount = settings.currentColumns;
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
    }, [resumeEntryId, imagesAsync.value]);

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
            final crossAxisCount = settings.currentColumns;
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
            context.push('${AppRoutes.imageViewer}/$index');
          }
        });
      }
      return null;
    }, [pendingEntryId, imagesAsync.value]);

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
            context.go(AppRoutes.storageSelection);
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
              context.push('${AppRoutes.imageViewer}/$index');
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
            const StorageDisconnectBanner(), // USB切断時のみ表示される
            if (isSyncing) const LinearProgressIndicator(minHeight: 2),
            // 表示密度調整スライダー
            if (showDensitySlider.value) _buildDensitySliderPanel(context, ref),
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
                      // ユーザー設定の現在の列数を使用
                      final settings = ref.watch(gridColumnSettingsProvider);
                      final crossAxisCount = settings.currentColumns;

                      final gridView = GridView.builder(
                        controller: scrollController,
                        // Windows: FastScrollHandler がスクロールを制御するため
                        // ポインターシグナルによるスクロールを無有効化 (Req 13.1)
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
                                context.push('${AppRoutes.imageViewer}/$index');
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

                      // スケールジェスチャー（ピンチイン・アウト）による列数の段階的増減
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

                          // しきい値（例: 1.35倍で1列減少、0.74倍で1列増加）
                          // 意図的にしっかり広げる/すぼめる操作をしたときのみ切り替わる値に調整
                          const double thresholdRatio = 1.35;
                          int targetColumns = settings.currentColumns;
                          final lastScale = lastScaleRef.value;

                          bool isChanged = false;
                          if (currentScale / lastScale >= thresholdRatio) {
                            // ピンチアウト (拡大) = 列数減少 (画像を大きく)
                            if (targetColumns > settings.minColumns) {
                              targetColumns--;
                              lastScaleRef.value = currentScale;
                              isChanged = true;
                            }
                          } else if (currentScale / lastScale <=
                              1.0 / thresholdRatio) {
                            // ピンチイン (縮小) = 列数増加 (画像を小さく)
                            if (targetColumns < settings.maxColumns) {
                              targetColumns++;
                              lastScaleRef.value = currentScale;
                              isChanged = true;
                            }
                          }

                          if (isChanged &&
                              targetColumns != settings.currentColumns) {
                            lastChangeTimeRef.value = now;
                            ref
                                .read(gridColumnSettingsProvider.notifier)
                                .setCurrentColumns(targetColumns);
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
                loading: () => _buildSkeletonGrid(context, ref, navBarHeight),
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
  Widget _buildSkeletonGrid(
    BuildContext context,
    WidgetRef ref,
    double navBarHeight,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final settings = ref.watch(gridColumnSettingsProvider);
        final crossAxisCount = (constraints.maxWidth / 150)
            .floor()
            .clamp(settings.minColumns, settings.maxColumns)
            .toInt();

        // 画面全体を覆うのに必要なアイテム数を動的に計算する
        // タイルのアスペクト比は 1.0 (正方形) なので、高さは幅と同じ
        final tileHeight = constraints.maxWidth / crossAxisCount;
        final rowCount = (constraints.maxHeight / tileHeight).ceil() + 1;
        final itemCount = crossAxisCount * rowCount;

        return Skeletonizer(
          enabled: true,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
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
            itemCount: itemCount,
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

  /// 選択モードの AppBar を構築する (Requirement 4.1, 13.1)
  ///
  /// 選択件数と「コレクションに追加」アクションボタンを表示する。
  /// キャンセルボタンで選択モードを終了する。
  PreferredSizeWidget _buildSelectionModeAppBar(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<Set<EntryId>> selectedEntryIds,
    ValueNotifier<bool> isSelectionMode,
  ) {
    final selectedCount = selectedEntryIds.value.length;

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

  /// 表示密度調整用のスライダーパネルを構築する
  Widget _buildDensitySliderPanel(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(gridColumnSettingsProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.zoom_in, size: 20),
          Expanded(
            child: Slider(
              value: settings.currentColumns.toDouble(),
              min: settings.minColumns.toDouble(),
              max: settings.maxColumns.toDouble(),
              divisions: settings.maxColumns - settings.minColumns,
              label: '${settings.currentColumns} 列',
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: (val) {
                ref
                    .read(gridColumnSettingsProvider.notifier)
                    .setCurrentColumns(val.toInt());
              },
            ),
          ),
          const Icon(Icons.zoom_out, size: 20),
          const SizedBox(width: 8),
          SizedBox(
            width: 45,
            child: Text(
              '${settings.currentColumns} 列',
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
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
