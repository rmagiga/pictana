/// GoRouter 定義 (設計書 §17)
///
/// 画面遷移チェーン:
/// Image Viewer → Gallery Grid → Folder Browser → Storage Selection
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/screens/collection_image_detail_screen.dart';
import '../presentation/screens/collection_image_list_screen.dart';
import '../presentation/screens/collection_list_screen.dart';
import '../presentation/screens/folder_browser_screen.dart';
import '../presentation/screens/gallery_grid_screen.dart';
import '../presentation/screens/image_viewer_screen.dart';
import '../presentation/screens/settings_screen.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/storage_selection_screen.dart';

/// ルートパス定数
abstract final class AppRoutes {
  static const splash = '/';
  static const storageSelection = '/storage';
  static const folderBrowser = '/folders';
  static const galleryGrid = '/gallery';
  static const imageViewer = '/viewer';
  static const collectionList = '/collections';
  static const collectionImages = '/collection-images';
  static const collectionViewer = '/collection-viewer';
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
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.collectionList,
      name: 'collectionList',
      builder: (context, state) => const CollectionListScreen(),
    ),
    GoRoute(
      path: '${AppRoutes.collectionImages}/:id',
      name: 'collectionImages',
      builder: (context, state) {
        final idStr = state.pathParameters['id'] ?? '0';
        final id = int.tryParse(idStr) ?? 0;
        return CollectionImageListScreen(collectionId: id);
      },
    ),
    GoRoute(
      path: '${AppRoutes.collectionViewer}/:collectionId/:entryId',
      name: 'collectionViewer',
      builder: (context, state) {
        final collectionIdStr = state.pathParameters['collectionId'] ?? '0';
        final collectionId = int.tryParse(collectionIdStr) ?? 0;
        final entryId = state.pathParameters['entryId'] ?? '';
        return CollectionImageDetailScreen(
          collectionId: collectionId,
          initialEntryId: Uri.decodeComponent(entryId),
        );
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('エラー')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text('ページが見つかりません'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.storageSelection),
            child: const Text('ホームに戻る'),
          ),
        ],
      ),
    ),
  ),
);
