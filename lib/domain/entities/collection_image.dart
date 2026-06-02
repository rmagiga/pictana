/// コレクション画像 エンティティ
///
/// コレクションに登録された画像への参照を表現する。
/// 物理ファイルへのリンクであり、コピーではない。
/// 1つの画像は複数のコレクションに所属可能。
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:pictana/domain/entities/entry_id.dart';

part 'collection_image.freezed.dart';

/// コレクション画像 エンティティ
///
/// コレクション内の画像一覧で表示される情報を保持する。
/// [entryId] はプラットフォーム固有の画像識別子を抽象化した値オブジェクト。
@freezed
abstract class CollectionImage with _$CollectionImage {
  const factory CollectionImage({
    /// コレクション画像 ID（自動採番）
    required int id,

    /// 所属コレクション ID
    required int collectionId,

    /// 画像の識別子（プラットフォーム差異を抽象化）
    required EntryId entryId,

    /// 表示並び順（gap-based、間隔1000）
    required int sortOrder,

    /// コレクションへの追加日時
    required DateTime addedAt,
  }) = _CollectionImage;
}
