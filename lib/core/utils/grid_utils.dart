/// グリッドレイアウト計算ユーティリティ
///
/// 画面幅に応じたレスポンシブグリッド列数の計算を提供する。
/// 固定サイズカード（160dp）と間隔（8dp）に基づくレイアウト計算。
library;

import 'dart:math' as math;

/// 画面幅からグリッド列数を計算する（リデザイン版）
///
/// [screenWidth]: 画面幅（dp）
/// [minColumns]: 最小列数（設定値、デフォルト 3）
/// [maxColumns]: 最大列数（設定値、デフォルト 12）
///
/// 計算式: floor((screenWidth - 32) / 168)
/// - 32dp = 左右パディング合計 (16dp × 2)
/// - 168dp = カード幅(160dp) + 間隔(8dp)
/// - 結果を [minColumns, maxColumns] にクランプ
int calculateGridColumns(
  double screenWidth, {
  int minColumns = 3,
  int maxColumns = 12,
}) {
  final rawColumns = ((screenWidth - 32) / 168).floor();
  return rawColumns.clamp(minColumns, maxColumns);
}

/// グリッドの左右余白を計算する
///
/// 固定サイズカードを配置した後の残余スペースを均等分配する。
/// コンテンツ幅 = columns × 160 + (columns - 1) × 8 = columns × 168 - 8
/// 片側パディング = (screenWidth - コンテンツ幅) / 2
///
/// [screenWidth]: 画面幅（dp）
/// [columns]: 実際の列数
/// 戻り値: 片側のパディング量（dp）
double calculateGridHorizontalPadding(double screenWidth, int columns) {
  // コンテンツ幅: カード幅 × 列数 + 間隔 × (列数 - 1)
  final contentWidth = columns * 168.0 - 8.0;
  // 残余スペースを左右均等に分配
  final padding = (screenWidth - contentWidth) / 2.0;
  return math.max(0.0, padding);
}
