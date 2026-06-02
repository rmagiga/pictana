/// CollectionRepository Interface
///
/// 責務:
/// - コレクションの CRUD 操作
/// - コレクション内画像の追加・解除・並び替え
/// - コレクション名の重複チェック
/// - コレクション・画像の並び順管理
///
/// 実装は Infrastructure 層（Drift）が提供する。
/// Domain/Application 層はこの Interface のみに依存する。
library;

import 'package:pictana/domain/entities/collection.dart';
import 'package:pictana/domain/entities/collection_image.dart';
import 'package:pictana/domain/entities/entry_id.dart';
import 'package:pictana/domain/value_objects/collection_name.dart';

/// コレクションリポジトリインターフェース
abstract interface class CollectionRepository {
  /// コレクション一覧を sortOrder 昇順で取得する
  Future<List<Collection>> getCollections();

  /// コレクション一覧を sortOrder 昇順で監視する
  Stream<List<Collection>> watchCollections();

  /// 指定 ID のコレクションを取得する
  Future<Collection?> getCollectionById(int id);

  /// コレクションを新規作成する
  Future<Collection> createCollection(CollectionName name);

  /// コレクションを削除する（関連する CollectionImage も CASCADE 削除）
  Future<void> deleteCollection(int id);

  /// 複数コレクションを一括削除する
  Future<void> deleteCollections(List<int> ids);

  /// コレクション名を変更する
  Future<Collection> renameCollection(int id, CollectionName newName);

  /// コレクション名の重複チェック（自身を除外可能）
  Future<bool> isNameDuplicate(String name, {int? excludeId});

  /// コレクション一覧の並び順を更新する
  Future<void> reorderCollections(List<int> orderedIds);

  /// コレクションに画像を追加する（重複はスキップ）
  ///
  /// 戻り値は実際に追加された件数。
  Future<int> addImages(int collectionId, List<EntryId> entryIds);

  /// コレクションから画像を解除する
  Future<void> removeImages(int collectionId, List<EntryId> entryIds);

  /// コレクション内の画像一覧を sortOrder 昇順で取得する
  Future<List<CollectionImage>> getCollectionImages(int collectionId);

  /// コレクション内の画像一覧を sortOrder 昇順で監視する
  Stream<List<CollectionImage>> watchCollectionImages(int collectionId);

  /// コレクション内画像の並び順を更新する
  Future<void> reorderImages(int collectionId, List<EntryId> orderedEntryIds);

  /// 指定画像が所属するコレクション一覧を取得する
  Future<List<Collection>> getCollectionsForImage(EntryId entryId);

  /// 指定画像群の各コレクションへの所属状態を取得する
  ///
  /// 戻り値の Map は collectionId をキーとし、
  /// 対象画像群がすべてそのコレクションに所属している場合に true を返す。
  Future<Map<int, bool>> getImageMembership(
    List<EntryId> entryIds,
    List<int> collectionIds,
  );

  /// コレクション内の画像数を取得する
  Future<int> getImageCount(int collectionId);
}
