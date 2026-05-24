import 'package:flutter_test/flutter_test.dart';
import 'package:pictana/application/usecases/viewer/preload_adjacent_images_usecase.dart';
import 'package:pictana/domain/entities/entry_id.dart';
import 'package:pictana/domain/entities/image_entry.dart';
import 'package:pictana/domain/repositories/image_repository.dart';

class MockImageRepository implements ImageRepository {
  final List<ImageEntry> calledEntries = [];
  final Map<String, bool> shouldThrow = {};

  @override
  Future<List<int>> getImageBytes(ImageEntry entry) async {
    calledEntries.add(entry);
    if (shouldThrow[entry.uri] == true) {
      throw Exception('Load error for ${entry.uri}');
    }
    return [1, 2, 3];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockImageRepository mockRepo;
  late PreloadAdjacentImagesUseCase useCase;
  late List<ImageEntry> testEntries;

  setUp(() {
    mockRepo = MockImageRepository();
    useCase = PreloadAdjacentImagesUseCase(imageRepository: mockRepo);
    testEntries = List.generate(10, (i) {
      return ImageEntry(
        id: EntryId.windows('C:\\test\\image_$i.jpg'),
        name: 'image_$i.jpg',
        extension: 'jpg',
        size: 1024,
        modifiedAt: DateTime(2024, 1, 1),
        uri: 'C:\\test\\image_$i.jpg',
        mimeType: ImageMimeType.jpeg,
      );
    });
  });

  group('PreloadAdjacentImagesUseCase', () {
    test('デフォルト（isMovingForward = true）の時は、進行方向（右）を優先して前後4枚をプリロードする', () async {
      await useCase.execute(testEntries, 4);

      // 期待されるロード順:
      // 進行方向（右側）: 5, 6, 7, 8
      // 逆方向（左側）: 3, 2, 1, 0
      final expectedUris = [
        'C:\\test\\image_5.jpg',
        'C:\\test\\image_6.jpg',
        'C:\\test\\image_7.jpg',
        'C:\\test\\image_8.jpg',
        'C:\\test\\image_3.jpg',
        'C:\\test\\image_2.jpg',
        'C:\\test\\image_1.jpg',
        'C:\\test\\image_0.jpg',
      ];

      expect(mockRepo.calledEntries.map((e) => e.uri).toList(), expectedUris);
    });

    test('isMovingForward = false の時は、進行方向（左）を優先して前後4枚をプリロードする', () async {
      await useCase.execute(testEntries, 5, isMovingForward: false);

      // 期待されるロード順:
      // 進行方向（左側）: 4, 3, 2, 1
      // 逆方向（右側）: 6, 7, 8, 9
      final expectedUris = [
        'C:\\test\\image_4.jpg',
        'C:\\test\\image_3.jpg',
        'C:\\test\\image_2.jpg',
        'C:\\test\\image_1.jpg',
        'C:\\test\\image_6.jpg',
        'C:\\test\\image_7.jpg',
        'C:\\test\\image_8.jpg',
        'C:\\test\\image_9.jpg',
      ];

      expect(mockRepo.calledEntries.map((e) => e.uri).toList(), expectedUris);
    });

    test('リストの境界付近で範囲外のインデックスは除外される（開始付近）', () async {
      await useCase.execute(testEntries, 1, isMovingForward: true);

      // 期待されるインデックス（currentIndex = 1）:
      // 進行方向（右側）: 2, 3, 4, 5
      // 逆方向（左側）: 0 (1-1=0, 1-2=-1[除外], 1-3=-2[除外], 1-4=-3[除外])
      final expectedUris = [
        'C:\\test\\image_2.jpg',
        'C:\\test\\image_3.jpg',
        'C:\\test\\image_4.jpg',
        'C:\\test\\image_5.jpg',
        'C:\\test\\image_0.jpg',
      ];

      expect(mockRepo.calledEntries.map((e) => e.uri).toList(), expectedUris);
    });

    test('リストの境界付近で範囲外のインデックスは除外される（末尾付近）', () async {
      await useCase.execute(testEntries, 8, isMovingForward: true);

      // 期待されるインデックス（currentIndex = 8）:
      // 進行方向（右側）: 9 (8+1=9, 8+2=10[除外], 8+3=11[除外], 8+4=12[除外])
      // 逆方向（左側）: 7, 6, 5, 4
      final expectedUris = [
        'C:\\test\\image_9.jpg',
        'C:\\test\\image_7.jpg',
        'C:\\test\\image_6.jpg',
        'C:\\test\\image_5.jpg',
        'C:\\test\\image_4.jpg',
      ];

      expect(mockRepo.calledEntries.map((e) => e.uri).toList(), expectedUris);
    });

    test('プリロードでエラーが発生しても、他の画像のプリロードが継続される', () async {
      // image_6.jpg のロードで例外を投げるように設定
      mockRepo.shouldThrow['C:\\test\\image_6.jpg'] = true;

      await useCase.execute(testEntries, 4);

      // image_5.jpg, image_6.jpg(エラー), image_7.jpg, image_8.jpg ... などの呼び出しが行われること
      // （※ image_6.jpg の呼び出し時点で例外が発生しても、他の image_7.jpg や左側の画像も呼ばれる）
      final expectedUris = [
        'C:\\test\\image_5.jpg',
        'C:\\test\\image_6.jpg',
        'C:\\test\\image_7.jpg',
        'C:\\test\\image_8.jpg',
        'C:\\test\\image_3.jpg',
        'C:\\test\\image_2.jpg',
        'C:\\test\\image_1.jpg',
        'C:\\test\\image_0.jpg',
      ];

      expect(mockRepo.calledEntries.map((e) => e.uri).toList(), expectedUris);
    });
  });
}
