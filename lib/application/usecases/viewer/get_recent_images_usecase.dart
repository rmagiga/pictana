import '../../../domain/entities/image_entry.dart';
import '../../../domain/repositories/image_repository.dart';

/// 最近開いた画像履歴を取得するユースケース
class GetRecentImagesUseCase {
  const GetRecentImagesUseCase({required ImageRepository imageRepository})
      : _repo = imageRepository;

  final ImageRepository _repo;

  Future<List<ImageEntry>> execute() async {
    return _repo.getRecentImages();
  }
}
