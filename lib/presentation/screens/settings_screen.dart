/// 設定画面 (設計書 §18.6)
///
/// テーマ、グリッド列数、サムネイルサイズ、キャッシュサイズ上限、キャッシュクリアを管理する。
/// Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 9.1, 9.2, 9.5, 10.1, 10.2, 10.3, 10.4, 10.5
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/usecases/settings/cache_size_limit_setting.dart';
import '../../application/usecases/settings/thumbnail_size_setting.dart';
import '../../core/utils/format_bytes.dart';
import '../../domain/value_objects/cache_size_limit.dart';
import '../../domain/value_objects/thumbnail_size_option.dart';
import '../providers/settings_providers.dart';
import '../widgets/grid_column_setting_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cacheSizeAsync = ref.watch(cacheSizeProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final currentCacheLimit = ref.watch(cacheSizeLimitSettingProvider);
    final currentThumbnailSize = ref.watch(thumbnailSizeSettingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          _buildSectionHeader(context, '表示'),
          ListTile(
            title: const Text('テーマ'),
            subtitle: Text(_themeModeName(themeMode)),
            trailing: DropdownButton<int>(
              value: themeMode,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: 0, child: Text('システムに合わせる')),
                DropdownMenuItem(value: 1, child: Text('ライト')),
                DropdownMenuItem(value: 2, child: Text('ダーク')),
              ],
              onChanged: (mode) {
                if (mode != null) {
                  ref.read(appThemeModeProvider.notifier).setTheme(mode);
                }
              },
            ),
          ),
          const GridColumnSettingTile(),

          // サムネイルサイズ設定 (Req 8.1, 8.2, 8.3, 8.4)
          ListTile(
            title: const Text('サムネイルサイズ'),
            subtitle: Text(
              '${currentThumbnailSize.displayName} (${currentThumbnailSize.px}px)',
            ),
            trailing: DropdownButton<ThumbnailSizeOption>(
              value: currentThumbnailSize,
              underline: const SizedBox.shrink(),
              items: ThumbnailSizeOption.values
                  .map(
                    (option) => DropdownMenuItem<ThumbnailSizeOption>(
                      value: option,
                      child: Text('${option.displayName} (${option.px}px)'),
                    ),
                  )
                  .toList(),
              onChanged: (option) {
                if (option != null) {
                  ref
                      .read(thumbnailSizeSettingProvider.notifier)
                      .update(option);
                }
              },
            ),
          ),

          const Divider(),
          _buildSectionHeader(context, 'キャッシュ管理'),

          // キャッシュサイズ上限設定 (Req 9.1, 9.2)
          ListTile(
            title: const Text('キャッシュサイズ上限'),
            subtitle: Text('現在の上限: ${currentCacheLimit.displayName}'),
            trailing: DropdownButton<CacheSizeLimit>(
              value: currentCacheLimit,
              underline: const SizedBox.shrink(),
              items: CacheSizeLimit.values
                  .map(
                    (limit) => DropdownMenuItem<CacheSizeLimit>(
                      value: limit,
                      child: Text(limit.displayName),
                    ),
                  )
                  .toList(),
              onChanged: (limit) {
                if (limit != null) {
                  ref
                      .read(cacheSizeLimitSettingProvider.notifier)
                      .update(limit);
                }
              },
            ),
          ),

          // 現在のキャッシュ使用量表示 (Req 9.5, 10.1)
          ListTile(
            title: const Text('現在のキャッシュ使用量'),
            subtitle: cacheSizeAsync.when(
              data: (size) => Text(
                '${formatBytes(size)} / ${currentCacheLimit.displayName}',
              ),
              loading: () => const Text('計算中...'),
              error: (e, _) => const Text('取得エラー'),
            ),
          ),

          // キャッシュクリアボタン (Req 10.2, 10.3, 10.4, 10.5)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: OutlinedButton.icon(
              onPressed: cacheSizeAsync.isLoading
                  ? null
                  : () => _showClearCacheDialog(context, ref, theme),
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

  /// キャッシュクリア確認ダイアログを表示する (Req 10.2, 10.3, 10.4, 10.5)
  Future<void> _showClearCacheDialog(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) async {
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
      try {
        await ref.read(cacheSizeProvider.notifier).clearCache();
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('キャッシュをクリアしました')));
        }
      } catch (e) {
        // エラー発生時は通知してボタンを再有効化 (Req 10.5)
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('キャッシュのクリアに失敗しました')));
        }
      }
    }
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
}
