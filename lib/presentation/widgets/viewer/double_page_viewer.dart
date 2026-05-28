import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/usecases/settings/swipe_direction_setting.dart';
import '../../../domain/entities/image_entry.dart';
import '../../providers/viewer_controller_provider.dart';
import '../../providers/viewer_providers.dart';
import 'interactive_image_view.dart';
import 'single_page_viewer.dart';
import 'swipe_direction_controller.dart';

/// 見開き表示（漫画モード）を行うビューアウィジェット
class DoublePageViewer extends ConsumerWidget {
  const DoublePageViewer({
    super.key,
    required this.images,
    required this.state,
    required this.controller,
    required this.pageController,
    required this.transformationController,
    required this.onZoomChanged,
  });

  final List<ImageEntry> images;
  final ViewerState state;
  final ViewerController controller;
  final PageController pageController;
  final TransformationController transformationController;
  final ValueChanged<bool> onZoomChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. 縦持ち（Portrait）時は自動的に SinglePageViewer にフォールバックする
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.size.height > mediaQuery.size.width;

    if (isPortrait) {
      return SinglePageViewer(
        images: images,
        state: state,
        controller: controller,
        pageController: pageController,
        transformationController: transformationController,
        onZoomChanged: onZoomChanged,
      );
    }

    final pages = state.pages;
    if (pages.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    Widget itemBuilder(BuildContext context, int pageIndex) {
      final page = pages[pageIndex];

      // ページが見開き（2枚）構成の場合
      if (page.isDoublePage && page.entries.length >= 2) {
        final isRtl = state.folderSettings?.isRightToLeft ?? true;
        final entryLeft = isRtl ? page.entries[1] : page.entries[0];
        final entryRight = isRtl ? page.entries[0] : page.entries[1];

        return Row(
          key: ValueKey('double_page_${pageIndex}_${entryLeft.id.rawValue}_${entryRight.id.rawValue}'),
          children: [
            Expanded(
              child: InteractiveImageView(
                key: ValueKey('image_left_${entryLeft.id.rawValue}'),
                image: entryLeft,
                // Windowsかつ現在のアクティブ画像と同じ場合のみtransformationControllerを適用
                transformationController: Platform.isWindows && entryLeft.id.rawValue == images[state.currentIndex].id.rawValue
                    ? transformationController
                    : null,
                onZoomChanged: onZoomChanged,
              ),
            ),
            Expanded(
              child: InteractiveImageView(
                key: ValueKey('image_right_${entryRight.id.rawValue}'),
                image: entryRight,
                transformationController: Platform.isWindows && entryRight.id.rawValue == images[state.currentIndex].id.rawValue
                    ? transformationController
                    : null,
                onZoomChanged: onZoomChanged,
              ),
            ),
          ],
        );
      }

      // 単一ページ表示（表紙、横長画像、端数）
      final image = page.entries.first;
      return Center(
        key: ValueKey('single_page_${pageIndex}_${image.id.rawValue}'),
        child: InteractiveImageView(
          key: ValueKey('image_center_${image.id.rawValue}'),
          image: image,
          transformationController: Platform.isWindows && image.id.rawValue == images[state.currentIndex].id.rawValue
              ? transformationController
              : null,
          onZoomChanged: onZoomChanged,
        ),
      );
    }

    void onPageChanged(int pageIndex) {
      // 進行方向の判定
      final currentPageIndex = controller.currentPageIndex;
      final isMovingForward = pageIndex > currentPageIndex;

      // ページインデックスをもとにアクティブな画像インデックスを設定する
      controller.setCurrentPageIndex(pageIndex);

      // 画像の代表インデックスをもとに先読み（プリロード）を実行
      final targetPage = pages[pageIndex];
      if (targetPage.entries.isNotEmpty) {
        final reprImage = targetPage.entries.first;
        final reprIndex = images.indexWhere((img) => img.id.rawValue == reprImage.id.rawValue);
        if (reprIndex >= 0) {
          ref.read(preloadAdjacentImagesUseCaseProvider).execute(
            images,
            reprIndex,
            isMovingForward: isMovingForward,
            pages: pages,
          );
        }
      }
    }

    // Windowsデスクトップの場合はスワイプコントロールを使わず通常のPageViewを使用
    if (Platform.isWindows) {
      return PageView.builder(
        controller: pageController,
        scrollDirection: Axis.horizontal,
        itemCount: pages.length,
        onPageChanged: onPageChanged,
        itemBuilder: itemBuilder,
      );
    }

    // モバイルの場合はスワイプジェスチャー方向の設定に従う
    final swipeDirection = ref.watch(swipeDirectionSettingProvider);
    return SwipeDirectionController(
      direction: swipeDirection,
      isZoomed: state.isZoomed,
      pageController: pageController,
      itemCount: pages.length,
      itemBuilder: itemBuilder,
      onPageChanged: onPageChanged,
    );
  }
}
