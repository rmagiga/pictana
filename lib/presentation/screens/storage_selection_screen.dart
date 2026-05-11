/// StorageSelection画面 (設計書 §17.1)
///
/// ユーザーが明示的に開くフォルダを選択する画面。
/// 起動時に既定フォルダが見つからなかった場合や、
/// ユーザーが意図して他のフォルダを開きたい場合に表示される。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/logging/app_logger.dart';
import '../../router/app_router.dart';
import '../providers/gallery_providers.dart';
import '../providers/storage_providers.dart';

class StorageSelectionScreen extends ConsumerWidget {
  const StorageSelectionScreen({super.key});

  Future<void> _selectFolder(BuildContext context, WidgetRef ref) async {
    try {
      final useCase = ref.read(selectStorageUseCaseProvider);
      final folder = await useCase.execute();

      if (folder != null) {
        // 選択されたフォルダをセットしてギャラリーへ
        ref.read(currentFolderProvider.notifier).setFolder(folder);
        if (context.mounted) {
          context.go(AppRoutes.galleryGrid);
        }
      }
    } catch (e) {
      appLogger.e('フォルダ選択エラー', error: e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('フォルダの選択に失敗しました: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('フォルダを選択'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_open_rounded,
                size: 96,
                color: theme.colorScheme.primary.withAlpha(150),
              ),
              const SizedBox(height: 24),
              Text(
                '画像フォルダが見つかりません',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '写真が保存されているフォルダを選択してください。',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              FilledButton.icon(
                onPressed: () => _selectFolder(context, ref),
                icon: const Icon(Icons.create_new_folder_outlined),
                label: const Text('フォルダを選択'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
