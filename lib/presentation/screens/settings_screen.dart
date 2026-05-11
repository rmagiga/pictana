/// 設定画面 (設計書 §18.6)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cacheSizeAsync = ref.watch(cacheSizeProvider);
    final themeMode = ref.watch(appThemeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, '表示'),
          ListTile(
            title: const Text('テーマ'),
            subtitle: Text(_themeModeName(themeMode)),
            trailing: PopupMenuButton<int>(
              initialValue: themeMode,
              onSelected: (mode) {
                ref.read(appThemeModeProvider.notifier).setTheme(mode);
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 0, child: Text('システムに合わせる')),
                PopupMenuItem(value: 1, child: Text('ライト')),
                PopupMenuItem(value: 2, child: Text('ダーク')),
              ],
            ),
          ),
          const Divider(),
          _buildSectionHeader(context, 'キャッシュ管理'),
          ListTile(
            title: const Text('現在のサムネイルキャッシュ容量'),
            subtitle: cacheSizeAsync.when(
              data: (size) => Text(_formatBytes(size)),
              loading: () => const Text('計算中...'),
              error: (e, _) => const Text('取得エラー'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: OutlinedButton.icon(
              onPressed: cacheSizeAsync.isLoading
                  ? null
                  : () async {
                      // 確認ダイアログ
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('キャッシュのクリア'),
                          content: const Text('生成されたサムネイルをすべて削除します。よろしいですか？'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('キャンセル'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: FilledButton.styleFrom(
                                backgroundColor: theme.colorScheme.error,
                              ),
                              child: const Text('削除'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await ref.read(cacheSizeProvider.notifier).clearCache();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('キャッシュをクリアしました')),
                          );
                        }
                      }
                    },
              icon: const Icon(Icons.delete_outline),
              label: const Text('キャッシュをクリア'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _themeModeName(int mode) {
    switch (mode) {
      case 1:
        return 'ライト';
      case 2:
        return 'ダーク';
      default:
        return 'システムに合わせる';
    }
  }

  String _formatBytes(int bytes) {
    if (bytes == 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
