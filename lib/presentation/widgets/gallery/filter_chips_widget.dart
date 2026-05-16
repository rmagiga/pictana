/// 種類フィルターチップウィジェット (Req 12.1, 12.2, 12.4, 12.5)
///
/// 画像の MIME type でフィルタリングするためのチップ群を水平スクロール表示する。
/// 「全て」を含む 7 種類のチップを提供し、選択状態をハイライトで示す。
library;

import 'package:flutter/material.dart';

import '../../../domain/entities/image_entry.dart';

/// フィルターチップに表示する MIME type の定義
///
/// [ImageMimeType] の中からフィルター対象として表示するものと、
/// そのラベル文字列を定義する。
const _filterOptions = <(ImageMimeType?, String)>[
  (null, '全て'),
  (ImageMimeType.jpeg, 'JPEG'),
  (ImageMimeType.png, 'PNG'),
  (ImageMimeType.webp, 'WebP'),
  (ImageMimeType.gif, 'GIF'),
  (ImageMimeType.heic, 'HEIC'),
  (ImageMimeType.avif, 'AVIF'),
];

/// 種類フィルターチップウィジェット
///
/// 画像形式ごとのフィルターチップを水平スクロール可能な行として表示する。
/// [selectedMimeType] が null の場合は「全て」が選択状態となる。
class FilterChipsWidget extends StatelessWidget {
  const FilterChipsWidget({
    super.key,
    required this.selectedMimeType,
    required this.onMimeTypeSelected,
  });

  /// 現在選択中の MIME type（null = 全て）
  final ImageMimeType? selectedMimeType;

  /// MIME type が選択された時のコールバック（null = 全て選択）
  final ValueChanged<ImageMimeType?> onMimeTypeSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filterOptions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (mimeType, label) = _filterOptions[index];
          final isSelected = selectedMimeType == mimeType;

          return FilterChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) => onMimeTypeSelected(mimeType),
          );
        },
      ),
    );
  }
}
