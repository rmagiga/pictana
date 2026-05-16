/// 検索フィルター純粋関数 (Req 11.2, 11.6, 12.2, 12.3, 12.4)
library;

import '../entities/image_entry.dart';

/// ファイル名検索 + MIME type フィルターを適用する純粋関数。
///
/// [images] に対して以下の条件を AND 結合でフィルタリングする:
/// - [query] が空でない場合: ファイル名に大文字小文字無視で部分一致
/// - [mimeTypeFilter] が null でない場合: MIME type が一致
///
/// 両条件が無効（query が空かつ mimeTypeFilter が null）の場合は元リストをそのまま返す。
List<ImageEntry> applySearchFilter({
  required List<ImageEntry> images,
  required String query,
  required ImageMimeType? mimeTypeFilter,
}) {
  var result = images;
  if (query.isNotEmpty) {
    final lowerQuery = query.toLowerCase();
    result = result
        .where((e) => e.name.toLowerCase().contains(lowerQuery))
        .toList();
  }
  if (mimeTypeFilter != null) {
    result = result.where((e) => e.mimeType == mimeTypeFilter).toList();
  }
  return result;
}
