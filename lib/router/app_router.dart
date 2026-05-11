/// GoRouter 定義 (設計書 §17)
///
/// 画面遷移チェーン:
/// Image Viewer → Gallery Grid → Folder Browser → Storage Selection
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/screens/folder_browser_screen.dart';
import '../presentation/screens/gallery_grid_screen.dart';
import '../presentation/screens/image_viewer_screen.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/storage_selection_screen.dart';

/// ルートパス定数
abstract final class AppRoutes {
  static const splash = '/';
  static const storageSelection = '/storage';
  static const folderBrowser = '/folders';
  static const galleryGrid = '/gallery';
  static const imageViewer = '/viewer';
  static const settings = '/settings';
}

/// GoRouter インスタンス
final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.storageSelection,
      name: 'storageSelection',
      builder: (context, state) => const StorageSelectionScreen(),
    ),
    GoRoute(
      path: AppRoutes.folderBrowser,
      name: 'folderBrowser',
      builder: (context, state) => const FolderBrowserScreen(),
    ),
    GoRoute(
      path: AppRoutes.galleryGrid,
      name: 'galleryGrid',
      builder: (context, state) => const GalleryGridScreen(),
    ),
    GoRoute(
      path: '${AppRoutes.imageViewer}/:index',
      name: 'imageViewer',
      builder: (context, state) {
        final indexStr = state.pathParameters['index'] ?? '0';
        final index = int.tryParse(indexStr) ?? 0;
        return ImageViewerScreen(initialIndex: index);
      },
    ),
    GoRoute(
      path: AppRoutes.settings,
      name: 'settings',
      builder: (context, state) {
        // Phase 5で実装
        return const Scaffold(
          body: Center(child: Text('設定 (Phase 5)')),
        );
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('ページが見つかりません: ${state.error}'),
    ),
  ),
);
