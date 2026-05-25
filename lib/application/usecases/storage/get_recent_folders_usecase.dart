import '../../../domain/entities/folder_entry.dart';
import '../../../domain/repositories/storage_repository.dart';

/// 最近開いたフォルダ履歴を取得するユースケース
class GetRecentFoldersUseCase {
  const GetRecentFoldersUseCase({required StorageRepository storageRepository})
      : _repo = storageRepository;

  final StorageRepository _repo;

  Future<List<FolderEntry>> execute() async {
    return _repo.getRecentFolders();
  }
}
