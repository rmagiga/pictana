/// Ctrl+マウスホイールズーム処理ウィジェット (Req 3)
///
/// Windows 環境で Ctrl キーを押しながらマウスホイールを操作した際に
/// 画像のズームイン/ズームアウトを行う。
/// Ctrl キーが押されていない場合はスクロールイベントを無視する。
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/value_objects/zoom_calculation.dart';

/// Ctrl+マウスホイールによるズーム操作を処理するウィジェット
///
/// [Listener] で [PointerScrollEvent] を監視し、Ctrl キーが押されている場合のみ
/// ズーム処理を実行する。焦点はマウスカーソル位置を使用する。
///
/// 使用する純粋関数:
/// - [clampZoomIn]: ズームイン時の倍率計算
/// - [clampZoomOut]: ズームアウト時の倍率計算
class CtrlWheelZoomHandler extends StatelessWidget {
  /// CtrlWheelZoomHandler を作成する
  const CtrlWheelZoomHandler({
    super.key,
    required this.child,
    required this.currentScale,
    required this.onScaleChanged,
    required this.onFocalPoint,
  });

  /// 子ウィジェット
  final Widget child;

  /// 現在のズーム倍率
  final double currentScale;

  /// ズーム倍率が変更されたときのコールバック
  final ValueChanged<double> onScaleChanged;

  /// ズームの焦点位置（マウスカーソル位置）が決定されたときのコールバック
  final ValueChanged<Offset> onFocalPoint;

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
  /// Ctrl キーが押されている場合のみズーム操作を実行する。
  /// スクロール上方向（dy < 0）でズームイン、下方向（dy > 0）でズームアウト。
  void _handleScrollEvent(PointerScrollEvent event) {
    // Ctrl キーが押されていない場合は何もしない (Req 3.4)
    if (!HardwareKeyboard.instance.isControlPressed) {
      return;
    }

    // 焦点位置をマウスカーソル位置に設定
    onFocalPoint(event.localPosition);

    // スクロール方向に応じてズームイン/ズームアウト
    final double newScale;
    if (event.scrollDelta.dy < 0) {
      // 上方向スクロール → ズームイン (Req 3.1)
      newScale = clampZoomIn(currentScale);
    } else {
      // 下方向スクロール → ズームアウト (Req 3.2)
      newScale = clampZoomOut(currentScale);
    }

    // 倍率が変化した場合のみコールバックを呼ぶ
    if (newScale != currentScale) {
      onScaleChanged(newScale);
    }
  }
}
