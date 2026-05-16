/// calculateGridColumns プロパティベーステスト
///
/// 画面幅に応じたグリッド列数計算のプロパティベーステストによる網羅的検証。
///
/// **Validates: Requirements 1.2, 7.1, 7.2, 7.3**
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
Generator<double> get _positiveScreenWidthGenerator =>
    any.intInRange(1, 100000).map((i) => i / 10.0);

/// 有効な minColumns 値を生成するジェネレータ（3, 4, 5, 6）
Generator<int> get _minColumnsGenerator => any.choose([3, 4, 5, 6]);

/// 有効な maxColumns 値を生成するジェネレータ（6, 8, 10, 12）
Generator<int> get _maxColumnsGenerator => any.choose([6, 8, 10, 12]);

/// 有効な min/max ペアを生成するジェネレータ
/// 制約: max >= min + 2
Generator<({int min, int max})> get _validMinMaxGenerator => any.combine2(
  _minColumnsGenerator,
  _maxColumnsGenerator,
  (int min, int max) {
    // max >= min + 2 を満たすペアのみ使用
    // 満たさない場合は max を min + 2 以上に調整
    final adjustedMax = max >= min + 2 ? max : min + 2;
    // adjustedMax が有効な選択肢（6, 8, 10, 12）に収まるようにクランプ
    final clampedMax = adjustedMax.clamp(6, 12);
    // それでも制約を満たさない場合（min=6 で max=6 など）は min を下げる
    final finalMin = clampedMax >= min + 2 ? min : clampedMax - 2;
    return (min: finalMin, max: clampedMax);
  },
);

void main() {
  // =========================================================================
  // Feature: folder-selection-ux-redesign, Property 1: Column calculation follows formula with clamping
  // プロパティベーステスト: 列数計算が formula + clamp に従う
  // =========================================================================
  group('Property 1: Column calculation follows formula with clamping', () {
    // 任意の screenWidth（正の double）と有効な min/max 設定に対して、
    // calculateGridColumns の結果が clamp(floor((screenWidth - 32) / 168), min, max) と一致する
    Glados2(_positiveScreenWidthGenerator, _validMinMaxGenerator).test(
      '任意の画面幅と有効な min/max 設定に対して formula + clamp が成立する',
      (screenWidth, minMax) {
        final result = calculateGridColumns(
          screenWidth,
          minColumns: minMax.min,
          maxColumns: minMax.max,
        );

        // 期待値: floor((screenWidth - 32) / 168) を [min, max] にクランプ
        final rawColumns = ((screenWidth - 32) / 168).floor();
        final expected = rawColumns.clamp(minMax.min, minMax.max);

        expect(
          result,
          equals(expected),
          reason:
              '画面幅 $screenWidth, min=${minMax.min}, max=${minMax.max} に対して '
              '結果 $result は期待値 $expected (raw=$rawColumns) と一致しない',
        );
      },
    );

    // 結果が常に [minColumns, maxColumns] の範囲内であることを検証
    Glados2(
      _positiveScreenWidthGenerator,
      _validMinMaxGenerator,
    ).test('結果は常に [minColumns, maxColumns] の範囲内である', (screenWidth, minMax) {
      final result = calculateGridColumns(
        screenWidth,
        minColumns: minMax.min,
        maxColumns: minMax.max,
      );

      expect(
        result,
        greaterThanOrEqualTo(minMax.min),
        reason: '画面幅 $screenWidth に対して結果 $result が minColumns=${minMax.min} 未満',
      );
      expect(
        result,
        lessThanOrEqualTo(minMax.max),
        reason: '画面幅 $screenWidth に対して結果 $result が maxColumns=${minMax.max} 超過',
      );
    });

    // 画面幅が増加すると列数は単調非減少であることを検証
    Glados2(_positiveScreenWidthGenerator, _validMinMaxGenerator).test(
      '画面幅が増加すると列数は単調非減少である',
      (screenWidth, minMax) {
        final result1 = calculateGridColumns(
          screenWidth,
          minColumns: minMax.min,
          maxColumns: minMax.max,
        );
        // 168dp（1カード分）追加した幅で計算
        final result2 = calculateGridColumns(
          screenWidth + 168,
          minColumns: minMax.min,
          maxColumns: minMax.max,
        );

        expect(
          result2,
          greaterThanOrEqualTo(result1),
          reason:
              '画面幅 ${screenWidth + 168} の列数 $result2 が '
              '画面幅 $screenWidth の列数 $result1 より小さい',
        );
      },
    );
  });

  // =========================================================================
  // Feature: folder-selection-ux-redesign, Property 2: Grid horizontal padding is symmetric and non-negative
  // プロパティベーステスト: 水平パディングが対称かつ非負
  // =========================================================================
  group('Property 2: Grid horizontal padding is symmetric and non-negative', () {
    // 有効な列数を生成するジェネレータ（1〜12）
    final validColumnsGenerator = any.intInRange(1, 12);

    // 536dp 以上の画面幅を生成するジェネレータ
    final wideScreenWidthGenerator = any
        .intInRange(536, 4000)
        .map((i) => i.toDouble());

    // パディングが常に非負であることを検証
    Glados2(wideScreenWidthGenerator, validColumnsGenerator).test(
      '任意の画面幅 >= 536dp と有効な列数に対してパディングは非負である',
      (screenWidth, columns) {
        final padding = calculateGridHorizontalPadding(screenWidth, columns);

        expect(
          padding,
          greaterThanOrEqualTo(0.0),
          reason:
              '画面幅 $screenWidth, 列数 $columns に対して '
              'パディング $padding が負の値',
        );
      },
    );

    // パディングが対称（左右均等）であることを検証
    // calculateGridHorizontalPadding は片側のパディングを返すため、
    // パディングが正の場合、contentWidth + padding * 2 が screenWidth と一致することを確認
    Glados2(
      wideScreenWidthGenerator,
      validColumnsGenerator,
    ).test('パディングが正の場合、コンテンツ幅 + 両側パディングが画面幅と一致する', (screenWidth, columns) {
      final padding = calculateGridHorizontalPadding(screenWidth, columns);
      final contentWidth = columns * 168.0 - 8.0;

      // パディングが 0 の場合はコンテンツ幅が画面幅を超えているケース（スキップ）
      if (padding > 0) {
        final totalWidth = contentWidth + padding * 2;
        // 浮動小数点誤差を考慮して 0.01dp の許容範囲
        expect(
          (totalWidth - screenWidth).abs(),
          lessThan(0.01),
          reason:
              '画面幅 $screenWidth に対して '
              'コンテンツ幅 $contentWidth + パディング ${padding * 2} = $totalWidth が一致しない',
        );
      }
    });

    // パディングが (screenWidth - contentWidth) / 2 の計算式に従うことを検証
    Glados2(wideScreenWidthGenerator, validColumnsGenerator).test(
      'パディングは (screenWidth - contentWidth) / 2 の計算式に従う',
      (screenWidth, columns) {
        final padding = calculateGridHorizontalPadding(screenWidth, columns);
        final contentWidth = columns * 168.0 - 8.0;
        final expectedRaw = (screenWidth - contentWidth) / 2.0;
        final expected = expectedRaw < 0 ? 0.0 : expectedRaw;

        // 浮動小数点誤差を考慮
        expect(
          (padding - expected).abs(),
          lessThan(0.001),
          reason:
              '画面幅 $screenWidth, 列数 $columns に対して '
              'パディング $padding は期待値 $expected と一致しない',
        );
      },
    );
  });
}
