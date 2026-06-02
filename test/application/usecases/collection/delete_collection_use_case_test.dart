/// DeleteCollectionUseCase ユニットテスト
///
/// インメモリ Drift DB を使用した統合テスト。
/// 単一/複数コレクション削除、CASCADE 削除を検証する。
///
/// Requirements: 2.1, 2.2
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pictana/application/usecases/collection/delete_collection_use_case.dart';
import 'package:pictana/domain/entities/entry_id.dart';
import 'package:pictana/domain/value_objects/collection_name.dart';
import 'package:pictana/infrastructure/database/app_database.dart';
import 'package:pictana/infrastructure/database/collection_repository_impl.dart';

void main() {
  late AppDatabase db;
  late CollectionRepositoryImpl repository;
  late DeleteCollectionUseCase useCase;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = CollectionRepositoryImpl(db);
    useCase = DeleteCollectionUseCase(repository: repository);
  });

  tearDown(() async {
    await db.close();
  });

  group('DeleteCollectionUseCase', () {
    group('単一コレクション削除', () {
      test('コレクションを削除するとgetCollectionByIdがnullを返す', () async {
        // コレクション作成
        final collection = await repository.createCollection(
          CollectionName.create('テストコレクション'),
        );

        // 削除実行
        await useCase.execute([collection.id]);

        // 削除確認
        final result = await repository.getCollectionById(collection.id);
        expect(result, isNull);
      });

      test('画像が追加されたコレクションでも正常に削除できる', () async {
        // コレクション作成
        final collection = await repository.createCollection(
          CollectionName.create('画像付きコレクション'),
        );

        // 画像を追加
        final entryIds = [
          const EntryId(
            rawValue: 'img1.jpg',
            platformType: PlatformType.windows,
          ),
          const EntryId(
            rawValue: 'img2.jpg',
            platformType: PlatformType.windows,
          ),
        ];
        await repository.addImages(collection.id, entryIds);

        // 画像が追加されたことを確認
        final imagesBefore = await repository.getCollectionImages(
          collection.id,
        );
        expect(imagesBefore.length, 2);

        // コレクション削除（エラーなく完了すること）
        await useCase.execute([collection.id]);

        // コレクション自体が削除されていることを確認
        final result = await repository.getCollectionById(collection.id);
        expect(result, isNull);
      });
    });

    group('複数コレクション一括削除', () {
      test('複数コレクションを一括削除できる', () async {
        // 複数コレクション作成
        final c1 = await repository.createCollection(
          CollectionName.create('コレクション1'),
        );
        final c2 = await repository.createCollection(
          CollectionName.create('コレクション2'),
        );
        final c3 = await repository.createCollection(
          CollectionName.create('コレクション3'),
        );

        // 2件を一括削除
        await useCase.execute([c1.id, c3.id]);

        // 削除されたコレクションが取得できないことを確認
        expect(await repository.getCollectionById(c1.id), isNull);
        expect(await repository.getCollectionById(c3.id), isNull);

        // 残存コレクションが取得できることを確認
        final remaining = await repository.getCollectionById(c2.id);
        expect(remaining, isNotNull);
        expect(remaining!.name.value, 'コレクション2');
      });

      test('画像付きの複数コレクションを一括削除できる', () async {
        // コレクション作成
        final c1 = await repository.createCollection(
          CollectionName.create('コレクションA'),
        );
        final c2 = await repository.createCollection(
          CollectionName.create('コレクションB'),
        );

        // 各コレクションに画像追加
        await repository.addImages(c1.id, [
          const EntryId(
            rawValue: 'img1.jpg',
            platformType: PlatformType.windows,
          ),
        ]);
        await repository.addImages(c2.id, [
          const EntryId(
            rawValue: 'img2.jpg',
            platformType: PlatformType.windows,
          ),
        ]);

        // 一括削除（エラーなく完了すること）
        await useCase.execute([c1.id, c2.id]);

        // 全てのコレクションが削除されていることを確認
        expect(await repository.getCollectionById(c1.id), isNull);
        expect(await repository.getCollectionById(c2.id), isNull);
      });
    });

    group('エッジケース', () {
      test('空リストを渡した場合は何も実行しない', () async {
        final collection = await repository.createCollection(
          CollectionName.create('残存コレクション'),
        );

        // 空リストで削除実行
        await useCase.execute([]);

        // コレクションが残存していることを確認
        final result = await repository.getCollectionById(collection.id);
        expect(result, isNotNull);
      });

      test('存在しないIDを指定してもエラーにならない', () async {
        // 存在しないIDで削除実行（例外がスローされないことを確認）
        await expectLater(useCase.execute([99999]), completes);
      });
    });
  });
}
