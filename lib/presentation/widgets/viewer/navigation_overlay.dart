/// Windows 矢印ボタンナビゲーションオーバーレイ (Req 1)
///
/// マウスホバーで左右の矢印ボタンをフェードイン/アウト表示する。
/// [navigationBounds] で前後遷移の可否を判定し、
/// アニメーション中はタップイベントを無視する。
library;

import 'package:flutter/material.dart';

import '../../../domain/value_objects/navigation_bounds.dart';

/// Windows 矢印ボタンオーバーレイウィジェット
///
/// 画像ビューア上にマウスホバーで表示される前後ナビゲーションボタンを提供する。
/// - マウスホバーで 200ms フェードイン/アウト
/// - 左端 16dp / 右端 16dp、垂直中央、最小 48x48dp タップ領域
/// - [navigationBounds] で表示/非表示を制御
/// - アニメーション中はタップ無視
class NavigationOverlay extends StatefulWidget {
  /// ナビゲーションオーバーレイを作成する
  const NavigationOverlay({
    super.key,
    required this.currentIndex,
    required this.totalCount,
    required this.isAnimating,
    required this.onPrevious,
    required this.onNext,
    this.isRightToLeft = false,
  });

  /// 現在表示中の画像インデックス
  final int currentIndex;

  /// 画像リストの総数
  final int totalCount;

  /// ページ遷移アニメーション中かどうか
  final bool isAnimating;

  /// 前の画像に遷移するコールバック
  final VoidCallback onPrevious;

  /// 次の画像に遷移するコールバック
  final VoidCallback onNext;

  /// 右開き (RTL) かどうか
  final bool isRightToLeft;

  @override
  State<NavigationOverlay> createState() => _NavigationOverlayState();
}

class _NavigationOverlayState extends State<NavigationOverlay> {
  /// マウスがオーバーレイ領域内にあるかどうか
  bool _isHovered = false;

  /// フェードアニメーションの持続時間
  static const _fadeDuration = Duration(milliseconds: 200);

  /// ボタンの端からの距離
  static const double _edgeInset = 16.0;

  /// ボタンの最小タップ領域サイズ
  static const double _minTapSize = 48.0;

  @override
  Widget build(BuildContext context) {
    final (canGoPrevious, canGoNext) = navigationBounds(
      widget.currentIndex,
      widget.totalCount,
    );

    // RTL（右開き）の場合、左右の矢印ボタンの表示条件とアクション、ツールチップを反転させる
    final showLeft = widget.isRightToLeft ? canGoNext : canGoPrevious;
    final showRight = widget.isRightToLeft ? canGoPrevious : canGoNext;

    final leftAction = widget.isRightToLeft ? widget.onNext : widget.onPrevious;
    final rightAction = widget.isRightToLeft ? widget.onPrevious : widget.onNext;

    final leftTooltip = widget.isRightToLeft ? '次の画像' : '前の画像';
    final rightTooltip = widget.isRightToLeft ? '前の画像' : '次の画像';

    return MouseRegion(
      opaque: false,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Stack(
        children: [
          // 左矢印ボタン
          if (showLeft)
            Positioned(
              left: _edgeInset,
              top: 0,
              bottom: 0,
              child: Center(
                child: _NavigationButton(
                  icon: Icons.chevron_left,
                  tooltip: leftTooltip,
                  isVisible: _isHovered,
                  isAnimating: widget.isAnimating,
                  onPressed: leftAction,
                ),
              ),
            ),

          // 右矢印ボタン
          if (showRight)
            Positioned(
              right: _edgeInset,
              top: 0,
              bottom: 0,
              child: Center(
                child: _NavigationButton(
                  icon: Icons.chevron_right,
                  tooltip: rightTooltip,
                  isVisible: _isHovered,
                  isAnimating: widget.isAnimating,
                  onPressed: rightAction,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 個別のナビゲーションボタン
///
/// フェードイン/アウトアニメーション付きの矢印ボタン。
/// アニメーション中はタップを無視する。
class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.icon,
    required this.tooltip,
    required this.isVisible,
    required this.isAnimating,
    required this.onPressed,
  });

  /// ボタンに表示するアイコン
  final IconData icon;

  /// ツールチップテキスト
  final String tooltip;

  /// ボタンが表示状態かどうか（ホバー中）
  final bool isVisible;

  /// ページ遷移アニメーション中かどうか
  final bool isAnimating;

  /// ボタン押下時のコールバック
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      // アニメーション中またはフェードアウト中はタップを無視
      ignoring: isAnimating || !isVisible,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: _NavigationOverlayState._fadeDuration,
        child: SizedBox(
          width: _NavigationOverlayState._minTapSize,
          height: _NavigationOverlayState._minTapSize,
          child: Material(
            color: Colors.black54,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: Center(child: Icon(icon, color: Colors.white, size: 32)),
            ),
          ),
        ),
      ),
    );
  }
}
