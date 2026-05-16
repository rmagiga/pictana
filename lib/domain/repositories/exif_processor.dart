/// ExifProcessor Interface
///
/// 責務:
/// - バイトデータから EXIF Orientation を解析
/// - 回転角度を返す
library;

/// EXIF 回転補正プロセッサ (Req 6)
abstract interface class ExifProcessor {
  /// バイトデータから EXIF Orientation を解析し回転角度を返す。
  ///
  /// 戻り値: 0, 90, 180, 270 のいずれか。
  /// EXIF なし/解析失敗時は 0 を返す。
  int extractRotation(List<int> bytes);
}
