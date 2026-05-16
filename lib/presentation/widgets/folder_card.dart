/// お気に入りフォルダカード ウィジェット
///
/// グリッド内の個別カードウィジェット。
/// Card（角丸8dp、elevation 1dp → ホバー/フォーカス時 3dp）で構成し、
/// カード上部70%にサムネイルオーバーレイ（2×2グリッド）、
/// 下部30%にフォルダアイコン(16dp)とフォルダ名(1行)を表示する。
/// タップでフォルダ遷移、長押し/右クリックで削除コンテキストメニューを表示する。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/favorite_folder.dart';
import 'thumbnail_overlay.dart';

/// お気に入りフォルダカード
///
/// - Card（角丸8dp、elevation 1dp → ホバー/フォーカス時 3dp）
/// - InkWell によるリップルエフェクト
/// - カード上部 70%: [ThumbnailOverlay]（2×2 グリッド）
/// - カード下部 30%: フォルダアイコン(16dp) + フォルダ名(1行、ellipsis)
/// - Material Design 3 Surface カラーを背景色に使用
/// - 長押し/右クリックで削除コンテキストメニューを表示
class FolderCard extends ConsumerStatefulWidget {
  /// お気に入りフォルダカードを作成する
  const FolderCard({
    super.key,
    required this.folder,
    required this.onTap,
    required this.onDelete,
  });

  /// 表示対象のお気に入りフォルダ
  final FavoriteFolder folder;

  /// タップ時のコールバック
  final VoidCallback onTap;

  /// 削除時のコールバック
  final VoidCallback onDelete;

  @override
  ConsumerState<FolderCard> createState() => _FolderCardState();
}

class _FolderCardState extends ConsumerState<FolderCard> {
  /// デフォルトの elevation
  static const double _defaultElevation = 1.0;

  /// ホバー/フォーカス時の elevation
  static const double _hoveredElevation = 3.0;

  /// カードの角丸半径
  static const double _borderRadius = 8.0;

  /// フォルダアイコンのサイズ
  static const double _folderIconSize = 16.0;

  /// ホバー状態
  bool _isHovered = false;

  /// フォーカス状態
  bool _isFocused = false;

  /// 現在の elevation を返す
  double get _currentElevation =>
      (_isHovered || _isFocused) ? _hoveredElevation : _defaultElevation;

  /// コンテキストメニューを表示する
  ///
  /// 指定された位置に「削除」オプションを含むポップアップメニューを表示する。
  /// ユーザーが「削除」を選択した場合、[widget.onDelete] コールバックを呼び出す。
  Future<void> _showContextMenu(BuildContext context, Offset position) async {
    final renderBox =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final overlaySize = renderBox.size;

    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        overlaySize.width - position.dx,
        overlaySize.height - position.dy,
      ),
      items: [
        const PopupMenuItem<String>(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete),
            title: Text('削除'),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );

    if (result == 'delete') {
      widget.onDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Focus(
        onFocusChange: (focused) => setState(() => _isFocused = focused),
        child: GestureDetector(
          // デスクトップ: 右クリックでコンテキストメニュー表示
          onSecondaryTapUp: (details) {
            _showContextMenu(context, details.globalPosition);
          },
          // モバイル/デスクトップ: 長押しでコンテキストメニュー表示
          onLongPressStart: (details) {
            _showContextMenu(context, details.globalPosition);
          },
          child: Card(
            elevation: _currentElevation,
            color: colorScheme.surface,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
            child: InkWell(
              onTap: widget.onTap,
              child: Column(
                children: [
                  // カード上部 70%: サムネイルオーバーレイ（2×2 グリッド）
                  Expanded(
                    flex: 7,
                    child: ThumbnailOverlay(folder: widget.folder),
                  ),
                  // カード下部 30%: フォルダアイコン + フォルダ名
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder,
                            size: _folderIconSize,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              widget.folder.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
