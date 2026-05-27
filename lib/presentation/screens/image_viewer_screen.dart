/// 画像ビューア画面 (設計書 §18.4)
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/image_entry.dart';
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
  const ImageViewerScreen({super.key, required this.initialIndex});

  final int initialIndex;

  @override
  ConsumerState<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends ConsumerState<ImageViewerScreen> {
  late PageController _pageController;
  bool _isPageAnimating = false;
  double _currentScale = 1.0;
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _transformationController.addListener(_onTransformChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recordCurrentImageViewed();
    });
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformChanged);
    _transformationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if ((_currentScale - scale).abs() > 0.001) {
      setState(() {
        _currentScale = scale;
      });
      final images = ref.read(galleryImagesProvider).value;
      if (images != null) {
        ref
            .read(viewerControllerProvider(
              initialIndex: widget.initialIndex,
              totalCount: images.length,
            ).notifier)
            .setZoomed(scale > 1.01);
      }
    }
  }

  void _recordCurrentImageViewed() {
    final images = ref.read(galleryImagesProvider).value;
    if (images != null) {
      final state = ref.read(viewerControllerProvider(
        initialIndex: widget.initialIndex,
        totalCount: images.length,
      ));
      final currentIndex = state.currentIndex;
      if (currentIndex >= 0 && currentIndex < images.length) {
        final currentImage = images[currentIndex];
        ref.read(recentImagesListProvider.notifier).addRecent(currentImage);
        
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

  void _goToPreviousPage(ViewerController controller, ViewerState state, int targetIndex) {
    controller.goToPrevious();
  }

  void _goToNextPage(ViewerController controller, ViewerState state, int targetIndex, int totalCount) {
    controller.goToNext();
  }

  void _showViewerSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ViewerSettingsSheet(
        initialIndex: widget.initialIndex,
        totalCount: ref.read(galleryImagesProvider).value?.length ?? 0,
      ),
    );
  }

  void _navigateToPage(ViewerController controller, ViewerState state, int targetPage) {
    if (_isPageAnimating) {
      final snappedPage = _pageController.page?.round() ?? 
          (state.displayMode == ViewerDisplayMode.double ? controller.currentPageIndex : state.currentIndex);
      _pageController.jumpToPage(snappedPage);
    }

    setState(() => _isPageAnimating = true);
    if (state.displayMode == ViewerDisplayMode.double) {
      controller.setCurrentPageIndex(targetPage);
    } else {
      controller.setCurrentIndex(targetPage);
    }
    
    _pageController
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

  void _showImageInfo(ImageEntry image) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ImageInfoSheet(image: image),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagesAsync = ref.watch(galleryImagesProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: imagesAsync.when(
        data: (images) {
          if (images.isEmpty) {
            return const Center(
              child: Text('画像がありません', style: TextStyle(color: Colors.white)),
            );
          }

          final provider = viewerControllerProvider(
            initialIndex: widget.initialIndex,
            totalCount: images.length,
          );
          final state = ref.watch(provider);
          final controller = ref.read(provider.notifier);

          final currentIndex = state.currentIndex;
          final currentImage = images[currentIndex];

          ref.listen<ViewerState>(provider, (prev, next) {
            if (prev != null && prev.currentIndex != next.currentIndex) {
              final isDouble = next.displayMode == ViewerDisplayMode.double;
              final targetPage = isDouble ? controller.currentPageIndex : next.currentIndex;
              
              if (!_isPageAnimating && _pageController.hasClients && _pageController.page?.round() != targetPage) {
                _pageController.jumpToPage(targetPage);
              }
              _recordCurrentImageViewed();
            }
          });

          Widget pageViewSection = GestureDetector(
            onTap: controller.toggleOverlay,
            child: ViewerDisplayContainer(
              images: images,
              state: state,
              controller: controller,
              pageController: _pageController,
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
                    title: Text(
                      currentImage.name,
                      style: const TextStyle(fontSize: 16),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: _showViewerSettings,
                        tooltip: '表示設定',
                      ),
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () => _showImageInfo(currentImage),
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
                  onPrevious: () => _goToPreviousPage(controller, state, currentIndex - 1),
                  onNext: () => _goToNextPage(controller, state, currentIndex + 1, images.length),
                  isRightToLeft: state.displayMode == ViewerDisplayMode.double && (state.folderSettings?.isRightToLeft ?? true),
                ),
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
        loading: () => const Center(child: CircularProgressIndicator()),
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
