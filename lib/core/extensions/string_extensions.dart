/// String 拡張メソッド
library;

import '../constants/app_constants.dart';

extension StringExtensions on String {
  /// ファイルの拡張子（小文字、ドットなし）を返す
  String get fileExtension {
    final dot = lastIndexOf('.');
    if (dot < 0 || dot == length - 1) return '';
    return substring(dot + 1).toLowerCase();
  }

  /// 対応画像形式かどうかを判定する
  bool get isSupportedImage => kSupportedExtensions.contains(fileExtension);

  /// ファイル名（拡張子なし）を返す
  String get fileNameWithoutExtension {
    final slash = lastIndexOf('/');
    final backslash = lastIndexOf('\\');
    final start = (slash > backslash ? slash : backslash) + 1;
    final dot = lastIndexOf('.');
    if (dot <= start) return substring(start);
    return substring(start, dot);
  }

  /// パスからファイル名を返す
  String get fileName {
    final slash = lastIndexOf('/');
    final backslash = lastIndexOf('\\');
    final start = (slash > backslash ? slash : backslash) + 1;
    return substring(start);
  }

  /// ファイルサイズを人間可読な文字列に変換する
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(2)} GB';
  }
}
