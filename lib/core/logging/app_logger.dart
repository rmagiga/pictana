/// アプリ共通ロガー (設計書 §4.6)
library;

import 'package:logger/logger.dart';

/// アプリ全体で使用するシングルトンロガー
final appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
  ),
  level: Level.debug,
);

/// 各層向けの名前付きロガー生成ヘルパー
Logger createLogger(String name) => Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
      ),
      level: Level.debug,
    );
