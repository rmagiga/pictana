/// テーマ設定 Riverpod Provider
library;

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/providers/repository_providers.dart';
import '../../infrastructure/database/tables/app_settings_table.dart';

part 'theme_provider.g.dart';

/// アプリのテーマモード状態
///
/// DB (AppDatabase) を用いて永続化を行う。
@Riverpod(keepAlive: true)
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    _loadInitial();
    return ThemeMode.system; // デフォルト: システムに合わせる
  }

  Future<void> _loadInitial() async {
    try {
      final db = ref.read(appDatabaseProvider);
      final value = await db.getSetting(AppSettingKeys.theme);
      if (value != null) {
        state = switch (value) {
          'dark' => ThemeMode.dark,
          'light' => ThemeMode.light,
          'system' => ThemeMode.system,
          _ => ThemeMode.system,
        };
      }
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final db = ref.read(appDatabaseProvider);
      final valueStr = switch (mode) {
        ThemeMode.dark => 'dark',
        ThemeMode.light => 'light',
        ThemeMode.system => 'system',
      };
      await db.setSetting(AppSettingKeys.theme, valueStr);
    } catch (_) {}
  }

  void setDark() => setThemeMode(ThemeMode.dark);
  void setLight() => setThemeMode(ThemeMode.light);
  void setSystem() => setThemeMode(ThemeMode.system);

  void toggle() {
    final nextMode = switch (state) {
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.system => ThemeMode.dark,
    };
    setThemeMode(nextMode);
  }

  void fromString(String value) {
    final mode = switch (value) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };
    setThemeMode(mode);
  }

  String toSettingString() => switch (state) {
        ThemeMode.dark => 'dark',
        ThemeMode.light => 'light',
        ThemeMode.system => 'system',
      };
}
