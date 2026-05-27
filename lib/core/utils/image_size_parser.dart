import 'dart:io';
import 'dart:typed_data';

/// 画像の解像度情報
class ImageSize {
  const ImageSize(this.width, this.height);
  final int width;
  final int height;

  @override
  String toString() => '${width}x$height';
}

/// 画像ファイルからヘッダー情報のみを高速に読み込み、解像度（幅・高さ）を抽出するユーティリティクラス
class ImageSizeParser {
  /// ファイルパスから画像サイズを高速に解析する
  static Future<ImageSize?> parseFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return null;

    RandomAccessFile? raf;
    try {
      raf = await file.open(mode: FileMode.read);
      
      // 最初は4KB読み込む。JPEGのSOFマーカーがこれより後ろにある場合は、必要に応じて追加で読み込む。
      final length = await raf.length();
      final initialReadSize = length < 4096 ? length : 4096;
      final bytes = await raf.read(initialReadSize);

      return parseBytes(bytes, raf: raf);
    } catch (_) {
      return null;
    } finally {
      await raf?.close();
    }
  }

  /// バイト配列から画像サイズを解析する
  static ImageSize? parseBytes(Uint8List bytes, {RandomAccessFile? raf}) {
    if (bytes.length < 8) return null;

    // 1. PNG 判定
    if (bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A) {
      return _parsePng(bytes);
    }

    // 2. GIF 判定
    if (bytes.length >= 10 &&
        bytes[0] == 0x47 && // G
        bytes[1] == 0x49 && // I
        bytes[2] == 0x46 && // F
        bytes[3] == 0x38 && // 8
        (bytes[4] == 0x37 || bytes[4] == 0x39) && // 7 or 9
        bytes[5] == 0x61) { // a
      return _parseGif(bytes);
    }

    // 3. WebP 判定 (RIFF .... WEBP)
    if (bytes.length >= 16 &&
        bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46 && // RIFF
        bytes[8] == 0x57 && bytes[9] == 0x45 && bytes[10] == 0x42 && bytes[11] == 0x50) { // WEBP
      return _parseWebp(bytes);
    }

    // 4. JPEG 判定
    if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
      return _parseJpeg(bytes, raf: raf);
    }

    return null;
  }

  static ImageSize? _parsePng(Uint8List bytes) {
    if (bytes.length < 24) return null;
    // PNGのIHDRチャンクは12〜15バイト目が "IHDR"、16〜19バイト目が幅、20〜23バイト目が高さ
    if (bytes[12] == 0x49 && bytes[13] == 0x48 && bytes[14] == 0x44 && bytes[15] == 0x52) {
      final width = _readUint32BE(bytes, 16);
      final height = _readUint32BE(bytes, 20);
      return ImageSize(width, height);
    }
    return null;
  }

  static ImageSize? _parseGif(Uint8List bytes) {
    // 6-7バイト目が幅、8-9バイト目が高さ (Little Endian)
    final width = _readUint16LE(bytes, 6);
    final height = _readUint16LE(bytes, 8);
    return ImageSize(width, height);
  }

  static ImageSize? _parseWebp(Uint8List bytes) {
    final format = String.fromCharCodes(bytes.sublist(12, 16));
    if (format == 'VP8 ') {
      // Lossy WebP: 先頭から23-25バイト目が 0x9d, 0x01, 0x2a (マジックコード)
      if (bytes.length < 30) return null;
      if (bytes[23] == 0x9D && bytes[24] == 0x01 && bytes[25] == 0x2A) {
        // 26-27バイト目が幅、28-29バイト目が高さ（下位14ビット）
        final width = _readUint16LE(bytes, 26) & 0x3FFF;
        final height = _readUint16LE(bytes, 28) & 0x3FFF;
        return ImageSize(width, height);
      }
    } else if (format == 'VP8L') {
      // Lossless WebP
      if (bytes.length < 25) return null;
      if (bytes[20] == 0x2F) { // VP8L シグネチャ
        // 21-24バイト目の32ビットデータから14ビットずつ幅・高さを抽出
        final data = _readUint32LE(bytes, 21);
        final width = (data & 0x3FFF) + 1;
        final height = ((data >> 14) & 0x3FFF) + 1;
        return ImageSize(width, height);
      }
    } else if (format == 'VP8X') {
      // Extended WebP
      if (bytes.length < 26) return null;
      // 20-22バイト目（24ビット）が幅 - 1、23-25バイト目（24ビット）が高さ - 1 (Little Endian)
      final width = _readUint24LE(bytes, 20) + 1;
      final height = _readUint24LE(bytes, 23) + 1;
      return ImageSize(width, height);
    }
    return null;
  }

  static ImageSize? _parseJpeg(Uint8List initialBytes, {RandomAccessFile? raf}) {
    var bytes = initialBytes;
    var offset = 2; // SOI (0xFFD8) の後から開始

    // マーカーセグメントの解析ループ
    while (true) {
      // 解析対象バッファが足りなくなった場合、ファイルから追加読み込みする
      if (offset + 4 > bytes.length) {
        if (raf == null) return null;
        try {
          // 現在の読み込み済みサイズからさらに追加で4KB読み込む
          final currentPos = bytes.length;
          final fileLen = raf.lengthSync();
          if (currentPos >= fileLen) return null;

          final additionalSize = fileLen - currentPos < 4096 ? fileLen - currentPos : 4096;
          raf.setPositionSync(currentPos);
          final newBytes = raf.readSync(additionalSize);
          if (newBytes.isEmpty) return null;

          final builder = BytesBuilder()
            ..add(bytes)
            ..add(newBytes);
          bytes = builder.takeBytes();
        } catch (_) {
          return null;
        }
      }

      // JPEGマーカーは必ず 0xFF で始まる
      if (bytes[offset] != 0xFF) {
        // 不正なデータのスキップ処理
        offset++;
        continue;
      }

      final marker = bytes[offset + 1];
      if (marker == 0xFF) {
        // パディングの 0xFF をスキップ
        offset++;
        continue;
      }

      // SOS (Start of Scan) または EOI (End of Image) に到達したら解析終了
      if (marker == 0xDA || marker == 0xD9) {
        return null;
      }

      // セグメント長（2バイト）を取得
      final segmentLength = _readUint16BE(bytes, offset + 2);

      // SOF (Start of Frame) マーカーを検出
      // SOF0 (0xC0), SOF1 (0xC1), SOF2 (0xC2), SOF3 (0xC3), SOF5 (0xC5), SOF6 (0xC6), SOF7 (0xC7),
      // SOF9 (0xC9), SOF10 (0xCA), SOF11 (0xCB), SOF13 (0xCD), SOF14 (0xCE), SOF15 (0xCF)
      if ((marker >= 0xC0 && marker <= 0xC3) ||
          (marker >= 0xC5 && marker <= 0xC7) ||
          (marker >= 0xC9 && marker <= 0xCB) ||
          (marker >= 0xCD && marker <= 0xCF)) {
        if (offset + 9 > bytes.length) return null;
        // SOF内: 4バイト目が高さ、6バイト目が幅 (Big Endian)
        final height = _readUint16BE(bytes, offset + 5);
        final width = _readUint16BE(bytes, offset + 7);
        return ImageSize(width, height);
      }

      // 次のセグメントへ進む
      offset += 2 + segmentLength;
    }
  }

  // --- ヘルパーメソッド群 ---

  static int _readUint16BE(Uint8List bytes, int offset) {
    return (bytes[offset] << 8) | bytes[offset + 1];
  }

  static int _readUint16LE(Uint8List bytes, int offset) {
    return bytes[offset] | (bytes[offset + 1] << 8);
  }

  static int _readUint24LE(Uint8List bytes, int offset) {
    return bytes[offset] | (bytes[offset + 1] << 8) | (bytes[offset + 2] << 16);
  }

  static int _readUint32BE(Uint8List bytes, int offset) {
    return (bytes[offset] << 24) |
        (bytes[offset + 1] << 16) |
        (bytes[offset + 2] << 8) |
        bytes[offset + 3];
  }

  static int _readUint32LE(Uint8List bytes, int offset) {
    return bytes[offset] |
        (bytes[offset + 1] << 8) |
        (bytes[offset + 2] << 16) |
        (bytes[offset + 3] << 24);
  }
}
