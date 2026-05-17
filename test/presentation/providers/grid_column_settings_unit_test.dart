/// GridColumnSettingsNotifier ユニットテスト
///
/// DB 読み書き、デフォルトフォールバック、min/max 自動調整の具体的なケースを検証する。
///
/// **Validates: Requirements 8.3, 8.4, 8.5**
library;

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pictana/application/providers/repository_providers.dart';
import 'package:pictana/infrastructure/database/app_database.dart';
import 'package:pictana/presentation/providers/grid_column_settings_provider.dart';

void main() {
  // drift の複数インスタンス警告を抑制
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('GridColumnSettingsNotifier - 初期状態', () {
    test('初期状態はデフォルト値 (min=3, max=12)', () {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );

      final state = container.read(gridColumnSettingsProvider);

      expect(state.minColumns, equals(3));
      expect(state.maxColumns, equals(12));

      container.dispose();
      db.close();
    });
  });

  group('GridColumnSettingsNotifier - setMinColumns', () {
    test('min=4 を設定すると state が更新される', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );

      final notifier = container.read(
        gridColumnSettingsProvider.notifier,
      );
      await notifier.setMinColumns(4);

      final state = container.read(gridColumnSettingsProvider);
      expect(state.minColumns, equals(4));
      expect(state.maxColumns, equals(12)); // max は変わらない

      container.dispose();
      await db.close();
    });

    test('min=10 を設定すると max が min+2=12 に自動調整される', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );

      // _loadInitial の非同期処理が完了するのを待つ
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final notifier = container.read(
        gridColumnSettingsProvider.notifier,
      );
      await notifier.setMinColumns(10);

      final state = container.read(gridColumnSettingsProvider);
      expect(state.minColumns, equals(10));
      expect(state.maxColumns, equals(12)); // max >= min + 2 = 12

      container.dispose();
      await db.close();
    });

    test('min=11 を設定すると max が min+2=13 に自動調整される', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );

      // Provider を初期化して _loadInitial の非同期処理が完了するのを待つ
      container.read(gridColumnSettingsProvider);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final notifier = container.read(
        gridColumnSettingsProvider.notifier,
      );
      await notifier.setMinColumns(11);

      // setMinColumns 後に _loadInitial が再度走らないことを確認するため少し待つ
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final state = container.read(gridColumnSettingsProvider);
      expect(state.minColumns, equals(11));
      expect(state.maxColumns, equals(13)); // max >= min + 2

      container.dispose();
      await db.close();
    });
  });

  group('GridColumnSettingsNotifier - setMaxColumns', () {
    test('max=8 を設定すると state が更新される', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );

      final notifier = container.read(
        gridColumnSettingsProvider.notifier,
      );
      await notifier.setMaxColumns(8);

      final state = container.read(gridColumnSettingsProvider);
      expect(state.minColumns, equals(3)); // min は変わらない
      expect(state.maxColumns, equals(8));

      container.dispose();
      await db.close();
    });

    test('max=4 を設定すると min+2=5 に自動調整される', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );

      final notifier = container.read(
        gridColumnSettingsProvider.notifier,
      );
      await notifier.setMaxColumns(4);

      final state = container.read(gridColumnSettingsProvider);
      expect(state.minColumns, equals(3));
      expect(state.maxColumns, equals(5)); // max >= min + 2 = 5

      container.dispose();
      await db.close();
    });

    test('max=1 を設定すると min+2=5 に自動調整される', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );

      final notifier = container.read(
        gridColumnSettingsProvider.notifier,
      );
      await notifier.setMaxColumns(1);

      final state = container.read(gridColumnSettingsProvider);
      expect(state.minColumns, equals(3));
      expect(state.maxColumns, equals(5)); // max >= min + 2 = 5

      container.dispose();
      await db.close();
    });
  });

  group('GridColumnSettingsNotifier - DB 永続化', () {
    test('setMinColumns で DB に保存される', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );

      final notifier = container.read(
        gridColumnSettingsProvider.notifier,
      );
      await notifier.setMinColumns(5);

      // DB から直接読み取って確認
      final savedMin = await db.getSetting('grid_min_columns');
      expect(savedMin, equals('5'));

      container.dispose();
      await db.close();
    });

    test('setMaxColumns で DB に保存される', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );

      final notifier = container.read(
        gridColumnSettingsProvider.notifier,
      );
      await notifier.setMaxColumns(10);

      // DB から直接読み取って確認
      final savedMax = await db.getSetting('grid_max_columns');
      expect(savedMax, equals('10'));

      container.dispose();
      await db.close();
    });
  });
}
