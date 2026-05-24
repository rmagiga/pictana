/// PreloadAdjacentImagesUseCase (設計書 §18.4)
///
/// 画像ビューアの高速なスワイプ操作を実現するため、
/// 現在表示中の画像の前後の画像をメモリ上に事前読み込みするユースケース。
library;

import '../../../core/logging/app_logger.dart';
import '../../../domain/entities/image_entry.dart';
import '../../../domain/repositories/image_repository.dart';

class PreloadAdjacentImagesUseCase {
  const PreloadAdjacentImagesUseCase({
    required ImageRepository imageRepository,
  }) : _repo = imageRepository;

  final ImageRepository _repo;

  /// 前後の画像をメモリにプリロードする
  ///
  /// 進行方向（isMovingForward）側の画像を優先的に、前後最大4枚ずつ（計8枚）を
  /// 非同期で読み込みます。
  Future<void> execute(
    List<ImageEntry> entries,
    int currentIndex, {
    bool isMovingForward = true,
  }) async {
    if (entries.isEmpty) return;

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

    // 進行方向側から順に非同期でロードを開始する
    for (final index in targetIndices) {
      try {
        _repo.getImageBytes(entries[index]).ignore();
      } catch (e) {
        // 個別の画像ロードにおける同期的なエラーはログ出力して無視し、他のプリロードを継続する
        appLogger.w('プリロード処理でエラーが発生しました（無視）: index=$index', error: e);
      }
    }
  }
}
