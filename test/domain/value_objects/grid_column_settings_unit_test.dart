/// GridColumnSettings ユニットテスト
///
/// デフォルト値と基本的な動作を検証する。
///
/// **Validates: Requirements 8.1, 8.2**
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:optrig/domain/value_objects/grid_column_settings.dart';

void main() {
  group('GridColumnSettings - デフォルト値', () {
    test('デフォルトの minColumns は 3', () {
      const settings = GridColumnSettings();
      expect(settings.minColumns, equals(3));
    });

    test('デフォルトの maxColumns は 12', () {
      const settings = GridColumnSettings();
      expect(settings.maxColumns, equals(12));
    });
  });

  group('GridColumnSettings - カスタム値', () {
    test('minColumns を指定して生成できる', () {
      const settings = GridColumnSettings(minColumns: 5);
      expect(settings.minColumns, equals(5));
      expect(settings.maxColumns, equals(12));
    });

    test('maxColumns を指定して生成できる', () {
      const settings = GridColumnSettings(maxColumns: 8);
      expect(settings.minColumns, equals(3));
      expect(settings.maxColumns, equals(8));
    });

    test('min と max の両方を指定して生成できる', () {
      const settings = GridColumnSettings(minColumns: 4, maxColumns: 10);
      expect(settings.minColumns, equals(4));
      expect(settings.maxColumns, equals(10));
    });
  });

  group('GridColumnSettings - copyWith', () {
    test('copyWith で minColumns のみ変更できる', () {
      const original = GridColumnSettings(minColumns: 3, maxColumns: 12);
      final updated = original.copyWith(minColumns: 5);
      expect(updated.minColumns, equals(5));
      expect(updated.maxColumns, equals(12));
    });

    test('copyWith で maxColumns のみ変更できる', () {
      const original = GridColumnSettings(minColumns: 3, maxColumns: 12);
      final updated = original.copyWith(maxColumns: 8);
      expect(updated.minColumns, equals(3));
      expect(updated.maxColumns, equals(8));
    });
  });

  group('GridColumnSettings - equality', () {
    test('同じ値を持つインスタンスは等しい', () {
      const a = GridColumnSettings(minColumns: 4, maxColumns: 10);
      const b = GridColumnSettings(minColumns: 4, maxColumns: 10);
      expect(a, equals(b));
    });

    test('異なる値を持つインスタンスは等しくない', () {
      const a = GridColumnSettings(minColumns: 3, maxColumns: 12);
      const b = GridColumnSettings(minColumns: 4, maxColumns: 12);
      expect(a, isNot(equals(b)));
    });
  });
}
