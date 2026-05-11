/// アプリテーマ定義 (設計書 §5.6)
library;

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// アプリのThemeData を返すファクトリ
abstract final class AppTheme {
  /// ダークテーマ
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          surface: AppColorsDark.surface,
          surfaceContainerHighest: AppColorsDark.surfaceVariant,
          primary: AppColorsDark.primary,
          primaryContainer: AppColorsDark.primaryContainer,
          onSurface: AppColorsDark.onBackground,
          error: AppColorsDark.error,
        ),
        scaffoldBackgroundColor: AppColorsDark.background,
        cardColor: AppColorsDark.surface,
        dividerColor: AppColorsDark.divider,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColorsDark.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: AppColorsDark.onBackground,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: AppColorsDark.onBackground),
        ),
        iconTheme: const IconThemeData(color: AppColorsDark.onBackground),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColorsDark.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColorsDark.surfaceVariant,
          selectedColor: AppColorsDark.primaryContainer,
          labelStyle: const TextStyle(color: AppColorsDark.onBackground),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: AppColorsDark.surface,
          contentTextStyle: TextStyle(color: AppColorsDark.onBackground),
        ),
      );

  /// ライトテーマ
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          surface: AppColorsLight.surface,
          surfaceContainerHighest: AppColorsLight.surfaceVariant,
          primary: AppColorsLight.primary,
          primaryContainer: AppColorsLight.primaryContainer,
          onSurface: AppColorsLight.onBackground,
          error: AppColorsLight.error,
        ),
        scaffoldBackgroundColor: AppColorsLight.background,
        cardColor: AppColorsLight.surface,
        dividerColor: AppColorsLight.divider,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColorsLight.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 1,
          titleTextStyle: TextStyle(
            color: AppColorsLight.onBackground,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: AppColorsLight.onBackground),
        ),
        iconTheme: const IconThemeData(color: AppColorsLight.onBackground),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColorsLight.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColorsLight.surfaceVariant,
          selectedColor: AppColorsLight.primaryContainer,
          labelStyle: const TextStyle(color: AppColorsLight.onBackground),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
}
