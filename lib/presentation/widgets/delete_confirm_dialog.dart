/// コレクション削除確認ダイアログ
///
/// 単一コレクション削除時は「「{name}」を削除しますか？」、
/// 複数コレクション削除時は「N件のコレクションを削除しますか？」と各名前の一覧を表示する。
/// 「画像ファイルは削除されません」という注意文を必ず含める。
///
/// 確認ボタンのタップのみが true を返し、
/// ダイアログ外タップ・戻るボタン・キャンセルボタンは null を返す（削除キャンセル）。
library;

import 'package:flutter/material.dart';

/// コレクション削除確認ダイアログを表示する
///
/// [collectionNames] に削除対象のコレクション名リストを渡す。
/// ユーザーが確認ボタンをタップした場合は `true` を返し、
/// キャンセル・ダイアログ外タップ・戻るボタンの場合は `null` を返す。
Future<bool?> showDeleteConfirmDialog(
  BuildContext context,
  List<String> collectionNames,
) {
  return showDialog<bool>(
    context: context,
    builder: (context) => DeleteConfirmDialog(collectionNames: collectionNames),
  );
}

/// コレクション削除確認ダイアログ
///
/// - 単一コレクション: 「「{name}」を削除しますか？」
/// - 複数コレクション: 「N件のコレクションを削除しますか？」+ 名前一覧
/// - 注意文: 「画像ファイルは削除されません」
/// - 確認ボタンのみが削除を実行（true を返す）
/// - キャンセル・外タップ・戻るボタンは削除をキャンセル（null を返す）
class DeleteConfirmDialog extends StatelessWidget {
  const DeleteConfirmDialog({required this.collectionNames, super.key});

  /// 削除対象のコレクション名リスト
  final List<String> collectionNames;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('削除の確認'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 削除確認メッセージ
          Text(_buildConfirmMessage()),
          // 複数コレクション時は名前一覧を表示
          if (collectionNames.length > 1) ...[
            const SizedBox(height: 12),
            _buildNameList(theme),
          ],
          const SizedBox(height: 16),
          // 注意文: 画像ファイルは削除されない旨
          Text(
            '※ 画像ファイルは削除されません',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('削除', style: TextStyle(color: theme.colorScheme.error)),
        ),
      ],
    );
  }

  /// 確認メッセージを構築する
  String _buildConfirmMessage() {
    if (collectionNames.length == 1) {
      return '「${collectionNames.first}」を削除しますか？';
    }
    return '${collectionNames.length}件のコレクションを削除しますか？';
  }

  /// 複数コレクション時の名前一覧ウィジェットを構築する
  Widget _buildNameList(ThemeData theme) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 150),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: collectionNames
              .map(
                (name) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '・$name',
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
