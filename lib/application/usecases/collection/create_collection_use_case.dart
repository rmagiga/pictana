/// CreateCollectionUseCase
///
/// コレクション新規作成のユースケース。
/// 名前バリデーション → 重複チェック → 永続化 の順で処理する。
/// バリデーション失敗時は [CollectionNameException] をスローし、
/// 重複検出時は [CollectionNameDuplicateException] をスローする。
library;

import '../../../core/errors/collection_exceptions.dart';
import '../../../domain/entities/collection.dart';
import '../../../domain/repositories/collection_repository.dart';
import '../../../domain/value_objects/collection_name.dart';

/// コレクション新規作成ユースケース
///
/// 責務:
/// - CollectionName バリデーション（空文字・文字数・改行チェック）
/// - 既存コレクション名との重複チェック
/// - コレクションの永続化
class CreateCollectionUseCase {
  const CreateCollectionUseCase({required CollectionRepository repository})
    : _repository = repository;

  final CollectionRepository _repository;

  /// コレクションを新規作成する。
  ///
  /// [name] には未検証の生文字列を渡す。
  /// 内部で trim・バリデーション・重複チェックを実施した上で永続化する。
  ///
  /// バリデーション失敗時:
  /// - 空文字 → [CollectionNameEmptyException]
  /// - 51文字以上 → [CollectionNameTooLongException]
  /// - 改行含む → [CollectionNameContainsNewlineException]
  ///
  /// 重複検出時:
  /// - [CollectionNameDuplicateException]
  Future<Collection> execute(String name) async {
    // 1. CollectionName バリデーション（trim + ルールチェック）
    final collectionName = CollectionName.create(name);

    // 2. 重複チェック
    final isDuplicate = await _repository.isNameDuplicate(collectionName.value);
    if (isDuplicate) {
      throw CollectionNameDuplicateException(
        existingName: collectionName.value,
      );
    }

    // 3. 永続化
    return _repository.createCollection(collectionName);
  }
}
