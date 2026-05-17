/// calculateGridColumns / calculateGridHorizontalPadding ユニットテスト
///
/// 境界値テストと具体的なケースによる検証。
///
/// **Validates: Requirements 7.1, 7.2, 7.3**
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:pictana/core/utils/grid_utils.dart';

void main() {
  // ===========================================================================
  // calculateGridColumns 境界値テスト
  // ===========================================================================
  group('calculateGridColumns - 境界値テスト', () {
    test('width=535dp（狭い画面）→ minColumns にクランプされる', () {
      // (535 - 32) / 168 = 2.99... → floor = 2 → clamp(3, 12) = 3
      expect(calculateGridColumns(535), equals(3));
    });

    test('width=536dp → 3列', () {
      // (536 - 32) / 168 = 3.0 → floor = 3 → clamp(3, 12) = 3
      expect(calculateGridColumns(536), equals(3));
    });

    test('width=704dp → 4列', () {
      // (704 - 32) / 168 = 4.0 → floor = 4
      expect(calculateGridColumns(704), equals(4));
    });

    test('width=2048dp（超ワイド）→ maxColumns にクランプされる', () {
      // (2048 - 32) / 168 = 12.0 → floor = 12 → clamp(3, 12) = 12
      expect(calculateGridColumns(2048), equals(12));
    });

    test('width=3000dp → maxColumns=12 にクランプ', () {
      // (3000 - 32) / 168 = 17.66... → floor = 17 → clamp(3, 12) = 12
      expect(calculateGridColumns(3000), equals(12));
    });

    test('カスタム minColumns=4 で width=535dp → 4列', () {
      // (535 - 32) / 168 = 2.99... → floor = 2 → clamp(4, 12) = 4
      expect(calculateGridColumns(535, minColumns: 4), equals(4));
    });

    test('カスタム maxColumns=6 で width=2048dp → 6列', () {
      // (2048 - 32) / 168 = 12.0 → clamp(3, 6) = 6
      expect(calculateGridColumns(2048, maxColumns: 6), equals(6));
    });

    test('width=200dp（極端に狭い）→ minColumns にクランプ', () {
      // (200 - 32) / 168 = 1.0 → floor = 1 → clamp(3, 12) = 3
      expect(calculateGridColumns(200), equals(3));
    });

    test('width=32dp（パディング分のみ）→ minColumns にクランプ', () {
      // (32 - 32) / 168 = 0.0 → floor = 0 → clamp(3, 12) = 3
      expect(calculateGridColumns(32), equals(3));
    });
  });

  // ===========================================================================
  // calculateGridHorizontalPadding ユニットテスト
  // ===========================================================================
  group('calculateGridHorizontalPadding - 基本テスト', () {
    test('3列で width=536dp → パディング計算が正しい', () {
      // contentWidth = 3 * 168 - 8 = 496
      // padding = (536 - 496) / 2 = 20.0
      final padding = calculateGridHorizontalPadding(536, 3);
      expect(padding, closeTo(20.0, 0.01));
    });

    test('4列で width=704dp → パディング計算が正しい', () {
      // contentWidth = 4 * 168 - 8 = 664
      // padding = (704 - 664) / 2 = 20.0
      final padding = calculateGridHorizontalPadding(704, 4);
      expect(padding, closeTo(20.0, 0.01));
    });

    test('コンテンツ幅が画面幅を超える場合 → パディング 0', () {
      // contentWidth = 5 * 168 - 8 = 832
      // padding = (400 - 832) / 2 = -216 → max(0, -216) = 0
      final padding = calculateGridHorizontalPadding(400, 5);
      expect(padding, equals(0.0));
    });

    test('1列で width=200dp → パディング計算が正しい', () {
      // contentWidth = 1 * 168 - 8 = 160
      // padding = (200 - 160) / 2 = 20.0
      final padding = calculateGridHorizontalPadding(200, 1);
      expect(padding, closeTo(20.0, 0.01));
    });

    test('12列で width=2048dp → パディング計算が正しい', () {
      // contentWidth = 12 * 168 - 8 = 2008
      // padding = (2048 - 2008) / 2 = 20.0
      final padding = calculateGridHorizontalPadding(2048, 12);
      expect(padding, closeTo(20.0, 0.01));
    });
  });
}
