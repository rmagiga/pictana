import '../../../domain/repositories/image_repository.dart';

/// フォルダ内の最終閲覧位置（続き位置）の保存・取得を管理するユースケース
class ResumePositionUseCase {
  const ResumePositionUseCase({required ImageRepository imageRepository})
      : _repo = imageRepository;

  final ImageRepository _repo;

  /// 続き位置を保存する
  Future<void> savePosition({
    required String folderUri,
    required String entryId,
  }) async {
    await _repo.saveLastViewedEntryId(folderUri, entryId);
  }

  /// 続き位置を取得する
  Future<String?> getPosition(String folderUri) async {
    return _repo.getLastViewedEntryId(folderUri);
  }
}
