/// テーマ設定 Riverpod Provider
library;

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_provider.g.dart';

/// アプリのテーマモード状態
///
/// DB からの読み込みは AppSettingsProvider 経由で行い、
/// このProviderは純粋なテーマモード切替のみを担う。
@Riverpod(keepAlive: true)
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() => ThemeMode.dark; // デフォルト: ダークモード

  void setDark() => state = ThemeMode.dark;
  void setLight() => state = ThemeMode.light;
  void setSystem() => state = ThemeMode.system;

  void toggle() {
    state = switch (state) {
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.system => ThemeMode.dark,
    };
  }

  void fromString(String value) {
    state = switch (value) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };
  }

  String toSettingString() => switch (state) {
        ThemeMode.dark => 'dark',
        ThemeMode.light => 'light',
        ThemeMode.system => 'system',
      };
}
