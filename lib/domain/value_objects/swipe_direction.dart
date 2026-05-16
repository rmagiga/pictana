/// スワイプ方向 Value Object (Req 4, 7)
library;

/// Android でのスワイプ方向設定値
enum SwipeDirection {
  /// 左右スワイプ（デフォルト）
  horizontal,

  /// 上下スワイプ
  vertical,

  /// 両方
  both;

  /// 表示名
  String get displayName => switch (this) {
    SwipeDirection.horizontal => '左右',
    SwipeDirection.vertical => '上下',
    SwipeDirection.both => '両方',
  };
}
