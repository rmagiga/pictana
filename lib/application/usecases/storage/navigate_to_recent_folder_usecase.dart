import 'dart:async';

import '../../../core/errors/favorite_exceptions.dart';
import '../../../domain/entities/folder_entry.dart';
import '../../../domain/repositories/storage_repository.dart';

/// 最近開いたフォルダへのナビゲーションを実行するユースケース
class NavigateToRecentFolderUseCase {
  const NavigateToRecentFolderUseCase({required StorageRepository storageRepository})
      : _storageRepository = storageRepository;

  final StorageRepository _storageRepository;

  /// アクセス確認のタイムアウト時間
  static const Duration accessTimeout = Duration(seconds: 5);

  /// フォルダのアクセス可否を確認し、[FolderEntry] を返す。
  ///
  /// アクセス確認は5秒のタイムアウトを設定し、
  /// タイムアウトまたはアクセス不可の場合は [FolderAccessException] をスローする。
  Future<FolderEntry> execute({required FolderEntry folder}) async {
    // 既に FolderEntry があるため、リストアは不要だが、
    // platformType 等のパースに合わせた安全な FolderEntry の再構築や、
    // URI の再パーミッション確認のため restoreFolderFromUri を呼び出す
    final restoredFolder = _storageRepository.restoreFolderFromUri(
      uri: folder.uri,
      name: folder.name,
    );

    try {
      // フォルダへのアクセス確認（サブフォルダ一覧取得を試行）
      // 5秒タイムアウト付き
      await _storageRepository
          .getSubFolders(restoredFolder)
          .timeout(accessTimeout);

      return restoredFolder;
    } on TimeoutException {
      throw FolderAccessException(
        uri: folder.uri,
        reason: 'フォルダへのアクセスがタイムアウトしました（5秒）',
      );
    } catch (e) {
      throw FolderAccessException(
        uri: folder.uri,
        reason: 'フォルダにアクセスできません: $e',
      );
    }
  }
}
