/// GridColumnSettingsNotifier プロパティテスト
///
/// 任意の min/max 設定操作シーケンスに対して `max >= min + 2` が
/// 常に成立することを検証する。
///
/// **Validates: Requirements 8.3**
@Tags(['property-test'])
library;

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, tearDown, test;
import 'package:optrig/application/providers/repository_providers.dart';
import 'package:optrig/infrastructure/database/app_database.dart';
import 'package:optrig/presentation/providers/grid_column_settings_provider.dart';

// ---------------------------------------------------------------------------
// glados 用カスタムジェネレータ
// ---------------------------------------------------------------------------

/// 設定操作を表す sealed クラス
sealed class ColumnSettingOperation {
  const ColumnSettingOperation();
}

/// 最小列数を設定する操作
class SetMinOperation extends ColumnSettingOperation {
  const SetMinOperation(this.value);
  final int value;

  @override
  String toString() => 'SetMin($value)';
}

/// 最大列数を設定する操作
class SetMaxOperation extends ColumnSettingOperation {
  const SetMaxOperation(this.value);
  final int value;

  @override
  String toString() => 'SetMax($value)';
}

extension GridColumnSettingsGenerators on Any {
  /// 最小列数の候補値（UI で選択可能な値: 3, 4, 5, 6）
  Generator<int> get minColumnValue => any.choose([3, 4, 5, 6]);

  /// 最大列数の候補値（UI で選択可能な値: 6, 8, 10, 12）
  Generator<int> get maxColumnValue => any.choose([6, 8, 10, 12]);

  /// 設定操作を生成するジェネレータ
  ///
  /// SetMin または SetMax をランダムに生成する。
  Generator<ColumnSettingOperation> get columnSettingOperation => any.combine2(
    any.boolValue,
    any.intInRange(1, 20),
    (bool isMin, int value) {
      if (isMin) {
        // UI で選択可能な値に加え、境界値テスト用に広い範囲も含める
        return SetMinOperation(value);
      } else {
        return SetMaxOperation(value);
      }
    },
  );

  /// 設定操作シーケンスを生成するジェネレータ
  ///
  /// 1〜30 個の操作を生成し、様々な操作順序をカバーする。
  Generator<List<ColumnSettingOperation>> get columnSettingOperations =>
      any.listWithLengthInRange(1, 30, any.columnSettingOperation);

  /// bool 値を生成するジェネレータ
  Generator<bool> get boolValue => any.choose([true, false]);
}

// ---------------------------------------------------------------------------
// テスト本体
// ---------------------------------------------------------------------------

void main() {
  // drift の複数インスタンス警告を抑制（テスト用途のため問題なし）
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  // ===========================================================================
  // Feature: folder-selection-ux-redesign, Property 4: Min/max column constraint invariant
  // ===========================================================================
  group(
    'Feature: folder-selection-ux-redesign, Property 4: Min/max column constraint invariant',
    () {
      Glados(any.columnSettingOperations).test(
        '任意の min/max 設定操作シーケンスに対して max >= min + 2 が常に成立する',
        (operations) async {
          final db = AppDatabase.forTesting(NativeDatabase.memory());

          final container = ProviderContainer(
            overrides: [appDatabaseProvider.overrideWithValue(db)],
          );

          try {
            final notifier = container.read(
              gridColumnSettingsNotifierProvider.notifier,
            );

            // 初期状態の検証
            final initialState = container.read(
              gridColumnSettingsNotifierProvider,
            );
            expect(
              initialState.maxColumns >= initialState.minColumns + 2,
              isTrue,
              reason:
                  '初期状態: min=${initialState.minColumns}, '
                  'max=${initialState.maxColumns} で max >= min + 2 が成立しない',
            );

            // 各操作を順番に実行し、毎回制約を検証
            for (final op in operations) {
              switch (op) {
                case SetMinOperation(:final value):
                  await notifier.setMinColumns(value);
                case SetMaxOperation(:final value):
                  await notifier.setMaxColumns(value);
              }

              final state = container.read(gridColumnSettingsNotifierProvider);
              expect(
                state.maxColumns >= state.minColumns + 2,
                isTrue,
                reason:
                    '操作 $op の後: min=${state.minColumns}, '
                    'max=${state.maxColumns} で max >= min + 2 が成立しない',
              );
            }
          } finally {
            container.dispose();
            await db.close();
          }
        },
      );
    },
  );
}
