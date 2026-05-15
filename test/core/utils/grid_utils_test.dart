/// calculateGridColumns ユニットテスト & プロパティテスト
///
/// 画面幅に応じたグリッド列数計算の境界値テストおよび
/// プロパティベーステストによる網羅的検証。
///
/// Requirements: 1.3, 9.1, 9.2, 9.3
///
/// **Validates: Requirements 1.3, 9.1, 9.2, 9.3**
@Tags(['property-test'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, tearDown, test;
import 'package:optrig/core/utils/grid_utils.dart';

// ---------------------------------------------------------------------------
// glados 用カスタムジェネレータ
// ---------------------------------------------------------------------------

/// 正の double 値を生成するジェネレータ（0.1 〜 10000.0 の範囲）
///
/// 画面幅として現実的な範囲を含みつつ、境界値付近も十分にカバーする。
Generator<double> get _positiveDoubleGenerator =>
    any.intInRange(1, 100000).map((i) => i / 10.0);

void main() {
  // =========================================================================
  // ユニットテスト（境界値テスト）
  // =========================================================================
  group('calculateGridColumns', () {
    test('画面幅600dp未満の場合、2列を返す', () {
      expect(calculateGridColumns(0), 2);
      expect(calculateGridColumns(320), 2);
      expect(calculateGridColumns(599.9), 2);
    });

    test('画面幅600dp以上900dp未満の場合、3列を返す', () {
      expect(calculateGridColumns(600), 3);
      expect(calculateGridColumns(750), 3);
      expect(calculateGridColumns(899.9), 3);
    });

    test('画面幅900dp以上の場合、4列を返す', () {
      expect(calculateGridColumns(900), 4);
      expect(calculateGridColumns(1200), 4);
      expect(calculateGridColumns(1920), 4);
    });

    test('境界値599と600で列数が切り替わる', () {
      expect(calculateGridColumns(599), 2);
      expect(calculateGridColumns(600), 3);
    });

    test('境界値899と900で列数が切り替わる', () {
      expect(calculateGridColumns(899), 3);
      expect(calculateGridColumns(900), 4);
    });
  });

  // =========================================================================
  // プロパティベーステスト
  // =========================================================================
  group('Feature: favorites-folder-grid, Property 1: レスポンシブ列数計算の正確性', () {
    // Property 1: 任意の正の double 値に対して、戻り値が常に {2, 3, 4} のいずれか
    Glados(_positiveDoubleGenerator).test(
      '任意の正の画面幅に対して戻り値は常に 2, 3, 4 のいずれかである',
      (screenWidth) {
        final result = calculateGridColumns(screenWidth);
        expect(
          result,
          anyOf(equals(2), equals(3), equals(4)),
          reason: '画面幅 $screenWidth に対して戻り値 $result は {2, 3, 4} に含まれない',
        );
      },
    );

    // Property 1 補足: ブレークポイントロジックの正確性
    Glados(_positiveDoubleGenerator).test('画面幅 < 600 の場合は 2 列を返す', (
      screenWidth,
    ) {
      final result = calculateGridColumns(screenWidth);
      if (screenWidth < 600) {
        expect(
          result,
          equals(2),
          reason: '画面幅 $screenWidth (< 600) に対して $result を返したが、2 であるべき',
        );
      }
    });

    Glados(_positiveDoubleGenerator).test('画面幅 600 以上 900 未満の場合は 3 列を返す', (
      screenWidth,
    ) {
      final result = calculateGridColumns(screenWidth);
      if (screenWidth >= 600 && screenWidth < 900) {
        expect(
          result,
          equals(3),
          reason: '画面幅 $screenWidth (600 ≤ w < 900) に対して $result を返したが、3 であるべき',
        );
      }
    });

    Glados(_positiveDoubleGenerator).test('画面幅 900 以上の場合は 4 列を返す', (
      screenWidth,
    ) {
      final result = calculateGridColumns(screenWidth);
      if (screenWidth >= 900) {
        expect(
          result,
          equals(4),
          reason: '画面幅 $screenWidth (≥ 900) に対して $result を返したが、4 であるべき',
        );
      }
    });
  });
}
