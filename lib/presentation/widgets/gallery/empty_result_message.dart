import 'package:flutter/material.dart';

/// 検索結果が 0 件の時や、画像が存在しない場合に表示するメッセージウィジェット
class EmptyResultMessage extends StatelessWidget {
  const EmptyResultMessage({
    super.key,
    required this.isFiltered,
  });

  final bool isFiltered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFiltered ? Icons.search_off : Icons.image_not_supported_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            isFiltered ? '検索結果がありません' : '画像が見つかりません。',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (isFiltered) ...[
            const SizedBox(height: 8),
            Text(
              '検索条件を変更してください',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
