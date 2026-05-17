/// formatBytes ユニットテスト
///
/// 各単位の閾値境界と代表的な値の検証。
///
/// **Validates: Requirements 10.1**
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:pictana/core/utils/format_bytes.dart';

void main() {
  // ===========================================================================
  // B（バイト）単位のテスト
  // ===========================================================================
  group('formatBytes - B 単位', () {
    test('0 バイト → "0 B"', () {
      expect(formatBytes(0), equals('0 B'));
    });

    test('1 バイト → "1 B"', () {
      expect(formatBytes(1), equals('1 B'));
    });

    test('512 バイト → "512 B"', () {
      expect(formatBytes(512), equals('512 B'));
    });

    test('1023 バイト（KB 閾値直前）→ "1023 B"', () {
      expect(formatBytes(1023), equals('1023 B'));
    });
  });

  // ===========================================================================
  // KB 単位のテスト
  // ===========================================================================
  group('formatBytes - KB 単位', () {
    test('1024 バイト（ちょうど 1 KB）→ "1.0 KB"', () {
      expect(formatBytes(1024), equals('1.0 KB'));
    });

    test('1536 バイト（1.5 KB）→ "1.5 KB"', () {
      expect(formatBytes(1536), equals('1.5 KB'));
    });

    test('1048575 バイト（MB 閾値直前）→ KB 表示', () {
      // 1048575 / 1024 = 1023.999...
      expect(formatBytes(1048575), equals('1024.0 KB'));
    });
  });

  // ===========================================================================
  // MB 単位のテスト
  // ===========================================================================
  group('formatBytes - MB 単位', () {
    test('1048576 バイト（ちょうど 1 MB）→ "1.0 MB"', () {
      expect(formatBytes(1048576), equals('1.0 MB'));
    });

    test('500 * 1024 * 1024 バイト（500 MB）→ "500.0 MB"', () {
      expect(formatBytes(500 * 1024 * 1024), equals('500.0 MB'));
    });

    test('1073741823 バイト（GB 閾値直前）→ MB 表示', () {
      // 1073741823 / (1024*1024) = 1023.999...
      expect(formatBytes(1073741823), equals('1024.0 MB'));
    });
  });

  // ===========================================================================
  // GB 単位のテスト
  // ===========================================================================
  group('formatBytes - GB 単位', () {
    test('1073741824 バイト（ちょうど 1 GB）→ "1.00 GB"', () {
      expect(formatBytes(1073741824), equals('1.00 GB'));
    });

    test('2.5 GB → "2.50 GB"', () {
      final bytes = (2.5 * 1024 * 1024 * 1024).toInt();
      expect(formatBytes(bytes), equals('2.50 GB'));
    });

    test('10 GB → "10.00 GB"', () {
      expect(formatBytes(10 * 1024 * 1024 * 1024), equals('10.00 GB'));
    });
  });
}
