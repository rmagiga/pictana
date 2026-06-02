/// RenameCollectionUseCase
///
/// コレクション名変更のユースケース。
/// 名前バリデーション → 重複チェック（自身を除外）→ 更新 の順で処理する。
/// バリデーション失敗時は [CollectionNameException] をスローし、
/// 重複検出時は [CollectionNameDuplicateException] をスローする。
library;

import '../../../core/errors/collection_exceptions.dart';
import '../../../domain/entities/collection.dart';
import '../../../domain/repositories/collection_repository.dart';
import '../../../domain/value_objects/collection_name.dart';

/// コレクション名変更ユースケース
///
/// 責務:
/// - CollectionName バリデーション（空文字・文字数・改行チェック）
/// - 既存コレクション名との重複チェック（自身を除外）
/// - コレクション名の更新
class RenameCollectionUseCase {
  const RenameCollectionUseCase({required CollectionRepository repository})
    : _repository = repository;

  final CollectionRepository _repository;

  /// コレクション名を変更する。
  ///
  /// [id] は変更対象のコレクション ID。
  /// [newName] には未検証の生文字列を渡す。
  /// 内部で trim・バリデーション・重複チェックを実施した上で更新する。
  ///
  /// バリデーション失敗時:
  /// - 空文字 → [CollectionNameEmptyException]
  /// - 51文字以上 → [CollectionNameTooLongException]
  /// - 改行含む → [CollectionNameContainsNewlineException]
  ///
  /// 重複検出時（自身以外の既存名と一致）:
  /// - [CollectionNameDuplicateException]
  Future<Collection> execute(int id, String newName) async {
    // 1. CollectionName バリデーション（trim + ルールチェック）
    final collectionName = CollectionName.create(newName);

    // 2. 重複チェック（自身を除外）
    final isDuplicate = await _repository.isNameDuplicate(
      collectionName.value,
      excludeId: id,
    );
    if (isDuplicate) {
      throw CollectionNameDuplicateException(
        existingName: collectionName.value,
      );
    }

    // 3. 更新
    return _repository.renameCollection(id, collectionName);
  }
}
