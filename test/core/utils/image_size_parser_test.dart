import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:pictana/core/utils/image_size_parser.dart';

void main() {
  group('ImageSizeParser', () {
    test('PNGの解像度を正しくパースできること', () async {
      final pngBytes = Uint8List.fromList([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG Signature
        0x00, 0x00, 0x00, 0x0D,                         // IHDR Length (13)
        0x49, 0x48, 0x44, 0x52,                         // "IHDR"
        0x00, 0x00, 0x03, 0x20,                         // Width: 800 (0x320)
        0x00, 0x00, 0x02, 0x58,                         // Height: 600 (0x258)
        0x08, 0x02, 0x00, 0x00, 0x00,                   // Bit depth, Color type, etc.
        0x00, 0x00, 0x00, 0x00                          // CRC
      ]);

      final size = await ImageSizeParser.parseBytes(pngBytes);
      expect(size, isNotNull);
      expect(size!.width, 800);
      expect(size.height, 600);
    });

    test('GIFの解像度を正しくパースできること', () async {
      final gifBytes = Uint8List.fromList([
        0x47, 0x49, 0x46, 0x38, 0x39, 0x61, // "GIF89a"
        0x20, 0x03,                         // Width: 800 (Little Endian: 0x0320)
        0x58, 0x02,                         // Height: 600 (Little Endian: 0x0258)
        0x00, 0x00, 0x00                    // Packed fields, etc.
      ]);

      final size = await ImageSizeParser.parseBytes(gifBytes);
      expect(size, isNotNull);
      expect(size!.width, 800);
      expect(size.height, 600);
    });

    test('WebP (Lossy / VP8) の解像度を正しくパースできること', () async {
      final webpBytes = Uint8List.fromList([
        0x52, 0x49, 0x46, 0x46, // "RIFF"
        0x00, 0x00, 0x00, 0x00, // Chunk Size
        0x57, 0x45, 0x42, 0x50, // "WEBP"
        0x56, 0x50, 0x38, 0x20, // "VP8 "
        0x00, 0x00, 0x00, 0x00, // VP8 Chunk Size
        0x00, 0x00, 0x00,       // Frame Header (3 bytes)
        0x9D, 0x01, 0x2A,       // Magic code
        0x20, 0x03,             // Width: 800 (LE: 0x0320)
        0x58, 0x02              // Height: 600 (LE: 0x0258)
      ]);

      final size = await ImageSizeParser.parseBytes(webpBytes);
      expect(size, isNotNull);
      expect(size!.width, 800);
      expect(size.height, 600);
    });

    test('WebP (Lossless / VP8L) の解像度を正しくパースできること', () async {
      // 幅 800 (799 = 0x31F)
      // 高さ 600 (599 = 0x257)
      // bits: (599 << 14) | 799 = (0x257 << 14) | 0x31F = 0x95C31F
      // LE bytes: 0x1F, 0xC3, 0x95, 0x00
      final webpBytes = Uint8List.fromList([
        0x52, 0x49, 0x46, 0x46, // "RIFF"
        0x00, 0x00, 0x00, 0x00, // Chunk Size
        0x57, 0x45, 0x42, 0x50, // "WEBP"
        0x56, 0x50, 0x38, 0x4C, // "VP8L"
        0x00, 0x00, 0x00, 0x00, // Chunk Size
        0x2F,                   // Signature
        0x1F, 0xC3, 0x95, 0x00  // width-1, height-1 bits (4 bytes)
      ]);

      final size = await ImageSizeParser.parseBytes(webpBytes);
      expect(size, isNotNull);
      expect(size!.width, 800);
      expect(size.height, 600);
    });

    test('WebP (Extended / VP8X) の解像度を正しくパースできること', () async {
      // 幅 800 - 1 = 799 = 0x1F, 0x03, 0x00
      // 高さ 600 - 1 = 599 = 0x57, 0x02, 0x00
      final webpBytes = Uint8List.fromList([
        0x52, 0x49, 0x46, 0x46, // "RIFF"
        0x00, 0x00, 0x00, 0x00, // Chunk Size
        0x57, 0x45, 0x42, 0x50, // "WEBP"
        0x56, 0x50, 0x38, 0x58, // "VP8X"
        0x0A, 0x00, 0x00, 0x00, // Chunk Size (10)
        0x00, 0x00, 0x00, 0x00, // Flags
        0x1F, 0x03, 0x00,       // Width-1 (24-bit LE: 799)
        0x57, 0x02, 0x00        // Height-1 (24-bit LE: 599)
      ]);

      final size = await ImageSizeParser.parseBytes(webpBytes);
      expect(size, isNotNull);
      expect(size!.width, 800);
      expect(size.height, 600);
    });

    test('JPEGの解像度を正しくパースできること', () async {
      final jpegBytes = Uint8List.fromList([
        0xFF, 0xD8,             // SOI
        0xFF, 0xE0,             // APP0
        0x00, 0x10,             // Length: 16
        0x4A, 0x46, 0x49, 0x46, 0x00, // "JFIF\0"
        0x01, 0x01, 0x01, 0x00, 0x60, 0x00, 0x60, 0x00, 0x00,
        0xFF, 0xC0,             // SOF0 (Start of Frame)
        0x00, 0x11,             // Segment Length (17)
        0x08,                   // Precision
        0x02, 0x58,             // Height: 600 (BE: 0x0258)
        0x03, 0x20,             // Width: 800 (BE: 0x0320)
        0x03,                   // Components
        0x01, 0x11, 0x00,
        0x02, 0x11, 0x01,
        0x03, 0x11, 0x01,
        0xFF, 0xDA              // SOS (Start of Scan) - ここで終了
      ]);

      final size = await ImageSizeParser.parseBytes(jpegBytes);
      expect(size, isNotNull);
      expect(size!.width, 800);
      expect(size.height, 600);
    });
  });
}
