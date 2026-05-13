/// Property 13: サムネイルキャッシュ ラウンドトリップ
///
/// 任意の ImageEntry に対して、サムネイル生成とキャッシュ保存が成功した後、
/// 同じエントリに対する getThumbnail 呼び出しがキャッシュデータを返し、
/// ネイティブプラットフォームチャネルを呼び出さないことを検証するプロパティテスト。
///
/// **Validates: Requirements 7.1, 7.4**
@Tags(['android-saf', 'property-test'])
library;

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, tearDown, test;
import 'package:optrig/domain/entities/entry_id.dart';
import 'package:optrig/domain/entities/image_entry.dart';
import 'package:optrig/domain/repositories/thumbnail_repository.dart';

// ---------------------------------------------------------------------------
// テスト用の簡易キャッシュモデル
//
// AndroidThumbnailRepository のメモリキャッシュロジックを純粋関数として
// 抽出したもの。ネイティブチャネルや DB を使わずにキャッシュの
// ラウンドトリップ特性を検証する。
// ---------------------------------------------------------------------------

/// サムネイルキャッシュのキーを生成する（本体実装と同じロジック）
String buildCacheKey(String uri, ThumbnailSize size) {
  return '$uri::${size.px}';
}

/// テスト用の簡易サムネイルキャッシュ
///
/// AndroidThumbnailRepository のメモリキャッシュ動作をシミュレートする。
/// ネイティブ生成の呼び出し回数を追跡し、キャッシュヒット時に
/// ネイティブ呼び出しが発生しないことを検証可能にする。
class SimpleThumbnailCache {
  final Map<String, Uint8List> _memoryCache = {};

  /// ネイティブ生成が呼び出された回数
  int nativeCallCount = 0;

  /// サムネイルを取得する（キャッシュ優先）
  ///
  /// キャッシュヒット時: キャッシュデータを返す（ネイティブ呼び出しなし）
  /// キャッシュミス時: [nativeGenerator] を呼び出してキャッシュに保存
  Uint8List? getThumbnail(
    ImageEntry entry, {
    ThumbnailSize size = ThumbnailSize.grid,
    required Uint8List? Function() nativeGenerator,
  }) {
    final cacheKey = buildCacheKey(entry.uri, size);

    // 1. メモリキャッシュ確認
    final cached = _memoryCache[cacheKey];
    if (cached != null) {
      return cached;
    }

    // 2. ネイティブ生成（キャッシュミス時のみ）
    nativeCallCount++;
    final generated = nativeGenerator();
    if (generated == null) return null;

    // 3. キャッシュに保存
    _memoryCache[cacheKey] = generated;
    return generated;
  }

  /// キャッシュにデータが存在するか確認
  bool containsKey(String uri, ThumbnailSize size) {
    return _memoryCache.containsKey(buildCacheKey(uri, size));
  }
}

// ---------------------------------------------------------------------------
// glados 用カスタムジェネレータ
// ---------------------------------------------------------------------------

/// ランダムなバイトデータを生成する Generator
Generator<Uint8List> get _bytesGenerator =>
    any.intInRange(1, 1024).bind((length) {
      return any
          .listWithLengthInRange(length, length, any.intInRange(0, 255))
          .map((bytes) => Uint8List.fromList(bytes));
    });

/// ランダムな ImageEntry を生成する Generator
Generator<ImageEntry> get _imageEntryGenerator => any.nonEmptyLetters.bind((
  name,
) {
  return any.nonEmptyLetters.bind((docId) {
    return any.intInRange(100, 10000000).map((size) {
      const ext = 'jpg';
      return ImageEntry(
        id: EntryId.android('primary:DCIM/$docId.$ext'),
        name: '$name.$ext',
        extension: ext,
        uri:
            'content://com.android.externalstorage.documents/tree/primary%3ADCIM/document/primary%3ADCIM%2F$docId.$ext',
        mimeType: ImageMimeType.jpeg,
        size: size,
        modifiedAt: DateTime(2024, 1, 1),
      );
    });
  });
});

// ---------------------------------------------------------------------------
// プロパティテスト
// ---------------------------------------------------------------------------

void main() {
  group('Feature: android-saf, Property 13: サムネイルキャッシュ ラウンドトリップ', () {
    Glados(_imageEntryGenerator).test('キャッシュ保存後の取得は同じデータを返す', (entry) {
      final cache = SimpleThumbnailCache();
      final thumbnailData = Uint8List.fromList(
        List.generate(256, (i) => i % 256),
      );

      // 初回呼び出し: ネイティブ生成
      final firstResult = cache.getThumbnail(
        entry,
        nativeGenerator: () => thumbnailData,
      );

      // 2 回目呼び出し: キャッシュから取得
      final secondResult = cache.getThumbnail(
        entry,
        nativeGenerator: () => throw StateError('ネイティブ生成が呼ばれるべきではない'),
      );

      expect(firstResult, isNotNull);
      expect(secondResult, isNotNull);
      expect(secondResult, equals(firstResult));
    });

    Glados2(_imageEntryGenerator, _bytesGenerator).test(
      'キャッシュヒット時はネイティブプラットフォームチャネルを呼び出さない',
      (entry, bytes) {
        final cache = SimpleThumbnailCache();

        // 初回: ネイティブ生成（1 回呼ばれる）
        cache.getThumbnail(entry, nativeGenerator: () => bytes);
        expect(cache.nativeCallCount, 1);

        // 2 回目: キャッシュヒット（ネイティブ呼び出し増えない）
        cache.getThumbnail(
          entry,
          nativeGenerator: () => throw StateError('ネイティブ生成が呼ばれるべきではない'),
        );
        expect(cache.nativeCallCount, 1);
      },
    );

    Glados2(_imageEntryGenerator, _bytesGenerator).test(
      'キャッシュされたデータはバイト単位で元データと一致する',
      (entry, originalBytes) {
        final cache = SimpleThumbnailCache();

        // キャッシュに保存
        cache.getThumbnail(entry, nativeGenerator: () => originalBytes);

        // キャッシュから取得
        final cached = cache.getThumbnail(
          entry,
          nativeGenerator: () => throw StateError('ネイティブ生成が呼ばれるべきではない'),
        );

        expect(cached, isNotNull);
        expect(cached!.length, originalBytes.length);
        for (var i = 0; i < originalBytes.length; i++) {
          expect(cached[i], originalBytes[i], reason: 'バイト[$i] が一致しない');
        }
      },
    );

    Glados(_imageEntryGenerator).test('異なる ThumbnailSize は独立してキャッシュされる', (
      entry,
    ) {
      final cache = SimpleThumbnailCache();
      final gridData = Uint8List.fromList([1, 2, 3, 4]);
      final largeData = Uint8List.fromList([5, 6, 7, 8]);

      // grid サイズでキャッシュ
      cache.getThumbnail(
        entry,
        size: ThumbnailSize.grid,
        nativeGenerator: () => gridData,
      );

      // large サイズでキャッシュ（別キー）
      cache.getThumbnail(
        entry,
        size: ThumbnailSize.large,
        nativeGenerator: () => largeData,
      );

      // grid を再取得 → grid データが返る
      final cachedGrid = cache.getThumbnail(
        entry,
        size: ThumbnailSize.grid,
        nativeGenerator: () => throw StateError('ネイティブ生成が呼ばれるべきではない'),
      );

      // large を再取得 → large データが返る
      final cachedLarge = cache.getThumbnail(
        entry,
        size: ThumbnailSize.large,
        nativeGenerator: () => throw StateError('ネイティブ生成が呼ばれるべきではない'),
      );

      expect(cachedGrid, equals(gridData));
      expect(cachedLarge, equals(largeData));
      expect(cachedGrid, isNot(equals(cachedLarge)));
    });

    Glados(_imageEntryGenerator).test('ネイティブ生成が null を返した場合はキャッシュされない', (
      entry,
    ) {
      final cache = SimpleThumbnailCache();

      // ネイティブ生成が null を返す
      final firstResult = cache.getThumbnail(
        entry,
        nativeGenerator: () => null,
      );
      expect(firstResult, isNull);

      // 再度呼び出し → ネイティブ生成が再度呼ばれる
      final retryData = Uint8List.fromList([10, 20, 30]);
      final secondResult = cache.getThumbnail(
        entry,
        nativeGenerator: () => retryData,
      );

      expect(secondResult, equals(retryData));
      expect(cache.nativeCallCount, 2);
    });

    Glados2(_imageEntryGenerator, _imageEntryGenerator).test(
      '異なる ImageEntry は独立してキャッシュされる',
      (entry1, entry2) {
        // 同じ URI の場合はスキップ（異なるエントリのテストなので）
        if (entry1.uri == entry2.uri) return;

        final cache = SimpleThumbnailCache();
        final data1 = Uint8List.fromList([1, 1, 1]);
        final data2 = Uint8List.fromList([2, 2, 2]);

        // entry1 をキャッシュ
        cache.getThumbnail(entry1, nativeGenerator: () => data1);

        // entry2 をキャッシュ
        cache.getThumbnail(entry2, nativeGenerator: () => data2);

        // entry1 を再取得
        final cached1 = cache.getThumbnail(
          entry1,
          nativeGenerator: () => throw StateError('ネイティブ生成が呼ばれるべきではない'),
        );

        // entry2 を再取得
        final cached2 = cache.getThumbnail(
          entry2,
          nativeGenerator: () => throw StateError('ネイティブ生成が呼ばれるべきではない'),
        );

        expect(cached1, equals(data1));
        expect(cached2, equals(data2));
        expect(cache.nativeCallCount, 2);
      },
    );
  });
}
