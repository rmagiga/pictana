/// ギャラリーグリッド画面 (設計書 §18.3)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_router.dart';
import '../providers/gallery_providers.dart';
import '../widgets/image_grid_tile.dart';
import '../widgets/sort_menu.dart';
import '../widgets/storage_disconnect_banner.dart';

class GalleryGridScreen extends ConsumerWidget {
  const GalleryGridScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folder = ref.watch(currentFolderProvider);
    final imagesAsync = ref.watch(galleryImagesProvider);
    final countAsync = ref.watch(galleryImageCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(folder?.name ?? 'Optrig Gallery'),
            if (countAsync.valueOrNull != null)
              Text(
                '${countAsync.value} items',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        actions: [
          // 検索ボタン (Phase 5)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 検索UIのトグル
            },
          ),
          // ソートメニュー
          const SortMenu(),
          // 設定ボタン
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Settings画面へ
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const StorageDisconnectBanner(), // USB切断時のみ表示される
          Expanded(
            child: imagesAsync.when(
              data: (images) {
                if (images.isEmpty) {
                  return const Center(
                    child: Text('画像が見つかりません。'),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    // 画面幅に応じて列数を動的に変更
                    final crossAxisCount = (constraints.maxWidth / 150).floor().clamp(3, 10);

                    return GridView.builder(
                      padding: const EdgeInsets.all(4),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        final image = images[index];
                        return ImageGridTile(
                          image: image,
                          onTap: () {
                            // TODO: Image Viewer へ遷移 (Phase 4)
                          },
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('エラーが発生しました: $e'),
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
      // FABでフォルダ再選択 (Windows向け簡易UI)
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(AppRoutes.storageSelection),
        tooltip: '別のフォルダを開く',
        child: const Icon(Icons.folder_open),
      ),
    );
  }
}
