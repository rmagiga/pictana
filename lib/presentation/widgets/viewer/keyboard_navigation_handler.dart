/// キーボードナビゲーションおよび各種ショートカット処理ウィジェット (Req 2)
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/value_objects/navigation_bounds.dart';

/// キーボードによる画像ナビゲーションとショートカット操作を処理するウィジェット
///
/// 対応ショートカット:
/// - 矢印キー (Left/Right) / PageUp/PageDown / h, j, k, l : 前後移動
/// - gg : 最初の画像へジャンプ
/// - G : 最後の画像へジャンプ
/// - [数字]g または [数字]G または [数字] + Enter : 指定した番号の画像へジャンプ
/// - f または * : お気に入り（フォルダ）切り替え
/// - + / = / i : ズームイン
/// - - / o : ズームアウト
/// - r : ズームリセット
class KeyboardNavigationHandler extends StatefulWidget {
  /// KeyboardNavigationHandler を作成する
  const KeyboardNavigationHandler({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.totalCount,
    required this.isZoomed,
    required this.onNavigate,
    this.onToggleFavorite,
    this.onZoomIn,
    this.onZoomOut,
    this.onZoomReset,
  });

  /// 子ウィジェット
  final Widget child;

  /// 現在表示中の画像インデックス
  final int currentIndex;

  /// 画像リストの総数
  final int totalCount;

  /// ズーム状態かどうか
  final bool isZoomed;

  /// ナビゲーション先インデックスを通知するコールバック
  final ValueChanged<int> onNavigate;

  /// お気に入り切り替えのコールバック
  final VoidCallback? onToggleFavorite;

  /// ズームインのコールバック
  final VoidCallback? onZoomIn;

  /// ズームアウトのコールバック
  final VoidCallback? onZoomOut;

  /// ズームリセットのコールバック
  final VoidCallback? onZoomReset;

  @override
  State<KeyboardNavigationHandler> createState() =>
      _KeyboardNavigationHandlerState();
}

class _KeyboardNavigationHandlerState extends State<KeyboardNavigationHandler> {
  /// 入力キーのバッファ（数字または単独の 'g'）
  String _inputBuffer = '';

  /// 入力バッファを自動クリアするタイマー
  Timer? _bufferTimer;

  @override
  void dispose() {
    _bufferTimer?.cancel();
    super.dispose();
  }

  /// バッファをクリアする
  void _resetBuffer() {
    if (_inputBuffer.isNotEmpty) {
      setState(() {
        _inputBuffer = '';
      });
    }
    _bufferTimer?.cancel();
    _bufferTimer = null;
  }

  /// バッファ自動クリアタイマーを開始・更新する
  void _startBufferTimer() {
    _bufferTimer?.cancel();
    _bufferTimer = Timer(const Duration(seconds: 2), () {
      _resetBuffer();
    });
  }

  /// キーイベントを処理する
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    // KeyDown イベントのみ処理する（リピートも含む）
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final logicalKey = event.logicalKey;
    final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;

    // 1. お気に入り・ズーム等のショートカットキー（ズーム状態に関わらず動作）
    
    // お気に入りトグル: f または * (Shift+8)
    if (logicalKey == LogicalKeyboardKey.keyF ||
        logicalKey == LogicalKeyboardKey.asterisk ||
        (logicalKey == LogicalKeyboardKey.digit8 && isShiftPressed)) {
      widget.onToggleFavorite?.call();
      _resetBuffer();
      return KeyEventResult.handled;
    }

    // ズームイン: + / = / i
    if (logicalKey == LogicalKeyboardKey.numpadAdd ||
        logicalKey == LogicalKeyboardKey.equal ||
        (logicalKey == LogicalKeyboardKey.equal && isShiftPressed) ||
        logicalKey == LogicalKeyboardKey.keyI) {
      widget.onZoomIn?.call();
      _resetBuffer();
      return KeyEventResult.handled;
    }

    // ズームアウト: - / o
    if (logicalKey == LogicalKeyboardKey.numpadSubtract ||
        logicalKey == LogicalKeyboardKey.minus ||
        logicalKey == LogicalKeyboardKey.keyO) {
      widget.onZoomOut?.call();
      _resetBuffer();
      return KeyEventResult.handled;
    }

    // ズームリセット: r
    if (logicalKey == LogicalKeyboardKey.keyR) {
      widget.onZoomReset?.call();
      _resetBuffer();
      return KeyEventResult.handled;
    }

    // ズーム中はナビゲーション（ジャンプ・送り）キーは消費するが遷移しない
    if (widget.isZoomed) {
      final isNavKey = _isNavigationKey(logicalKey);
      if (isNavKey) {
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    // 2. Vim風の j/k 送り、および通常の矢印キー/PageUp/PageDown
    
    // 前の画像へ遷移するキー (ArrowLeft / PageUp / h / k)
    final isPreviousKey =
        logicalKey == LogicalKeyboardKey.arrowLeft ||
        logicalKey == LogicalKeyboardKey.pageUp ||
        logicalKey == LogicalKeyboardKey.keyK ||
        logicalKey == LogicalKeyboardKey.keyH;

    // 次の画像へ遷移するキー (ArrowRight / PageDown / j / l)
    final isNextKey =
        logicalKey == LogicalKeyboardKey.arrowRight ||
        logicalKey == LogicalKeyboardKey.pageDown ||
        logicalKey == LogicalKeyboardKey.keyJ ||
        logicalKey == LogicalKeyboardKey.keyL;

    final (canGoPrevious, canGoNext) = navigationBounds(
      widget.currentIndex,
      widget.totalCount,
    );

    if (isPreviousKey) {
      if (canGoPrevious) {
        widget.onNavigate(widget.currentIndex - 1);
      }
      _resetBuffer();
      return KeyEventResult.handled;
    }

    if (isNextKey) {
      if (canGoNext) {
        widget.onNavigate(widget.currentIndex + 1);
      }
      _resetBuffer();
      return KeyEventResult.handled;
    }

    // 3. 数字入力およびVim風の gg / G / [数字]g / [数字]G ジャンプ
    
    // 数字キー (0-9)
    if (_isNumericKey(logicalKey)) {
      final digit = _getDigit(logicalKey);
      setState(() {
        _inputBuffer += digit;
      });
      _startBufferTimer();
      return KeyEventResult.handled;
    }

    // 'g' キー
    if (logicalKey == LogicalKeyboardKey.keyG && !isShiftPressed) {
      if (_inputBuffer == 'g') {
        // 'gg' が押された -> 最初の画像へジャンプ
        widget.onNavigate(0);
        _resetBuffer();
        return KeyEventResult.handled;
      } else if (_inputBuffer.isNotEmpty && _isDigitsOnly(_inputBuffer)) {
        // '[数字]g' が押された -> その番号の画像へジャンプ
        _jumpToBufferNumber();
        return KeyEventResult.handled;
      } else {
        // 初めて 'g' が押された
        setState(() {
          _inputBuffer = 'g';
        });
        _startBufferTimer();
        return KeyEventResult.handled;
      }
    }

    // 'G' キー (Shift + g)
    if (logicalKey == LogicalKeyboardKey.keyG && isShiftPressed) {
      if (_inputBuffer.isEmpty) {
        // 'G' のみ -> 最後の画像へジャンプ
        widget.onNavigate(widget.totalCount - 1);
        _resetBuffer();
        return KeyEventResult.handled;
      } else if (_isDigitsOnly(_inputBuffer)) {
        // '[数字]G' -> その番号の画像へジャンプ
        _jumpToBufferNumber();
        return KeyEventResult.handled;
      }
    }

    // Enter キーによるジャンプ確定
    if (logicalKey == LogicalKeyboardKey.enter ||
        logicalKey == LogicalKeyboardKey.numpadEnter) {
      if (_inputBuffer.isNotEmpty && _isDigitsOnly(_inputBuffer)) {
        _jumpToBufferNumber();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  /// ナビゲーション操作に関連するキーかどうかを判定
  bool _isNavigationKey(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.pageUp ||
        key == LogicalKeyboardKey.pageDown ||
        key == LogicalKeyboardKey.keyJ ||
        key == LogicalKeyboardKey.keyK ||
        key == LogicalKeyboardKey.keyH ||
        key == LogicalKeyboardKey.keyL ||
        key == LogicalKeyboardKey.keyG ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        _isNumericKey(key);
  }

  /// テンキーを含む数字キーかどうかを判定
  bool _isNumericKey(LogicalKeyboardKey key) {
    return (key.keyId >= LogicalKeyboardKey.digit0.keyId &&
            key.keyId <= LogicalKeyboardKey.digit9.keyId) ||
        (key.keyId >= LogicalKeyboardKey.numpad0.keyId &&
            key.keyId <= LogicalKeyboardKey.numpad9.keyId);
  }

  /// 数字キーから文字を取得
  String _getDigit(LogicalKeyboardKey key) {
    if (key.keyId >= LogicalKeyboardKey.digit0.keyId &&
        key.keyId <= LogicalKeyboardKey.digit9.keyId) {
      return (key.keyId - LogicalKeyboardKey.digit0.keyId).toString();
    }
    return (key.keyId - LogicalKeyboardKey.numpad0.keyId).toString();
  }

  /// 数字のみの文字列かどうかを判定
  bool _isDigitsOnly(String str) {
    return RegExp(r'^\d+$').hasMatch(str);
  }

  /// バッファに溜まった数字の画像へジャンプ（1-based）
  void _jumpToBufferNumber() {
    final pageNum = int.tryParse(_inputBuffer);
    if (pageNum != null && pageNum > 0 && pageNum <= widget.totalCount) {
      widget.onNavigate(pageNum - 1);
    }
    _resetBuffer();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: widget.child,
    );
  }
}
