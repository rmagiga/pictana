import '../../../domain/entities/folder_entry.dart';
import '../../../domain/repositories/storage_repository.dart';

/// フォルダを最近開いたフォルダ履歴に記録するユースケース
class RecordRecentFolderUseCase {
  const RecordRecentFolderUseCase({required StorageRepository storageRepository})
      : _repo = storageRepository;

  final StorageRepository _repo;

  Future<void> execute(FolderEntry folder) async {
    await _repo.recordRecentFolder(folder);
  }
}
