/// コレクション エンティティ
///
/// 画像を論理的にグループ化する仮想フォルダを表現する。
/// 物理ファイルの移動・コピーを伴わず、データベース上の関連付けのみで実現する。
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:pictana/domain/value_objects/collection_name.dart';

part 'collection.freezed.dart';

/// コレクション エンティティ
///
/// コレクション一覧画面で表示される情報を保持する。
/// [imageCount] は DB の COUNT サブクエリで取得される集計値であり、
/// テーブルカラムとしては存在しない。
@freezed
abstract class Collection with _$Collection {
  const factory Collection({
    /// コレクション ID（自動採番）
    required int id,

    /// コレクション名（バリデーション済み値オブジェクト）
    required CollectionName name,

    /// コレクション内の画像数（集計値）
    required int imageCount,

    /// 表示並び順（gap-based、間隔1000）
    required int sortOrder,

    /// 作成日時
    required DateTime createdAt,

    /// 更新日時
    required DateTime updatedAt,

    /// サムネイル用の先頭画像 EntryId（画像未登録時は null）
    String? thumbnailEntryId,
  }) = _Collection;
}
