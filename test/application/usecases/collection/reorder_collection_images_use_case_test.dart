/// コレクション内画像の並び替えユースケーステスト
///
/// インメモリ Drift DB を使用した統合テスト。
/// 並び替え後の画像取得順序が更新されていることを検証する。
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pictana/application/usecases/collection/add_images_to_collection_use_case.dart';
import 'package:pictana/application/usecases/collection/create_collection_use_case.dart';
import 'package:pictana/application/usecases/collection/reorder_collection_images_use_case.dart';
import 'package:pictana/domain/entities/entry_id.dart';
import 'package:pictana/infrastructure/database/app_database.dart';
import 'package:pictana/infrastructure/database/collection_repository_impl.dart';

void main() {
  late AppDatabase db;
  late CollectionRepositoryImpl repository;
  late CreateCollectionUseCase createUseCase;
  late AddImagesToCollectionUseCase addUseCase;
  late ReorderCollectionImagesUseCase reorderUseCase;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = CollectionRepositoryImpl(db);
    createUseCase = CreateCollectionUseCase(repository: repository);
    addUseCase = AddImagesToCollectionUseCase(repository: repository);
    reorderUseCase = ReorderCollectionImagesUseCase(repository: repository);
  });

  tearDown(() async {
    await db.close();
  });

  EntryId createTestEntryId(String value) =>
      EntryId(rawValue: value, platformType: PlatformType.windows);

  group('ReorderCollectionImagesUseCase', () {
    test('コレクション内の画像の並び順を変更でき、再取得した際に新しい順序で取得される', () async {
      final collection = await createUseCase.execute('テストコレクション');
      final entry1 = createTestEntryId('img1.jpg');
      final entry2 = createTestEntryId('img2.jpg');
      final entry3 = createTestEntryId('img3.jpg');

      // 画像を追加（初期状態）
      await addUseCase.execute(
        collectionIds: [collection.id],
        entryIds: [entry1, entry2, entry3],
      );

      // 初期状態の順序を確認
      final initialImages = await repository.getCollectionImages(collection.id);
      expect(initialImages.length, 3);
      expect(initialImages[0].entryId.rawValue, 'img1.jpg');
      expect(initialImages[1].entryId.rawValue, 'img2.jpg');
      expect(initialImages[2].entryId.rawValue, 'img3.jpg');

      // 並び順を変更: img3 -> img1 -> img2
      await reorderUseCase.execute(collection.id, [entry3, entry1, entry2]);

      // 変更後の順序を確認
      final orderedImages = await repository.getCollectionImages(collection.id);
      expect(orderedImages.length, 3);
      expect(orderedImages[0].entryId.rawValue, 'img3.jpg');
      expect(orderedImages[1].entryId.rawValue, 'img1.jpg');
      expect(orderedImages[2].entryId.rawValue, 'img2.jpg');
    });

    test('空リストが渡された場合は何も実行せずエラーにもならない', () async {
      final collection = await createUseCase.execute('テストコレクション');
      await expectLater(
        reorderUseCase.execute(collection.id, []),
        completes,
      );
    });
  });
}
