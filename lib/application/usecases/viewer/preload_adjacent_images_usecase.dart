/// PreloadAdjacentImagesUseCase (設計書 §18.4)
///
/// 画像ビューアの高速なスワイプ操作を実現するため、
/// 現在表示中の画像の前後の画像をメモリ上に事前読み込みするユースケース。
library;

import '../../../core/logging/app_logger.dart';
import '../../../domain/entities/image_entry.dart';
import '../../../domain/repositories/image_repository.dart';
import '../../../presentation/widgets/viewer/viewer_page_model.dart';

class PreloadAdjacentImagesUseCase {
  const PreloadAdjacentImagesUseCase({
    required ImageRepository imageRepository,
  }) : _repo = imageRepository;

  final ImageRepository _repo;

  /// 前後の画像をメモリにプリロードする
  ///
  /// 見開きモード（pagesが指定されている場合）は、ページ単位で前後のペアを先読みします。
  /// 通常モードは、進行方向（isMovingForward）側の画像を優先的に前後最大4枚ずつを非同期で読み込みます。
  Future<void> execute(
    List<ImageEntry> entries,
    int currentIndex, {
    bool isMovingForward = true,
    List<ViewerPageModel>? pages,
  }) async {
    if (entries.isEmpty) return;

    final targetImages = <ImageEntry>[];

    if (pages != null && pages.isNotEmpty) {
      // 見開きモード時のプリロード (前後2ページ = 最大4〜8枚)
      const pagePreloadCount = 2;
      final currentImage = entries[currentIndex];
      final currentPageIndex = pages.indexWhere(
        (p) => p.entries.any((e) => e.id.rawValue == currentImage.id.rawValue),
      );

      if (currentPageIndex >= 0) {
        final targetPageIndices = <int>[];

        // 1. 進行方向のページインデックスを追加
        for (int i = 1; i <= pagePreloadCount; i++) {
          final index = isMovingForward ? currentPageIndex + i : currentPageIndex - i;
          if (index >= 0 && index < pages.length) {
            targetPageIndices.add(index);
          }
        }

        // 2. 逆方向のページインデックスを追加
        for (int i = 1; i <= pagePreloadCount; i++) {
          final index = isMovingForward ? currentPageIndex - i : currentPageIndex + i;
          if (index >= 0 && index < pages.length) {
            targetPageIndices.add(index);
          }
        }

        // インデックスに該当する全画像を取得
        for (final idx in targetPageIndices) {
          targetImages.addAll(pages[idx].entries);
        }
      }
    } else {
      // 通常モード時のプリロード
      const preloadCount = 4;
      final targetIndices = <int>[];

      // 1. 進行方向のプリロード対象を追加
      for (int i = 1; i <= preloadCount; i++) {
        final index = isMovingForward ? currentIndex + i : currentIndex - i;
        if (index >= 0 && index < entries.length) {
          targetIndices.add(index);
        }
      }

      // 2. 逆方向のプリロード対象を追加
      for (int i = 1; i <= preloadCount; i++) {
        final index = isMovingForward ? currentIndex - i : currentIndex + i;
        if (index >= 0 && index < entries.length) {
          targetIndices.add(index);
        }
      }

      for (final idx in targetIndices) {
        targetImages.add(entries[idx]);
      }
    }

    // 順に非同期でロードを開始する
    for (final image in targetImages) {
      try {
        _repo.getImageBytes(image).ignore();
      } catch (e) {
        appLogger.w('プリロード処理でエラーが発生しました（無視）: uri=${image.uri}', error: e);
      }
    }
  }
}
