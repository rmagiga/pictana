/// LoadFolderImagesUseCase (設計書 §18.2)
///
/// ギャラリーグリッド表示用の画像一覧取得ユースケース。
/// - フォルダ内画像をページング取得
/// - ソート・フィルター適用
/// - Stream でインクリメンタル表示
library;

import '../../../domain/entities/folder_entry.dart';
import '../../../domain/entities/image_entry.dart';
import '../../../domain/repositories/image_repository.dart';
import '../../../domain/value_objects/sort_option.dart';

/// フォルダ画像読み込み UseCase
class LoadFolderImagesUseCase {
  const LoadFolderImagesUseCase({required ImageRepository imageRepository})
      : _repo = imageRepository;

  final ImageRepository _repo;

  /// フォルダ内の画像を Stream で返す。
  ///
  /// インクリメンタル表示のため、取得済みの分から順次 emit する。
  Stream<List<ImageEntry>> execute({
    required FolderEntry folder,
    SortOption sort = SortOption.defaultOption,
    ImageFilter filter = ImageFilter.none,
  }) {
    return _repo.getImages(
      folder: folder,
      sort: sort,
      filter: filter,
    );
  }

  /// 指定ページの画像一覧を返す（無限スクロール用）。
  Future<List<ImageEntry>> executePage({
    required FolderEntry folder,
    required int page,
    int pageSize = 50,
    SortOption sort = SortOption.defaultOption,
    ImageFilter filter = ImageFilter.none,
  }) {
    return _repo.getImagePage(
      folder: folder,
      page: page,
      pageSize: pageSize,
      sort: sort,
      filter: filter,
    );
  }

  /// フォルダ内の画像総数を返す。
  Future<int> count({
    required FolderEntry folder,
    ImageFilter filter = ImageFilter.none,
  }) {
    return _repo.countImages(folder: folder, filter: filter);
  }
}
