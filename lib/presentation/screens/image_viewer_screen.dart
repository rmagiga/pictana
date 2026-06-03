/// 画像ビューア画面 (設計書 §18.4)
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers/repository_providers.dart';
import '../../domain/entities/entry_id.dart';
import '../../domain/entities/image_entry.dart';
import '../../domain/value_objects/navigation_bounds.dart';
import '../providers/collection_image_list_provider.dart';
import '../providers/collection_list_provider.dart';
import '../providers/favorite_toggle_provider.dart';
import '../providers/gallery_providers.dart';
import '../providers/viewer_providers.dart';
import '../providers/viewer_controller_provider.dart';
import '../widgets/image_info_sheet.dart';
import '../widgets/viewer/ctrl_wheel_zoom_handler.dart';
import '../widgets/viewer/keyboard_navigation_handler.dart';
import '../widgets/viewer/navigation_overlay.dart';
import '../widgets/viewer/viewer_display_container.dart';
import '../widgets/viewer/viewer_display_mode.dart';
import '../widgets/viewer/viewer_settings_sheet.dart';

class ImageViewerScreen extends ConsumerStatefulWidget {
  const ImageViewerScreen({super.key, required this.initialIndex, this.collectionId});

  final int initialIndex;
  final int? collectionId;

  @override
  ConsumerState<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends ConsumerState<ImageViewerScreen> {
  PageController? _pageController;
  bool _isPageAnimating = false;
  double _currentScale = 1.0;
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recordCurrentImageViewed();
    });
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformChanged);
    _transformationController.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if ((_currentScale - scale).abs() > 0.001) {
      setState(() {
        _currentScale = scale;
      });
      final images = widget.collectionId != null
          ? ref.read(collectionImageEntriesProvider(widget.collectionId!)).value
          : ref.read(galleryImagesProvider).value;
      if (images != null) {
        ref
            .read(viewerControllerProvider(
              initialIndex: widget.initialIndex,
              totalCount: images.length,
              collectionId: widget.collectionId,
            ).notifier)
            .setZoomed(scale > 1.01);
      }
    }
  }

  void _recordCurrentImageViewed() {
    final images = widget.collectionId != null
        ? ref.read(collectionImageEntriesProvider(widget.collectionId!)).value
        : ref.read(galleryImagesProvider).value;
    if (images != null) {
      final state = ref.read(viewerControllerProvider(
        initialIndex: widget.initialIndex,
        totalCount: images.length,
        collectionId: widget.collectionId,
      ));
      final currentIndex = state.currentIndex;
      if (currentIndex >= 0 && currentIndex < images.length) {
        final currentImage = images[currentIndex];
        ref.read(recentImagesListProvider.notifier).addRecent(currentImage);
        
        if (widget.collectionId != null) {
          final key = 'collection_${widget.collectionId}';
          ref.read(resumePositionUseCaseProvider).savePosition(
                folderUri: key,
                entryId: currentImage.id.rawValue,
              );
          ref.invalidate(folderResumePositionProvider(key));
        } else {
          final folder = ref.read(currentFolderProvider);
          if (folder != null) {
            ref.read(resumePositionUseCaseProvider).savePosition(
                  folderUri: folder.uri,
                  entryId: currentImage.id.rawValue,
                );
            ref.invalidate(folderResumePositionProvider(folder.uri));
          }
        }
      }
    }
  }

  void _toggleFolderFavorite() {
    final folder = ref.read(currentFolderProvider);
    if (folder != null) {
      ref.read(favoriteToggleProvider.notifier).toggle(
            uri: folder.uri,
            name: folder.name,
          );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${folder.name} のお気に入り状態を切り替えました'),
          duration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  void _zoomIn() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    final newScale = (currentScale + 0.5).clamp(1.0, 5.0);
    _onCtrlWheelScaleChanged(newScale);
  }

  void _zoomOut() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    final newScale = (currentScale - 0.5).clamp(1.0, 5.0);
    _onCtrlWheelScaleChanged(newScale);
  }

  void _zoomReset() {
    _transformationController.value = Matrix4.identity();
  }



  void _showViewerSettings() {
    final images = widget.collectionId != null
        ? ref.read(collectionImageEntriesProvider(widget.collectionId!)).value ?? []
        : ref.read(galleryImagesProvider).value ?? [];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ViewerSettingsSheet(
        initialIndex: widget.initialIndex,
        totalCount: images.length,
        collectionId: widget.collectionId,
      ),
    );
  }

  /// 所属コレクション一覧ダイアログを表示する (Requirement 12.3, 12.4)
  Future<void> _showCollectionsDialog(EntryId entryId) async {
    final repository = ref.read(collectionRepositoryProvider);
    final collections = await repository.getCollectionsForImage(entryId);

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('所属コレクション一覧'),
        content: collections.isEmpty
            ? const Text('所属するコレクションがありません')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: collections.length,
                  itemBuilder: (context, index) {
                    final collection = collections[index];
                    return ListTile(
                      leading: const Icon(Icons.collections_bookmark),
                      title: Text(collection.name.value),
                      subtitle: Text('${collection.imageCount}枚'),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  /// 「このコレクションから解除」アクション (Requirement 12.8, 12.9)
  Future<void> _removeFromCollection(
    List<ImageEntry> images,
    int currentIndex,
  ) async {
    if (images.isEmpty || widget.collectionId == null) return;

    final currentImage = images[currentIndex];

    // 確認ダイアログを表示
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('コレクションから解除'),
        content: const Text(
          'この画像をコレクションから解除しますか？\n'
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

    if (confirmed != true || !mounted) return;

    try {
      final useCase = ref.read(removeImagesFromCollectionUseCaseProvider);
      await useCase.execute(widget.collectionId!, [currentImage.id]);

      if (!mounted) return;

      // 最後の1枚を解除した場合は一覧画面へ戻る (Requirement 12.9)
      if (images.length <= 1) {
        context.pop();
        return;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('画像の解除に失敗しました'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  /// 所属コレクション一覧ボタンが活性かどうかを判定する
  Future<bool> _hasCollections(EntryId entryId) async {
    final repository = ref.read(collectionRepositoryProvider);
    final collections = await repository.getCollectionsForImage(entryId);
    return collections.isNotEmpty;
  }

  /// EntryId をユーザーに見やすい形式にフォーマットする
  String _formatEntryId(EntryId entryId) {
    final raw = entryId.rawValue;
    // ファイルパスの場合はファイル名部分のみ表示
    final lastSeparator = raw.lastIndexOf(RegExp(r'[/\\]'));
    if (lastSeparator >= 0 && lastSeparator < raw.length - 1) {
      return raw.substring(lastSeparator + 1);
    }
    // URI の場合は末尾部分を表示
    if (raw.length > 40) {
      return '...${raw.substring(raw.length - 37)}';
    }
    return raw;
  }

  void _navigateToPage(ViewerController controller, ViewerState state, int targetPage) {
    if (_pageController == null) return;
    if (_isPageAnimating) {
      final snappedPage = _pageController!.page?.round() ?? 
          (state.displayMode == ViewerDisplayMode.double ? controller.currentPageIndex : state.currentIndex);
      _pageController!.jumpToPage(snappedPage);
    }

    setState(() => _isPageAnimating = true);
    if (state.displayMode == ViewerDisplayMode.double) {
      controller.setCurrentPageIndex(targetPage);
    } else {
      controller.setCurrentIndex(targetPage);
    }
    
    _pageController!
        .animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        )
        .then((_) {
          if (mounted) {
            setState(() => _isPageAnimating = false);
            _recordCurrentImageViewed();
          }
        });
  }

  void _onCtrlWheelScaleChanged(double newScale) {
    _transformationController.value = Matrix4.diagonal3Values(
      newScale,
      newScale,
      1.0,
    );
  }

  void _onCtrlWheelFocalPoint(Offset focalPoint) {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if (scale <= 1.0) return;
    final tx = focalPoint.dx * (1 - scale);
    final ty = focalPoint.dy * (1 - scale);
    final matrix = Matrix4.translationValues(tx, ty, 0.0)
      ..multiply(Matrix4.diagonal3Values(scale, scale, 1.0));
    _transformationController.value = matrix;
  }

  void _showImageInfo(List<ImageEntry> images) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ImageInfoSheet(images: images),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagesAsync = widget.collectionId != null
        ? ref.watch(collectionImageEntriesProvider(widget.collectionId!))
        : ref.watch(galleryImagesProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: imagesAsync.when(
        data: (images) {
          if (images.isEmpty) {
            if (widget.collectionId != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) context.pop();
              });
            }
            return const Center(
              child: Text('画像がありません', style: TextStyle(color: Colors.white)),
            );
          }

          final initialIndex = images.indexWhere(
            (img) => img.id.rawValue == (widget.collectionId != null
                ? widget.initialIndex < images.length ? images[widget.initialIndex].id.rawValue : ''
                : images[widget.initialIndex < images.length ? widget.initialIndex : 0].id.rawValue),
          );
          final realInitialIndex = initialIndex >= 0 ? initialIndex : 0;

          final provider = viewerControllerProvider(
            initialIndex: realInitialIndex,
            totalCount: images.length,
            collectionId: widget.collectionId,
          );
          final state = ref.watch(provider);
          final controller = ref.read(provider.notifier);

          if (!state.isInitialized) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (_pageController == null) {
            final initialPage = state.displayMode == ViewerDisplayMode.double
                ? controller.currentPageIndex
                : state.currentIndex;
            _pageController = PageController(initialPage: initialPage);
          }

          final currentIndex = state.currentIndex;
          final currentImage = images[currentIndex];

          final isDouble = state.displayMode == ViewerDisplayMode.double;
          String titleText = _formatEntryId(currentImage.id);
          if (isDouble && state.pages.isNotEmpty) {
            final pageIndex = controller.currentPageIndex;
            if (pageIndex >= 0 && pageIndex < state.pages.length) {
              final page = state.pages[pageIndex];
              if (page.isDoublePage && page.entries.length >= 2) {
                final isRtl = state.folderSettings?.isRightToLeft ?? true;
                final entryLeft = isRtl ? page.entries[1] : page.entries[0];
                final entryRight = isRtl ? page.entries[0] : page.entries[1];
                titleText = '${_formatEntryId(entryLeft.id)} - ${_formatEntryId(entryRight.id)}';
              }
            }
          }

          ref.listen<ViewerState>(provider, (prev, next) {
            if (prev != null && (prev.currentIndex != next.currentIndex || prev.displayMode != next.displayMode)) {
              final isDouble = next.displayMode == ViewerDisplayMode.double;
              final targetPage = isDouble ? controller.currentPageIndex : next.currentIndex;
              
              if (_pageController != null && _pageController!.hasClients) {
                final isModeChanged = prev.displayMode != next.displayMode;
                if (isModeChanged || (!_isPageAnimating && _pageController!.page?.round() != targetPage)) {
                  _pageController!.jumpToPage(targetPage);
                }
              }
              // ページ遷移または表示モード変更時にズーム状態をリセットする
              _zoomReset();
              _recordCurrentImageViewed();
            }
          });

          Widget pageViewSection = GestureDetector(
            onTap: controller.toggleOverlay,
            child: ViewerDisplayContainer(
              images: images,
              state: state,
              controller: controller,
              pageController: _pageController!,
              transformationController: _transformationController,
              onZoomChanged: (zoomed) => controller.setZoomed(zoomed),
            ),
          );

          if (Platform.isWindows) {
            pageViewSection = CtrlWheelZoomHandler(
              currentScale: _currentScale,
              onScaleChanged: _onCtrlWheelScaleChanged,
              onFocalPoint: _onCtrlWheelFocalPoint,
              child: pageViewSection,
            );
          }

          Widget content = Stack(
            fit: StackFit.expand,
            children: [
              pageViewSection,

              // AppBar (オーバーレイ)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                top: state.isOverlayVisible
                    ? 0
                    : -kToolbarHeight - MediaQuery.paddingOf(context).top,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.paddingOf(context).top,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    foregroundColor: Colors.white,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    ),
                    title: Text(
                      titleText,
                      style: TextStyle(
                        fontSize: isDouble ? 14 : 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    actions: [
                      // コレクションモード時のアクション
                      if (widget.collectionId != null) ...[
                        FutureBuilder<bool>(
                          future: _hasCollections(currentImage.id),
                          builder: (context, snapshot) {
                            final hasCollections = snapshot.data ?? false;
                            return IconButton(
                              icon: const Icon(Icons.collections_bookmark),
                              tooltip: '所属コレクション一覧',
                              onPressed: hasCollections
                                  ? () => _showCollectionsDialog(currentImage.id)
                                  : null,
                            );
                          },
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          tooltip: 'メニュー',
                          onSelected: (value) {
                            if (value == 'remove') {
                              _removeFromCollection(images, currentIndex);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem<String>(
                              value: 'remove',
                              child: Row(
                                children: [
                                  Icon(Icons.link_off, size: 20),
                                  SizedBox(width: 12),
                                  Text('このコレクションから解除'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: _showViewerSettings,
                        tooltip: '表示設定',
                      ),
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () {
                          List<ImageEntry> targetImages;
                          if (state.displayMode == ViewerDisplayMode.double &&
                              state.pages.isNotEmpty) {
                            final pageIndex = controller.currentPageIndex;
                            if (pageIndex >= 0 && pageIndex < state.pages.length) {
                              targetImages = state.pages[pageIndex].entries;
                            } else {
                              targetImages = [currentImage];
                            }
                          } else {
                            targetImages = [currentImage];
                          }
                          _showImageInfo(targetImages);
                        },
                        tooltip: '画像情報',
                      ),
                    ],
                  ),
                ),
              ),

              // ページインジケーター (オーバーレイ下部)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                bottom: state.isOverlayVisible
                    ? MediaQuery.paddingOf(context).bottom + 16
                    : -50,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        state.displayMode == ViewerDisplayMode.double
                            ? '${controller.currentPageIndex + 1} / ${state.pages.length}'
                            : '${currentIndex + 1} / ${images.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Windows: ナビゲーションオーバーレイ (矢印ボタン)
              if (Platform.isWindows)
                NavigationOverlay(
                  currentIndex: state.displayMode == ViewerDisplayMode.double ? controller.currentPageIndex : currentIndex,
                  totalCount: state.displayMode == ViewerDisplayMode.double ? state.pages.length : images.length,
                  isAnimating: _isPageAnimating,
                  onPrevious: () {
                    final current = state.displayMode == ViewerDisplayMode.double ? controller.currentPageIndex : currentIndex;
                    if (current > 0) {
                      _navigateToPage(controller, state, current - 1);
                    }
                  },
                  onNext: () {
                    final current = state.displayMode == ViewerDisplayMode.double ? controller.currentPageIndex : currentIndex;
                    final total = state.displayMode == ViewerDisplayMode.double ? state.pages.length : images.length;
                    if (current < total - 1) {
                      _navigateToPage(controller, state, current + 1);
                    }
                  },
                  isRightToLeft: state.displayMode == ViewerDisplayMode.double && (state.folderSettings?.isRightToLeft ?? true),
                )
              else ...[
                // モバイル向けの簡易前後移動ボタン
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: state.isOverlayVisible ? false : true,
                    child: AnimatedOpacity(
                      opacity: state.isOverlayVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Builder(
                        builder: (context) {
                          final isRtl = state.displayMode == ViewerDisplayMode.double &&
                              (state.folderSettings?.isRightToLeft ?? true);
                          final (canGoPrevious, canGoNext) = navigationBounds(
                            state.displayMode == ViewerDisplayMode.double
                                ? controller.currentPageIndex
                                : currentIndex,
                            state.displayMode == ViewerDisplayMode.double
                                ? state.pages.length
                                : images.length,
                          );

                          final showLeft = isRtl ? canGoNext : canGoPrevious;
                          final showRight = isRtl ? canGoPrevious : canGoNext;

                          final leftAction = isRtl
                              ? () {
                                  final current = state.displayMode == ViewerDisplayMode.double ? controller.currentPageIndex : currentIndex;
                                  final total = state.displayMode == ViewerDisplayMode.double ? state.pages.length : images.length;
                                  if (current < total - 1) {
                                    _navigateToPage(controller, state, current + 1);
                                  }
                                }
                              : () {
                                  final current = state.displayMode == ViewerDisplayMode.double ? controller.currentPageIndex : currentIndex;
                                  if (current > 0) {
                                    _navigateToPage(controller, state, current - 1);
                                  }
                                };

                          final rightAction = isRtl
                              ? () {
                                  final current = state.displayMode == ViewerDisplayMode.double ? controller.currentPageIndex : currentIndex;
                                  if (current > 0) {
                                    _navigateToPage(controller, state, current - 1);
                                  }
                                }
                              : () {
                                  final current = state.displayMode == ViewerDisplayMode.double ? controller.currentPageIndex : currentIndex;
                                  final total = state.displayMode == ViewerDisplayMode.double ? state.pages.length : images.length;
                                  if (current < total - 1) {
                                    _navigateToPage(controller, state, current + 1);
                                  }
                                };

                          return Row(
                            children: [
                              if (showLeft)
                                GestureDetector(
                                  onTap: leftAction,
                                  behavior: HitTestBehavior.translucent,
                                  child: Container(
                                    width: 56,
                                    alignment: Alignment.center,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black45,
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: const Icon(
                                        Icons.chevron_left,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                const SizedBox(width: 56),
                              const Expanded(child: SizedBox.shrink()),
                              if (showRight)
                                GestureDetector(
                                  onTap: rightAction,
                                  behavior: HitTestBehavior.translucent,
                                  child: Container(
                                    width: 56,
                                    alignment: Alignment.center,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black45,
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: const Icon(
                                        Icons.chevron_right,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                const SizedBox(width: 56),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );

          if (Platform.isWindows) {
            content = KeyboardNavigationHandler(
              currentIndex: state.displayMode == ViewerDisplayMode.double ? controller.currentPageIndex : currentIndex,
              totalCount: state.displayMode == ViewerDisplayMode.double ? state.pages.length : images.length,
              isZoomed: state.isZoomed,
              onNavigate: (index) => _navigateToPage(controller, state, index),
              onToggleFavorite: _toggleFolderFavorite,
              onZoomIn: _zoomIn,
              onZoomOut: _zoomOut,
              onZoomReset: _zoomReset,
              isRightToLeft: state.displayMode == ViewerDisplayMode.double && (state.folderSettings?.isRightToLeft ?? true),
              child: content,
            );
          }

          return content;
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (e, st) => Center(
          child: Text(
            'エラーが発生しました',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
