/// CreateCollectionUseCase ユニットテスト
///
/// インメモリ Drift DB を使用した統合テスト。
/// コレクション作成、バリデーション、重複チェックを検証する。
///
/// Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pictana/application/usecases/collection/create_collection_use_case.dart';
import 'package:pictana/core/errors/collection_exceptions.dart';
import 'package:pictana/infrastructure/database/app_database.dart';
import 'package:pictana/infrastructure/database/collection_repository_impl.dart';

void main() {
  late AppDatabase db;
  late CollectionRepositoryImpl repository;
  late CreateCollectionUseCase useCase;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = CollectionRepositoryImpl(db);
    useCase = CreateCollectionUseCase(repository: repository);
  });

  tearDown(() async {
    await db.close();
  });

  group('CreateCollectionUseCase', () {
    group('正常系: コレクション作成', () {
      test('有効な名前でコレクションを作成できる', () async {
        final collection = await useCase.execute('テストコレクション');

        expect(collection.name.value, 'テストコレクション');
        expect(collection.id, isPositive);
        expect(collection.imageCount, 0);
      });

      test('前後の空白が trim される', () async {
        final collection = await useCase.execute('  コレクション  ');

        expect(collection.name.value, 'コレクション');
      });

      test('絵文字を含む名前で作成できる', () async {
        final collection = await useCase.execute('🎨 アート集');

        expect(collection.name.value, '🎨 アート集');
      });

      test('50文字ちょうどの名前で作成できる', () async {
        final name = 'あ' * 50;
        final collection = await useCase.execute(name);

        expect(collection.name.value, name);
      });

      test('作成後にリポジトリから取得できる', () async {
        final created = await useCase.execute('永続化テスト');
        final fetched = await repository.getCollectionById(created.id);

        expect(fetched, isNotNull);
        expect(fetched!.name.value, '永続化テスト');
      });
    });

    group('バリデーションエラー', () {
      test('空文字で CollectionNameEmptyException をスローする', () async {
        expect(
          () => useCase.execute(''),
          throwsA(isA<CollectionNameEmptyException>()),
        );
      });

      test('空白のみで CollectionNameEmptyException をスローする', () async {
        expect(
          () => useCase.execute('   '),
          throwsA(isA<CollectionNameEmptyException>()),
        );
      });

      test('51文字以上で CollectionNameTooLongException をスローする', () async {
        final name = 'あ' * 51;
        expect(
          () => useCase.execute(name),
          throwsA(isA<CollectionNameTooLongException>()),
        );
      });

      test('改行を含む名前で CollectionNameContainsNewlineException をスローする', () async {
        expect(
          () => useCase.execute('テスト\nコレクション'),
          throwsA(isA<CollectionNameContainsNewlineException>()),
        );
      });

      test(
        '復帰文字を含む名前で CollectionNameContainsNewlineException をスローする',
        () async {
          expect(
            () => useCase.execute('テスト\rコレクション'),
            throwsA(isA<CollectionNameContainsNewlineException>()),
          );
        },
      );
    });

    group('重複チェック', () {
      test('既存の名前で CollectionNameDuplicateException をスローする', () async {
        await useCase.execute('既存コレクション');

        expect(
          () => useCase.execute('既存コレクション'),
          throwsA(isA<CollectionNameDuplicateException>()),
        );
      });

      test('重複例外に既存のコレクション名が含まれる', () async {
        await useCase.execute('重複テスト');

        try {
          await useCase.execute('重複テスト');
          fail('例外がスローされるべき');
        } on CollectionNameDuplicateException catch (e) {
          expect(e.existingName, '重複テスト');
        }
      });

      test('trim 後に同じ名前になる場合は重複と判定される', () async {
        await useCase.execute('コレクション');

        expect(
          () => useCase.execute('  コレクション  '),
          throwsA(isA<CollectionNameDuplicateException>()),
        );
      });

      test('大文字小文字が異なる場合は別のコレクションとして作成できる', () async {
        await useCase.execute('Collection');

        final collection = await useCase.execute('collection');
        expect(collection.name.value, 'collection');
      });
    });
  });
}
