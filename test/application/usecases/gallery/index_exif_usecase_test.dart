import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:pictana/application/usecases/gallery/index_exif_usecase.dart';
import 'package:pictana/domain/entities/entry_id.dart';
import 'package:pictana/domain/entities/folder_entry.dart';
import 'package:pictana/domain/entities/image_entry.dart';
import 'package:pictana/domain/repositories/exif_processor.dart';
import 'package:pictana/domain/repositories/image_repository.dart';
import 'package:pictana/infrastructure/database/app_database.dart';

class _MockImageRepository implements ImageRepository {
  bool shouldThrow = false;

  @override
  Future<List<int>> getImageBytes(ImageEntry entry) async {
    if (shouldThrow) {
      throw Exception('Read error');
    }
    return [0, 1, 2, 3];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockExifProcessor implements ExifProcessor {
  bool shouldThrow = false;
  ExifMetadata metadataToReturn = ExifMetadata(
    dateTime: DateTime(2026, 5, 28, 12, 0, 0),
    camera: 'Test Camera',
    latitude: 35.6812,
    longitude: 139.7671,
  );

  @override
  Future<ExifMetadata> extractMetadata(List<int> bytes) async {
    if (shouldThrow) {
      throw Exception('Exif parse error');
    }
    return metadataToReturn;
  }

  @override
  int extractRotation(List<int> bytes) => 0;

  @override
  List<int>? extractThumbnail(List<int> bytes) => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late _MockImageRepository imageRepository;
  late _MockExifProcessor exifProcessor;
  late IndexExifUseCase useCase;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    imageRepository = _MockImageRepository();
    exifProcessor = _MockExifProcessor();
    useCase = IndexExifUseCase(
      database: db,
      imageRepository: imageRepository,
      exifProcessor: exifProcessor,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('IndexExifUseCase', () {
    test('EXIF未取得の画像が存在する場合、非同期でパースしてDBを更新する', () async {
      final folderUri = 'file:///test/folder';
      final folder = FolderEntry(
        id: EntryId.windows(folderUri),
        name: 'test',
        uri: folderUri,
      );

      await db
          .into(db.images)
          .insert(
            ImagesCompanion.insert(
              entryId: 'img1',
              uri: 'file:///test/folder/img1.jpg',
              folderUri: folderUri,
              name: 'img1.jpg',
              extension: 'jpg',
              modified: DateTime.now().millisecondsSinceEpoch,
              size: 1024,
              mimeType: 'jpeg',
              indexedAt: DateTime.now(),
            ),
          );

      final missing = await db.getImagesMissingExif(folderUri);
      expect(missing.length, equals(1));
      expect(missing.first.exifDateTime, isNull);

      await useCase.execute(folder);

      final updated = await db.getImageByEntryId('img1');
      expect(updated, isNotNull);
      expect(
        updated!.exifDateTime,
        equals(exifProcessor.metadataToReturn.dateTime),
      );
      expect(updated.exifCamera, equals(exifProcessor.metadataToReturn.camera));
      expect(
        updated.exifGpsLatitude,
        equals(exifProcessor.metadataToReturn.latitude),
      );
      expect(
        updated.exifGpsLongitude,
        equals(exifProcessor.metadataToReturn.longitude),
      );

      final missingAfter = await db.getImagesMissingExif(folderUri);
      expect(missingAfter, isEmpty);
    });

    test('画像バイトのロードで例外が発生した場合、Epoch0日付とダミー値で更新して再試行を防止する', () async {
      final folderUri = 'file:///test/folder';
      final folder = FolderEntry(
        id: EntryId.windows(folderUri),
        name: 'test',
        uri: folderUri,
      );

      await db
          .into(db.images)
          .insert(
            ImagesCompanion.insert(
              entryId: 'img_fail',
              uri: 'file:///test/folder/img_fail.jpg',
              folderUri: folderUri,
              name: 'img_fail.jpg',
              extension: 'jpg',
              modified: DateTime.now().millisecondsSinceEpoch,
              size: 1024,
              mimeType: 'jpeg',
              indexedAt: DateTime.now(),
            ),
          );

      imageRepository.shouldThrow = true;

      await useCase.execute(folder);

      final updated = await db.getImageByEntryId('img_fail');
      expect(updated, isNotNull);
      expect(
        updated!.exifDateTime,
        equals(DateTime.fromMillisecondsSinceEpoch(0)),
      );
      expect(updated.exifCamera, equals('Failed'));

      final missing = await db.getImagesMissingExif(folderUri);
      expect(missing, isEmpty);
    });

    test('EXIF解析で例外が発生した場合、Epoch0日付とダミー値で更新して再試行を防止する', () async {
      final folderUri = 'file:///test/folder';
      final folder = FolderEntry(
        id: EntryId.windows(folderUri),
        name: 'test',
        uri: folderUri,
      );

      await db
          .into(db.images)
          .insert(
            ImagesCompanion.insert(
              entryId: 'img_parse_fail',
              uri: 'file:///test/folder/img_parse_fail.jpg',
              folderUri: folderUri,
              name: 'img_parse_fail.jpg',
              extension: 'jpg',
              modified: DateTime.now().millisecondsSinceEpoch,
              size: 1024,
              mimeType: 'jpeg',
              indexedAt: DateTime.now(),
            ),
          );

      exifProcessor.shouldThrow = true;

      await useCase.execute(folder);

      final updated = await db.getImageByEntryId('img_parse_fail');
      expect(updated, isNotNull);
      expect(
        updated!.exifDateTime,
        equals(DateTime.fromMillisecondsSinceEpoch(0)),
      );
      expect(updated.exifCamera, equals('Failed'));

      final missing = await db.getImagesMissingExif(folderUri);
      expect(missing, isEmpty);
    });
  });
}
