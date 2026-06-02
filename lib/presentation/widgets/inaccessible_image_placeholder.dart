/// 参照不能画像のプレースホルダーウィジェット
///
/// 元フォルダへのアクセス権喪失またはファイル削除により画像が参照不能になった場合に、
/// サムネイル表示領域に代替表示を行う。
///
/// - サムネイルキャッシュあり: グレースケールフィルター + 半透明オーバーレイ + 警告アイコン
/// - サムネイルキャッシュなし: 壊れた画像アイコン + グレー背景
library;

import 'package:flutter/material.dart';

/// グレースケール変換用カラーマトリクス
///
/// ITU-R BT.601 輝度係数（R:0.2126, G:0.7152, B:0.0722）に基づく
/// 彩度 0% への変換マトリクス。
const List<double> _grayscaleMatrix = <double>[
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0, 0, 0, 1, 0, //
];

/// 参照不能画像のプレースホルダーウィジェット
///
/// [cachedThumbnail] が指定されている場合はグレースケール変換したサムネイルに
/// 半透明オーバーレイと警告アイコンを重畳表示する。
/// [cachedThumbnail] が null の場合は壊れた画像アイコンとグレー背景を表示する。
///
/// タップ時の遷移拒否やインライン通知は呼び出し元が担当する。
class InaccessibleImagePlaceholder extends StatelessWidget {
  const InaccessibleImagePlaceholder({this.cachedThumbnail, super.key});

  /// キャッシュ済みサムネイル画像（null の場合は汎用プレースホルダーを表示）
  final ImageProvider? cachedThumbnail;

  @override
  Widget build(BuildContext context) {
    if (cachedThumbnail != null) {
      return _buildCachedThumbnailPlaceholder(context);
    }
    return _buildGenericPlaceholder(context);
  }

  /// サムネイルキャッシュありの場合の表示
  ///
  /// グレースケールフィルター付きサムネイル + 半透明オーバーレイ + 警告アイコン
  Widget _buildCachedThumbnailPlaceholder(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        // グレースケール変換したサムネイル画像
        ColorFiltered(
          colorFilter: const ColorFilter.matrix(_grayscaleMatrix),
          child: Image(
            image: cachedThumbnail!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _buildGenericPlaceholder(context),
          ),
        ),

        // 半透明オーバーレイ
        Container(color: theme.colorScheme.surface.withValues(alpha: 0.5)),

        // 警告アイコン
        Center(
          child: Icon(
            Icons.warning_amber_rounded,
            size: 32,
            color: theme.colorScheme.error,
          ),
        ),
      ],
    );
  }

  /// サムネイルキャッシュなしの場合の表示
  ///
  /// 壊れた画像アイコン + グレー背景
  Widget _buildGenericPlaceholder(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 32,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
