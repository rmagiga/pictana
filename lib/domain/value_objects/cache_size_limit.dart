/// キャッシュサイズ上限 Value Object (Req 9)
library;

/// キャッシュサイズ上限の選択肢
enum CacheSizeLimit {
  /// 100MB
  mb100(100 * 1024 * 1024, '100MB'),

  /// 250MB
  mb250(250 * 1024 * 1024, '250MB'),

  /// 500MB - デフォルト
  mb500(500 * 1024 * 1024, '500MB'),

  /// 1GB
  gb1(1024 * 1024 * 1024, '1GB');

  const CacheSizeLimit(this.bytes, this.displayName);

  /// バイト数
  final int bytes;

  /// 表示名
  final String displayName;
}
