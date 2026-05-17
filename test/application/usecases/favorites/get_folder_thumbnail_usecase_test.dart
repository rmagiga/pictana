/// GetFolderThumbnailUseCase ユニットテスト
///
/// 手動 Fake を使用したユニットテスト。
/// 画像あり/画像なし/例外スロー時の3パターンを検証する。
///
/// Requirements: 3.1, 3.5, 3.6
library;

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:optrig/application/usecases/favorites/get_folder_thumbnail_usecase.dart';
import 'package:optrig/domain/entities/entry_id.dart';
import 'package:optrig/domain/entities/favorite_folder.dart';
import 'package:optrig/domain/entities/folder_entry.dart';
import 'package:optrig/domain/entities/image_entry.dart';
import 'package:optrig/domain/repositories/image_repository.dart';
import 'package:optrig/domain/repositories/thumbnail_repository.dart';
import 'package:optrig/domain/value_objects/sort_option.dart';
import 'package:optrig/domain/value_objects/thumbnail_size_option.dart';

// ---------------------------------------------------------------------------
// テスト用 Fake 実装
// ---------------------------------------------------------------------------

/// テスト用 ImageRepository
///
/// [getImagePageResult] で返却値を制御し、
/// [getImagePageException] で例外スローを制御する。
class FakeImageRepository implements ImageRepository {
  List<ImageEntry> getImagePageResult = [];
  Exception? getImagePageException;

  /// getImagePage が呼ばれた回数
  int getImagePageCallCount = 0;

  @override
  Future<List<ImageEntry>> getImagePage({
    required FolderEntry folder,
    required int page,
    required int pageSize,
    SortOption sort = SortOption.defaultOption,
    ImageFilter filter = ImageFilter.none,
  }) async {
    getImagePageCallCount++;
    if (getImagePageException != null) {
      throw getImagePageException!;
    }
    return getImagePageResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// テスト用 ThumbnailRepository
///
/// [getThumbnailResult] で返却値を制御する。
class FakeThumbnailRepository implements ThumbnailRepository {
  Uint8List? getThumbnailResult;

  /// getThumbnail が呼ばれた回数
  int getThumbnailCallCount = 0;

  @override
  Future<Uint8List?> getThumbnail(
    ImageEntry entry, {
    ThumbnailSizeOption size = ThumbnailSizeOption.medium,
  }) async {
    getThumbnailCallCount++;
    return getThumbnailResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

// ---------------------------------------------------------------------------
// テストデータ
// ---------------------------------------------------------------------------

/// テスト用 FavoriteFolder
FavoriteFolder createTestFolder({
  int id = 1,
  String uri = 'file:///test/folder1',
  String name = 'テストフォルダ',
}) {
  return FavoriteFolder(
    id: id,
    uri: uri,
    name: name,
    registeredAt: DateTime(2024, 1, 1),
  );
}

/// テスト用 ImageEntry
ImageEntry createTestImageEntry({
  String name = 'photo001.jpg',
  String uri = 'file:///test/folder1/photo001.jpg',
}) {
  return ImageEntry(
    id: EntryId(rawValue: uri, platformType: PlatformType.windows),
    name: name,
    extension: 'jpg',
    size: 1024000,
    modifiedAt: DateTime(2024, 1, 1),
    uri: uri,
    mimeType: ImageMimeType.jpeg,
  );
}

// ---------------------------------------------------------------------------
// テスト本体
// ---------------------------------------------------------------------------

void main() {
  late FakeImageRepository fakeImageRepository;
  late FakeThumbnailRepository fakeThumbnailRepository;
  late GetFolderThumbnailUseCase useCase;

  setUp(() {
    fakeImageRepository = FakeImageRepository();
    fakeThumbnailRepository = FakeThumbnailRepository();
    useCase = GetFolderThumbnailUseCase(
      imageRepository: fakeImageRepository,
      thumbnailRepository: fakeThumbnailRepository,
    );
  });

  group('GetFolderThumbnailUseCase', () {
    group('画像あり - サムネイル取得成功', () {
      test('フォルダ内に画像が存在する場合、サムネイルバイト列を返す', () async {
        // Arrange
        final testImage = createTestImageEntry();
        final expectedBytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]);
        fakeImageRepository.getImagePageResult = [testImage];
        fakeThumbnailRepository.getThumbnailResult = expectedBytes;

        final folder = createTestFolder();

        // Act
        final result = await useCase.execute(folder: folder);

        // Assert
        expect(result, isNotNull);
        expect(result, expectedBytes);
        expect(fakeImageRepository.getImagePageCallCount, 1);
        expect(fakeThumbnailRepository.getThumbnailCallCount, 1);
      });
    });

    group('画像なし - null を返す', () {
      test('フォルダ内に画像が存在しない場合、null を返す', () async {
        // Arrange
        fakeImageRepository.getImagePageResult = [];

        final folder = createTestFolder();

        // Act
        final result = await useCase.execute(folder: folder);

        // Assert
        expect(result, isNull);
        expect(fakeImageRepository.getImagePageCallCount, 1);
        // ThumbnailRepository は呼ばれない
        expect(fakeThumbnailRepository.getThumbnailCallCount, 0);
      });
    });

    group('例外スロー - null を返す', () {
      test('ImageRepository が例外をスローした場合、null を返す', () async {
        // Arrange
        fakeImageRepository.getImagePageException = Exception('アクセス失敗');

        final folder = createTestFolder();

        // Act
        final result = await useCase.execute(folder: folder);

        // Assert
        expect(result, isNull);
        expect(fakeImageRepository.getImagePageCallCount, 1);
        // ThumbnailRepository は呼ばれない
        expect(fakeThumbnailRepository.getThumbnailCallCount, 0);
      });
    });
  });
}
