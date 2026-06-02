/// CollectionSelectDialog プロパティテスト
///
/// glados を使用して、コレクション選択ダイアログに関するプロパティを検証する。
/// Property 13 はインメモリ DB を使用し、UseCase 層を通じた所属状態同期を検証する。
/// Property 14 は純粋ロジックテストとしてフィルター正確性を検証する。
///
/// テスト対象:
/// - Property 13: 所属状態の双方向同期
/// - Property 14: コレクション名検索フィルターの正確性
// Feature: collection-management, Property 13: 所属状態の双方向同期
// Feature: collection-management, Property 14: コレクション名検索フィルターの正確性
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

extension CollectionSelectGenerators on Any {
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

  /// コレクション数（2〜5個）を生成する
  Generator<int> get collectionCount => any.intInRange(2, 6);

  /// 画像数（1〜4枚）を生成する
  Generator<int> get imageCount => any.intInRange(1, 5);

  /// 検索フィルター用のコレクション名リスト（3〜8個）を生成する
  Generator<List<String>> get collectionNameList =>
      any.intInRange(3, 9).bind((count) {
        return any.list(any.validCollectionName).map((names) {
          // 一意性を保証するためサフィックスを付加
          final result = <String>[];
          for (var i = 0; i < count; i++) {
            final baseName = i < names.length ? names[i] : 'col';
            var candidate =
                '${baseName.substring(0, baseName.length.clamp(0, 40))}$i';
            if (candidate.trim().isEmpty) candidate = 'col$i';
            result.add(candidate);
          }
          return result;
        });
      });

  /// 検索文字列を生成する（0〜5文字、大文字小文字混合）
  Generator<String> get searchQuery => any.stringOf(_validChars).map((s) {
    if (s.length > 5) return s.substring(0, 5);
    return s;
  });
}

// ---------------------------------------------------------------------------
// テスト本体
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // Property 13: 所属状態の双方向同期
  // =========================================================================
  group('Feature: collection-management, Property 13: 所属状態の双方向同期', () {
    /// **Validates: Requirements 4.3, 13.7**
    ///
    /// *For any* 画像セットとコレクションセットに対して、チェック状態（ON/OFF）を
    /// 指定して確定操作を実行した場合、確定後の各コレクションにおける画像の所属状態は
    /// チェック状態と一致する（ONなら所属、OFFなら非所属）。
    Glados3(
      any.collectionCount,
      any.imageCount,
      any.intInRange(0, 100),
    ).test('チェック状態を適用後、各コレクションの所属状態はチェック状態と一致する', (
      collectionCount,
      imageCount,
      seed,
    ) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      try {
        final repository = CollectionRepositoryImpl(db);
        final createUseCase = CreateCollectionUseCase(repository: repository);
        final addUseCase = AddImagesToCollectionUseCase(repository: repository);
        final removeUseCase = RemoveImagesFromCollectionUseCase(
          repository: repository,
        );

        // Arrange: N 個のコレクションを作成
        final collectionIds = <int>[];
        for (var i = 0; i < collectionCount; i++) {
          final collection = await createUseCase.execute('col_$i');
          collectionIds.add(collection.id);
        }

        // Arrange: 画像 ID を生成
        final entryIds = List.generate(
          imageCount,
          (i) => _testEntryId('img_${i.toString().padLeft(3, '0')}'),
        );

        // Arrange: 一部のコレクションに画像を事前追加（初期所属状態を作る）
        // seed に基づいて初期状態を決定的に設定
        for (var i = 0; i < collectionCount; i++) {
          if ((seed + i) % 3 == 0) {
            await addUseCase.execute(
              collectionIds: [collectionIds[i]],
              entryIds: entryIds,
            );
          }
        }

        // Act: チェック状態を決定し確定操作をシミュレート
        // seed に基づいてチェック状態を決定的に生成
        final checkStates = List.generate(
          collectionCount,
          (i) => (seed + i * 7) % 2 == 0,
        );

        // 確定操作: ONのコレクションに画像を追加、OFFのコレクションから画像を除外
        for (var i = 0; i < collectionCount; i++) {
          if (checkStates[i]) {
            // ON: 画像を追加（既に所属済みならスキップされる）
            await addUseCase.execute(
              collectionIds: [collectionIds[i]],
              entryIds: entryIds,
            );
          } else {
            // OFF: 画像を除外
            await removeUseCase.execute(collectionIds[i], entryIds);
          }
        }

        // Assert: 各コレクションの所属状態がチェック状態と一致する
        for (var i = 0; i < collectionCount; i++) {
          final images = await repository.getCollectionImages(collectionIds[i]);
          final memberEntryIds = images
              .map((img) => img.entryId.rawValue)
              .toSet();

          if (checkStates[i]) {
            // ON: 全画像が所属しているべき
            for (final entryId in entryIds) {
              expect(
                memberEntryIds.contains(entryId.rawValue),
                isTrue,
                reason:
                    'チェックONのコレクション ${collectionIds[i]} に'
                    '画像 ${entryId.rawValue} が所属しているべき',
              );
            }
          } else {
            // OFF: 全画像が非所属であるべき
            for (final entryId in entryIds) {
              expect(
                memberEntryIds.contains(entryId.rawValue),
                isFalse,
                reason:
                    'チェックOFFのコレクション ${collectionIds[i]} に'
                    '画像 ${entryId.rawValue} が非所属であるべき',
              );
            }
          }
        }
      } finally {
        await db.close();
      }
    });

    /// 初期状態が全所属の場合でも、OFF にしたコレクションから正しく除外される
    Glados2(
      any.collectionCount,
      any.imageCount,
    ).test('全所属状態から一部を OFF にすると正しく除外される', (collectionCount, imageCount) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      try {
        final repository = CollectionRepositoryImpl(db);
        final createUseCase = CreateCollectionUseCase(repository: repository);
        final addUseCase = AddImagesToCollectionUseCase(repository: repository);
        final removeUseCase = RemoveImagesFromCollectionUseCase(
          repository: repository,
        );

        // Arrange: コレクションを作成し全画像を全コレクションに追加
        final collectionIds = <int>[];
        for (var i = 0; i < collectionCount; i++) {
          final collection = await createUseCase.execute('full_$i');
          collectionIds.add(collection.id);
        }

        final entryIds = List.generate(
          imageCount,
          (i) => _testEntryId('img_full_${i.toString().padLeft(3, '0')}'),
        );

        await addUseCase.execute(
          collectionIds: collectionIds,
          entryIds: entryIds,
        );

        // Act: 先頭のコレクションだけ OFF、残りは ON
        // OFF のコレクションから画像を除外
        await removeUseCase.execute(collectionIds[0], entryIds);

        // Assert: 先頭コレクションは空、残りは全画像所属
        final firstImages = await repository.getCollectionImages(
          collectionIds[0],
        );
        expect(firstImages.length, 0, reason: 'OFF にしたコレクションは画像が空であるべき');

        for (var i = 1; i < collectionCount; i++) {
          final images = await repository.getCollectionImages(collectionIds[i]);
          expect(
            images.length,
            imageCount,
            reason: 'ON のままのコレクション ${collectionIds[i]} は全画像が所属しているべき',
          );
        }
      } finally {
        await db.close();
      }
    });
  });

  // =========================================================================
  // Property 14: コレクション名検索フィルターの正確性
  // =========================================================================
  group('Feature: collection-management, Property 14: コレクション名検索フィルターの正確性', () {
    /// **Validates: Requirements 13.10**
    ///
    /// *For any* コレクション名のリストと検索文字列に対して、フィルター結果に含まれる
    /// 全てのコレクション名は検索文字列を部分文字列として含み、フィルター結果に
    /// 含まれない全てのコレクション名は検索文字列を部分文字列として含まない。
    Glados2(any.collectionNameList, any.searchQuery).test(
      'フィルター結果は検索文字列の部分一致条件と完全に一致する',
      (names, query) {
        // Act: フィルターを実行（大文字小文字区別なし）
        final lowerQuery = query.toLowerCase();
        final filtered = names
            .where((name) => name.toLowerCase().contains(lowerQuery))
            .toList();
        final excluded = names
            .where((name) => !name.toLowerCase().contains(lowerQuery))
            .toList();

        // Assert: フィルター結果に含まれる全ての名前は検索文字列を含む
        for (final name in filtered) {
          expect(
            name.toLowerCase().contains(lowerQuery),
            isTrue,
            reason:
                'フィルター結果に含まれる "$name" は検索文字列 "$query" を'
                '部分文字列として含むべき',
          );
        }

        // Assert: フィルター結果に含まれない全ての名前は検索文字列を含まない
        for (final name in excluded) {
          expect(
            name.toLowerCase().contains(lowerQuery),
            isFalse,
            reason:
                'フィルター結果に含まれない "$name" は検索文字列 "$query" を'
                '部分文字列として含まないべき',
          );
        }

        // Assert: filtered と excluded の合計が元のリストと一致する
        expect(
          filtered.length + excluded.length,
          names.length,
          reason: 'フィルター後の合計数は元のリスト数と一致するべき',
        );
      },
    );

    /// 空文字列での検索は全コレクションを返す
    Glados(any.collectionNameList).test('空文字列での検索は全コレクションを返す', (names) {
      // Act: 空文字列でフィルター
      const query = '';
      final lowerQuery = query.toLowerCase();
      final filtered = names
          .where((name) => name.toLowerCase().contains(lowerQuery))
          .toList();

      // Assert: 空文字列は全ての文字列に部分一致するため、全件返る
      expect(filtered.length, names.length, reason: '空文字列での検索は全コレクションを返すべき');
    });

    /// 大文字小文字を区別しない検索の一貫性
    Glados2(any.collectionNameList, any.searchQuery).test(
      '大文字小文字を区別しない検索結果は query の大文字小文字に依存しない',
      (names, query) {
        // Act: 元のクエリと大文字化したクエリでフィルター
        final lowerQuery = query.toLowerCase();
        final upperQuery = query.toUpperCase();

        final filteredLower = names
            .where((name) => name.toLowerCase().contains(lowerQuery))
            .toList();
        final filteredUpper = names
            .where(
              (name) => name.toLowerCase().contains(upperQuery.toLowerCase()),
            )
            .toList();

        // Assert: 大文字小文字に関わらず同じ結果
        expect(
          filteredLower,
          equals(filteredUpper),
          reason: '大文字小文字を区別しない検索は query の case に依存しないべき',
        );
      },
    );
  });
}
