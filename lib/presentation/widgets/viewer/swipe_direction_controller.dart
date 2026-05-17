/// スワイプ方向制御ウィジェット (Req 4, 7)
///
/// [SwipeDirection] 設定に応じて PageView の scrollDirection を切り替え、
/// ズーム中はスワイプによる画像遷移を無効化する。
/// `both` モードでは縦横両方向のスワイプを合成して処理する。
library;

import 'package:flutter/material.dart';

import '../../../domain/value_objects/swipe_direction.dart';

/// スワイプ方向制御ウィジェット
///
/// Android 向けに [SwipeDirection] 設定に基づいてページ遷移方向を制御する。
/// - [SwipeDirection.horizontal]: 左右スワイプのみ（デフォルト）
/// - [SwipeDirection.vertical]: 上下スワイプのみ
/// - [SwipeDirection.both]: 縦横両方向のスワイプで遷移可能
///
/// ズーム中（[isZoomed] == true）はスワイプによる画像遷移を無効化し、
/// パン操作のみを受け付ける。
class SwipeDirectionController extends StatefulWidget {
  /// SwipeDirectionController を作成する
  const SwipeDirectionController({
    super.key,
    required this.direction,
    required this.isZoomed,
    required this.pageController,
    required this.itemCount,
    required this.itemBuilder,
    this.onPageChanged,
  });

  /// 現在のスワイプ方向設定
  final SwipeDirection direction;

  /// ズーム状態かどうか（true の場合スワイプ無効）
  final bool isZoomed;

  /// PageView のコントローラー
  final PageController pageController;

  /// ページ数
  final int itemCount;

  /// ページのビルダー
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// ページ変更時のコールバック
  final ValueChanged<int>? onPageChanged;

  @override
  State<SwipeDirectionController> createState() =>
      _SwipeDirectionControllerState();
}

class _SwipeDirectionControllerState extends State<SwipeDirectionController> {
  /// both モードで縦方向スワイプを検知するための開始位置
  Offset? _dragStartPosition;

  /// both モードでのドラッグ方向が確定したかどうか
  bool _isDragDirectionDecided = false;

  /// both モードで縦方向ドラッグが検知されたかどうか
  bool _isVerticalDrag = false;

  /// ページ遷移アニメーション中かどうか（連続スワイプ制御用）
  bool _isAnimating = false;

  /// ドラッグ方向判定のしきい値（ピクセル）
  /// この距離以上移動したら方向を確定する
  static const double _directionThreshold = 10.0;

  /// ページ遷移アニメーションの duration
  static const Duration _pageDuration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    // ズーム中はスワイプ無効（NeverScrollableScrollPhysics）
    if (widget.isZoomed) {
      return _buildPageView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
      );
    }

    return switch (widget.direction) {
      SwipeDirection.horizontal => _buildPageView(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
      ),
      SwipeDirection.vertical => _buildPageView(
        scrollDirection: Axis.vertical,
        physics: const ClampingScrollPhysics(),
      ),
      SwipeDirection.both => _buildBothDirectionView(),
    };
  }

  /// 単一方向の PageView を構築する
  Widget _buildPageView({
    required Axis scrollDirection,
    required ScrollPhysics physics,
  }) {
    return PageView.builder(
      controller: widget.pageController,
      scrollDirection: scrollDirection,
      physics: physics,
      itemCount: widget.itemCount,
      onPageChanged: widget.onPageChanged,
      itemBuilder: widget.itemBuilder,
    );
  }

  /// both モード: 縦横両方向のスワイプを処理する
  ///
  /// 横方向は PageView のデフォルト動作で処理し、
  /// 縦方向は GestureDetector で検知してページ遷移を実行する。
  Widget _buildBothDirectionView() {
    return GestureDetector(
      onVerticalDragStart: _onVerticalDragStart,
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      child: _buildPageView(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
      ),
    );
  }

  /// 縦方向ドラッグ開始
  void _onVerticalDragStart(DragStartDetails details) {
    _dragStartPosition = details.globalPosition;
    _isDragDirectionDecided = false;
    _isVerticalDrag = false;
  }

  /// 縦方向ドラッグ更新
  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (_dragStartPosition == null) return;

    if (!_isDragDirectionDecided) {
      final delta = details.globalPosition - _dragStartPosition!;
      // 十分な移動量があれば方向を確定
      if (delta.distance > _directionThreshold) {
        _isDragDirectionDecided = true;
        // 縦方向の移動量が横方向より大きければ縦ドラッグと判定
        _isVerticalDrag = delta.dy.abs() > delta.dx.abs();
      }
    }
  }

  /// 縦方向ドラッグ終了
  void _onVerticalDragEnd(DragEndDetails details) {
    if (_dragStartPosition == null || !_isVerticalDrag) {
      _resetDragState();
      return;
    }

    // アニメーション中でも次のページ遷移を受け付ける（連続スワイプ対応）
    final velocity = details.primaryVelocity ?? 0;
    final currentPage = widget.pageController.page?.round() ?? 0;

    // 上スワイプ（負の速度）= 次の画像
    if (velocity < -200) {
      _animateToPage(currentPage + 1);
    }
    // 下スワイプ（正の速度）= 前の画像
    else if (velocity > 200) {
      _animateToPage(currentPage - 1);
    }

    _resetDragState();
  }

  /// ページ遷移アニメーションを実行する（連続スワイプ対応）
  ///
  /// 前のアニメーションが完了していなくても、即座に次のページへ遷移する。
  /// [PageController.jumpToPage] で現在位置を確定してから
  /// [PageController.animateToPage] で次のページへ遷移する。
  void _animateToPage(int targetPage) {
    if (targetPage < 0 || targetPage >= widget.itemCount) return;

    // 前のアニメーション中なら現在位置を即座に確定する
    if (_isAnimating) {
      final snappedPage = widget.pageController.page?.round() ?? targetPage;
      widget.pageController.jumpToPage(snappedPage);
    }

    _isAnimating = true;
    widget.pageController
        .animateToPage(
          targetPage,
          duration: _pageDuration,
          curve: Curves.easeOut,
        )
        .then((_) {
          _isAnimating = false;
        });
  }

  /// ドラッグ状態をリセットする
  void _resetDragState() {
    _dragStartPosition = null;
    _isDragDirectionDecided = false;
    _isVerticalDrag = false;
  }
}
