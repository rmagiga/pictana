/// マウスホイール高速スクロール処理ウィジェット (Req 13)
///
/// Windows 環境でマウスホイール操作時にデフォルトの 3 倍のスクロール量を適用し、
/// 200ms のイージングアニメーションで滑らかにスクロールする。
/// Ctrl キーが押されている場合はスクロールを無効にする
/// （CtrlWheelZoomHandler がズームを処理するため）。
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// マウスホイール高速スクロールを処理するウィジェット (Windows 専用)
///
/// [Listener] で [PointerScrollEvent] を監視し、Ctrl キーが押されていない場合に
/// スクロール量をデフォルトの 3 倍に増幅して [ScrollController] でアニメーション付き
/// スクロールを実行する。
///
/// Ctrl キー押下中はイベントを無視し、他のハンドラー（ズーム等）に処理を委譲する。
///
/// **使用方法:**
/// 子ウィジェットの [Scrollable] には [NeverScrollableScrollPhysics] を設定し、
/// ポインタースクロールの処理をこのウィジェットに委譲すること。
/// タッチ/ドラッグによるスクロールは [AlwaysScrollableScrollPhysics] を親として
/// 設定することで引き続き有効にできる。
///
/// ```dart
/// FastScrollHandler(
///   scrollController: _scrollController,
///   child: GridView.builder(
///     controller: _scrollController,
///     physics: const _FastScrollPhysics(),
///     // ...
///   ),
/// )
/// ```
class FastScrollHandler extends StatelessWidget {
  /// FastScrollHandler を作成する
  const FastScrollHandler({
    super.key,
    required this.scrollController,
    required this.child,
    this.scrollMultiplier = 3.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeOut,
  });

  /// スクロール制御に使用する [ScrollController]
  final ScrollController scrollController;

  /// 子ウィジェット
  final Widget child;

  /// スクロール量の倍率（デフォルト: 3 倍）
  final double scrollMultiplier;

  /// スクロールアニメーションの持続時間（デフォルト: 200ms）
  final Duration animationDuration;

  /// スクロールアニメーションのイージングカーブ
  final Curve animationCurve;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          _handleScrollEvent(event);
        }
      },
      child: child,
    );
  }

  /// スクロールイベントを処理する
  ///
  /// Ctrl キーが押されている場合はスクロールを行わない (Req 13.4)。
  /// Ctrl キーが押されていない場合はスクロール量を [scrollMultiplier] 倍に増幅し、
  /// [animationDuration] のイージングアニメーションで滑らかにスクロールする。
  void _handleScrollEvent(PointerScrollEvent event) {
    // Ctrl キーが押されている場合はスクロール無効 (Req 13.4)
    // CtrlWheelZoomHandler がズームを処理する
    if (HardwareKeyboard.instance.isControlPressed) {
      return;
    }

    // ScrollController が有効でない場合は何もしない
    if (!scrollController.hasClients) {
      return;
    }

    // スクロール量を 3 倍に増幅 (Req 13.1)
    final double scrollDelta = event.scrollDelta.dy * scrollMultiplier;

    // 現在位置から増幅されたスクロール量を加算し、有効範囲にクランプ
    final double currentOffset = scrollController.offset;
    final double maxOffset = scrollController.position.maxScrollExtent;
    final double minOffset = scrollController.position.minScrollExtent;
    final double targetOffset = (currentOffset + scrollDelta).clamp(
      minOffset,
      maxOffset,
    );

    // 200ms イージングアニメーションでスクロール (Req 13.2)
    scrollController.animateTo(
      targetOffset,
      duration: animationDuration,
      curve: animationCurve,
    );
  }
}

/// [FastScrollHandler] と組み合わせて使用するスクロール物理演算
///
/// マウスホイール（ポインターシグナル）によるスクロールを無効化し、
/// タッチ/ドラッグによるスクロールのみを許可する。
/// [FastScrollHandler] がポインタースクロールを独自に処理するため、
/// 子ウィジェットのデフォルトスクロール動作と競合しない。
///
/// [shouldAcceptUserOffset] を常に false にすることで、[Scrollable] が
/// ポインタースクロールイベントを [GestureBinding.instance.pointerSignalResolver]
/// に登録しないようにする。ドラッグによるスクロールには影響しない。
class FastScrollPhysics extends ScrollPhysics {
  /// FastScrollPhysics を作成する
  const FastScrollPhysics({super.parent});

  @override
  FastScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return FastScrollPhysics(parent: buildParent(ancestor));
  }

  /// ポインターシグナルによるスクロールを無効化する。
  ///
  /// [Scrollable._receivedPointerSignal] はこの値が false の場合、
  /// ポインタースクロールイベントを処理しない。
  /// ドラッグによるスクロールには影響しない。
  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) => false;
}
