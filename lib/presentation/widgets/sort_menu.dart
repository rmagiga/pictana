/// ソートメニューウィジェット (設計書 §18.3)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/value_objects/sort_option.dart';
import '../providers/gallery_providers.dart';

class SortMenu extends ConsumerWidget {
  const SortMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortOption = ref.watch(gallerySortOptionProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 昇順/降順のトグルボタン
        IconButton(
          icon: Icon(
            sortOption.isAscending ? Icons.arrow_upward : Icons.arrow_downward,
            size: 20,
          ),
          onPressed: () {
            ref
                .read(gallerySortOptionProvider.notifier)
                .updateOption(sortOption.toggleDirection());
          },
          tooltip: sortOption.isAscending ? '昇順' : '降順',
        ),
        // ソート基準選択メニュー
        PopupMenuButton<SortField>(
          initialValue: sortOption.field,
          tooltip: '並び替え',
          onSelected: (field) {
            ref
                .read(gallerySortOptionProvider.notifier)
                .updateOption(sortOption.withField(field));
          },
          itemBuilder: (context) {
            return SortField.values.map((field) {
              return PopupMenuItem(
                value: field,
                child: Row(
                  children: [
                    Icon(
                      _getIconForField(field),
                      size: 20,
                      color: field == sortOption.field
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      field.label,
                      style: TextStyle(
                        fontWeight: field == sortOption.field
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }).toList();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(sortOption.field.label),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getIconForField(SortField field) {
    return switch (field) {
      SortField.name => Icons.sort_by_alpha,
      SortField.date => Icons.calendar_today,
      SortField.size => Icons.data_usage,
      SortField.type => Icons.category,
    };
  }
}
