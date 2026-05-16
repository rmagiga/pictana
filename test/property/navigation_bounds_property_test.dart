/// ナビゲーション境界判定 プロパティベーステスト
///
/// glados を使用して、navigationBounds 関数の正当性プロパティを検証する。
///
/// テスト対象:
/// - Property 1: ナビゲーション境界判定の正確性
///
/// 検証内容:
/// - totalCount <= 1 → (false, false)
/// - currentIndex == 0 → canGoPrevious == false
/// - currentIndex == totalCount - 1 → canGoNext == false
/// - 0 < currentIndex < totalCount - 1 → (true, true)
// Feature: image-viewer-enhancements, Property 1: ナビゲーション境界判定の正確性
@Tags(['property-test', 'image-viewer-enhancements'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, tearDown, test;
import 'package:optrig/domain/value_objects/navigation_bounds.dart';

void main() {
  // ===========================================================================
  // Property 1: ナビゲーション境界判定の正確性
  // ===========================================================================
  group('Feature: image-viewer-enhancements, Property 1: ナビゲーション境界判定の正確性', () {
    /// **Validates: Requirements 1.5, 1.6, 1.8, 2.5, 2.6**
    ///
    /// totalCount <= 1 の場合、常に (false, false) を返す。
    /// 単一画像または空リストではナビゲーション不可。
    Glados2(any.intInRange(0, 1000), any.intInRange(0, 1)).test(
      'totalCount <= 1 の場合は常に (false, false) を返す',
      (currentIndex, totalCount) {
        final (canPrev, canNext) = navigationBounds(currentIndex, totalCount);

        expect(canPrev, isFalse);
        expect(canNext, isFalse);
      },
    );

    /// **Validates: Requirements 1.5, 2.5**
    ///
    /// currentIndex == 0（リスト先頭）の場合、canGoPrevious は常に false。
    Glados(any.intInRange(2, 1000)).test(
      'currentIndex == 0 の場合は canGoPrevious == false',
      (totalCount) {
        final (canPrev, canNext) = navigationBounds(0, totalCount);

        expect(canPrev, isFalse);
        // totalCount >= 2 なので canGoNext は true
        expect(canNext, isTrue);
      },
    );

    /// **Validates: Requirements 1.6, 2.6**
    ///
    /// currentIndex == totalCount - 1（リスト末尾）の場合、canGoNext は常に false。
    Glados(any.intInRange(2, 1000)).test(
      'currentIndex == totalCount - 1 の場合は canGoNext == false',
      (totalCount) {
        final lastIndex = totalCount - 1;
        final (canPrev, canNext) = navigationBounds(lastIndex, totalCount);

        expect(canNext, isFalse);
        // totalCount >= 2 なので canGoPrevious は true
        expect(canPrev, isTrue);
      },
    );

    /// **Validates: Requirements 1.5, 1.6, 2.5, 2.6**
    ///
    /// 0 < currentIndex < totalCount - 1（中間位置）の場合、
    /// 前後両方向にナビゲーション可能。
    Glados(any.intInRange(3, 1000)).test(
      '0 < currentIndex < totalCount - 1 の場合は (true, true) を返す',
      (totalCount) {
        // 中間インデックスを生成（1 〜 totalCount - 2 の範囲）
        final midIndex = 1 + ((totalCount - 2) ~/ 2);
        final (canPrev, canNext) = navigationBounds(midIndex, totalCount);

        expect(canPrev, isTrue);
        expect(canNext, isTrue);
      },
    );

    /// **Validates: Requirements 1.5, 1.6, 1.8, 2.5, 2.6**
    ///
    /// 任意の有効な currentIndex と totalCount に対して、
    /// navigationBounds の結果が全条件を同時に満たすことを検証する統合プロパティ。
    Glados2(any.intInRange(0, 999), any.intInRange(0, 1000)).test(
      '任意の有効入力に対して境界判定が正しい',
      (rawIndex, totalCount) {
        // totalCount == 0 の場合は有効なインデックスが存在しないためスキップ
        if (totalCount == 0) {
          final (canPrev, canNext) = navigationBounds(rawIndex, totalCount);
          expect(canPrev, isFalse);
          expect(canNext, isFalse);
          return;
        }

        // 有効なインデックスに正規化
        final currentIndex = rawIndex % totalCount;
        final (canPrev, canNext) = navigationBounds(currentIndex, totalCount);

        if (totalCount <= 1) {
          expect(canPrev, isFalse);
          expect(canNext, isFalse);
        } else {
          expect(canPrev, equals(currentIndex > 0));
          expect(canNext, equals(currentIndex < totalCount - 1));
        }
      },
    );
  });
}
