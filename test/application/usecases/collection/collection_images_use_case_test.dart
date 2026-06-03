/// コレクションに対する画像追加・解除のユースケーステスト
///
/// インメモリ Drift DB を使用した統合テスト。
/// 冪等性、複数コレクション所属、解除の影響範囲を検証する。
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pictana/application/usecases/collection/add_images_to_collection_use_case.dart';
import 'package:pictana/application/usecases/collection/create_collection_use_case.dart';
import 'package:pictana/application/usecases/collection/remove_images_from_collection_use_case.dart';
import 'package:pictana/domain/entities/entry_id.dart';
import 'package:pictana/infrastructure/database/app_database.dart';
import 'package:pictana/infrastructure/database/collection_repository_impl.dart';

void main() {
  late AppDatabase db;
  late CollectionRepositoryImpl repository;
  late CreateCollectionUseCase createUseCase;
  late AddImagesToCollectionUseCase addUseCase;
  late RemoveImagesFromCollectionUseCase removeUseCase;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = CollectionRepositoryImpl(db);
    createUseCase = CreateCollectionUseCase(repository: repository);
    addUseCase = AddImagesToCollectionUseCase(repository: repository);
    removeUseCase = RemoveImagesFromCollectionUseCase(repository: repository);
  });

  tearDown(() async {
    await db.close();
  });

  EntryId createTestEntryId(String value) =>
      EntryId(rawValue: value, platformType: PlatformType.windows);

  group('Collection Images UseCases', () {
    test('コレクションに画像を追加でき、追加された画像が取得できる', () async {
      final collection = await createUseCase.execute('テストコレクション');
      final entry = createTestEntryId('image1.jpg');

      final addedCount = await addUseCase.execute(
        collectionIds: [collection.id],
        entryIds: [entry],
      );

      expect(addedCount, 1);

      final images = await repository.getCollectionImages(collection.id);
      expect(images.length, 1);
      expect(images.first.entryId.rawValue, 'image1.jpg');
    });

    test('画像追加の冪等性: 同じ画像を2回追加しても重複せず、2回目は追加件数0になる', () async {
      final collection = await createUseCase.execute('テストコレクション');
      final entry = createTestEntryId('image1.jpg');

      // 1回目の追加
      final addedCount1 = await addUseCase.execute(
        collectionIds: [collection.id],
        entryIds: [entry],
      );
      expect(addedCount1, 1);

      // 2回目の追加（重複）
      final addedCount2 = await addUseCase.execute(
        collectionIds: [collection.id],
        entryIds: [entry],
      );
      expect(addedCount2, 0);

      // 重複登録されていないことを確認
      final images = await repository.getCollectionImages(collection.id);
      expect(images.length, 1);
    });

    test('画像解除の影響範囲: コレクションAから解除してもコレクションBでの所属状態は変わらない', () async {
      final collectionA = await createUseCase.execute('コレクションA');
      final collectionB = await createUseCase.execute('コレクションB');
      final entry = createTestEntryId('shared.jpg');

      // 両方に追加
      await addUseCase.execute(
        collectionIds: [collectionA.id, collectionB.id],
        entryIds: [entry],
      );

      // コレクションAから削除
      await removeUseCase.execute(collectionA.id, [entry]);

      // コレクションAからは削除されている
      final imagesA = await repository.getCollectionImages(collectionA.id);
      expect(imagesA, isEmpty);

      // コレクションBには残っている
      final imagesB = await repository.getCollectionImages(collectionB.id);
      expect(imagesB.length, 1);
      expect(imagesB.first.entryId.rawValue, 'shared.jpg');
    });

    test('複数コレクション所属: 1つの画像が複数のコレクションに所属し、所属コレクション一覧を取得できる', () async {
      final col1 = await createUseCase.execute('col1');
      final col2 = await createUseCase.execute('col2');
      final col3 = await createUseCase.execute('col3');
      final entry = createTestEntryId('multi.jpg');

      await addUseCase.execute(
        collectionIds: [col1.id, col2.id, col3.id],
        entryIds: [entry],
      );

      final collections = await repository.getCollectionsForImage(entry);
      final colIds = collections.map((c) => c.id).toSet();

      expect(colIds.length, 3);
      expect(colIds.contains(col1.id), isTrue);
      expect(colIds.contains(col2.id), isTrue);
      expect(colIds.contains(col3.id), isTrue);
    });
  });
}
