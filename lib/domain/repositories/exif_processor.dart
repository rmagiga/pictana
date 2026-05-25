/// ExifProcessor Interface
///
/// 責務:
/// - バイトデータから EXIF Orientation を解析
/// - 回転角度を返す
library;

/// EXIF 詳細メタデータモデル
class ExifMetadata {
  const ExifMetadata({
    this.dateTime,
    this.camera,
    this.latitude,
    this.longitude,
  });

  /// 撮影日時
  final DateTime? dateTime;

  /// カメラ機種名 (Make + Model 等)
  final String? camera;

  /// GPS 緯度
  final double? latitude;

  /// GPS 経度
  final double? longitude;

  /// 空のメタデータ
  static const empty = ExifMetadata();
}

/// EXIF 回転補正プロセッサ (Req 6)
abstract interface class ExifProcessor {
  /// バイトデータから EXIF Orientation を解析し回転角度を返す。
  ///
  /// 戻り値: 0, 90, 180, 270 のいずれか。
  /// EXIF なし/解析失敗時は 0 を返す。
  int extractRotation(List<int> bytes);

  /// 画像データの EXIF 領域から埋め込みサムネイルを抽出して返す。
  /// サムネイルが存在しない、または解析失敗時は null を返す。
  List<int>? extractThumbnail(List<int> bytes);

  /// 画像データの EXIF 領域から詳細メタデータを抽出して返す。
  Future<ExifMetadata> extractMetadata(List<int> bytes);
}
