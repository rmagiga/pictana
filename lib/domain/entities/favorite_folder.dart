/// FavoriteFolder Entity
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorite_folder.freezed.dart';
part 'favorite_folder.g.dart';

/// お気に入りフォルダ Entity
@freezed
abstract class FavoriteFolder with _$FavoriteFolder {
  const factory FavoriteFolder({
    /// 主キー（自動インクリメント）
    required int id,

    /// フォルダ URI（ユニーク制約）
    required String uri,

    /// フォルダ表示名
    required String name,

    /// お気に入り登録日時
    required DateTime registeredAt,
  }) = _FavoriteFolder;

  factory FavoriteFolder.fromJson(Map<String, dynamic> json) =>
      _$FavoriteFolderFromJson(json);
}
