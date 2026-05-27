import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/image_entry.dart';
import '../../providers/viewer_controller_provider.dart';
import 'viewer_display_mode.dart';
import 'single_page_viewer.dart';
import 'double_page_viewer.dart';

/// 表示モードに応じて適切なビューアコンポーネントを切り替えるコンテナウィジェット
class ViewerDisplayContainer extends ConsumerWidget {
  const ViewerDisplayContainer({
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
    switch (state.displayMode) {
      case ViewerDisplayMode.single:
        return SinglePageViewer(
          images: images,
          state: state,
          controller: controller,
          pageController: pageController,
          transformationController: transformationController,
          onZoomChanged: onZoomChanged,
        );
      case ViewerDisplayMode.double:
        return DoublePageViewer(
          images: images,
          state: state,
          controller: controller,
          pageController: pageController,
          transformationController: transformationController,
          onZoomChanged: onZoomChanged,
        );
      case ViewerDisplayMode.scroll:
        // スクロールモードは現状シングル表示にフォールバック（将来実装）
        return SinglePageViewer(
          images: images,
          state: state,
          controller: controller,
          pageController: pageController,
          transformationController: transformationController,
          onZoomChanged: onZoomChanged,
        );
    }
  }
}
