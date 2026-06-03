import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/usecases/settings/thumbnail_size_setting.dart';
import '../../../domain/value_objects/thumbnail_size_option.dart';

/// ギャラリーの表示密度（サムネイルのサイズ）を調整するためのスライダーパネル
class DensitySliderPanel extends ConsumerWidget {
  const DensitySliderPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSize = ref.watch(thumbnailSizeSettingProvider);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.zoom_in, size: 20),
          Expanded(
            child: Slider(
              value: currentSize.index.toDouble(),
              min: 0,
              max: (ThumbnailSizeOption.values.length - 1).toDouble(),
              divisions: ThumbnailSizeOption.values.length - 1,
              label: currentSize.displayName,
              activeColor: theme.colorScheme.primary,
              onChanged: (val) {
                final option = ThumbnailSizeOption.values[val.toInt()];
                ref
                    .read(thumbnailSizeSettingProvider.notifier)
                    .update(option);
              },
            ),
          ),
          const Icon(Icons.zoom_out, size: 20),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Text(
              currentSize.displayName,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
