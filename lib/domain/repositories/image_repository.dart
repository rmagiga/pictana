/// ImageRepository Interface (設計書 §9.2)
///
/// 責務:
/// - 画像列挙
/// - 画像取得
/// - metadata取得
/// - ファイル名検索
/// - 形式フィルター
library;

import '../entities/folder_entry.dart';
import '../entities/image_entry.dart';
import '../value_objects/sort_option.dart';

/// 画像フィルター条件
class ImageFilter {
  const ImageFilter({
    this.nameQuery,
    this.mimeTypes,
  });

  /// ファイル名検索クエリ（null の場合はフィルターなし）
  final String? nameQuery;

  /// 許可する MIME type セット（null の場合は全形式）
  final Set<ImageMimeType>? mimeTypes;

  /// フィルターなしの定数
  static const none = ImageFilter();

  bool get hasFilter => nameQuery != null || mimeTypes != null;
}

abstract interface class ImageRepository {
  /// 指定フォルダ内の画像一覧を返す。
  ///
  /// [filter] でファイル名・形式絞り込み可能。
  /// [sort] でソート順を指定。
  ///
  /// 大量ファイル対応のため Stream で返す。
  /// 取得済み分から順次 emit することで インクリメンタル表示を実現する。
  Stream<List<ImageEntry>> getImages({
    required FolderEntry folder,
    SortOption sort = SortOption.defaultOption,
    ImageFilter filter = ImageFilter.none,
  });

  /// 指定ページの画像リストを返す（無限スクロール用）。
  Future<List<ImageEntry>> getImagePage({
    required FolderEntry folder,
    required int page,
    required int pageSize,
    SortOption sort = SortOption.defaultOption,
    ImageFilter filter = ImageFilter.none,
  });

  /// フォルダ内の画像総数を返す。
  Future<int> countImages({
    required FolderEntry folder,
    ImageFilter filter = ImageFilter.none,
  });

  /// 指定画像のメタデータを取得する（EXIF含む）。
  Future<ImageEntry> getImageMetadata(ImageEntry entry);

  /// 画像データのバイト列を返す（ビューア用）。
  ///
  /// 同期IOは禁止。必ず非同期で返す。
  Future<List<int>> getImageBytes(ImageEntry entry);
}
