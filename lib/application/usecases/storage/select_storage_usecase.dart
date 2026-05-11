/// SelectStorageUseCase (設計書 §17.1)
///
/// ユーザーがフォルダ選択ダイアログを経てストレージを登録するユースケース。
/// - OS標準ダイアログを表示
/// - 選択フォルダを最近フォルダに記録
/// - Android では SAF URI 権限を永続化
library;

import '../../../domain/entities/folder_entry.dart';
import '../../../domain/repositories/storage_repository.dart';

/// ストレージ選択 UseCase
class SelectStorageUseCase {
  const SelectStorageUseCase({required StorageRepository storageRepository})
      : _repo = storageRepository;

  final StorageRepository _repo;

  /// フォルダ選択ダイアログを表示し、選択された [FolderEntry] を返す。
  ///
  /// キャンセルされた場合は null を返す。
  Future<FolderEntry?> execute() async {
    final folder = await _repo.selectFolder();
    if (folder == null) return null;

    // SAF URI 権限の永続化（Android のみ有効）
    await _repo.persistUriPermission(folder.uri);

    // 最近フォルダへ記録
    await _repo.recordRecentFolder(folder);

    return folder;
  }
}
