import '../../../domain/entities/image_entry.dart';
import '../../../domain/repositories/image_repository.dart';

/// 最近開いた画像を記録するユースケース
class RecordRecentImageUseCase {
  const RecordRecentImageUseCase({required ImageRepository imageRepository})
      : _repo = imageRepository;

  final ImageRepository _repo;

  Future<void> execute(ImageEntry image) async {
    await _repo.recordRecentImage(image);
  }
}
