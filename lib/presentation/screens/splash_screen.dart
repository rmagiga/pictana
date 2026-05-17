/// Splash画面 (設計書 §17.1)
///
/// 起動時にOS既定画像フォルダや最近開いたフォルダを検出し、
/// 結果に応じて初期画面へ遷移する。
///
/// - StorageMonitor.detectDefaultFolder を起動時に呼び出し (Req 16.1)
/// - 3 秒タイムアウト、検出失敗時は Storage Selection 画面表示 (Req 16.3)
/// - 最近開いたフォルダ履歴を優先 (Req 16.5)
/// - 検出完了まで読み込み中インジケーターを表示 (Req 16.1)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers/repository_providers.dart';
import '../../application/usecases/storage/storage_monitor.dart';
import '../../core/logging/app_logger.dart';
import '../../domain/entities/folder_entry.dart';
import '../../router/app_router.dart';
import '../providers/gallery_providers.dart';

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

  /// 起動時の自動フォルダ検出フロー (Req 16.1, 16.2, 16.3, 16.4, 16.5, 16.6)
  ///
  /// 処理順序:
  /// 1. 最近開いたフォルダ履歴を確認（優先）(Req 16.5)
  /// 2. 履歴がなければ StorageMonitor.detectDefaultFolder で OS 既定フォルダを検出 (Req 16.1, 16.4)
  /// 3. 全体で 3 秒タイムアウト、失敗時は Storage Selection 画面へ (Req 16.3)
  Future<void> _initializeApp() async {
    try {
      // 3 秒タイムアウト付きでフォルダ検出を実行 (Req 16.3)
      final targetFolder = await _detectTargetFolder().timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );

      if (!mounted) return;

      if (targetFolder == null) {
        // 検出失敗またはタイムアウト → Storage Selection 画面へ (Req 16.3)
        appLogger.w('起動時フォルダ検出が失敗またはタイムアウトしました');
        context.go(AppRoutes.storageSelection);
      } else {
        // フォルダを選択状態にする
        ref.read(currentFolderProvider.notifier).setFolder(targetFolder);

        // StorageMonitor を初期化（ストレージ監視を開始）
        ref.read(storageMonitorProvider.notifier);

        // ギャラリー画面へ遷移 (Req 16.2, 16.6)
        context.go(AppRoutes.galleryGrid);
      }
    } catch (e) {
      appLogger.e('起動時の自動フォルダ検出に失敗しました', error: e);
      if (mounted) {
        // エラー時もストレージ選択画面へ逃す (Req 16.3)
        context.go(AppRoutes.storageSelection);
      }
    }
  }

  /// 最近フォルダ優先 → OS 既定フォルダの順でターゲットフォルダを検出する
  ///
  /// - 最近開いたフォルダ履歴があればそれを優先 (Req 16.5)
  /// - なければ StorageMonitor.detectDefaultFolder を呼び出し (Req 16.1, 16.4)
  Future<FolderEntry?> _detectTargetFolder() async {
    final repo = ref.read(storageRepositoryProvider);

    // 1. 最近開いたフォルダ履歴を確認（優先）(Req 16.5)
    final recentFolders = await repo.getRecentFolders();
    if (recentFolders.isNotEmpty) {
      appLogger.i('最近開いたフォルダを使用: ${recentFolders.first.name}');
      return recentFolders.first;
    }

    // 2. StorageMonitor.detectDefaultFolder で OS 既定フォルダを検出 (Req 16.1, 16.4)
    final storageMonitor = ref.read(storageMonitorProvider.notifier);
    final defaultFolder = await storageMonitor.detectDefaultFolder();

    if (defaultFolder != null) {
      appLogger.i('OS 既定画像フォルダを検出: ${defaultFolder.name}');
    } else {
      appLogger.w('OS 既定画像フォルダが見つかりませんでした');
    }

    return defaultFolder;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ロゴ
            Icon(
              Icons.photo_library_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Pictana',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            // 読み込み中インジケーター (Req 16.1)
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              '画像フォルダを検出中...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
