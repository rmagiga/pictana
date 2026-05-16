/// ズーム倍率計算の純粋関数。
///
/// Ctrl+マウスホイールズーム (Req 3) で使用する。
/// 倍率は常に [1.0, 5.0] の範囲にクランプされる。
library;

import 'dart:math';

/// ズームインの最大倍率
const double maxZoom = 5.0;

/// ズームアウトの最小倍率
const double minZoom = 1.0;

/// ズームイン時の倍率を計算する。
///
/// [currentScale] に 10% を加算し、最大 [maxZoom] にクランプする。
/// 計算式: min(currentScale * 1.1, 5.0)
double clampZoomIn(double currentScale) {
  return min(currentScale * 1.1, maxZoom);
}

/// ズームアウト時の倍率を計算する。
///
/// [currentScale] から 10% を減算し、最小 [minZoom] にクランプする。
/// 計算式: max(currentScale * 0.9, 1.0)
double clampZoomOut(double currentScale) {
  return max(currentScale * 0.9, minZoom);
}
