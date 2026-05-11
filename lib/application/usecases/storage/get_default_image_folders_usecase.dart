/// GetDefaultImageFoldersUseCase (設計書 §17.1)
///
/// 起動時の自動フォルダ検出。
/// - OS既定の画像フォルダを取得
/// - 最近フォルダ一覧を取得
/// - フォルダが見つからなければ null を返し、選択画面へ誘導する
library;

import '../../../domain/entities/folder_entry.dart';
import '../../../domain/repositories/storage_repository.dart';

/// OS既定画像フォルダ + 最近フォルダ取得 UseCase
class GetDefaultImageFoldersUseCase {
  const GetDefaultImageFoldersUseCase({
    required StorageRepository storageRepository,
  }) : _repo = storageRepository;

  final StorageRepository _repo;

  /// 起動時のフォルダ情報を取得する。
  ///
  /// 返り値:
  /// - [defaultFolder]: OS既定の画像フォルダ（見つからなければ null）
  /// - [recentFolders]: 最近開いたフォルダ一覧（最大20件）
  Future<DefaultFolderResult> execute() async {
    final results = await Future.wait([
      _repo.getDefaultImageFolder(),
      _repo.getRecentFolders(),
    ]);
    return DefaultFolderResult(
      defaultFolder: results[0] as FolderEntry?,
      recentFolders: results[1] as List<FolderEntry>,
    );
  }
}

/// 起動時フォルダ検出の結果型
class DefaultFolderResult {
  const DefaultFolderResult({
    required this.defaultFolder,
    required this.recentFolders,
  });

  /// OS既定の画像フォルダ（見つからなければ null）
  final FolderEntry? defaultFolder;

  /// 最近開いたフォルダ一覧
  final List<FolderEntry> recentFolders;

  /// ストレージ選択画面を表示する必要があるか
  bool get needsStorageSelection =>
      defaultFolder == null && recentFolders.isEmpty;
}
