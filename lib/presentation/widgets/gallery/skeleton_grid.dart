import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../application/usecases/settings/thumbnail_size_setting.dart';
import '../../providers/grid_column_settings_provider.dart';

/// ギャラリーの初回読込中に表示するスケルトン表示グリッド
class SkeletonGrid extends ConsumerWidget {
  const SkeletonGrid({
    super.key,
    required this.navBarHeight,
  });

  final double navBarHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final settings = ref.watch(gridColumnSettingsProvider);
        final thumbnailSize = ref.watch(thumbnailSizeSettingProvider);
        final crossAxisCount = (constraints.maxWidth / (thumbnailSize.px + 4))
            .floor()
            .clamp(settings.minColumns, settings.maxColumns)
            .toInt();

        // 画面全体を覆うのに必要なアイテム数を動的に計算する
        // タイルのアスペクト比は 1.0 (正方形) なので、高さは幅と同じ
        final tileHeight = constraints.maxWidth / crossAxisCount;
        final rowCount = (constraints.maxHeight / tileHeight).ceil() + 1;
        final itemCount = crossAxisCount * rowCount;

        return Skeletonizer(
          enabled: true,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              left: 4,
              right: 4,
              top: 4,
              bottom: 4 + navBarHeight,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: const SizedBox.expand(),
              );
            },
          ),
        );
      },
    );
  }
}
