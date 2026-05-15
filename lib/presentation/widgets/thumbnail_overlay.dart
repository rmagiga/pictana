/// サムネイルオーバーレイ ウィジェット
///
/// フォルダカードの上半分領域にサムネイル画像を重ねて表示する。
/// [getFolderThumbnailProvider] を watch してサムネイルバイト列を取得し、
/// ローディング中はシマーアニメーション、成功時は画像表示、
/// 失敗/画像なし時は非表示（[SizedBox.shrink]）とする。
library;

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../domain/entities/favorite_folder.dart';
import '../providers/folder_thumbnail_provider.dart';

/// サムネイルオーバーレイ
///
/// フォルダカード上半分にサムネイル画像を表示するウィジェット。
/// - ローディング中: シマーアニメーション表示
/// - 成功: [Image.memory] で BoxFit.cover 表示 + [ClipRRect]
/// - 失敗/画像なし: [SizedBox.shrink] で非表示
class ThumbnailOverlay extends ConsumerStatefulWidget {
  /// サムネイルオーバーレイを作成する
  const ThumbnailOverlay({super.key, required this.folder});

  /// サムネイルを取得する対象フォルダ
  final FavoriteFolder folder;

  @override
  ConsumerState<ThumbnailOverlay> createState() => _ThumbnailOverlayState();
}

class _ThumbnailOverlayState extends ConsumerState<ThumbnailOverlay> {
  /// カード上部の角丸半径
  static const double _borderRadius = 12.0;

  @override
  Widget build(BuildContext context) {
    final thumbnailAsync = ref.watch(getFolderThumbnailProvider(widget.folder));

    return thumbnailAsync.when(
      loading: () => _buildShimmer(context),
      data: (bytes) => _buildThumbnail(bytes),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  /// シマーアニメーションを構築する（ローディング中）
  Widget _buildShimmer(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(_borderRadius),
        topRight: Radius.circular(_borderRadius),
      ),
      child: Shimmer.fromColors(
        baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
        ),
      ),
    );
  }

  /// サムネイル画像を構築する（成功時）
  ///
  /// [bytes] が null の場合は非表示とする。
  Widget _buildThumbnail(Uint8List? bytes) {
    if (bytes == null) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(_borderRadius),
        topRight: Radius.circular(_borderRadius),
      ),
      child: Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        // エラー時は非表示にフォールバック
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
    );
  }
}
