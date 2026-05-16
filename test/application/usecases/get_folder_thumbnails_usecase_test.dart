/// GetFolderThumbnailsUseCase サムネイルスロット割り当てプロパティテスト
///
/// 任意の画像結果リスト（長さ 0〜N）に対して、2×2 グリッドのスロット割り当てが
/// 順序通り（top-left → top-right → bottom-left → bottom-right）に行われ、
/// 残りのスロットがプレースホルダー状態であることを検証する。
///
/// **Validates: Requirements 2.2, 2.3, 2.8**
@Tags(['property-test'])
library;

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, tearDown, test;
import 'package:optrig/application/usecases/storage/get_folder_thumbnails_usecase.dart';
import 'package:optrig/domain/entities/entry_id.dart';
import 'package:optrig/domain/entities/favorite_folder.dart';
import 'package:optrig/domain/entities/folder_entry.dart';
import 'package:optrig/domain/entities/image_entry.dart';
import 'package:optrig/domain/repositories/image_repository.dart';
import 'package:optrig/domain/repositories/thumbnail_repository.dart';
import 'package:optrig/domain/value_objects/sort_option.dart';

// ---------------------------------------------------------------------------
// テスト用 Fake 実装
// ---------------------------------------------------------------------------

/// テスト用 ImageRepository
///
/// [imageCount] で返却する画像数を制御する。
/// 各画像はファイル名昇順で生成される。
class FakeImageRepository implements ImageRepository {
  FakeImageRepository({required this.imageCount});

  final int imageCount;

  @override
  Future<List<ImageEntry>> getImagePage({
    required FolderEntry folder,
    required int page,
    required int pageSize,
    SortOption sort = SortOption.defaultOption,
    ImageFilter filter = ImageFilter.none,
  }) async {
    // pageSize 分だけ返す（imageCount を超えない）
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

/// テスト用 ThumbnailRepository
///
/// [thumbnailResults] で各画像のサムネイル取得結果を制御する。
/// true の場合はバイト列を返し、false の場合は null を返す。
class FakeThumbnailRepository implements ThumbnailRepository {
  FakeThumbnailRepository({required this.thumbnailResults});

  /// 各スロットのサムネイル取得成否（true: 成功、false: 失敗/null）
  final List<bool> thumbnailResults;

  int _callIndex = 0;

  @override
  Future<Uint8List?> getThumbnail(
    ImageEntry entry, {
    ThumbnailSize size = ThumbnailSize.grid,
  }) async {
    final index = _callIndex++;
    if (index < thumbnailResults.length && thumbnailResults[index]) {
      // 成功時: インデックスを含むバイト列を返す（順序検証用）
      return Uint8List.fromList([index]);
    }
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

// ---------------------------------------------------------------------------
// テストデータ
// ---------------------------------------------------------------------------

/// テスト用 FavoriteFolder
FavoriteFolder createTestFolder() {
  return FavoriteFolder(
    id: 1,
    uri: 'file:///test/folder',
    name: 'テストフォルダ',
    registeredAt: DateTime(2024, 1, 1),
  );
}

// ---------------------------------------------------------------------------
// glados 用カスタムジェネレータ
// ---------------------------------------------------------------------------

/// フォルダ内の画像数を生成するジェネレータ（0〜20）
///
/// 0枚（空フォルダ）から20枚（4枚以上）まで幅広くカバーする。
Generator<int> get _imageCountGenerator => any.intInRange(0, 20);

/// 各スロットのサムネイル取得成否リストを生成するジェネレータ
///
/// 最大4スロット分の bool リストを生成する。
/// true: サムネイル取得成功、false: 取得失敗（null）
Generator<List<bool>> get _thumbnailSuccessGenerator =>
    any.listWithLengthInRange(0, 4, any.bool);

// ---------------------------------------------------------------------------
// テスト本体
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // Feature: folder-selection-ux-redesign, Property 3: Thumbnail slot assignment fills top-left to bottom-right
  // =========================================================================
  group(
    'Property 3: Thumbnail slot assignment fills top-left to bottom-right',
    () {
      Glados(_imageCountGenerator).test(
        '任意の画像数 N に対して、結果リストの長さは min(4, N) である',
        (imageCount) async {
          final fakeImageRepo = FakeImageRepository(imageCount: imageCount);
          final fakeThumbnailRepo = FakeThumbnailRepository(
            thumbnailResults: List.filled(4, true),
          );
          final useCase = GetFolderThumbnailsUseCase(
            imageRepository: fakeImageRepo,
            thumbnailRepository: fakeThumbnailRepo,
          );

          final result = await useCase.execute(folder: createTestFolder());

          // 結果リストの長さは min(4, imageCount)
          final expectedLength = imageCount < 4 ? imageCount : 4;
          expect(
            result.length,
            equals(expectedLength),
            reason:
                '画像数 $imageCount に対して結果長 ${result.length} は '
                '期待値 $expectedLength と一致しない',
          );
        },
      );

      Glados(_imageCountGenerator).test(
        '結果リストの各要素はスロット順序 [top-left, top-right, bottom-left, bottom-right] に対応する',
        (imageCount) async {
          final fakeImageRepo = FakeImageRepository(imageCount: imageCount);
          // 全スロット成功にして順序を検証
          final fakeThumbnailRepo = FakeThumbnailRepository(
            thumbnailResults: List.filled(4, true),
          );
          final useCase = GetFolderThumbnailsUseCase(
            imageRepository: fakeImageRepo,
            thumbnailRepository: fakeThumbnailRepo,
          );

          final result = await useCase.execute(folder: createTestFolder());

          // 各スロットのバイト列がインデックス順に割り当てられていることを検証
          for (var i = 0; i < result.length; i++) {
            if (result[i] != null) {
              expect(
                result[i]![0],
                equals(i),
                reason:
                    'スロット $i のバイト値 ${result[i]![0]} が '
                    '期待インデックス $i と一致しない（順序違反）',
              );
            }
          }
        },
      );

      Glados2(
        _imageCountGenerator,
        _thumbnailSuccessGenerator,
      ).test('取得失敗したスロットは null（プレースホルダー状態）となり、順序は維持される', (
        imageCount,
        thumbnailSuccesses,
      ) async {
        // 実際に使用するスロット数
        final slotCount = imageCount < 4 ? imageCount : 4;
        // thumbnailSuccesses を slotCount に合わせる
        final adjustedSuccesses = List.generate(
          slotCount,
          (i) => i < thumbnailSuccesses.length ? thumbnailSuccesses[i] : true,
        );

        final fakeImageRepo = FakeImageRepository(imageCount: imageCount);
        final fakeThumbnailRepo = FakeThumbnailRepository(
          thumbnailResults: adjustedSuccesses,
        );
        final useCase = GetFolderThumbnailsUseCase(
          imageRepository: fakeImageRepo,
          thumbnailRepository: fakeThumbnailRepo,
        );

        final result = await useCase.execute(folder: createTestFolder());

        // 結果リストの長さは min(4, imageCount)
        expect(result.length, equals(slotCount));

        // 各スロットの null/non-null が thumbnailSuccesses と一致する
        for (var i = 0; i < result.length; i++) {
          if (adjustedSuccesses[i]) {
            expect(result[i], isNotNull, reason: 'スロット $i は成功設定だが null が返された');
          } else {
            expect(result[i], isNull, reason: 'スロット $i は失敗設定だが non-null が返された');
          }
        }
      });

      Glados(
        _imageCountGenerator,
      ).test('画像数が 0 の場合、空リストが返される（全スロットがプレースホルダー状態）', (imageCount) async {
        // imageCount を 0 に固定して空フォルダのケースを検証
        final fakeImageRepo = FakeImageRepository(imageCount: 0);
        final fakeThumbnailRepo = FakeThumbnailRepository(thumbnailResults: []);
        final useCase = GetFolderThumbnailsUseCase(
          imageRepository: fakeImageRepo,
          thumbnailRepository: fakeThumbnailRepo,
        );

        final result = await useCase.execute(folder: createTestFolder());

        // 空リスト = 全4スロットがプレースホルダー状態
        expect(result, isEmpty);
      });

      Glados(_imageCountGenerator).test('結果リストの長さは常に 0〜4 の範囲内である', (
        imageCount,
      ) async {
        final fakeImageRepo = FakeImageRepository(imageCount: imageCount);
        final fakeThumbnailRepo = FakeThumbnailRepository(
          thumbnailResults: List.filled(4, true),
        );
        final useCase = GetFolderThumbnailsUseCase(
          imageRepository: fakeImageRepo,
          thumbnailRepository: fakeThumbnailRepo,
        );

        final result = await useCase.execute(folder: createTestFolder());

        expect(
          result.length,
          lessThanOrEqualTo(4),
          reason: '結果長 ${result.length} が最大スロット数 4 を超過',
        );
        expect(
          result.length,
          greaterThanOrEqualTo(0),
          reason: '結果長 ${result.length} が負の値',
        );
      });
    },
  );
}
