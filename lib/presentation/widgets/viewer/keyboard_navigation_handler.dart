/// キーボードナビゲーション処理ウィジェット (Req 2)
///
/// Windows 環境でキーボードの矢印キーおよび PageUp/PageDown キーによる
/// 画像ナビゲーションを処理する。
/// ズーム中はキーイベントを消費するが遷移は行わない。
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/value_objects/navigation_bounds.dart';

/// キーボードによる画像ナビゲーションを処理するウィジェット
///
/// [Focus] + [KeyboardListener] で ArrowLeft/Right, PageUp/Down を捕捉し、
/// [onNavigate] コールバックで遷移先インデックスを通知する。
///
/// - ズーム中 ([isZoomed] == true): キーイベントを消費するが遷移しない (Req 2.7)
/// - 自動フォーカス: [autofocus] = true で画面表示時にフォーカスを取得 (Req 2.8)
/// - 境界条件: [navigationBounds] で前後遷移の可否を判定 (Req 2.5, 2.6)
class KeyboardNavigationHandler extends StatelessWidget {
  /// KeyboardNavigationHandler を作成する
  const KeyboardNavigationHandler({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.totalCount,
    required this.isZoomed,
    required this.onNavigate,
  });

  /// 子ウィジェット
  final Widget child;

  /// 現在表示中の画像インデックス
  final int currentIndex;

  /// 画像リストの総数
  final int totalCount;

  /// ズーム状態かどうか（スケール > 1.0）
  final bool isZoomed;

  /// ナビゲーション先インデックスを通知するコールバック
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Focus(autofocus: true, onKeyEvent: _handleKeyEvent, child: child);
  }

  /// キーイベントを処理する
  ///
  /// 対応キー:
  /// - ArrowLeft / PageUp: 前の画像へ遷移 (Req 2.1, 2.3)
  /// - ArrowRight / PageDown: 次の画像へ遷移 (Req 2.2, 2.4)
  ///
  /// ズーム中はキーイベントを消費するが遷移しない (Req 2.7)。
  /// 境界条件ではキーイベントを消費するが遷移しない (Req 2.5, 2.6)。
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    // KeyDown イベントのみ処理する（リピートも含む）
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final logicalKey = event.logicalKey;

    // 前の画像へ遷移するキー
    final isPreviousKey =
        logicalKey == LogicalKeyboardKey.arrowLeft ||
        logicalKey == LogicalKeyboardKey.pageUp;

    // 次の画像へ遷移するキー
    final isNextKey =
        logicalKey == LogicalKeyboardKey.arrowRight ||
        logicalKey == LogicalKeyboardKey.pageDown;

    // 対応キー以外は無視
    if (!isPreviousKey && !isNextKey) {
      return KeyEventResult.ignored;
    }

    // ズーム中はキーイベントを消費するが遷移しない (Req 2.7)
    if (isZoomed) {
      return KeyEventResult.handled;
    }

    // ナビゲーション境界を判定
    final (canGoPrevious, canGoNext) = navigationBounds(
      currentIndex,
      totalCount,
    );

    // 前の画像へ遷移 (Req 2.1, 2.3)
    if (isPreviousKey) {
      if (canGoPrevious) {
        onNavigate(currentIndex - 1);
      }
      // 境界でもキーイベントを消費する (Req 2.5)
      return KeyEventResult.handled;
    }

    // 次の画像へ遷移 (Req 2.2, 2.4)
    if (isNextKey) {
      if (canGoNext) {
        onNavigate(currentIndex + 1);
      }
      // 境界でもキーイベントを消費する (Req 2.6)
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }
}
