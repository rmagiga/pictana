/// グリッド列数設定タイル ウィジェット
///
/// 設定画面の「表示」セクション内に配置し、
/// お気に入りグリッドの最小列数と最大列数を DropdownButton で設定する。
/// GridColumnSettingsProvider を使用して即座にグリッドに反映する。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/grid_column_settings_provider.dart';

/// グリッド列数設定タイル
///
/// - ラベル「グリッド列数」
/// - 最小列数 DropdownButton: 3, 4, 5, 6（デフォルト: 3）
/// - 最大列数 DropdownButton: 6, 8, 10, 12（デフォルト: 12）
/// - min >= max 時の自動調整ロジックを UI に反映
/// - 変更時に即座にグリッドに反映（アプリ再起動不要）
class GridColumnSettingTile extends ConsumerWidget {
  const GridColumnSettingTile({super.key});

  /// 最小列数の選択肢
  static const List<int> _minOptions = [3, 4, 5, 6];

  /// 最大列数の選択肢
  static const List<int> _maxOptions = [6, 8, 10, 12];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(gridColumnSettingsNotifierProvider);
    final notifier = ref.read(gridColumnSettingsNotifierProvider.notifier);

    return ListTile(
      title: const Text('グリッド列数'),
      subtitle: Text('最小 ${settings.minColumns} 〜 最大 ${settings.maxColumns}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 最小列数 DropdownButton
          _buildDropdown(
            context: context,
            label: '最小',
            value: settings.minColumns,
            items: _minOptions,
            onChanged: (value) {
              if (value != null) {
                notifier.setMinColumns(value);
              }
            },
          ),
          const SizedBox(width: 8),
          // 最大列数 DropdownButton
          _buildDropdown(
            context: context,
            label: '最大',
            value: settings.maxColumns,
            items: _maxOptions,
            onChanged: (value) {
              if (value != null) {
                notifier.setMaxColumns(value);
              }
            },
          ),
        ],
      ),
    );
  }

  /// DropdownButton を構築する
  Widget _buildDropdown({
    required BuildContext context,
    required String label,
    required int value,
    required List<int> items,
    required ValueChanged<int?> onChanged,
  }) {
    // 現在の値が選択肢に含まれない場合、最も近い値を使用
    final effectiveValue = items.contains(value)
        ? value
        : items.reduce((a, b) => (a - value).abs() < (b - value).abs() ? a : b);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        DropdownButton<int>(
          value: effectiveValue,
          underline: const SizedBox.shrink(),
          items: items
              .map(
                (item) =>
                    DropdownMenuItem<int>(value: item, child: Text('$item')),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
