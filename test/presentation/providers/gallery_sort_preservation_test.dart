/// Property 2: Preservation - 初回表示・DB 復元・ソート実行の既存動作維持
///
/// UNFIXED コードで既存の正しい動作を確認する preservation テスト。
/// これらのテストは修正後も引き続き PASS することを保証する。
///
/// **Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5**
library;

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, tearDown, test;
import 'package:pictana/application/providers/repository_providers.dart';
import 'package:pictana/application/usecases/gallery/sort_images_usecase.dart';
import 'package:pictana/domain/entities/entry_id.dart';
import 'package:pictana/domain/entities/image_entry.dart';
import 'package:pictana/domain/value_objects/sort_option.dart';
import 'package:pictana/infrastructure/database/app_database.dart';
import 'package:pictana/presentation/providers/gallery_providers.dart';

// ---------------------------------------------------------------------------
// テスト用ヘルパー: _sortEntries() と同等のソートロジック
// ---------------------------------------------------------------------------

/// `WindowsImageRepository._sortEntries()` と同じロジックを再現するヘルパー。
/// private メソッドを直接テストできないため、同一ロジックで検証する。
void sortEntries(List<ImageEntry> entries, SortOption sort) {
  final asc = sort.isAscending;
  entries.sort(
    (a, b) => switch (sort.field) {
      SortField.name =>
        asc ? a.name.compareTo(b.name) : b.name.compareTo(a.name),
      SortField.date =>
        asc
            ? a.modifiedAt.compareTo(b.modifiedAt)
            : b.modifiedAt.compareTo(a.modifiedAt),
      SortField.size =>
        asc ? a.size.compareTo(b.size) : b.size.compareTo(a.size),
      SortField.type =>
        asc
            ? a.extension.compareTo(b.extension)
            : b.extension.compareTo(a.extension),
    },
  );
}

// ---------------------------------------------------------------------------
// テスト用 ImageEntry ファクトリ
// ---------------------------------------------------------------------------

/// テスト用の ImageEntry を生成する
ImageEntry createTestImageEntry({
  required String name,
  required String extension,
  required int size,
  required DateTime modifiedAt,
}) {
  return ImageEntry(
    id: EntryId.windows('C:\\test\\$name'),
    name: name,
    extension: extension,
    uri: 'C:\\test\\$name',
    mimeType: ImageMimeType.fromExtension(extension),
    size: size,
    modifiedAt: modifiedAt,
  );
}

// ---------------------------------------------------------------------------
// glados ジェネレータ
// ---------------------------------------------------------------------------

extension SortPreservationGenerators on Any {
  /// ランダムな SortField を生成する
  Generator<SortField> get sortField => any.choose(SortField.values);

  /// ランダムな SortDirection を生成する
  Generator<SortDirection> get sortDirection =>
      any.choose(SortDirection.values);

  /// ランダムな SortOption を生成する
  Generator<SortOption> get sortOption => any.combine2(
    any.sortField,
    any.sortDirection,
    (SortField field, SortDirection direction) =>
        SortOption(field: field, direction: direction),
  );

  /// ランダムな ImageEntry を生成する
  Generator<ImageEntry> get imageEntry => any.combine4(
    any.nonEmptyLetters,
    any.choose(['jpg', 'png', 'webp', 'gif']),
    any.intInRange(1, 1000000000),
    any.intInRange(0, 100000000),
    (String name, String ext, int size, int dateOffset) {
      final safeName = name.substring(0, name.length.clamp(0, 20));
      final fileName = '$safeName.$ext';
      final date = DateTime(2020, 1, 1).add(Duration(seconds: dateOffset));
      return createTestImageEntry(
        name: fileName,
        extension: ext,
        size: size,
        modifiedAt: date,
      );
    },
  );

  /// ランダムな ImageEntry リストを生成する（2件以上）
  Generator<List<ImageEntry>> get imageEntryList =>
      any.listWithLengthInRange(2, 20, any.imageEntry);
}

// ---------------------------------------------------------------------------
// テスト本体
// ---------------------------------------------------------------------------

void main() {
  // drift の複数インスタンス警告を抑制（テスト用途のため問題なし）
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('Property 2: Preservation - 初回表示・DB 復元・ソート実行の既存動作維持', () {
    // -----------------------------------------------------------------------
    // Observe: GallerySortOption.build() が SortOption.defaultOption を返す
    // -----------------------------------------------------------------------
    group('GallerySortOption.build() の初期値', () {
      test('build() は SortOption.defaultOption を即座に返す', () async {
        final db = AppDatabase.forTesting(NativeDatabase.memory());

        final container = ProviderContainer(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
        );

        // build() の戻り値（同期的な初期値）
        final initialState = container.read(gallerySortOptionProvider);
        expect(initialState, equals(SortOption.defaultOption));

        // _loadInitial() を完了させてからクリーンアップ
        await Future<void>.delayed(const Duration(milliseconds: 50));
        container.dispose();
        await db.close();
      });
    });

    // -----------------------------------------------------------------------
    // Observe: _loadInitial() が DB 値を正しく state に設定する（ユーザー変更なし）
    // -----------------------------------------------------------------------
    group('_loadInitial() の DB 復元', () {
      test('DB に保存された値が _loadInitial() で正しく復元される', () async {
        final db = AppDatabase.forTesting(NativeDatabase.memory());

        // DB にソート設定を事前に保存
        final savedOption = const SortOption(
          field: SortField.date,
          direction: SortDirection.descending,
        );
        await db.setSetting('sort_field', savedOption.field.name);
        await db.setSetting('sort_direction', savedOption.direction.name);

        final container = ProviderContainer(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
        );

        // build() の初期値は defaultOption
        expect(
          container.read(gallerySortOptionProvider),
          equals(SortOption.defaultOption),
        );

        // _loadInitial() の非同期処理を待つ
        await Future<void>.delayed(const Duration(milliseconds: 100));

        // DB の値が復元される
        expect(container.read(gallerySortOptionProvider), equals(savedOption));

        container.dispose();
        await db.close();
      });
    });

    // -----------------------------------------------------------------------
    // Observe: updateOption() が DB に正しく保存する
    // -----------------------------------------------------------------------
    group('updateOption() の DB 永続化', () {
      test('updateOption() で設定した値が DB に正しく保存される', () async {
        final db = AppDatabase.forTesting(NativeDatabase.memory());

        final container = ProviderContainer(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
        );

        // notifier を取得（build() が呼ばれ、_loadInitial() 開始）
        final notifier = container.read(gallerySortOptionProvider.notifier);

        // _loadInitial() を確実に完了させる
        await Future<void>.delayed(const Duration(milliseconds: 100));

        final newOption = const SortOption(
          field: SortField.size,
          direction: SortDirection.descending,
        );

        await notifier.updateOption(newOption);

        // state が更新されている（updateOption 直後）
        expect(container.read(gallerySortOptionProvider), equals(newOption));

        // DB に正しく保存されている
        final fieldStr = await db.getSetting('sort_field');
        final dirStr = await db.getSetting('sort_direction');
        expect(fieldStr, equals(SortField.size.name));
        expect(dirStr, equals(SortDirection.descending.name));

        container.dispose();
        await db.close();
      });

      test('SortImagesUseCase.saveSortOption() が DB に正しく保存する', () async {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        try {
          final useCase = SortImagesUseCase(database: db);
          final option = const SortOption(
            field: SortField.date,
            direction: SortDirection.descending,
          );

          await useCase.saveSortOption(option);

          // DB に正しく保存されている
          final fieldStr = await db.getSetting('sort_field');
          final dirStr = await db.getSetting('sort_direction');
          expect(fieldStr, equals(SortField.date.name));
          expect(dirStr, equals(SortDirection.descending.name));
        } finally {
          await db.close();
        }
      });
    });

    // -----------------------------------------------------------------------
    // Observe: _sortEntries() が各ソートフィールド・方向で正しくソートする
    // -----------------------------------------------------------------------
    group('_sortEntries() のソート動作', () {
      late List<ImageEntry> testEntries;

      setUp(() {
        testEntries = [
          createTestImageEntry(
            name: 'banana.jpg',
            extension: 'jpg',
            size: 2000,
            modifiedAt: DateTime(2023, 3, 1),
          ),
          createTestImageEntry(
            name: 'apple.png',
            extension: 'png',
            size: 1000,
            modifiedAt: DateTime(2023, 1, 1),
          ),
          createTestImageEntry(
            name: 'cherry.webp',
            extension: 'webp',
            size: 3000,
            modifiedAt: DateTime(2023, 2, 1),
          ),
        ];
      });

      test('名前昇順でソートされる', () {
        final entries = List.of(testEntries);
        sortEntries(
          entries,
          const SortOption(
            field: SortField.name,
            direction: SortDirection.ascending,
          ),
        );
        expect(entries[0].name, 'apple.png');
        expect(entries[1].name, 'banana.jpg');
        expect(entries[2].name, 'cherry.webp');
      });

      test('名前降順でソートされる', () {
        final entries = List.of(testEntries);
        sortEntries(
          entries,
          const SortOption(
            field: SortField.name,
            direction: SortDirection.descending,
          ),
        );
        expect(entries[0].name, 'cherry.webp');
        expect(entries[1].name, 'banana.jpg');
        expect(entries[2].name, 'apple.png');
      });

      test('日付昇順でソートされる', () {
        final entries = List.of(testEntries);
        sortEntries(
          entries,
          const SortOption(
            field: SortField.date,
            direction: SortDirection.ascending,
          ),
        );
        expect(entries[0].name, 'apple.png');
        expect(entries[1].name, 'cherry.webp');
        expect(entries[2].name, 'banana.jpg');
      });

      test('日付降順でソートされる', () {
        final entries = List.of(testEntries);
        sortEntries(
          entries,
          const SortOption(
            field: SortField.date,
            direction: SortDirection.descending,
          ),
        );
        expect(entries[0].name, 'banana.jpg');
        expect(entries[1].name, 'cherry.webp');
        expect(entries[2].name, 'apple.png');
      });

      test('サイズ昇順でソートされる', () {
        final entries = List.of(testEntries);
        sortEntries(
          entries,
          const SortOption(
            field: SortField.size,
            direction: SortDirection.ascending,
          ),
        );
        expect(entries[0].name, 'apple.png');
        expect(entries[1].name, 'banana.jpg');
        expect(entries[2].name, 'cherry.webp');
      });

      test('サイズ降順でソートされる', () {
        final entries = List.of(testEntries);
        sortEntries(
          entries,
          const SortOption(
            field: SortField.size,
            direction: SortDirection.descending,
          ),
        );
        expect(entries[0].name, 'cherry.webp');
        expect(entries[1].name, 'banana.jpg');
        expect(entries[2].name, 'apple.png');
      });

      test('種類昇順でソートされる', () {
        final entries = List.of(testEntries);
        sortEntries(
          entries,
          const SortOption(
            field: SortField.type,
            direction: SortDirection.ascending,
          ),
        );
        expect(entries[0].extension, 'jpg');
        expect(entries[1].extension, 'png');
        expect(entries[2].extension, 'webp');
      });

      test('種類降順でソートされる', () {
        final entries = List.of(testEntries);
        sortEntries(
          entries,
          const SortOption(
            field: SortField.type,
            direction: SortDirection.descending,
          ),
        );
        expect(entries[0].extension, 'webp');
        expect(entries[1].extension, 'png');
        expect(entries[2].extension, 'jpg');
      });
    });

    // -----------------------------------------------------------------------
    // Property-based: 任意の SortOption に対して _sortEntries() が正しい順序を生成する
    // -----------------------------------------------------------------------
    group('Property-based: _sortEntries() のソート順序の正しさ', () {
      Glados2(any.sortOption, any.imageEntryList).test(
        '任意の SortOption に対して隣接要素が正しい順序関係を持つ（昇順なら a <= b、降順なら a >= b）',
        (sortOption, entries) {
          final sorted = List.of(entries);
          sortEntries(sorted, sortOption);

          // 隣接要素の順序関係を検証
          for (var i = 0; i < sorted.length - 1; i++) {
            final a = sorted[i];
            final b = sorted[i + 1];
            final cmp = switch (sortOption.field) {
              SortField.name => a.name.compareTo(b.name),
              SortField.date => a.modifiedAt.compareTo(b.modifiedAt),
              SortField.size => a.size.compareTo(b.size),
              SortField.type => a.extension.compareTo(b.extension),
            };

            if (sortOption.isAscending) {
              expect(
                cmp <= 0,
                isTrue,
                reason:
                    '昇順ソートで a[$i] <= a[${i + 1}] であるべき。'
                    'field=${sortOption.field}, '
                    'a=${_fieldValue(a, sortOption.field)}, '
                    'b=${_fieldValue(b, sortOption.field)}',
              );
            } else {
              expect(
                cmp >= 0,
                isTrue,
                reason:
                    '降順ソートで a[$i] >= a[${i + 1}] であるべき。'
                    'field=${sortOption.field}, '
                    'a=${_fieldValue(a, sortOption.field)}, '
                    'b=${_fieldValue(b, sortOption.field)}',
              );
            }
          }
        },
      );
    });

    // -----------------------------------------------------------------------
    // Property-based: updateOption() → loadSortOption() の round-trip
    // -----------------------------------------------------------------------
    group('Property-based: DB 永続化の round-trip', () {
      Glados(any.sortOption).test(
        '任意の SortOption に対して saveSortOption() → loadSortOption() で同じ値が復元される',
        (generatedOption) async {
          final db = AppDatabase.forTesting(NativeDatabase.memory());
          try {
            final useCase = SortImagesUseCase(database: db);

            // 保存
            await useCase.saveSortOption(generatedOption);

            // 復元
            final loaded = await useCase.loadSortOption();

            expect(
              loaded,
              equals(generatedOption),
              reason:
                  'saveSortOption($generatedOption) → loadSortOption() で'
                  '同じ値が復元されるべき。実際: $loaded',
            );
          } finally {
            await db.close();
          }
        },
      );
    });

    // -----------------------------------------------------------------------
    // Property-based: ユーザーが変更していない場合、_loadInitial() が DB 値を正しく復元する
    // -----------------------------------------------------------------------
    group('Property-based: _loadInitial() の DB 復元', () {
      Glados(any.sortOption).test(
        '任意の SortOption が DB に保存されている場合、_loadInitial() で正しく復元される',
        (savedOption) async {
          final db = AppDatabase.forTesting(NativeDatabase.memory());
          try {
            // DB にソート設定を事前に保存
            await db.setSetting('sort_field', savedOption.field.name);
            await db.setSetting('sort_direction', savedOption.direction.name);

            final container = ProviderContainer(
              overrides: [appDatabaseProvider.overrideWithValue(db)],
            );

            try {
              // build() の初期値は defaultOption
              expect(
                container.read(gallerySortOptionProvider),
                equals(SortOption.defaultOption),
              );

              // _loadInitial() の非同期処理を待つ
              await Future<void>.delayed(const Duration(milliseconds: 50));

              // DB の値が復元される
              expect(
                container.read(gallerySortOptionProvider),
                equals(savedOption),
                reason:
                    'DB に保存された $savedOption が _loadInitial() で'
                    '復元されるべき。実際: '
                    '${container.read(gallerySortOptionProvider)}',
              );
            } finally {
              container.dispose();
            }
          } finally {
            await db.close();
          }
        },
      );
    });
  });
}

/// デバッグ用: ImageEntry のフィールド値を文字列で返す
String _fieldValue(ImageEntry entry, SortField field) => switch (field) {
  SortField.name => entry.name,
  SortField.date => entry.modifiedAt.toIso8601String(),
  SortField.size => entry.size.toString(),
  SortField.type => entry.extension,
};
