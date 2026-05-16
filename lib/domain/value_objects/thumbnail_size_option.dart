/// サムネイルサイズ設定 Value Object (Req 8)
library;

/// サムネイルサイズの選択肢
enum ThumbnailSizeOption {
  /// 小 (128px)
  small(128, '小'),

  /// 中 (256px) - デフォルト
  medium(256, '中'),

  /// 大 (512px)
  large(512, '大');

  const ThumbnailSizeOption(this.px, this.displayName);

  /// ピクセルサイズ
  final int px;

  /// 表示名
  final String displayName;
}
