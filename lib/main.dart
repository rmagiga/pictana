/// アプリエントリーポイント
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'application/usecases/settings/cache_size_limit_setting.dart';
import 'application/usecases/settings/thumbnail_size_setting.dart';
import 'core/logging/app_logger.dart';
import 'core/utils/image_cache_config.dart';
import 'presentation/providers/grid_column_settings_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/themes/app_theme.dart';
import 'router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // グローバルエラーハンドリング: Flutter フレームワーク内の例外
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    appLogger.e(
      'FlutterError',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  // グローバルエラーハンドリング: Flutter フレームワーク外の非同期例外
  PlatformDispatcher.instance.onError = (error, stack) {
    appLogger.e('PlatformDispatcher error', error: error, stackTrace: stack);
    return true;
  };

  // ImageCache をデバイスメモリに応じて動的設定 (設計書 §11.3)
  configureImageCache();

  runApp(
    // Riverpod の ProviderScope でルートをラップする (設計書 §14)
    const ProviderScope(child: OptrigApp()),
  );
}

/// アプリルートウィジェット
class OptrigApp extends ConsumerWidget {
  const OptrigApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 起動時に永続化設定をロード (遅延評価による未適用の防止)
    ref.read(cacheSizeLimitSettingProvider);
    ref.read(thumbnailSizeSettingProvider);
    ref.read(gridColumnSettingsProvider);

    // テーマモードを監視 (設計書 §5.6)
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Pictana',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
