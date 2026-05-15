/// NavigateToFavoriteUseCase
///
/// お気に入りフォルダへのナビゲーションを実行するユースケース。
/// フォルダのアクセス可否を確認し、アクセス可能であれば FolderEntry を返す。
/// アクセス不可の場合は FolderAccessException をスローする。
library;

import 'dart:async';

import '../../../core/errors/favorite_exceptions.dart';
import '../../../domain/entities/entry_id.dart';
import '../../../domain/entities/folder_entry.dart';
import '../../../domain/repositories/favorite_repository.dart';
import '../../../domain/repositories/storage_repository.dart';
import '../../../domain/entities/favorite_folder.dart';

/// お気に入りフォルダへのナビゲーションを実行するユースケース
class NavigateToFavoriteUseCase {
  const NavigateToFavoriteUseCase({
    required FavoriteRepository favoriteRepository,
    required StorageRepository storageRepository,
  }) : _favoriteRepository = favoriteRepository,
       _storageRepository = storageRepository;

  // ignore: unused_field, デザイン仕様に基づくフィールド（将来の拡張用）
  final FavoriteRepository _favoriteRepository;
  final StorageRepository _storageRepository;

  /// アクセス確認のタイムアウト時間
  static const Duration accessTimeout = Duration(seconds: 5);

  /// フォルダのアクセス可否を確認し、[FolderEntry] を返す。
  ///
  /// [favorite] で指定されたお気に入りフォルダに対して、
  /// ストレージリポジトリ経由でアクセス確認を行う。
  ///
  /// アクセス確認は5秒のタイムアウトを設定し、
  /// タイムアウトまたはアクセス不可の場合は [FolderAccessException] をスローする。
  Future<FolderEntry> execute({required FavoriteFolder favorite}) async {
    // FavoriteFolder から FolderEntry を構築
    final folderEntry = _buildFolderEntry(favorite);

    try {
      // フォルダへのアクセス確認（サブフォルダ一覧取得を試行）
      // 5秒タイムアウト付き
      await _storageRepository
          .getSubFolders(folderEntry)
          .timeout(accessTimeout);

      return folderEntry;
    } on TimeoutException {
      throw FolderAccessException(
        uri: favorite.uri,
        reason: 'フォルダへのアクセスがタイムアウトしました（5秒）',
      );
    } catch (e) {
      throw FolderAccessException(
        uri: favorite.uri,
        reason: 'フォルダにアクセスできません: $e',
      );
    }
  }

  /// [FavoriteFolder] から [FolderEntry] を構築する
  FolderEntry _buildFolderEntry(FavoriteFolder favorite) {
    // URI のスキームからプラットフォームを判定
    final platformType = favorite.uri.startsWith('content://')
        ? PlatformType.android
        : PlatformType.windows;

    return FolderEntry(
      id: EntryId(rawValue: favorite.uri, platformType: platformType),
      name: favorite.name,
      uri: favorite.uri,
      parentId: null,
    );
  }
}
