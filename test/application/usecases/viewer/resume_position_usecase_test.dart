import 'package:flutter_test/flutter_test.dart';
import 'package:pictana/application/usecases/viewer/resume_position_usecase.dart';
import 'package:pictana/domain/repositories/image_repository.dart';

class _MockImageRepository implements ImageRepository {
  final Map<String, String> _positions = {};

  @override
  Future<void> saveLastViewedEntryId(String folderUri, String entryId) async {
    _positions[folderUri] = entryId;
  }

  @override
  Future<String?> getLastViewedEntryId(String folderUri) async {
    return _positions[folderUri];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _MockImageRepository imageRepository;
  late ResumePositionUseCase useCase;

  setUp(() {
    imageRepository = _MockImageRepository();
    useCase = ResumePositionUseCase(imageRepository: imageRepository);
  });

  group('ResumePositionUseCase', () {
    test('savePosition で最終閲覧位置が保存され、getPosition で取得できること', () async {
      final folderUri = 'file:///test/folder';
      final entryId = 'img_123';

      expect(await useCase.getPosition(folderUri), isNull);

      await useCase.savePosition(folderUri: folderUri, entryId: entryId);

      expect(await useCase.getPosition(folderUri), equals(entryId));
    });

    test('異なるフォルダURIは別々に管理されること', () async {
      final folderUri1 = 'file:///test/folder1';
      final folderUri2 = 'file:///test/folder2';
      final entryId1 = 'img_1';
      final entryId2 = 'img_2';

      await useCase.savePosition(folderUri: folderUri1, entryId: entryId1);
      await useCase.savePosition(folderUri: folderUri2, entryId: entryId2);

      expect(await useCase.getPosition(folderUri1), equals(entryId1));
      expect(await useCase.getPosition(folderUri2), equals(entryId2));
    });
  });
}
