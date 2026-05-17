/// GetFolderThumbnailUseCase
///
/// フォルダのサムネイル画像を取得するユースケース。
/// フォルダ内の先頭画像からサムネイルを生成して返す。
/// 画像が存在しない場合やサムネイル生成失敗時は null を返す。
library;

import 'dart:typed_data';

import '../../../domain/entities/entry_id.dart';
import '../../../domain/entities/favorite_folder.dart';
import '../../../domain/entities/folder_entry.dart';
import '../../../domain/repositories/image_repository.dart';
import '../../../domain/repositories/thumbnail_repository.dart';
import '../../../domain/value_objects/sort_option.dart';
import '../../../domain/value_objects/thumbnail_size_option.dart';

/// フォルダのサムネイル画像を取得するユースケース
class GetFolderThumbnailUseCase {
  const GetFolderThumbnailUseCase({
    required ImageRepository imageRepository,
    required ThumbnailRepository thumbnailRepository,
  }) : _imageRepository = imageRepository,
       _thumbnailRepository = thumbnailRepository;

  final ImageRepository _imageRepository;
  final ThumbnailRepository _thumbnailRepository;

  /// フォルダ URI から先頭画像のサムネイルを取得する。
  /// 画像が存在しない場合やサムネイル生成失敗時は null を返す。
  Future<Uint8List?> execute({
    required FavoriteFolder folder,
    ThumbnailSizeOption size = ThumbnailSizeOption.medium,
  }) async {
    try {
      // FavoriteFolder.uri から FolderEntry を構築
      final folderEntry = FolderEntry(
        id: EntryId(rawValue: folder.uri, platformType: PlatformType.unknown),
        name: folder.name,
        uri: folder.uri,
      );

      // 先頭画像を1件取得
      final images = await _imageRepository.getImagePage(
        folder: folderEntry,
        page: 0,
        pageSize: 1,
        sort: SortOption.defaultOption,
      );

      // 画像が存在しない場合は null を返す
      if (images.isEmpty) {
        return null;
      }

      // サムネイルを取得して返す
      return _thumbnailRepository.getThumbnail(images.first, size: size);
    } catch (_) {
      // 例外時は null を返す
      return null;
    }
  }
}
