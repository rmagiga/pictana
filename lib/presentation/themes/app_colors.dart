/// カラーパレット定義
library;

import 'package:flutter/material.dart';

/// ダークモードのカラーパレット
abstract final class AppColorsDark {
  /// 背景色
  static const background = Color(0xFF0D0D0D);

  /// サーフェス色（カード、ダイアログ等）
  static const surface = Color(0xFF1A1A1A);

  /// サーフェス変種
  static const surfaceVariant = Color(0xFF242424);

  /// プライマリアクセント
  static const primary = Color(0xFF6B8EFF);

  /// プライマリコンテナ
  static const primaryContainer = Color(0xFF1E2A4A);

  /// テキスト: 高優先度
  static const onBackground = Color(0xFFEEEEEE);

  /// テキスト: 中優先度
  static const onSurfaceMedium = Color(0xFFAAAAAA);

  /// テキスト: 低優先度
  static const onSurfaceLow = Color(0xFF666666);

  /// エラー色
  static const error = Color(0xFFCF6679);

  /// 警告色（USB切断バナー）
  static const warning = Color(0xFFE6A020);

  /// 成功色
  static const success = Color(0xFF4CAF82);

  /// 区切り線
  static const divider = Color(0xFF2A2A2A);
}

/// ライトモードのカラーパレット
abstract final class AppColorsLight {
  /// 背景色
  static const background = Color(0xFFF5F5F5);

  /// サーフェス色
  static const surface = Color(0xFFFFFFFF);

  /// サーフェス変種
  static const surfaceVariant = Color(0xFFECECEC);

  /// プライマリアクセント
  static const primary = Color(0xFF3D5CCC);

  /// プライマリコンテナ
  static const primaryContainer = Color(0xFFD8E2FF);

  /// テキスト: 高優先度
  static const onBackground = Color(0xFF1A1A1A);

  /// テキスト: 中優先度
  static const onSurfaceMedium = Color(0xFF555555);

  /// テキスト: 低優先度
  static const onSurfaceLow = Color(0xFF999999);

  /// エラー色
  static const error = Color(0xFFB00020);

  /// 警告色
  static const warning = Color(0xFFC07800);

  /// 成功色
  static const success = Color(0xFF2E7D4F);

  /// 区切り線
  static const divider = Color(0xFFE0E0E0);
}
