/// FolderEntry Entity (設計書 §9.1)
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import 'entry_id.dart';

part 'folder_entry.freezed.dart';
part 'folder_entry.g.dart';

/// フォルダエントリ Entity
@freezed
abstract class FolderEntry with _$FolderEntry {
  const FolderEntry._();

  const factory FolderEntry({
    /// プラットフォーム固有識別子
    required EntryId id,

    /// フォルダ名
    required String name,

    /// アクセス用 URI 文字列
    required String uri,

    /// フォルダ内画像枚数。未スキャン時は null。
    int? imageCount,

    /// 親フォルダの EntryId。ルートの場合は null。
    EntryId? parentId,
  }) = _FolderEntry;

  factory FolderEntry.fromJson(Map<String, dynamic> json) =>
      _$FolderEntryFromJson(json);
}

extension FolderEntryX on FolderEntry {
  /// ルートフォルダかどうか
  bool get isRoot => parentId == null;

  /// 画像枚数の表示文字列
  String get imageCountLabel {
    if (imageCount == null) return '';
    return '$imageCount 枚';
  }
}
