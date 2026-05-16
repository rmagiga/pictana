/// 検索フィルター AND 結合正確性 プロパティベーステスト
///
/// glados を使用して、applySearchFilter 関数の正当性プロパティを検証する。
/// 各プロパティテストは最低100回のイテレーションで実行される。
///
/// テスト対象:
/// - Property 6: 検索フィルターの AND 結合正確性
// Feature: image-viewer-enhancements, Property 6: 検索フィルターの AND 結合正確性
@Tags(['property-test', 'image-viewer-enhancements'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, tearDown, test;
import 'package:optrig/domain/entities/entry_id.dart';
import 'package:optrig/domain/entities/image_entry.dart';
import 'package:optrig/domain/value_objects/search_filter.dart';

// ---------------------------------------------------------------------------
// カスタムジェネレータ
// ---------------------------------------------------------------------------

/// テスト用の ImageMimeType ジェネレータ
extension SearchFilterGenerators on Any {
  /// 有効な ImageMimeType を生成する（unknown を除外）
  Generator<ImageMimeType> get validMimeType => any
      .intInRange(0, 6)
      .map(
        (i) => [
          ImageMimeType.jpeg,
          ImageMimeType.png,
          ImageMimeType.webp,
          ImageMimeType.gif,
          ImageMimeType.heic,
          ImageMimeType.heif,
          ImageMimeType.avif,
        ][i],
      );

  /// null を含む ImageMimeType フィルター値を生成する
  Generator<ImageMimeType?> get mimeTypeFilter => any
      .intInRange(0, 7)
      .map(
        (i) => switch (i) {
          0 => null,
          1 => ImageMimeType.jpeg,
          2 => ImageMimeType.png,
          3 => ImageMimeType.webp,
          4 => ImageMimeType.gif,
          5 => ImageMimeType.heic,
          6 => ImageMimeType.heif,
          _ => ImageMimeType.avif,
        },
      );

  /// 検索クエリ文字列を生成する（空文字列を含む）
  Generator<String> get searchQuery => any.intInRange(0, 3).map((choice) {
    if (choice == 0) return ''; // 空クエリ
    return 'img'; // 短い検索文字列
  });

  /// ファイル名を生成する（様々なパターン）
  Generator<String> get fileName => any
      .intInRange(0, 9)
      .map(
        (i) => [
          'IMG_001.jpg',
          'photo_2024.png',
          'screenshot.webp',
          'animation.gif',
          'IMG_002.heic',
          'landscape.avif',
          'IMG_test.jpeg',
          'Document.png',
          'PHOTO_IMG.jpg',
          'test_file.webp',
        ][i],
      );

  /// テスト用 ImageEntry リストを生成する（0〜15件）
  Generator<List<ImageEntry>> get imageEntryList =>
      any.intInRange(0, 15).map((count) => _generateImageEntries(count));
}

/// テスト用の ImageEntry リストを生成するヘルパー
List<ImageEntry> _generateImageEntries(int count) {
  final names = [
    'IMG_001.jpg',
    'photo_2024.png',
    'screenshot.webp',
    'animation.gif',
    'IMG_002.heic',
    'landscape.avif',
    'IMG_test.jpeg',
    'Document.png',
    'PHOTO_IMG.jpg',
    'test_file.webp',
    'IMG_large.png',
    'vacation.gif',
    'IMG_final.heif',
    'render.avif',
    'capture.jpg',
  ];

  final mimeTypes = [
    ImageMimeType.jpeg,
    ImageMimeType.png,
    ImageMimeType.webp,
    ImageMimeType.gif,
    ImageMimeType.heic,
    ImageMimeType.avif,
    ImageMimeType.jpeg,
    ImageMimeType.png,
    ImageMimeType.jpeg,
    ImageMimeType.webp,
    ImageMimeType.png,
    ImageMimeType.gif,
    ImageMimeType.heif,
    ImageMimeType.avif,
    ImageMimeType.jpeg,
  ];

  return List.generate(
    count,
    (i) => ImageEntry(
      id: EntryId.windows('C:\\test\\${names[i]}'),
      name: names[i],
      extension: names[i].split('.').last,
      size: 1024 * (i + 1),
      modifiedAt: DateTime(2024, 1, 1).add(Duration(hours: i)),
      uri: 'file:///test/${names[i]}',
      mimeType: mimeTypes[i],
    ),
  );
}

// ---------------------------------------------------------------------------
// テスト本体
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // Property 6: 検索フィルターの AND 結合正確性
  // =========================================================================
  group(
    'Feature: image-viewer-enhancements, Property 6: 検索フィルターの AND 結合正確性',
    () {
      /// **Validates: Requirements 11.2, 11.6, 12.2, 12.3, 12.4**
      ///
      /// 結果の全エントリのファイル名がクエリを大文字小文字無視で部分一致として含む
      /// （クエリが空でない場合）
      Glados2(any.imageEntryList, any.letterOrDigits).test(
        '結果の全エントリがクエリを大文字小文字無視で部分一致として含む',
        (images, query) {
          // 空クエリはこのプロパティの対象外
          if (query.isEmpty) return;

          final result = applySearchFilter(
            images: images,
            query: query,
            mimeTypeFilter: null,
          );

          // 結果の全エントリがクエリを含むことを検証
          final lowerQuery = query.toLowerCase();
          for (final entry in result) {
            expect(
              entry.name.toLowerCase().contains(lowerQuery),
              isTrue,
              reason: 'エントリ "${entry.name}" はクエリ "$query" を含むべき',
            );
          }
        },
      );

      /// 結果の全エントリの MIME type が指定フィルターと一致する
      /// （フィルターが null でない場合）
      Glados2(any.imageEntryList, any.validMimeType).test(
        '結果の全エントリの MIME type が指定フィルターと一致する',
        (images, mimeType) {
          final result = applySearchFilter(
            images: images,
            query: '',
            mimeTypeFilter: mimeType,
          );

          // 結果の全エントリが指定 MIME type であることを検証
          for (final entry in result) {
            expect(
              entry.mimeType,
              mimeType,
              reason:
                  'エントリ "${entry.name}" の mimeType ${entry.mimeType} は '
                  '$mimeType であるべき',
            );
          }
        },
      );

      /// 元リスト内で両条件を満たす全エントリが結果に含まれる（漏れがない: 完全性）
      Glados3(any.imageEntryList, any.letterOrDigits, any.mimeTypeFilter).test(
        '両条件を満たす全エントリが結果に含まれる（完全性）',
        (images, query, mimeTypeFilter) {
          final result = applySearchFilter(
            images: images,
            query: query,
            mimeTypeFilter: mimeTypeFilter,
          );

          // 元リストから両条件を満たすエントリを手動で計算
          final lowerQuery = query.toLowerCase();
          final expected = images.where((e) {
            final matchesQuery =
                query.isEmpty || e.name.toLowerCase().contains(lowerQuery);
            final matchesMime =
                mimeTypeFilter == null || e.mimeType == mimeTypeFilter;
            return matchesQuery && matchesMime;
          }).toList();

          // 期待されるエントリが全て結果に含まれていることを検証
          for (final entry in expected) {
            expect(
              result.contains(entry),
              isTrue,
              reason: 'エントリ "${entry.name}" は結果に含まれるべき',
            );
          }

          // 結果のサイズが期待と一致することも検証（余分なエントリがないこと）
          expect(result.length, expected.length);
        },
      );

      /// クエリが空かつフィルターが null の場合、元リストと同一の結果を返す
      Glados(any.imageEntryList).test('クエリが空かつフィルターが null の場合、元リストと同一の結果を返す', (
        images,
      ) {
        final result = applySearchFilter(
          images: images,
          query: '',
          mimeTypeFilter: null,
        );

        // 元リストと完全に一致することを検証
        expect(result.length, images.length);
        for (var i = 0; i < images.length; i++) {
          expect(result[i], images[i]);
        }
      });
    },
  );
}
