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
  /// （MVPフェーズでは ImageProvider のキャッシュ任せにするか、
  ///   ここで明示的にバイト列を読んで捨てることで OS キャッシュに乗せる）
  Future<void> execute(List<ImageEntry> entries, int currentIndex) async {
    if (entries.isEmpty) return;

    final nextIndex = currentIndex + 1;
    final prevIndex = currentIndex - 1;

    try {
      if (nextIndex < entries.length) {
        // 次の画像を非同期で読み込む
        _repo.getImageBytes(entries[nextIndex]).ignore();
      }
      if (prevIndex >= 0) {
        // 前の画像を非同期で読み込む
        _repo.getImageBytes(entries[prevIndex]).ignore();
      }
    } catch (e) {
      appLogger.w('プリロード中にエラーが発生しました（無視）', error: e);
    }
  }
}
