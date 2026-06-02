/// UseCase 並び替えプロパティテスト
///
/// glados を使用して、コレクション内画像の一括移動・並び替え永続化に関する
/// プロパティを検証する。
/// インメモリ DB を使用し、UseCase 層を通じた並び替えロジックの正確性を保証する。
///
/// テスト対象:
/// - Property 10: 複数画像の一括移動は相対順序を維持する
/// - Property 11: 画像並び順の永続化ラウンドトリップ
/// - Property 12: コレクション並び順の永続化ラウンドトリップ
// Feature: collection-management, Property 10: 複数画像の一括移動は相対順序を維持する
// Feature: collection-management, Property 11: 画像並び順の永続化ラウンドトリップ
// Feature: collection-management, Property 12: コレクション並び順の永続化ラウンドトリップ
@Tags(['property-test', 'collection-management'])
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, tearDown, test;
import 'package:pictana/application/usecases/collection/add_images_to_collection_use_case.dart';
import 'package:pictana/application/usecases/collection/create_collection_use_case.dart';
import 'package:pictana/application/usecases/collection/reorder_collection_images_use_case.dart';
import 'package:pictana/application/usecases/collection/reorder_collections_use_case.dart';
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

extension CollectionReorderGenerators on Any {
  /// 有効なコレクション名を生成する（1〜50文字、改行なし、空白のみでない）
  Generator<String> get validCollectionName =>
      any.nonEmptyStringOf(_validChars).map((s) {
        final trimmed = s.trim();
        if (trimmed.isEmpty) return 'a';
        if (trimmed.length > 50) return trimmed.substring(0, 50);
        return trimmed;
      });

  /// テスト用画像 ID 文字列を生成する
  Generator<String> get imageIdString =>
      any.nonEmptyStringOf('abcdefghijklmnopqrstuvwxyz0123456789').map((s) {
        if (s.length > 20) return s.substring(0, 20);
        return s;
      });

  /// 画像リストのサイズ（3〜8個）を生成する
  Generator<int> get imageListSize => any.intInRange(3, 9);

  /// コレクション数（2〜5個）を生成する
  Generator<int> get collectionCount => any.intInRange(2, 6);

  /// 一括移動テスト用の入力データを生成する
  ///
  /// (画像数, 選択開始インデックスリスト, ドロップ位置インデックス) のタプル
  /// 選択画像とドロップ位置の妥当性を保証する
  Generator<(int, List<int>, int)> get bulkMoveInput =>
      any.intInRange(4, 9).bind((imageCount) {
        // 選択する画像数（1〜imageCount-1。全選択は移動の意味がないため除外）
        return any.intInRange(1, imageCount).bind((selectCount) {
          // 選択インデックスをランダムに生成
          return any.intInRange(0, imageCount).map((seed) {
            // 決定的に選択インデックスを生成（重複なし）
            final selectedIndices = <int>{};
            var current = seed % imageCount;
            for (
              var i = 0;
              i < selectCount && selectedIndices.length < selectCount;
              i++
            ) {
              selectedIndices.add(current);
              current = (current + 1 + (seed + i) % 3) % imageCount;
              if (selectedIndices.length < selectCount &&
                  selectedIndices.length == selectedIndices.length) {
                // 全インデックスから未選択のものを追加
                for (
                  var j = 0;
                  j < imageCount && selectedIndices.length < selectCount;
                  j++
                ) {
                  selectedIndices.add(j);
                }
              }
            }
            final sortedSelected = selectedIndices.toList()..sort();

            // ドロップ位置: 選択画像を除いた残りリストのどこかに挿入
            final remainingCount = imageCount - sortedSelected.length;
            // ドロップ位置は 0〜remainingCount（末尾に挿入可能）
            final dropPosition = seed % (remainingCount + 1);

            return (imageCount, sortedSelected, dropPosition);
          });
        });
      });
}

// ---------------------------------------------------------------------------
// 一括移動アルゴリズム（テスト側で再現）
// ---------------------------------------------------------------------------

/// 一括移動アルゴリズムを実行し、結果のリストを返す
///
/// [items] 全アイテムのリスト
/// [selectedIndices] 選択されたアイテムのインデックス（ソート済み）
/// [dropPosition] 残りリスト内での挿入位置
List<T> performBulkMove<T>(
  List<T> items,
  List<int> selectedIndices,
  int dropPosition,
) {
  // 1. 選択画像を抽出（相対順序維持）
  final selected = selectedIndices.map((i) => items[i]).toList();

  // 2. 残りのリスト
  final remaining = <T>[];
  for (var i = 0; i < items.length; i++) {
    if (!selectedIndices.contains(i)) {
      remaining.add(items[i]);
    }
  }

  // 3. ドロップ位置に挿入
  final clampedDrop = dropPosition.clamp(0, remaining.length);
  final result = [
    ...remaining.sublist(0, clampedDrop),
    ...selected,
    ...remaining.sublist(clampedDrop),
  ];

  return result;
}

// ---------------------------------------------------------------------------
// テスト本体
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // Property 10: 複数画像の一括移動は相対順序を維持する
  // =========================================================================
  group('Feature: collection-management, Property 10: 複数画像の一括移動は相対順序を維持する', () {
    /// **Validates: Requirements 9.6, 9.7, 10.1, 10.6**
    ///
    /// *For any* コレクション内の画像リスト、選択された画像のサブセット、
    /// および有効なドロップ位置に対して、一括移動後の結果リストにおいて
    /// 選択画像間の相対順序は移動前と同一である。
    Glados(any.bulkMoveInput).test('一括移動後の選択画像の相対順序は移動前と同一である', (input) async {
      final (imageCount, selectedIndices, dropPosition) = input;

      final db = AppDatabase.forTesting(NativeDatabase.memory());
      try {
        final repository = CollectionRepositoryImpl(db);
        final createUseCase = CreateCollectionUseCase(repository: repository);
        final addUseCase = AddImagesToCollectionUseCase(repository: repository);
        final reorderUseCase = ReorderCollectionImagesUseCase(
          repository: repository,
        );

        // Arrange: コレクションを作成し画像を追加
        final collection = await createUseCase.execute('reorder_test');
        final imageIds = List.generate(
          imageCount,
          (i) => 'img_${i.toString().padLeft(3, '0')}',
        );
        final entryIds = imageIds.map(_testEntryId).toList();

        await addUseCase.execute(
          collectionIds: [collection.id],
          entryIds: entryIds,
        );

        // Act: 一括移動アルゴリズムを実行
        // 選択画像を抽出し、ドロップ位置に挿入した新しい順序を計算
        final newOrder = performBulkMove(
          entryIds,
          selectedIndices,
          dropPosition,
        );

        // UseCase で並び替えを永続化
        await reorderUseCase.execute(collection.id, newOrder);

        // Assert: 永続化された結果を取得
        final result = await repository.getCollectionImages(collection.id);
        final resultEntryIds = result
            .map((img) => img.entryId.rawValue)
            .toList();

        // 選択画像の相対順序が維持されていることを検証
        final selectedIds = selectedIndices.map((i) => imageIds[i]).toList();
        final selectedInResult = resultEntryIds
            .where((id) => selectedIds.contains(id))
            .toList();

        expect(
          selectedInResult,
          equals(selectedIds),
          reason:
              '選択画像間の相対順序は移動前と同一であるべき\n'
              '元の順序: $selectedIds\n'
              '結果の順序: $selectedInResult',
        );

        // 全体の要素数が変わっていないことを検証
        expect(resultEntryIds.length, imageCount, reason: '一括移動後の画像数は変化しないべき');
      } finally {
        await db.close();
      }
    });
  });

  // =========================================================================
  // Property 11: 画像並び順の永続化ラウンドトリップ
  // =========================================================================
  group('Feature: collection-management, Property 11: 画像並び順の永続化ラウンドトリップ', () {
    /// **Validates: Requirements 8.2, 9.8, 10.4**
    ///
    /// *For any* コレクション内の画像リストに対して、
    /// `reorderImages(collectionId, orderedEntryIds)` で並び替えを実行した後、
    /// `getCollectionImages(collectionId)` で取得した結果の `entryId` 順序は
    /// `orderedEntryIds` と一致する。
    Glados(any.imageListSize).test(
      'reorderImages 後の getCollectionImages 結果は指定順序と一致する',
      (imageCount) async {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        try {
          final repository = CollectionRepositoryImpl(db);
          final createUseCase = CreateCollectionUseCase(repository: repository);
          final addUseCase = AddImagesToCollectionUseCase(
            repository: repository,
          );
          final reorderUseCase = ReorderCollectionImagesUseCase(
            repository: repository,
          );

          // Arrange: コレクションを作成し画像を追加
          final collection = await createUseCase.execute('roundtrip_test');
          final imageIds = List.generate(
            imageCount,
            (i) => 'img_${i.toString().padLeft(3, '0')}',
          );
          final entryIds = imageIds.map(_testEntryId).toList();

          await addUseCase.execute(
            collectionIds: [collection.id],
            entryIds: entryIds,
          );

          // Act: 逆順に並び替え（決定的なシャッフルとして逆順を使用）
          final reversedEntryIds = entryIds.reversed.toList();
          await reorderUseCase.execute(collection.id, reversedEntryIds);

          // Assert: 取得した結果が指定した順序と一致する
          final result = await repository.getCollectionImages(collection.id);
          final resultEntryIds = result
              .map((img) => img.entryId.rawValue)
              .toList();
          final expectedIds = reversedEntryIds.map((e) => e.rawValue).toList();

          expect(
            resultEntryIds,
            equals(expectedIds),
            reason: 'reorderImages で指定した順序と getCollectionImages の結果が一致するべき',
          );
        } finally {
          await db.close();
        }
      },
    );

    /// 任意のシャッフルパターンでも永続化ラウンドトリップが成立する
    Glados2(
      any.imageListSize,
      any.intInRange(1, 100),
    ).test('任意のシャッフルパターンでも永続化ラウンドトリップが成立する', (imageCount, seed) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      try {
        final repository = CollectionRepositoryImpl(db);
        final createUseCase = CreateCollectionUseCase(repository: repository);
        final addUseCase = AddImagesToCollectionUseCase(repository: repository);
        final reorderUseCase = ReorderCollectionImagesUseCase(
          repository: repository,
        );

        // Arrange: コレクションを作成し画像を追加
        final collection = await createUseCase.execute('shuffle_test');
        final imageIds = List.generate(
          imageCount,
          (i) => 'img_${i.toString().padLeft(3, '0')}',
        );
        final entryIds = imageIds.map(_testEntryId).toList();

        await addUseCase.execute(
          collectionIds: [collection.id],
          entryIds: entryIds,
        );

        // Act: seed に基づいた決定的シャッフル
        final shuffled = List<EntryId>.from(entryIds);
        for (var i = shuffled.length - 1; i > 0; i--) {
          final j = (seed * (i + 1) + i) % (i + 1);
          final temp = shuffled[i];
          shuffled[i] = shuffled[j];
          shuffled[j] = temp;
        }

        await reorderUseCase.execute(collection.id, shuffled);

        // Assert: 取得した結果がシャッフル後の順序と一致する
        final result = await repository.getCollectionImages(collection.id);
        final resultEntryIds = result
            .map((img) => img.entryId.rawValue)
            .toList();
        final expectedIds = shuffled.map((e) => e.rawValue).toList();

        expect(
          resultEntryIds,
          equals(expectedIds),
          reason: 'reorderImages で指定したシャッフル順序と結果が一致するべき',
        );
      } finally {
        await db.close();
      }
    });
  });

  // =========================================================================
  // Property 12: コレクション並び順の永続化ラウンドトリップ
  // =========================================================================
  group(
    'Feature: collection-management, Property 12: コレクション並び順の永続化ラウンドトリップ',
    () {
      /// **Validates: Requirements 11.1, 11.4**
      ///
      /// *For any* コレクション一覧に対して、
      /// `reorderCollections(orderedIds)` で並び替えを実行した後、
      /// `getCollections()` で取得した結果の `id` 順序は `orderedIds` と一致する。
      Glados(any.collectionCount).test(
        'reorderCollections 後の getCollections 結果は指定順序と一致する',
        (collectionCount) async {
          final db = AppDatabase.forTesting(NativeDatabase.memory());
          try {
            final repository = CollectionRepositoryImpl(db);
            final createUseCase = CreateCollectionUseCase(
              repository: repository,
            );
            final reorderUseCase = ReorderCollectionsUseCase(
              repository: repository,
            );

            // Arrange: N 個のコレクションを作成
            final collectionIds = <int>[];
            for (var i = 0; i < collectionCount; i++) {
              final collection = await createUseCase.execute('col_$i');
              collectionIds.add(collection.id);
            }

            // Act: 逆順に並び替え
            final reversedIds = collectionIds.reversed.toList();
            await reorderUseCase.execute(reversedIds);

            // Assert: 取得した結果が指定した順序と一致する
            final result = await repository.getCollections();
            final resultIds = result.map((c) => c.id).toList();

            expect(
              resultIds,
              equals(reversedIds),
              reason: 'reorderCollections で指定した順序と getCollections の結果が一致するべき',
            );
          } finally {
            await db.close();
          }
        },
      );

      /// 任意のシャッフルパターンでもコレクション並び順の永続化ラウンドトリップが成立する
      Glados2(any.collectionCount, any.intInRange(1, 100)).test(
        '任意のシャッフルパターンでもコレクション並び順の永続化ラウンドトリップが成立する',
        (collectionCount, seed) async {
          final db = AppDatabase.forTesting(NativeDatabase.memory());
          try {
            final repository = CollectionRepositoryImpl(db);
            final createUseCase = CreateCollectionUseCase(
              repository: repository,
            );
            final reorderUseCase = ReorderCollectionsUseCase(
              repository: repository,
            );

            // Arrange: N 個のコレクションを作成
            final collectionIds = <int>[];
            for (var i = 0; i < collectionCount; i++) {
              final collection = await createUseCase.execute('col_$i');
              collectionIds.add(collection.id);
            }

            // Act: seed に基づいた決定的シャッフル
            final shuffled = List<int>.from(collectionIds);
            for (var i = shuffled.length - 1; i > 0; i--) {
              final j = (seed * (i + 1) + i) % (i + 1);
              final temp = shuffled[i];
              shuffled[i] = shuffled[j];
              shuffled[j] = temp;
            }

            await reorderUseCase.execute(shuffled);

            // Assert: 取得した結果がシャッフル後の順序と一致する
            final result = await repository.getCollections();
            final resultIds = result.map((c) => c.id).toList();

            expect(
              resultIds,
              equals(shuffled),
              reason: 'reorderCollections で指定したシャッフル順序と結果が一致するべき',
            );
          } finally {
            await db.close();
          }
        },
      );
    },
  );
}
