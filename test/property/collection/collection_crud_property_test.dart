/// UseCase ラウンドトリッププロパティテスト
///
/// glados を使用して、コレクション作成・リネームのラウンドトリップ正当性を検証する。
/// インメモリ DB を使用し、UseCase 層を通じた永続化と取得の整合性を保証する。
///
/// テスト対象:
/// - Property 3: コレクション作成のラウンドトリップ
/// - Property 5: コレクションリネームのラウンドトリップ
// Feature: collection-management, Property 3: コレクション作成のラウンドトリップ
// Feature: collection-management, Property 5: コレクションリネームのラウンドトリップ
@Tags(['property-test', 'collection-management'])
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, tearDown, test;
import 'package:pictana/application/usecases/collection/create_collection_use_case.dart';
import 'package:pictana/application/usecases/collection/rename_collection_use_case.dart';
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

extension CollectionCrudGenerators on Any {
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
  /// リネームテスト用: 既存名と新名前が重複しないことを保証する
  Generator<(String, String)> get distinctCollectionNamePair => any.combine2(
    any.validCollectionName,
    any.validCollectionName,
    (String a, String b) {
      // 重複する場合はサフィックスを付加して区別する
      if (a.trim() == b.trim()) {
        final modified = '${b.trim()}x';
        if (modified.length > 50) {
          return (a.trim(), b.trim().substring(0, 49) + 'x');
        }
        return (a.trim(), modified);
      }
      return (a.trim(), b.trim());
    },
  );
}

// ---------------------------------------------------------------------------
// テスト本体
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // Property 3: コレクション作成のラウンドトリップ
  // =========================================================================
  group('Feature: collection-management, Property 3: コレクション作成のラウンドトリップ', () {
    /// **Validates: Requirements 1.1**
    ///
    /// *For any* 有効な CollectionName に対して、`createCollection(name)` で
    /// 作成したコレクションを `getCollectionById(id)` で取得した場合、
    /// 取得結果の `name.value` は作成時に指定した名前と一致する。
    Glados(any.validCollectionName).test(
      'createCollection で作成したコレクションを getCollectionById で取得すると名前が一致する',
      (name) async {
        // Arrange: インメモリ DB とリポジトリ・UseCase を初期化
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        try {
          final repository = CollectionRepositoryImpl(db);
          final createUseCase = CreateCollectionUseCase(repository: repository);

          // Act: UseCase 経由でコレクションを作成
          final created = await createUseCase.execute(name);

          // Assert: getCollectionById で取得した名前が一致する
          final fetched = await repository.getCollectionById(created.id);
          expect(fetched, isNotNull);
          expect(
            fetched!.name.value,
            created.name.value,
            reason: '作成時の名前 "${created.name.value}" と取得結果が一致すべき',
          );

          // trim 後の入力値とも一致する
          expect(
            fetched.name.value,
            name.trim(),
            reason: '取得結果は入力値の trim 後 "${name.trim()}" と一致すべき',
          );
        } finally {
          await db.close();
        }
      },
    );
  });

  // =========================================================================
  // Property 5: コレクションリネームのラウンドトリップ
  // =========================================================================
  group('Feature: collection-management, Property 5: コレクションリネームのラウンドトリップ', () {
    /// **Validates: Requirements 3.2**
    ///
    /// *For any* 既存コレクションと有効な新名前（既存名と重複しない）に対して、
    /// `renameCollection(id, newName)` 実行後に `getCollectionById(id)` で
    /// 取得した結果の `name.value` は新名前と一致する。
    Glados(any.distinctCollectionNamePair).test(
      'renameCollection 後に getCollectionById で取得すると新名前が一致する',
      (pair) async {
        final (originalName, newName) = pair;

        // Arrange: インメモリ DB とリポジトリ・UseCase を初期化
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        try {
          final repository = CollectionRepositoryImpl(db);
          final createUseCase = CreateCollectionUseCase(repository: repository);
          final renameUseCase = RenameCollectionUseCase(repository: repository);

          // 既存コレクションを作成
          final created = await createUseCase.execute(originalName);

          // Act: UseCase 経由でリネーム
          await renameUseCase.execute(created.id, newName);

          // Assert: getCollectionById で取得した名前が新名前と一致する
          final fetched = await repository.getCollectionById(created.id);
          expect(fetched, isNotNull);
          expect(
            fetched!.name.value,
            newName.trim(),
            reason: 'リネーム後の名前 "${newName.trim()}" と取得結果が一致すべき',
          );
        } finally {
          await db.close();
        }
      },
    );
  });
}
