/// GetFolderThumbnailsUseCase ユニットテスト
///
/// 具体的なケース（0枚、1-3枚、4枚以上）による検証。
///
/// **Validates: Requirements 2.2, 2.3**
library;

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pictana/application/usecases/storage/get_folder_thumbnails_usecase.dart';
import 'package:pictana/core/utils/cancel_token.dart';
import 'package:pictana/domain/entities/entry_id.dart';
import 'package:pictana/domain/entities/favorite_folder.dart';
import 'package:pictana/domain/entities/folder_entry.dart';
import 'package:pictana/domain/entities/image_entry.dart';
import 'package:pictana/domain/repositories/image_repository.dart';
import 'package:pictana/domain/repositories/storage_repository.dart';
import 'package:pictana/domain/repositories/thumbnail_repository.dart';
import 'package:pictana/domain/value_objects/sort_option.dart';
import 'package:pictana/domain/value_objects/thumbnail_size_option.dart';

// ---------------------------------------------------------------------------
// テスト用 Fake 実装
// ---------------------------------------------------------------------------

/// テスト用 StorageRepository
class _FakeStorageRepository implements StorageRepository {
  @override
  FolderEntry restoreFolderFromUri({
    required String uri,
    required String name,
  }) {
    return FolderEntry(
      id: EntryId(rawValue: uri, platformType: PlatformType.windows),
      name: name,
      uri: uri,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// テスト用 ImageRepository
class _FakeImageRepository implements ImageRepository {
  _FakeImageRepository({required this.imageCount});
  final int imageCount;

  @override
  Future<List<ImageEntry>> getImagePage({
    required FolderEntry folder,
    required int page,
    required int pageSize,
    SortOption sort = SortOption.defaultOption,
    ImageFilter filter = ImageFilter.none,
  }) async {
    final count = pageSize < imageCount ? pageSize : imageCount;
    return List.generate(count, (i) {
      final name = 'img_${i.toString().padLeft(4, '0')}.jpg';
      return ImageEntry(
        id: EntryId(
          rawValue: 'file:///$name',
          platformType: PlatformType.windows,
        ),
        name: name,
        extension: 'jpg',
        size: 1024,
        modifiedAt: DateTime(2024, 1, 1),
        uri: 'file:///test/$name',
        mimeType: ImageMimeType.jpeg,
      );
    });
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// テスト用 ThumbnailRepository（全成功）
class _SuccessThumbnailRepository implements ThumbnailRepository {
  int callCount = 0;

  @override
  Future<Uint8List?> getThumbnail(
    ImageEntry entry, {
    ThumbnailSizeOption size = ThumbnailSizeOption.medium,
    CancelToken? cancelToken,
  }) async {
    final index = callCount++;
    return Uint8List.fromList([index, 0xFF]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// テスト用 ThumbnailRepository（全失敗）
class _FailingThumbnailRepository implements ThumbnailRepository {
  @override
  Future<Uint8List?> getThumbnail(
    ImageEntry entry, {
    ThumbnailSizeOption size = ThumbnailSizeOption.medium,
    CancelToken? cancelToken,
  }) async {
    throw Exception('サムネイル取得失敗');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// テスト用 ImageRepository（例外をスロー）
class _FailingImageRepository implements ImageRepository {
  @override
  Future<List<ImageEntry>> getImagePage({
    required FolderEntry folder,
    required int page,
    required int pageSize,
    SortOption sort = SortOption.defaultOption,
    ImageFilter filter = ImageFilter.none,
  }) async {
    throw Exception('フォルダアクセス失敗');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

// ---------------------------------------------------------------------------
// テストデータ
// ---------------------------------------------------------------------------

FavoriteFolder _createTestFolder() {
  return FavoriteFolder(
    id: 1,
    uri: 'file:///test/folder',
    name: 'テストフォルダ',
    registeredAt: DateTime(2024, 1, 1),
  );
}

// ---------------------------------------------------------------------------
// テスト本体
// ---------------------------------------------------------------------------

void main() {
  group('GetFolderThumbnailsUseCase - 0枚のケース', () {
    test('画像が0枚の場合、空リストを返す', () async {
      final useCase = GetFolderThumbnailsUseCase(
        imageRepository: _FakeImageRepository(imageCount: 0),
        thumbnailRepository: _SuccessThumbnailRepository(),
        storageRepository: _FakeStorageRepository(),
      );

      final result = await useCase.execute(folder: _createTestFolder());

      expect(result, isEmpty);
    });

    test('フォルダアクセス失敗時、空リストを返す', () async {
      final useCase = GetFolderThumbnailsUseCase(
        imageRepository: _FailingImageRepository(),
        thumbnailRepository: _SuccessThumbnailRepository(),
        storageRepository: _FakeStorageRepository(),
      );

      final result = await useCase.execute(folder: _createTestFolder());

      expect(result, isEmpty);
    });
  });

  group('GetFolderThumbnailsUseCase - 1-3枚のケース', () {
    test('画像が1枚の場合、長さ1のリストを返す', () async {
      final useCase = GetFolderThumbnailsUseCase(
        imageRepository: _FakeImageRepository(imageCount: 1),
        thumbnailRepository: _SuccessThumbnailRepository(),
        storageRepository: _FakeStorageRepository(),
      );

      final result = await useCase.execute(folder: _createTestFolder());

      expect(result.length, equals(1));
      expect(result[0], isNotNull);
    });

    test('画像が2枚の場合、長さ2のリストを返す', () async {
      final useCase = GetFolderThumbnailsUseCase(
        imageRepository: _FakeImageRepository(imageCount: 2),
        thumbnailRepository: _SuccessThumbnailRepository(),
        storageRepository: _FakeStorageRepository(),
      );

      final result = await useCase.execute(folder: _createTestFolder());

      expect(result.length, equals(2));
      expect(result[0], isNotNull);
      expect(result[1], isNotNull);
    });

    test('画像が3枚の場合、長さ3のリストを返す', () async {
      final useCase = GetFolderThumbnailsUseCase(
        imageRepository: _FakeImageRepository(imageCount: 3),
        thumbnailRepository: _SuccessThumbnailRepository(),
        storageRepository: _FakeStorageRepository(),
      );

      final result = await useCase.execute(folder: _createTestFolder());

      expect(result.length, equals(3));
    });
  });

  group('GetFolderThumbnailsUseCase - 4枚以上のケース', () {
    test('画像が4枚の場合、長さ4のリストを返す', () async {
      final useCase = GetFolderThumbnailsUseCase(
        imageRepository: _FakeImageRepository(imageCount: 4),
        thumbnailRepository: _SuccessThumbnailRepository(),
        storageRepository: _FakeStorageRepository(),
      );

      final result = await useCase.execute(folder: _createTestFolder());

      expect(result.length, equals(4));
    });

    test('画像が10枚の場合でも、最大4枚のリストを返す', () async {
      final useCase = GetFolderThumbnailsUseCase(
        imageRepository: _FakeImageRepository(imageCount: 10),
        thumbnailRepository: _SuccessThumbnailRepository(),
        storageRepository: _FakeStorageRepository(),
      );

      final result = await useCase.execute(folder: _createTestFolder());

      expect(result.length, equals(4));
    });
  });

  group('GetFolderThumbnailsUseCase - サムネイル取得失敗', () {
    test('サムネイル取得が全て失敗した場合、全要素が null のリストを返す', () async {
      final useCase = GetFolderThumbnailsUseCase(
        imageRepository: _FakeImageRepository(imageCount: 3),
        thumbnailRepository: _FailingThumbnailRepository(),
        storageRepository: _FakeStorageRepository(),
      );

      final result = await useCase.execute(folder: _createTestFolder());

      expect(result.length, equals(3));
      expect(result[0], isNull);
      expect(result[1], isNull);
      expect(result[2], isNull);
    });
  });

  group('GetFolderThumbnailsUseCase - スロット順序', () {
    test('サムネイルはインデックス順に割り当てられる', () async {
      final useCase = GetFolderThumbnailsUseCase(
        imageRepository: _FakeImageRepository(imageCount: 4),
        thumbnailRepository: _SuccessThumbnailRepository(),
        storageRepository: _FakeStorageRepository(),
      );

      final result = await useCase.execute(folder: _createTestFolder());

      // 各スロットのバイト列の先頭バイトがインデックスと一致
      for (var i = 0; i < 4; i++) {
        expect(result[i], isNotNull);
        expect(result[i]![0], equals(i));
      }
    });
  });
}
