/// UseCase 画像操作プロパティテスト
///
/// glados を使用して、コレクションへの画像追加・解除に関するプロパティを検証する。
/// インメモリ DB を使用し、UseCase 層を通じた画像操作の正確性を保証する。
///
/// テスト対象:
/// - Property 7: 画像解除は対象コレクションのみに影響する
/// - Property 8: 画像追加の冪等性
/// - Property 9: 複数コレクション所属
// Feature: collection-management, Property 7: 画像解除は対象コレクションのみに影響する
// Feature: collection-management, Property 8: 画像追加の冪等性
// Feature: collection-management, Property 9: 複数コレクション所属
@Tags(['property-test', 'collection-management'])
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, tearDown, test;
import 'package:pictana/application/usecases/collection/add_images_to_collection_use_case.dart';
import 'package:pictana/application/usecases/collection/create_collection_use_case.dart';
import 'package:pictana/application/usecases/collection/remove_images_from_collection_use_case.dart';
import 'package:pictana/domain/entities/entry_id.dart';
import 'package:pictana/infrastructure/database/app_database.dart';
import 'package:pictana/infrastructure/database/collection_repository_impl.dart';

// ---------------------------------------------------------------------------
// カスタムジェネレータ
// ---------------------------------------------------------------------------

/// 有効なコレクション名用の文字セット
const _validChars =
    'abcdefghijklmnopqrstuvwxyz'
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    '0123456789'
    ' ';

/// テスト用 EntryId を生成するヘルパー
EntryId _testEntryId(String value) =>
    EntryId(rawValue: value, platformType: PlatformType.windows);

extension CollectionImageGenerators on Any {
  /// 有効なコレクション名を生成する（1〜50文字、改行なし、空白のみでない）
  Generator<String> get validCollectionName =>
      any.nonEmptyStringOf(_validChars).map((s) {
        final trimmed = s.trim();
        if (trimmed.isEmpty) return 'a';
        if (trimmed.length > 50) return trimmed.substring(0, 50);
        return trimmed;
      });

  /// 一意なコレクション名のリストを生成する（2〜5個）
  Generator<List<String>> get distinctCollectionNames =>
      any.intInRange(2, 6).bind((count) {
        return any.validCollectionName.map((name) {
          // count 個の一意な名前を生成
          final result = <String>[];
          for (var i = 0; i < count; i++) {
            final baseName = name.substring(0, name.length.clamp(0, 40));
            var candidate = '$baseName$i';
            if (candidate.trim().isEmpty) candidate = 'col$i';
            result.add(candidate);
          }
          return result;
        });
      });

  /// テスト用画像 ID 文字列を生成する
  Generator<String> get imageIdString =>
      any.nonEmptyStringOf('abcdefghijklmnopqrstuvwxyz0123456789-_').map((s) {
        if (s.length > 30) return s.substring(0, 30);
        return s;
      });
}

// ---------------------------------------------------------------------------
// テスト本体
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // Property 7: 画像解除は対象コレクションのみに影響する
  // =========================================================================
  group('Feature: collection-management, Property 7: 画像解除は対象コレクションのみに影響する', () {
    /// **Validates: Requirements 5.1, 5.2**
    ///
    /// *For any* 画像が複数のコレクションに所属している場合、1つのコレクションから
    /// `removeImages` を実行しても、他のコレクションにおける当該画像の所属状態は
    /// 変化しない。
    Glados(any.imageIdString).test('removeImages を実行しても他のコレクションの所属状態は変化しない', (
      imageId,
    ) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      try {
        final repository = CollectionRepositoryImpl(db);
        final createUseCase = CreateCollectionUseCase(repository: repository);
        final addUseCase = AddImagesToCollectionUseCase(repository: repository);
        final removeUseCase = RemoveImagesFromCollectionUseCase(
          repository: repository,
        );

        // Arrange: 2つのコレクションを作成
        final collection1 = await createUseCase.execute('col1');
        final collection2 = await createUseCase.execute('col2');

        // 画像を両方のコレクションに追加
        final entryId = _testEntryId(imageId);
        await addUseCase.execute(
          collectionIds: [collection1.id, collection2.id],
          entryIds: [entryId],
        );

        // Act: コレクション1から画像を解除
        await removeUseCase.execute(collection1.id, [entryId]);

        // Assert: コレクション1からは解除されている
        final images1 = await repository.getCollectionImages(collection1.id);
        expect(
          images1.where((img) => img.entryId.rawValue == imageId).length,
          0,
          reason: '解除したコレクションから画像が除去されているべき',
        );

        // Assert: コレクション2には依然として所属している
        final images2 = await repository.getCollectionImages(collection2.id);
        expect(
          images2.where((img) => img.entryId.rawValue == imageId).length,
          1,
          reason: '他のコレクションの所属状態は変化しないべき',
        );
      } finally {
        await db.close();
      }
    });
  });

  // =========================================================================
  // Property 8: 画像追加の冪等性
  // =========================================================================
  group('Feature: collection-management, Property 8: 画像追加の冪等性', () {
    /// **Validates: Requirements 4.7**
    ///
    /// *For any* コレクションと画像の組み合わせに対して、同じ画像を同じ
    /// コレクションに2回追加しても、コレクション内の当該画像は1件のみ存在する
    /// （重複登録されない）。
    Glados2(
      any.validCollectionName,
      any.imageIdString,
    ).test('同じ画像を2回追加してもコレクション内には1件のみ存在する', (collectionName, imageId) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      try {
        final repository = CollectionRepositoryImpl(db);
        final createUseCase = CreateCollectionUseCase(repository: repository);
        final addUseCase = AddImagesToCollectionUseCase(repository: repository);

        // Arrange: コレクションを作成
        final collection = await createUseCase.execute(collectionName);
        final entryId = _testEntryId(imageId);

        // Act: 同じ画像を2回追加
        await addUseCase.execute(
          collectionIds: [collection.id],
          entryIds: [entryId],
        );
        final secondAddCount = await addUseCase.execute(
          collectionIds: [collection.id],
          entryIds: [entryId],
        );

        // Assert: 2回目の追加は0件（スキップ）
        expect(secondAddCount, 0, reason: '2回目の追加は重複のためスキップされるべき');

        // Assert: コレクション内には1件のみ
        final images = await repository.getCollectionImages(collection.id);
        final matchingImages = images
            .where((img) => img.entryId.rawValue == imageId)
            .toList();
        expect(matchingImages.length, 1, reason: 'コレクション内の当該画像は1件のみ存在すべき');
      } finally {
        await db.close();
      }
    });
  });

  // =========================================================================
  // Property 9: 複数コレクション所属
  // =========================================================================
  group('Feature: collection-management, Property 9: 複数コレクション所属', () {
    /// **Validates: Requirements 4.5**
    ///
    /// *For any* 画像と N 個のコレクション（N ≥ 2）に対して、各コレクションに
    /// 画像を追加した後、`getCollectionsForImage(entryId)` は N 個全ての
    /// コレクションを含むリストを返す。
    Glados2(any.intInRange(2, 6), any.imageIdString).test(
      'N 個のコレクションに追加後、getCollectionsForImage は N 個全てを返す',
      (n, imageId) async {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        try {
          final repository = CollectionRepositoryImpl(db);
          final createUseCase = CreateCollectionUseCase(repository: repository);
          final addUseCase = AddImagesToCollectionUseCase(
            repository: repository,
          );

          // Arrange: N 個のコレクションを作成
          final collectionIds = <int>[];
          for (var i = 0; i < n; i++) {
            final collection = await createUseCase.execute('collection$i');
            collectionIds.add(collection.id);
          }

          // Act: 画像を全コレクションに追加
          final entryId = _testEntryId(imageId);
          await addUseCase.execute(
            collectionIds: collectionIds,
            entryIds: [entryId],
          );

          // Assert: getCollectionsForImage が N 個全てのコレクションを返す
          final collections = await repository.getCollectionsForImage(entryId);
          final returnedIds = collections.map((c) => c.id).toSet();

          expect(
            returnedIds.length,
            n,
            reason: 'getCollectionsForImage は $n 個全てのコレクションを返すべき',
          );

          for (final id in collectionIds) {
            expect(
              returnedIds.contains(id),
              isTrue,
              reason: 'コレクション ID $id が結果に含まれるべき',
            );
          }
        } finally {
          await db.close();
        }
      },
    );
  });
}
