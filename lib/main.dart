/// アプリエントリーポイント
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/utils/image_cache_config.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/themes/app_theme.dart';
import 'router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ImageCache をデバイスメモリに応じて動的設定 (設計書 §11.3)
  configureImageCache();

  runApp(
    // Riverpod の ProviderScope でルートをラップする (設計書 §14)
    const ProviderScope(
      child: OptrigApp(),
    ),
  );
}

/// アプリルートウィジェット
class OptrigApp extends ConsumerWidget {
  const OptrigApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // テーマモードを監視 (設計書 §5.6)
    final themeMode = ref.watch(themeModeNotifierProvider);

    return MaterialApp.router(
      title: 'Optrig',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
