import 'package:optrig/infrastructure/storage/common/exif_processor_impl.dart';
import 'package:test/test.dart';

void main() {
  late ExifProcessorImpl processor;

  setUp(() {
    processor = ExifProcessorImpl();
  });

  group('ExifProcessorImpl', () {
    group('空・短いデータ', () {
      test('空のバイトリストは 0 を返す', () {
        expect(processor.extractRotation([]), equals(0));
      });

      test('短すぎるデータは 0 を返す', () {
        expect(processor.extractRotation([0xFF, 0xD8]), equals(0));
      });

      test('無関係なデータは 0 を返す', () {
        expect(processor.extractRotation(List.filled(100, 0x00)), equals(0));
      });
    });

    group('JPEG EXIF 解析', () {
      test('Orientation=1 (正常) → 0度', () {
        final bytes = _buildJpegWithOrientation(1, bigEndian: true);
        expect(processor.extractRotation(bytes), equals(0));
      });

      test('Orientation=3 → 180度', () {
        final bytes = _buildJpegWithOrientation(3, bigEndian: true);
        expect(processor.extractRotation(bytes), equals(180));
      });

      test('Orientation=6 → 90度', () {
        final bytes = _buildJpegWithOrientation(6, bigEndian: true);
        expect(processor.extractRotation(bytes), equals(90));
      });

      test('Orientation=8 → 270度', () {
        final bytes = _buildJpegWithOrientation(8, bigEndian: true);
        expect(processor.extractRotation(bytes), equals(270));
      });

      test('リトルエンディアン Orientation=6 → 90度', () {
        final bytes = _buildJpegWithOrientation(6, bigEndian: false);
        expect(processor.extractRotation(bytes), equals(90));
      });

      test('ミラーリング成分 Orientation=2 → 0度 (ミラー無視)', () {
        final bytes = _buildJpegWithOrientation(2, bigEndian: true);
        expect(processor.extractRotation(bytes), equals(0));
      });

      test('ミラーリング成分 Orientation=5 → 270度 (ミラー無視)', () {
        final bytes = _buildJpegWithOrientation(5, bigEndian: true);
        expect(processor.extractRotation(bytes), equals(270));
      });

      test('ミラーリング成分 Orientation=7 → 90度 (ミラー無視)', () {
        final bytes = _buildJpegWithOrientation(7, bigEndian: true);
        expect(processor.extractRotation(bytes), equals(90));
      });
    });

    group('TIFF 解析', () {
      test('ビッグエンディアン TIFF Orientation=6 → 90度', () {
        final bytes = _buildTiffWithOrientation(6, bigEndian: true);
        expect(processor.extractRotation(bytes), equals(90));
      });

      test('リトルエンディアン TIFF Orientation=8 → 270度', () {
        final bytes = _buildTiffWithOrientation(8, bigEndian: false);
        expect(processor.extractRotation(bytes), equals(270));
      });
    });

    group('エラーケース', () {
      test('JPEG SOI のみ（APP1 なし）→ 0度', () {
        // SOI + SOS マーカー（EXIF なし）
        final bytes = [
          0xFF, 0xD8, // SOI
          0xFF, 0xDA, // SOS (画像データ開始)
          0x00, 0x02, // セグメント長
          ...List.filled(20, 0x00),
        ];
        expect(processor.extractRotation(bytes), equals(0));
      });

      test('不正な TIFF マジックナンバー → 0度', () {
        final bytes = [
          0x49, 0x49, // "II" (リトルエンディアン)
          0x00, 0x00, // 不正なマジックナンバー（42 ではない）
          0x08, 0x00, 0x00, 0x00, // IFD オフセット
          ...List.filled(20, 0x00),
        ];
        expect(processor.extractRotation(bytes), equals(0));
      });
    });
  });
}

/// テスト用: 指定 Orientation 値を持つ JPEG バイトデータを構築する。
List<int> _buildJpegWithOrientation(
  int orientation, {
  required bool bigEndian,
}) {
  final tiffHeader = _buildTiffBytes(orientation, bigEndian: bigEndian);

  // "Exif\0\0" ヘッダー
  final exifHeader = [0x45, 0x78, 0x69, 0x66, 0x00, 0x00];

  // APP1 セグメント長 = exifHeader + tiffHeader + 2 (長さフィールド自身を含む)
  final segmentLength = exifHeader.length + tiffHeader.length + 2;

  return [
    0xFF, 0xD8, // SOI
    0xFF, 0xE1, // APP1 マーカー
    (segmentLength >> 8) & 0xFF, segmentLength & 0xFF, // セグメント長
    ...exifHeader,
    ...tiffHeader,
  ];
}

/// テスト用: 指定 Orientation 値を持つ TIFF バイトデータを構築する。
List<int> _buildTiffWithOrientation(
  int orientation, {
  required bool bigEndian,
}) {
  return _buildTiffBytes(orientation, bigEndian: bigEndian);
}

/// TIFF ヘッダー + IFD (Orientation タグ 1 エントリ) を構築する。
List<int> _buildTiffBytes(int orientation, {required bool bigEndian}) {
  final bytes = <int>[];

  // バイト順マーカー
  if (bigEndian) {
    bytes.addAll([0x4D, 0x4D]); // "MM"
  } else {
    bytes.addAll([0x49, 0x49]); // "II"
  }

  // マジックナンバー 42
  _addUint16(bytes, 0x002A, bigEndian: bigEndian);

  // IFD0 オフセット（TIFF ヘッダーの先頭から 8 バイト目）
  _addUint32(bytes, 8, bigEndian: bigEndian);

  // IFD0: エントリ数 = 1
  _addUint16(bytes, 1, bigEndian: bigEndian);

  // IFD エントリ: Orientation タグ
  _addUint16(bytes, 0x0112, bigEndian: bigEndian); // タグ ID
  _addUint16(bytes, 3, bigEndian: bigEndian); // タイプ: SHORT
  _addUint32(bytes, 1, bigEndian: bigEndian); // カウント: 1
  // 値（4 バイトに収まるので直接格納）
  _addUint16(bytes, orientation, bigEndian: bigEndian);
  _addUint16(bytes, 0, bigEndian: bigEndian); // パディング

  return bytes;
}

void _addUint16(List<int> bytes, int value, {required bool bigEndian}) {
  if (bigEndian) {
    bytes.add((value >> 8) & 0xFF);
    bytes.add(value & 0xFF);
  } else {
    bytes.add(value & 0xFF);
    bytes.add((value >> 8) & 0xFF);
  }
}

void _addUint32(List<int> bytes, int value, {required bool bigEndian}) {
  if (bigEndian) {
    bytes.add((value >> 24) & 0xFF);
    bytes.add((value >> 16) & 0xFF);
    bytes.add((value >> 8) & 0xFF);
    bytes.add(value & 0xFF);
  } else {
    bytes.add(value & 0xFF);
    bytes.add((value >> 8) & 0xFF);
    bytes.add((value >> 16) & 0xFF);
    bytes.add((value >> 24) & 0xFF);
  }
}
