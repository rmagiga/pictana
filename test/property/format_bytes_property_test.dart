/// バイト数フォーマット プロパティベーステスト
///
/// glados を使用して、formatBytes 関数の正当性プロパティを検証する。
///
/// テスト対象:
/// - Property 5: バイト数フォーマットの正確性
///
/// 検証内容:
/// - 戻り値は常に " B", " KB", " MB", " GB" のいずれかで終わる
/// - 閾値に基づく正しい単位選択
/// - 戻り値は非空で数値部分を含む
/// - bytes = 0 の場合は "0 B" を返す
// Feature: image-viewer-enhancements, Property 5: バイト数フォーマットの正確性
@Tags(['property-test', 'image-viewer-enhancements'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, tearDown, test;
import 'package:optrig/core/utils/format_bytes.dart';

void main() {
  // ===========================================================================
  // Property 5: バイト数フォーマットの正確性
  // ===========================================================================
  group('Feature: image-viewer-enhancements, Property 5: バイト数フォーマットの正確性', () {
    /// **Validates: Requirements 10.1**
    ///
    /// 任意の非負整数に対して、formatBytes の戻り値は
    /// " B", " KB", " MB", " GB" のいずれかで終わる。
    Glados(any.intInRange(0, 10 * 1024 * 1024 * 1024)).test(
      '戻り値は常に有効な単位サフィックスで終わる',
      (bytes) {
        final result = formatBytes(bytes);
        final validSuffixes = [' B', ' KB', ' MB', ' GB'];

        expect(
          validSuffixes.any((suffix) => result.endsWith(suffix)),
          isTrue,
          reason: 'formatBytes($bytes) = "$result" は有効な単位で終わっていない',
        );
      },
    );

    /// **Validates: Requirements 10.1**
    ///
    /// 閾値に基づく正しい単位選択:
    /// - bytes < 1024 → " B"
    /// - bytes < 1024² → " KB"
    /// - bytes < 1024³ → " MB"
    /// - bytes >= 1024³ → " GB"
    Glados(any.intInRange(0, 10 * 1024 * 1024 * 1024)).test(
      '閾値に基づいて正しい単位が選択される',
      (bytes) {
        const kb = 1024;
        const mb = 1024 * 1024;
        const gb = 1024 * 1024 * 1024;

        final result = formatBytes(bytes);

        if (bytes < kb) {
          expect(
            result.endsWith(' B'),
            isTrue,
            reason: 'bytes=$bytes (< 1024) は B で終わるべき、実際: "$result"',
          );
        } else if (bytes < mb) {
          expect(
            result.endsWith(' KB'),
            isTrue,
            reason: 'bytes=$bytes (< 1024²) は KB で終わるべき、実際: "$result"',
          );
        } else if (bytes < gb) {
          expect(
            result.endsWith(' MB'),
            isTrue,
            reason: 'bytes=$bytes (< 1024³) は MB で終わるべき、実際: "$result"',
          );
        } else {
          expect(
            result.endsWith(' GB'),
            isTrue,
            reason: 'bytes=$bytes (>= 1024³) は GB で終わるべき、実際: "$result"',
          );
        }
      },
    );

    /// **Validates: Requirements 10.1**
    ///
    /// 戻り値は非空で、数値部分を含む文字列である。
    Glados(any.intInRange(0, 10 * 1024 * 1024 * 1024)).test('戻り値は非空で数値部分を含む', (
      bytes,
    ) {
      final result = formatBytes(bytes);

      // 非空チェック
      expect(
        result.isNotEmpty,
        isTrue,
        reason: 'formatBytes($bytes) が空文字列を返した',
      );

      // 数値部分を抽出（単位を除去）
      final numericPart = result
          .replaceAll(' B', '')
          .replaceAll(' KB', '')
          .replaceAll(' MB', '')
          .replaceAll(' GB', '')
          .trim();

      // 数値としてパース可能であることを確認
      final parsed = double.tryParse(numericPart);
      expect(
        parsed,
        isNotNull,
        reason: 'formatBytes($bytes) = "$result" の数値部分 "$numericPart" がパースできない',
      );
      expect(
        parsed!,
        greaterThanOrEqualTo(0),
        reason: 'formatBytes($bytes) = "$result" の数値部分が負の値',
      );
    });

    /// **Validates: Requirements 10.1**
    ///
    /// bytes = 0 の場合、結果は "0 B" である。
    test('bytes = 0 の場合は "0 B" を返す', () {
      final result = formatBytes(0);
      expect(result, equals('0 B'));
    });

    /// **Validates: Requirements 10.1**
    ///
    /// 任意の非負整数に対して、フォーマット結果の数値部分を
    /// 元の単位に逆変換した場合、元の値との誤差が許容範囲内である。
    Glados(
      any.intInRange(0, 10 * 1024 * 1024 * 1024),
    ).test('フォーマット結果を逆変換した場合、元の値に近似する', (bytes) {
      const kb = 1024;
      const mb = 1024 * 1024;
      const gb = 1024 * 1024 * 1024;

      final result = formatBytes(bytes);

      // 数値部分と単位を分離
      late double numericValue;
      late double multiplier;

      if (result.endsWith(' GB')) {
        numericValue = double.parse(
          result.substring(0, result.length - 3).trim(),
        );
        multiplier = gb.toDouble();
      } else if (result.endsWith(' MB')) {
        numericValue = double.parse(
          result.substring(0, result.length - 3).trim(),
        );
        multiplier = mb.toDouble();
      } else if (result.endsWith(' KB')) {
        numericValue = double.parse(
          result.substring(0, result.length - 3).trim(),
        );
        multiplier = kb.toDouble();
      } else {
        // " B" の場合
        numericValue = double.parse(
          result.substring(0, result.length - 2).trim(),
        );
        multiplier = 1.0;
      }

      final reconstructed = numericValue * multiplier;

      // 許容誤差: 各単位の精度に基づく
      // B: 誤差なし（整数表示）
      // KB: 小数1桁 → 最大誤差 0.05 * 1024 ≈ 51.2 bytes
      // MB: 小数1桁 → 最大誤差 0.05 * 1024² ≈ 52429 bytes
      // GB: 小数2桁 → 最大誤差 0.005 * 1024³ ≈ 5368709 bytes
      final maxError =
          multiplier *
          (multiplier == 1.0
              ? 0.0
              : multiplier == kb.toDouble()
              ? 0.05
              : multiplier == mb.toDouble()
              ? 0.05
              : 0.005);

      expect(
        (reconstructed - bytes).abs(),
        lessThanOrEqualTo(maxError + 0.01), // 浮動小数点誤差のマージン
        reason: 'formatBytes($bytes) = "$result" → 逆変換 $reconstructed、誤差が許容範囲外',
      );
    });
  });
}
