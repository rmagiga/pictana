/// ImageEntry Entity (設計書 §9.1)
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import 'entry_id.dart';

part 'image_entry.freezed.dart';
part 'image_entry.g.dart';

/// 対応画像 MIME type
enum ImageMimeType {
  jpeg('image/jpeg'),
  png('image/png'),
  webp('image/webp'),
  gif('image/gif'),
  heic('image/heic'),
  heif('image/heif'),
  avif('image/avif'),
  unknown('application/octet-stream');

  const ImageMimeType(this.value);
  final String value;

  static ImageMimeType fromExtension(String ext) => switch (ext.toLowerCase()) {
        'jpg' || 'jpeg' => ImageMimeType.jpeg,
        'png' => ImageMimeType.png,
        'webp' => ImageMimeType.webp,
        'gif' => ImageMimeType.gif,
        'heic' => ImageMimeType.heic,
        'heif' => ImageMimeType.heif,
        'avif' => ImageMimeType.avif,
        _ => ImageMimeType.unknown,
      };

  bool get isGif => this == ImageMimeType.gif;
  bool get isAnimatable => isGif;
}

/// 画像エントリ Entity
@freezed
abstract class ImageEntry with _$ImageEntry {
  const ImageEntry._();

  const factory ImageEntry({
    /// プラットフォーム固有識別子
    required EntryId id,

    /// ファイル名（拡張子あり）
    required String name,

    /// 拡張子（小文字、ドットなし）
    required String extension,

    /// 画像幅 (px)。未取得時は null。
    int? width,

    /// 画像高さ (px)。未取得時は null。
    int? height,

    /// ファイルサイズ (bytes)
    required int size,

    /// ファイル作成日時
    DateTime? createdAt,

    /// ファイル更新日時
    required DateTime modifiedAt,

    /// アクセス用 URI 文字列
    required String uri,

    /// MIME type
    required ImageMimeType mimeType,

    /// EXIF 回転角度 (0, 90, 180, 270)
    @Default(0) int exifRotation,
  }) = _ImageEntry;

  factory ImageEntry.fromJson(Map<String, dynamic> json) =>
      _$ImageEntryFromJson(json);
}

extension ImageEntryX on ImageEntry {
  /// GIF かどうか
  bool get isGif => mimeType.isGif;

  /// アスペクト比（width/height）。不明時は 1.0。
  double get aspectRatio {
    if (width == null || height == null || height == 0) return 1.0;
    return width! / height!;
  }

  /// 解像度文字列（例: "4032 × 3024"）
  String get resolutionString {
    if (width == null || height == null) return '不明';
    return '$width × $height';
  }
}
