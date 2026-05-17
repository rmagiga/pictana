// Feature: image-viewer-enhancements, Property 3: EXIF Orientation 回転マッピングの正確性
/// **Validates: Requirements 6.1, 6.3, 6.5**
///
/// EXIF Orientation 値 (1〜8) に対して exifOrientationToRotation が以下を満たすことを検証:
/// - 戻り値は {0, 90, 180, 270} のいずれか
/// - ミラーリング成分を含む値 (2, 4, 5, 7) は非ミラー対応値 (1, 3, 8, 6) と同じ回転を返す
/// - 範囲外の値 (≤0 または ≥9) に対しては 0 を返す
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, tearDown, test;
import 'package:pictana/domain/value_objects/exif_rotation.dart';

/// 有効な回転角度の集合
const validRotations = {0, 90, 180, 270};

/// ミラーペア: (ミラー値, 非ミラー対応値)
/// 2→1, 4→3, 5→8, 7→6
const mirrorPairs = <int, int>{2: 1, 4: 3, 5: 8, 7: 6};

void main() {
  group('Property 3: EXIF Orientation 回転マッピングの正確性', () {
    Glados(any.intInRange(1, 8)).test(
      '有効な Orientation 値 (1-8) に対して戻り値は {0, 90, 180, 270} のいずれか',
      (orientation) {
        final result = exifOrientationToRotation(orientation);

        expect(
          validRotations.contains(result),
          isTrue,
          reason: 'orientation=$orientation に対して result=$result は有効な回転角度ではない',
        );
      },
    );

    Glados(any.intInRange(-100, 0)).test('範囲外の値 (≤0) に対しては 0 を返す', (
      orientation,
    ) {
      final result = exifOrientationToRotation(orientation);

      expect(
        result,
        equals(0),
        reason: 'orientation=$orientation (範囲外) に対して result=$result ≠ 0',
      );
    });

    Glados(any.intInRange(9, 100)).test('範囲外の値 (≥9) に対しては 0 を返す', (
      orientation,
    ) {
      final result = exifOrientationToRotation(orientation);

      expect(
        result,
        equals(0),
        reason: 'orientation=$orientation (範囲外) に対して result=$result ≠ 0',
      );
    });

    Glados(any.choose(mirrorPairs.keys.toList())).test(
      'ミラー値 (2, 4, 5, 7) は非ミラー対応値と同じ回転角度を返す',
      (mirrorOrientation) {
        final nonMirrorOrientation = mirrorPairs[mirrorOrientation]!;
        final mirrorResult = exifOrientationToRotation(mirrorOrientation);
        final nonMirrorResult = exifOrientationToRotation(nonMirrorOrientation);

        expect(
          mirrorResult,
          equals(nonMirrorResult),
          reason:
              'ミラー値 $mirrorOrientation (result=$mirrorResult) と '
              '非ミラー値 $nonMirrorOrientation (result=$nonMirrorResult) の回転角度が異なる',
        );
      },
    );
  });
}
