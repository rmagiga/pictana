import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/usecases/settings/swipe_direction_setting.dart';
import '../../../domain/entities/image_entry.dart';
import '../../providers/viewer_controller_provider.dart';
import '../../providers/viewer_providers.dart';
import 'interactive_image_view.dart';
import 'swipe_direction_controller.dart';

/// 1ページずつ画像を表示する標準ビューアウィジェット
class SinglePageViewer extends ConsumerWidget {
  const SinglePageViewer({
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
    Widget itemBuilder(BuildContext context, int index) {
      final image = images[index];
      return InteractiveImageView(
        key: ValueKey('single_image_${index}_${image.id.rawValue}'),
        image: image,
        transformationController: Platform.isWindows && index == state.currentIndex
            ? transformationController
            : null,
        onZoomChanged: onZoomChanged,
      );
    }

    void onPageChanged(int index) {
      final isMovingForward = index > state.currentIndex;
      controller.setCurrentIndex(index);

      ref.read(preloadAdjacentImagesUseCaseProvider).execute(
        images,
        index,
        isMovingForward: isMovingForward,
      );
    }

    if (Platform.isWindows) {
      return PageView.builder(
        controller: pageController,
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        onPageChanged: onPageChanged,
        itemBuilder: itemBuilder,
      );
    }

    final swipeDirection = ref.watch(swipeDirectionSettingProvider);
    return SwipeDirectionController(
      direction: swipeDirection,
      isZoomed: state.isZoomed,
      pageController: pageController,
      itemCount: images.length,
      itemBuilder: itemBuilder,
      onPageChanged: onPageChanged,
    );
  }
}
