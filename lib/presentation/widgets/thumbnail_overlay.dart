/// サムネイルオーバーレイ ウィジェット（2×2 グリッド版）
///
/// フォルダカードの上部領域に最大4枚のサムネイル画像を 2×2 グリッドで表示する。
/// [getFolderThumbnailsProvider] を watch してサムネイルバイト列リストを取得し、
/// ローディング中はシマーアニメーション、成功時は画像表示、
/// 画像なし時はフォルダアイコン、失敗/空スロットはプレースホルダー色を表示する。
library;

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../domain/entities/favorite_folder.dart';
import '../providers/folder_thumbnail_provider.dart';

/// サムネイルオーバーレイ（2×2 グリッド版）
///
/// フォルダカード上部にサムネイル画像を 2×2 グリッドで表示するウィジェット。
/// - ローディング中: シマーアニメーション表示（最大10秒タイムアウト）
/// - 成功（1枚以上）: 2×2 グリッドに画像を配置、残りスロットはプレースホルダー色
/// - 成功（0枚）: フォルダアイコン(48dp) を中央表示
/// - 失敗: 全スロットをプレースホルダー色で表示
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
  static const double _borderRadius = 8.0;

  /// グリッドセル間のスペーシング
  static const double _gridSpacing = 2.0;

  /// シマータイムアウト時間（秒）
  static const int _shimmerTimeoutSeconds = 10;

  /// 画像なし時のフォルダアイコンサイズ
  static const double _folderIconSize = 48.0;

  /// タイムアウトタイマー
  Timer? _timeoutTimer;

  /// タイムアウトが発生したかどうか
  bool _hasTimedOut = false;

  @override
  void initState() {
    super.initState();
    _startTimeoutTimer();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  /// タイムアウトタイマーを開始する
  void _startTimeoutTimer() {
    _timeoutTimer = Timer(const Duration(seconds: _shimmerTimeoutSeconds), () {
      if (mounted) {
        setState(() {
          _hasTimedOut = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final thumbnailsAsync = ref.watch(
      getFolderThumbnailsProvider(widget.folder),
    );

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(_borderRadius),
        topRight: Radius.circular(_borderRadius),
      ),
      child: thumbnailsAsync.when(
        loading: () => _hasTimedOut
            ? _buildPlaceholderGrid(context)
            : _buildShimmer(context),
        data: (thumbnails) => _buildGrid(context, thumbnails),
        error: (_, _) => _buildPlaceholderGrid(context),
      ),
    );
  }

  /// シマーアニメーションを構築する（ローディング中）
  Widget _buildShimmer(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
      ),
    );
  }

  /// 2×2 グリッドを構築する（データ取得成功時）
  ///
  /// [thumbnails] が空の場合はフォルダアイコンを中央表示する。
  /// 1〜4枚の場合は利用可能なスロットに配置し、残りはプレースホルダー色。
  Widget _buildGrid(BuildContext context, List<Uint8List?> thumbnails) {
    // タイムアウトタイマーをキャンセル（データ取得完了）
    _timeoutTimer?.cancel();

    // 画像が1枚もない場合はフォルダアイコンを表示
    if (thumbnails.isEmpty || thumbnails.every((t) => t == null)) {
      return _buildFolderIcon(context);
    }

    return _buildThumbnailGrid(context, thumbnails);
  }

  /// フォルダアイコンを中央表示する（画像なし時）
  Widget _buildFolderIcon(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.folder,
          size: _folderIconSize,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  /// 2×2 サムネイルグリッドを構築する
  Widget _buildThumbnailGrid(
    BuildContext context,
    List<Uint8List?> thumbnails,
  ) {
    // 最大4枚に制限
    final slots = List<Uint8List?>.generate(4, (index) {
      if (index < thumbnails.length) {
        return thumbnails[index];
      }
      return null;
    });

    return Column(
      children: [
        // 上段: スロット0（左上）、スロット1（右上）
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildSlot(context, slots[0])),
              const SizedBox(width: _gridSpacing),
              Expanded(child: _buildSlot(context, slots[1])),
            ],
          ),
        ),
        const SizedBox(height: _gridSpacing),
        // 下段: スロット2（左下）、スロット3（右下）
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildSlot(context, slots[2])),
              const SizedBox(width: _gridSpacing),
              Expanded(child: _buildSlot(context, slots[3])),
            ],
          ),
        ),
      ],
    );
  }

  /// 個別スロットを構築する
  ///
  /// [bytes] が null の場合はプレースホルダー色、
  /// null でない場合は画像を BoxFit.cover で表示する。
  Widget _buildSlot(BuildContext context, Uint8List? bytes) {
    final theme = Theme.of(context);

    if (bytes == null) {
      // 空スロットまたは失敗スロット: プレースホルダー色
      return Container(color: theme.colorScheme.surfaceContainerHighest);
    }

    // 画像読み込み成功: BoxFit.cover で表示
    return Image.memory(
      bytes,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      // デコードエラー時はプレースホルダー色にフォールバック
      errorBuilder: (_, _, _) =>
          Container(color: theme.colorScheme.surfaceContainerHighest),
    );
  }

  /// 全スロットをプレースホルダー色で表示する（エラー時・タイムアウト時）
  Widget _buildPlaceholderGrid(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.folder,
          size: _folderIconSize,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
