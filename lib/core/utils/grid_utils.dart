/// グリッドレイアウト計算ユーティリティ
///
/// 画面幅に応じたレスポンシブグリッド列数の計算を提供する。
library;

/// 画面幅からグリッド列数を計算する
///
/// レスポンシブブレークポイントに基づき列数を返す:
/// - 600dp 未満: 2列
/// - 600dp 以上 900dp 未満: 3列
/// - 900dp 以上: 4列
int calculateGridColumns(double screenWidth) {
  if (screenWidth < 600) return 2;
  if (screenWidth < 900) return 3;
  return 4;
}
