/// ExifProcessorImpl
///
/// バイトデータから EXIF Orientation タグを解析し、
/// 回転角度を返す実装クラス。
library;

import 'package:pictana/domain/repositories/exif_processor.dart';
import 'package:pictana/domain/value_objects/exif_rotation.dart';

/// EXIF Orientation タグの解析と回転角度変換を行う実装。
///
/// JPEG (APP1 マーカー) および TIFF ヘッダーから Orientation タグ (0x0112) を
/// 読み取り、[exifOrientationToRotation] で回転角度に変換する。
/// 解析失敗時は 0 を返す。
class ExifProcessorImpl implements ExifProcessor {
  @override
  int extractRotation(List<int> bytes) {
    try {
      final orientation = _extractOrientation(bytes);
      return exifOrientationToRotation(orientation);
    } catch (_) {
      return 0;
    }
  }

  /// バイトデータから EXIF Orientation 値を抽出する。
  ///
  /// JPEG の場合: SOI (0xFFD8) → APP1 マーカー (0xFFE1) → "Exif\0\0" → TIFF ヘッダー
  /// TIFF の場合: 先頭が "II" または "MM" で始まる TIFF ヘッダー
  ///
  /// 見つからない場合は 1 (回転なし) を返す。
  int _extractOrientation(List<int> bytes) {
    if (bytes.length < 12) return 1;

    // JPEG 判定: SOI マーカー (0xFF 0xD8)
    if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
      return _parseJpegExif(bytes);
    }

    // TIFF 判定: "II" (リトルエンディアン) または "MM" (ビッグエンディアン)
    if ((bytes[0] == 0x49 && bytes[1] == 0x49) ||
        (bytes[0] == 0x4D && bytes[1] == 0x4D)) {
      return _parseTiffOrientation(bytes, 0);
    }

    return 1;
  }

  /// JPEG バイトデータから EXIF Orientation を解析する。
  ///
  /// APP1 マーカー (0xFFE1) を探し、"Exif\0\0" ヘッダーを確認後、
  /// TIFF ヘッダーとして解析する。
  int _parseJpegExif(List<int> bytes) {
    var offset = 2; // SOI の次から開始

    while (offset + 4 <= bytes.length) {
      // マーカー検出: 0xFF で始まる
      if (bytes[offset] != 0xFF) return 1;

      final marker = bytes[offset + 1];

      // SOS (0xDA) に到達したら EXIF は見つからなかった
      if (marker == 0xDA) return 1;

      // マーカーセグメントの長さを取得
      if (offset + 4 > bytes.length) return 1;
      final segmentLength = (bytes[offset + 2] << 8) | bytes[offset + 3];

      // APP1 マーカー (0xE1) を検出
      if (marker == 0xE1) {
        final exifStart = offset + 4; // セグメント長の後

        // "Exif\0\0" ヘッダーを確認 (6 バイト)
        if (exifStart + 6 > bytes.length) return 1;
        if (bytes[exifStart] != 0x45 || // 'E'
            bytes[exifStart + 1] != 0x78 || // 'x'
            bytes[exifStart + 2] != 0x69 || // 'i'
            bytes[exifStart + 3] != 0x66 || // 'f'
            bytes[exifStart + 4] != 0x00 ||
            bytes[exifStart + 5] != 0x00) {
          // APP1 だが EXIF ではない（XMP 等）→ 次のマーカーへ
          offset += 2 + segmentLength;
          continue;
        }

        // TIFF ヘッダーの開始位置
        final tiffStart = exifStart + 6;
        return _parseTiffOrientation(bytes, tiffStart);
      }

      // 次のマーカーへ移動
      offset += 2 + segmentLength;
    }

    return 1;
  }

  /// TIFF ヘッダーから Orientation タグ (0x0112) を解析する。
  ///
  /// [tiffOffset] は TIFF ヘッダーの開始位置（バイト順マーカーの位置）。
  int _parseTiffOrientation(List<int> bytes, int tiffOffset) {
    if (tiffOffset + 8 > bytes.length) return 1;

    // バイト順の判定
    final bool isLittleEndian;
    if (bytes[tiffOffset] == 0x49 && bytes[tiffOffset + 1] == 0x49) {
      isLittleEndian = true; // "II" = Intel = リトルエンディアン
    } else if (bytes[tiffOffset] == 0x4D && bytes[tiffOffset + 1] == 0x4D) {
      isLittleEndian = false; // "MM" = Motorola = ビッグエンディアン
    } else {
      return 1;
    }

    // マジックナンバー 42 (0x002A) を確認
    final magic = _readUint16(bytes, tiffOffset + 2, isLittleEndian);
    if (magic != 0x002A) return 1;

    // IFD0 へのオフセットを取得
    final ifdOffset = _readUint32(bytes, tiffOffset + 4, isLittleEndian);
    final ifdAbsolute = tiffOffset + ifdOffset;

    return _findOrientationInIfd(
      bytes,
      ifdAbsolute,
      tiffOffset,
      isLittleEndian,
    );
  }

  /// IFD (Image File Directory) 内から Orientation タグを検索する。
  int _findOrientationInIfd(
    List<int> bytes,
    int ifdOffset,
    int tiffOffset,
    bool isLittleEndian,
  ) {
    if (ifdOffset + 2 > bytes.length) return 1;

    final entryCount = _readUint16(bytes, ifdOffset, isLittleEndian);
    var entryOffset = ifdOffset + 2;

    for (var i = 0; i < entryCount; i++) {
      if (entryOffset + 12 > bytes.length) return 1;

      final tag = _readUint16(bytes, entryOffset, isLittleEndian);

      // Orientation タグ (0x0112) を発見
      if (tag == 0x0112) {
        // タグの値を取得（SHORT 型、2 バイト）
        // IFD エントリ構造: tag(2) + type(2) + count(4) + value/offset(4)
        final value = _readUint16(bytes, entryOffset + 8, isLittleEndian);
        return value;
      }

      entryOffset += 12; // 次のエントリへ（各エントリは 12 バイト）
    }

    return 1; // Orientation タグが見つからない → 回転なし
  }

  /// 指定位置から 16 ビット符号なし整数を読み取る。
  int _readUint16(List<int> bytes, int offset, bool isLittleEndian) {
    if (offset + 2 > bytes.length) return 0;
    if (isLittleEndian) {
      return bytes[offset] | (bytes[offset + 1] << 8);
    } else {
      return (bytes[offset] << 8) | bytes[offset + 1];
    }
  }

  /// 指定位置から 32 ビット符号なし整数を読み取る。
  int _readUint32(List<int> bytes, int offset, bool isLittleEndian) {
    if (offset + 4 > bytes.length) return 0;
    if (isLittleEndian) {
      return bytes[offset] |
          (bytes[offset + 1] << 8) |
          (bytes[offset + 2] << 16) |
          (bytes[offset + 3] << 24);
    } else {
      return (bytes[offset] << 24) |
          (bytes[offset + 1] << 16) |
          (bytes[offset + 2] << 8) |
          bytes[offset + 3];
    }
  }

  @override
  List<int>? extractThumbnail(List<int> bytes) {
    try {
      if (bytes.length < 12) return null;

      // JPEG 判定: SOI マーカー (0xFF 0xD8)
      if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
        return _parseJpegThumbnail(bytes);
      }

      // TIFF 判定: "II" または "MM"
      if ((bytes[0] == 0x49 && bytes[1] == 0x49) ||
          (bytes[0] == 0x4D && bytes[1] == 0x4D)) {
        return _parseTiffThumbnail(bytes, 0);
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  /// JPEG バイトデータから埋め込みサムネイルを探す。
  List<int>? _parseJpegThumbnail(List<int> bytes) {
    var offset = 2; // SOI の次から開始

    while (offset + 4 <= bytes.length) {
      if (bytes[offset] != 0xFF) return null;

      final marker = bytes[offset + 1];
      if (marker == 0xDA) return null; // SOS到達

      final segmentLength = (bytes[offset + 2] << 8) | bytes[offset + 3];

      if (marker == 0xE1) {
        final exifStart = offset + 4;
        if (exifStart + 6 > bytes.length) return null;
        if (bytes[exifStart] != 0x45 || // 'E'
            bytes[exifStart + 1] != 0x78 || // 'x'
            bytes[exifStart + 2] != 0x69 || // 'i'
            bytes[exifStart + 3] != 0x66 || // 'f'
            bytes[exifStart + 4] != 0x00 ||
            bytes[exifStart + 5] != 0x00) {
          offset += 2 + segmentLength;
          continue;
        }

        final tiffStart = exifStart + 6;
        return _parseTiffThumbnail(bytes, tiffStart);
      }

      offset += 2 + segmentLength;
    }

    return null;
  }

  /// TIFF ヘッダーから埋め込みサムネイル情報を取得する。
  List<int>? _parseTiffThumbnail(List<int> bytes, int tiffOffset) {
    if (tiffOffset + 8 > bytes.length) return null;

    final bool isLittleEndian;
    if (bytes[tiffOffset] == 0x49 && bytes[tiffOffset + 1] == 0x49) {
      isLittleEndian = true;
    } else if (bytes[tiffOffset] == 0x4D && bytes[tiffOffset + 1] == 0x4D) {
      isLittleEndian = false;
    } else {
      return null;
    }

    final magic = _readUint16(bytes, tiffOffset + 2, isLittleEndian);
    if (magic != 0x002A) return null;

    final ifdOffset = _readUint32(bytes, tiffOffset + 4, isLittleEndian);
    final ifdAbsolute = tiffOffset + ifdOffset;
    if (ifdAbsolute + 2 > bytes.length) return null;

    final entryCount = _readUint16(bytes, ifdAbsolute, isLittleEndian);
    final nextIfdOffsetLocation = ifdAbsolute + 2 + (entryCount * 12);
    if (nextIfdOffsetLocation + 4 > bytes.length) return null;

    final ifd1Offset = _readUint32(bytes, nextIfdOffsetLocation, isLittleEndian);
    if (ifd1Offset == 0) return null; // IFD1 なし

    final ifd1Absolute = tiffOffset + ifd1Offset;
    if (ifd1Absolute + 2 > bytes.length) return null;

    final ifd1EntryCount = _readUint16(bytes, ifd1Absolute, isLittleEndian);
    var entryOffset = ifd1Absolute + 2;

    int? thumbnailOffset;
    int? thumbnailLength;

    for (var i = 0; i < ifd1EntryCount; i++) {
      if (entryOffset + 12 > bytes.length) break;

      final tag = _readUint16(bytes, entryOffset, isLittleEndian);

      if (tag == 0x0201) {
        thumbnailOffset = _readUint32(bytes, entryOffset + 8, isLittleEndian);
      } else if (tag == 0x0202) {
        thumbnailLength = _readUint32(bytes, entryOffset + 8, isLittleEndian);
      }

      entryOffset += 12;
    }

    if (thumbnailOffset != null && thumbnailLength != null) {
      final start = tiffOffset + thumbnailOffset;
      final end = start + thumbnailLength;
      if (start >= 0 && end <= bytes.length && start < end) {
        return bytes.sublist(start, end);
      }
    }

    return null;
  }
}
