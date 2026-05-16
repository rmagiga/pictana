/// USB 切断インラインバナーウィジェット (Req 14.1, 14.2, 14.3, 14.4, 14.5, 14.6, 14.7)
///
/// ストレージ切断時に画面上部にインラインバナーを表示する。
/// - 警告アイコン + メッセージ + 「別のフォルダを開く」ボタン + 「×」閉じるボタン
/// - StorageMonitor Provider と連携し、再接続時に自動非表示
/// - 「×」ボタンで手動非表示後、新たな切断が発生した場合は再表示
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/usecases/storage/storage_monitor.dart';

/// USB 切断インラインバナー
///
/// [StorageMonitor] Provider の状態に基づき、ストレージ切断時に
/// 警告バナーを表示する。再接続検知時は自動的に非表示になる。
///
/// - [onOpenFolder]: 「別のフォルダを開く」ボタンタップ時のコールバック
///   （通常は Storage Selection 画面への遷移を行う）
class DisconnectBanner extends ConsumerWidget {
  /// DisconnectBanner を作成する
  const DisconnectBanner({super.key, required this.onOpenFolder});

  /// 「別のフォルダを開く」ボタンタップ時のコールバック
  final VoidCallback onOpenFolder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monitorState = ref.watch(storageMonitorProvider);

    // バナー非表示の場合は何も描画しない
    if (!monitorState.isBannerVisible) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    // 最大リトライ到達時はメッセージを変更
    final message = monitorState.maxRetryReached
        ? 'ストレージが切断されました。手動で再接続してください。'
        : 'ストレージが切断されました';

    return Material(
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            // 警告アイコン
            Icon(
              Icons.warning_amber_rounded,
              color: colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 12),
            // メッセージテキスト
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (monitorState.isRetrying)
                    Text(
                      '再接続を試行中... (${monitorState.retryCount}/60)',
                      style: TextStyle(
                        color: colorScheme.onErrorContainer,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            // 「別のフォルダを開く」ボタン
            TextButton(
              onPressed: onOpenFolder,
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onErrorContainer,
              ),
              child: const Text('別のフォルダを開く'),
            ),
            // 「×」閉じるボタン
            IconButton(
              icon: Icon(Icons.close, color: colorScheme.onErrorContainer),
              tooltip: 'バナーを閉じる',
              onPressed: () {
                ref.read(storageMonitorProvider.notifier).dismissBanner();
              },
            ),
          ],
        ),
      ),
    );
  }
}
