import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/value_objects/viewer_display_mode.dart';
import '../../providers/viewer_controller_provider.dart';

/// ビューア内の表示設定をカスタマイズするためのボトムシート
class ViewerSettingsSheet extends ConsumerWidget {
  const ViewerSettingsSheet({
    super.key,
    required this.initialIndex,
    required this.totalCount,
    this.collectionId,
  });

  final int initialIndex;
  final int totalCount;
  final int? collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = viewerControllerProvider(
      initialIndex: initialIndex,
      totalCount: totalCount,
      collectionId: collectionId,
    );
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    final settings = state.folderSettings;

    return Material(
      color: Colors.black.withValues(alpha: 0.9),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: SizedBox(
                  width: 40,
                  height: 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                collectionId != null ? '表示設定 (このコレクション)' : '表示設定 (このフォルダ)',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(color: Colors.white24, height: 24),

              // 表示モードの選択
              const Text(
                '表示モード',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _ModeButton(
                      label: '単一ページ',
                      isSelected: state.displayMode == ViewerDisplayMode.single,
                      onTap: () => controller.updateFolderSettings(displayMode: ViewerDisplayMode.single),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ModeButton(
                      label: '見開き (漫画)',
                      isSelected: state.displayMode == ViewerDisplayMode.double,
                      onTap: () => controller.updateFolderSettings(displayMode: ViewerDisplayMode.double),
                    ),
                  ),
                ],
              ),

              if (state.displayMode == ViewerDisplayMode.double) ...[
                const SizedBox(height: 20),
                // めくり方向のトグル
                SwitchListTile(
                  title: const Text('右開き (和書/漫画形式)', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('右から左へめくります', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  value: settings?.isRightToLeft ?? true,
                  activeThumbColor: Theme.of(context).colorScheme.primary,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) {
                    controller.updateFolderSettings(isRightToLeft: val);
                  },
                ),
                const Divider(color: Colors.white12, height: 16),
                // 表紙設定のトグル
                SwitchListTile(
                  title: const Text('最初のページを表紙にする', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('1ページ目を単一で表示し、2ページ目から見開きにします', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  value: settings?.hasCoverPage ?? true,
                  activeThumbColor: Theme.of(context).colorScheme.primary,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) {
                    controller.updateFolderSettings(hasCoverPage: val);
                  },
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white10,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.white24,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
