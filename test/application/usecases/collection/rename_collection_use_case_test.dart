/// RenameCollectionUseCase ユニットテスト
///
/// インメモリ Drift DB を使用した統合テスト。
/// コレクション名変更、バリデーション、自身を除いた重複チェックを検証する。
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pictana/application/usecases/collection/create_collection_use_case.dart';
import 'package:pictana/application/usecases/collection/rename_collection_use_case.dart';
import 'package:pictana/core/errors/collection_exceptions.dart';
import 'package:pictana/infrastructure/database/app_database.dart';
import 'package:pictana/infrastructure/database/collection_repository_impl.dart';

void main() {
  late AppDatabase db;
  late CollectionRepositoryImpl repository;
  late CreateCollectionUseCase createUseCase;
  late RenameCollectionUseCase renameUseCase;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = CollectionRepositoryImpl(db);
    createUseCase = CreateCollectionUseCase(repository: repository);
    renameUseCase = RenameCollectionUseCase(repository: repository);
  });

  tearDown(() async {
    await db.close();
  });

  group('RenameCollectionUseCase', () {
    group('正常系: コレクション名変更', () {
      test('存在するコレクションの名前を変更できる', () async {
        final created = await createUseCase.execute('変更前');
        final renamed = await renameUseCase.execute(created.id, '変更後');

        expect(renamed.name.value, '変更後');
        expect(renamed.id, created.id);

        final fetched = await repository.getCollectionById(created.id);
        expect(fetched, isNotNull);
        expect(fetched!.name.value, '変更後');
      });

      test('前後の空白が trim されて変更される', () async {
        final created = await createUseCase.execute('変更前');
        final renamed = await renameUseCase.execute(created.id, '  トリム後  ');

        expect(renamed.name.value, 'トリム後');
      });

      test('自身の元の名前と同じ名前への変更（変更なし）は成功する', () async {
        final created = await createUseCase.execute('同じ名前');
        final renamed = await renameUseCase.execute(created.id, '同じ名前');

        expect(renamed.name.value, '同じ名前');
      });

      test('自身の元の名前と trim 後に同じ名前になる変更も成功する', () async {
        final created = await createUseCase.execute('同じ名前');
        final renamed = await renameUseCase.execute(created.id, '  同じ名前  ');

        expect(renamed.name.value, '同じ名前');
      });
    });

    group('バリデーションエラー', () {
      test('空文字で CollectionNameEmptyException をスローする', () async {
        final created = await createUseCase.execute('コレクション');
        expect(
          () => renameUseCase.execute(created.id, ''),
          throwsA(isA<CollectionNameEmptyException>()),
        );
      });

      test('空白のみで CollectionNameEmptyException をスローする', () async {
        final created = await createUseCase.execute('コレクション');
        expect(
          () => renameUseCase.execute(created.id, '   '),
          throwsA(isA<CollectionNameEmptyException>()),
        );
      });

      test('51文字以上で CollectionNameTooLongException をスローする', () async {
        final created = await createUseCase.execute('コレクション');
        final name = 'あ' * 51;
        expect(
          () => renameUseCase.execute(created.id, name),
          throwsA(isA<CollectionNameTooLongException>()),
        );
      });

      test('改行を含む名前で CollectionNameContainsNewlineException をスローする', () async {
        final created = await createUseCase.execute('コレクション');
        expect(
          () => renameUseCase.execute(created.id, 'テスト\nコレクション'),
          throwsA(isA<CollectionNameContainsNewlineException>()),
        );
      });
    });

    group('重複チェック', () {
      test('他の既存コレクションと同じ名前に変更しようとすると CollectionNameDuplicateException をスローする', () async {
        await createUseCase.execute('ターゲット名');
        final collection2 = await createUseCase.execute('別コレクション');

        expect(
          () => renameUseCase.execute(collection2.id, 'ターゲット名'),
          throwsA(isA<CollectionNameDuplicateException>()),
        );
      });

      test('他の既存コレクションと trim 後に重複する場合も CollectionNameDuplicateException をスローする', () async {
        await createUseCase.execute('ターゲット名');
        final collection2 = await createUseCase.execute('別コレクション');

        expect(
          () => renameUseCase.execute(collection2.id, '  ターゲット名  '),
          throwsA(isA<CollectionNameDuplicateException>()),
        );
      });
    });
  });
}
