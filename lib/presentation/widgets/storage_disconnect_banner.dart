/// ストレージ切断通知バナー (設計書 §18.5)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_router.dart';
import '../providers/storage_providers.dart';

class StorageDisconnectBanner extends ConsumerWidget {
  const StorageDisconnectBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rootsAsync = ref.watch(storageRootsProvider);

    return rootsAsync.when(
      data: (roots) {
        // 全てのストレージが接続されているか確認
        final hasDisconnected = roots.any((r) => !r.isConnected);
        if (!hasDisconnected) {
          return const SizedBox.shrink(); // 全て正常なら表示しない
        }

        return Material(
          color: Theme.of(context).colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ストレージが切断されました',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'デバイスを再接続するか、別のフォルダを選択してください。',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.go(AppRoutes.storageSelection);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  child: const Text('別のフォルダを開く'),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, st) => const SizedBox.shrink(),
    );
  }
}
