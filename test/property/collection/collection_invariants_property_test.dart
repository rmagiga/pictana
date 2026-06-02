/// UseCase 不変条件プロパティテスト
///
/// glados を使用して、コレクション名の一意性と削除時の関連付け除去を検証する。
/// インメモリ DB を使用し、UseCase 層を通じたビジネスルールの正確性を保証する。
///
/// テスト対象:
/// - Property 4: コレクション名の一意性不変条件
/// - Property 6: コレクション削除は全関連付けを除去する
// Feature: collection-management, Property 4: コレクション名の一意性不変条件
// Feature: collection-management, Property 6: コレクション削除は全関連付けを除去する
@Tags(['property-test', 'collection-management'])
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, tearDown, test;
import 'package:pictana/application/usecases/collection/create_collection_use_case.dart';
import 'package:pictana/application/usecases/collection/delete_collection_use_case.dart';
import 'package:pictana/application/usecases/collection/rename_collection_use_case.dart';
import 'package:pictana/core/errors/collection_exceptions.dart';
import 'package:pictana/domain/entities/entry_id.dart';
import 'package:pictana/infrastructure/database/app_database.dart';
import 'package:pictana/infrastructure/database/collection_repository_impl.dart';

// ---------------------------------------------------------------------------
// カスタムジェネレータ
// ---------------------------------------------------------------------------

/// 有効なコレクション名用の文字セット（英数字 + スペース + 絵文字）
const _validChars =
    'abcdefghijklmnopqrstuvwxyz'
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    '0123456789'
    ' 🎨🌟💡📷';

extension CollectionInvariantsGenerators on Any {
  /// 有効なコレクション名を生成する（1〜50文字、改行なし、空白のみでない）
  Generator<String> get validCollectionName =>
      any.nonEmptyStringOf(_validChars).map((s) {
        final trimmed = s.trim();
        if (trimmed.isEmpty) return 'a';
        if (trimmed.length > 50) return trimmed.substring(0, 50);
        return trimmed;
      });

  /// 2つの異なる有効なコレクション名のペアを生成する
  ///
  /// 一意性テスト用: 2つ目の名前が1つ目と異なることを保証する
  Generator<(String, String)> get distinctCollectionNamePair => any.combine2(
    any.validCollectionName,
    any.validCollectionName,
    (String a, String b) {
      if (a.trim() == b.trim()) {
        final modified = '${b.trim()}x';
        if (modified.length > 50) {
          return (a.trim(), '${b.trim().substring(0, 49)}x');
        }
        return (a.trim(), modified);
      }
      return (a.trim(), b.trim());
    },
  );

  /// 画像追加件数を生成する（0〜5枚）
  Generator<int> get imageCount => any.intInRange(0, 5);
}

// ---------------------------------------------------------------------------
// テスト本体
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // Property 4: コレクション名の一意性不変条件
  // =========================================================================
  group('Feature: collection-management, Property 4: コレクション名の一意性不変条件', () {
    /// **Validates: Requirements 1.7**
    ///
    /// *For any* 既存のコレクション名 `existingName` に対して、
    /// 同じ名前で新規作成を試みた場合、操作は重複エラーで拒否される。
    Glados(any.validCollectionName).test(
      '同じ名前で2回作成すると CollectionNameDuplicateException がスローされる',
      (name) async {
        // Arrange: インメモリ DB とリポジトリ・UseCase を初期化
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        try {
          final repository = CollectionRepositoryImpl(db);
          final createUseCase = CreateCollectionUseCase(repository: repository);

          // Act: 1回目の作成は成功する
          await createUseCase.execute(name);

          // Assert: 2回目の同名作成は重複エラーで拒否される
          expect(
            () => createUseCase.execute(name),
            throwsA(isA<CollectionNameDuplicateException>()),
            reason: '同じ名前「$name」での2回目の作成は拒否されるべき',
          );
        } finally {
          await db.close();
        }
      },
    );

    /// **Validates: Requirements 3.3**
    ///
    /// *For any* 2つの異なる名前のコレクションが存在する場合、
    /// 一方を他方の名前にリネームしようとすると重複エラーで拒否される。
    Glados(any.distinctCollectionNamePair).test(
      '既存のコレクション名へのリネームは CollectionNameDuplicateException がスローされる',
      (pair) async {
        final (firstName, secondName) = pair;

        // Arrange: インメモリ DB とリポジトリ・UseCase を初期化
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        try {
          final repository = CollectionRepositoryImpl(db);
          final createUseCase = CreateCollectionUseCase(repository: repository);
          final renameUseCase = RenameCollectionUseCase(repository: repository);

          // 2つのコレクションを作成
          await createUseCase.execute(firstName);
          final second = await createUseCase.execute(secondName);

          // Act & Assert: 2番目のコレクションを1番目の名前にリネームすると拒否される
          expect(
            () => renameUseCase.execute(second.id, firstName),
            throwsA(isA<CollectionNameDuplicateException>()),
            reason: '「$secondName」を既存名「$firstName」にリネームすると拒否されるべき',
          );
        } finally {
          await db.close();
        }
      },
    );
  });

  // =========================================================================
  // Property 6: コレクション削除は全関連付けを除去する
  // =========================================================================
  group('Feature: collection-management, Property 6: コレクション削除は全関連付けを除去する', () {
    /// **Validates: Requirements 2.1**
    ///
    /// *For any* コレクション（0枚以上の画像を含む）に対して、
    /// `deleteCollection(id)` 実行後に `getCollectionById(id)` は `null` を返し、
    /// `getCollectionImages(id)` は空リストを返す。
    Glados(any.imageCount).test(
      'コレクション削除後は getCollectionById が null、getCollectionImages が空リストを返す',
      (numImages) async {
        // Arrange: インメモリ DB とリポジトリ・UseCase を初期化
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        try {
          final repository = CollectionRepositoryImpl(db);
          final createUseCase = CreateCollectionUseCase(repository: repository);
          final deleteUseCase = DeleteCollectionUseCase(repository: repository);

          // コレクションを作成
          final collection = await createUseCase.execute('テストコレクション');

          // 画像を追加（numImages 枚）
          if (numImages > 0) {
            final entryIds = List.generate(
              numImages,
              (i) => EntryId(
                rawValue: 'test_image_$i.jpg',
                platformType: PlatformType.windows,
              ),
            );
            await repository.addImages(collection.id, entryIds);

            // 画像が正しく追加されたことを確認
            final imagesBefore = await repository.getCollectionImages(
              collection.id,
            );
            expect(
              imagesBefore.length,
              numImages,
              reason: '削除前に $numImages 枚の画像が登録されているべき',
            );
          }

          // Act: コレクションを削除
          await deleteUseCase.execute([collection.id]);

          // Assert: コレクションが null になる
          final fetchedCollection = await repository.getCollectionById(
            collection.id,
          );
          expect(
            fetchedCollection,
            isNull,
            reason: '削除後の getCollectionById は null を返すべき',
          );

          // Assert: コレクション画像が空リストになる
          final fetchedImages = await repository.getCollectionImages(
            collection.id,
          );
          expect(
            fetchedImages,
            isEmpty,
            reason: '削除後の getCollectionImages は空リストを返すべき',
          );
        } finally {
          await db.close();
        }
      },
    );
  });
}
