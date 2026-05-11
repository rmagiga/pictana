/// Splash画面 (設計書 §17.1)
///
/// 起動時にOS既定画像フォルダや最近開いたフォルダを検出し、
/// 結果に応じて初期画面へ遷移する。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/logging/app_logger.dart';
import '../../router/app_router.dart';
import '../providers/gallery_providers.dart';
import '../providers/storage_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 画面描画後に自動処理を開始
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      final useCase = ref.read(getDefaultImageFoldersUseCaseProvider);
      final result = await useCase.execute();

      if (!mounted) return;

      if (result.needsStorageSelection) {
        // 最近フォルダもなく、既定フォルダも見つからなかった場合は選択画面へ
        context.go(AppRoutes.storageSelection);
      } else {
        // 開くべきフォルダを決定（最近フォルダ優先、なければ既定フォルダ）
        final targetFolder = result.recentFolders.isNotEmpty
            ? result.recentFolders.first
            : result.defaultFolder!;

        // フォルダを選択状態にする
        ref.read(currentFolderProvider.notifier).setFolder(targetFolder);

        // ギャラリー画面へ遷移
        context.go(AppRoutes.galleryGrid);
      }
    } catch (e) {
      appLogger.e('起動時の自動フォルダ検出に失敗しました', error: e);
      if (mounted) {
        // エラー時もストレージ選択画面へ逃す
        context.go(AppRoutes.storageSelection);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ロゴ (TODO: 本番画像に差し替え)
            Icon(
              Icons.photo_library_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Optrig',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
