/// GetFolderThumbnailsUseCase
///
/// フォルダ内の先頭4枚のサムネイルを取得するユースケース。
/// ファイル名昇順で最大4枚の画像を選択し、
/// 各画像のサムネイルバイト列を返す。
/// 取得失敗した画像は null として返す。
///
/// Requirements: 2.2, 2.3
library;

import 'dart:io';
import 'dart:typed_data';

import '../../../domain/entities/entry_id.dart';
import '../../../domain/entities/favorite_folder.dart';
import '../../../domain/entities/folder_entry.dart';
import '../../../domain/repositories/image_repository.dart';
import '../../../domain/repositories/storage_repository.dart';
import '../../../domain/repositories/thumbnail_repository.dart';
import '../../../domain/value_objects/sort_option.dart';

/// フォルダ内の先頭4枚のサムネイルを取得するユースケース
class GetFolderThumbnailsUseCase {
  const GetFolderThumbnailsUseCase({
    required ImageRepository imageRepository,
    required ThumbnailRepository thumbnailRepository,
    required StorageRepository storageRepository,
  }) : _imageRepository = imageRepository,
       _thumbnailRepository = thumbnailRepository,
       _storageRepository = storageRepository;

  final ImageRepository _imageRepository;
  final ThumbnailRepository _thumbnailRepository;
  final StorageRepository _storageRepository;

  /// フォルダ内の先頭4枚の画像サムネイルを取得する。
  ///
  /// ファイル名昇順で最大4枚の画像を選択し、各画像のサムネイルバイト列を返す。
  /// 取得失敗した画像は null として返す。
  /// フォルダアクセス失敗時は空リストを返す。
  ///
  /// 戻り値のリスト長は min(4, フォルダ内画像数) となる。
  /// スロット割り当て順序: [top-left, top-right, bottom-left, bottom-right]
  Future<List<Uint8List?>> execute({
    required FavoriteFolder folder,
    ThumbnailSize size = ThumbnailSize.grid,
  }) async {
    try {
      // FavoriteFolder.uri から FolderEntry を構築（プラットフォーム依存のパースは Repository に委譲）
      final folderEntry = _storageRepository.restoreFolderFromUri(
        uri: folder.uri,
        name: folder.name,
      );

      // 先頭4枚の画像をファイル名昇順で取得
      final images = await _imageRepository.getImagePage(
        folder: folderEntry,
        page: 0,
        pageSize: 4,
        sort: SortOption.defaultOption,
      );

      // 画像が存在しない場合は空リストを返す
      if (images.isEmpty) {
        return [];
      }

      // 各画像のサムネイルを取得（失敗時は null）
      final thumbnails = <Uint8List?>[];
      for (final image in images) {
        try {
          final thumbnail = await _thumbnailRepository.getThumbnail(
            image,
            size: size,
          );
          thumbnails.add(thumbnail);
        } catch (_) {
          thumbnails.add(null);
        }
      }

      return thumbnails;
    } catch (_) {
      // フォルダアクセス失敗時は空リストを返す
      return [];
    }
  }
}
