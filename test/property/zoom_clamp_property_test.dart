/// ズーム倍率クランプ不変条件 プロパティベーステスト
///
/// glados を使用して、ズーム倍率計算の正当性プロパティを検証する。
/// 各プロパティテストは最低100回のイテレーションで実行される。
///
/// テスト対象:
/// - Property 2: ズーム倍率クランプ不変条件
///
/// **Validates: Requirements 3.1, 3.2, 3.3**
// Feature: image-viewer-enhancements, Property 2: ズーム倍率クランプ不変条件
@Tags(['property-test', 'image-viewer-enhancements'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, tearDown, test;
import 'package:pictana/domain/value_objects/zoom_calculation.dart';

void main() {
  // ===========================================================================
  // Property 2: ズーム倍率クランプ不変条件
  // ===========================================================================
  group('Feature: image-viewer-enhancements, Property 2: ズーム倍率クランプ不変条件', () {
    /// clampZoomIn の結果は常に [1.0, 5.0] の範囲内に収まる
    Glados(any.doubleInRange(1.0, 5.0)).test(
      'clampZoomIn の結果は常に [minZoom, maxZoom] の範囲内',
      (currentScale) {
        final result = clampZoomIn(currentScale);

        expect(result, greaterThanOrEqualTo(minZoom));
        expect(result, lessThanOrEqualTo(maxZoom));
      },
    );

    /// clampZoomOut の結果は常に [1.0, 5.0] の範囲内に収まる
    Glados(any.doubleInRange(1.0, 5.0)).test(
      'clampZoomOut の結果は常に [minZoom, maxZoom] の範囲内',
      (currentScale) {
        final result = clampZoomOut(currentScale);

        expect(result, greaterThanOrEqualTo(minZoom));
        expect(result, lessThanOrEqualTo(maxZoom));
      },
    );

    /// clampZoomIn の結果は currentScale 以上（拡大方向）
    Glados(any.doubleInRange(1.0, 5.0)).test(
      'clampZoomIn(currentScale) >= currentScale（拡大方向の単調性）',
      (currentScale) {
        final result = clampZoomIn(currentScale);

        expect(result, greaterThanOrEqualTo(currentScale));
      },
    );

    /// clampZoomOut の結果は currentScale 以下（縮小方向）
    Glados(any.doubleInRange(1.0, 5.0)).test(
      'clampZoomOut(currentScale) <= currentScale（縮小方向の単調性）',
      (currentScale) {
        final result = clampZoomOut(currentScale);

        expect(result, lessThanOrEqualTo(currentScale));
      },
    );
  });
}
