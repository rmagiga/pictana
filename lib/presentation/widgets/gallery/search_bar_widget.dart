/// ギャラリー検索バーウィジェット (Req 11.1, 11.4, 11.5, 11.6)
///
/// 検索アイコンタップで展開し、テキスト入力で検索クエリを通知する。
/// 「×」ボタンで検索バーを閉じてフィルターを解除する。
/// 折りたたみ時は検索アイコンボタンのみ表示する。
library;

import 'package:flutter/material.dart';

/// ギャラリー検索バーウィジェット
///
/// 折りたたみ状態では検索アイコンボタンのみ表示し、
/// 展開状態では TextField と「×」クリアボタンを表示する。
///
/// - [isExpanded]: 検索バーの展開状態
/// - [onToggle]: 検索バーの展開/折りたたみを切り替えるコールバック
/// - [onQueryChanged]: テキスト入力時に検索クエリを通知するコールバック
/// - [onClear]: 「×」ボタンタップ時のコールバック（検索バーを閉じてフィルター解除）
class SearchBarWidget extends StatefulWidget {
  /// 検索バーウィジェットを作成する
  const SearchBarWidget({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    required this.onQueryChanged,
    required this.onClear,
  });

  /// 検索バーが展開されているかどうか
  final bool isExpanded;

  /// 検索バーの展開/折りたたみを切り替えるコールバック
  final VoidCallback onToggle;

  /// テキスト入力時に検索クエリを通知するコールバック
  final ValueChanged<String> onQueryChanged;

  /// 「×」ボタンタップ時のコールバック（検索バーを閉じてフィルター解除）
  final VoidCallback onClear;

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  /// テキスト入力コントローラー
  final _textController = TextEditingController();

  /// テキストフィールドのフォーカスノード
  final _focusNode = FocusNode();

  @override
  void didUpdateWidget(covariant SearchBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 展開状態に変わったらフォーカスを当てる
    if (widget.isExpanded && !oldWidget.isExpanded) {
      // フレーム描画後にフォーカスを当てる
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }
    // 折りたたみ状態に変わったらテキストをクリア
    if (!widget.isExpanded && oldWidget.isExpanded) {
      _textController.clear();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// 「×」ボタンタップ時の処理
  void _handleClear() {
    _textController.clear();
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    // 折りたたみ状態: 検索アイコンボタンのみ表示
    if (!widget.isExpanded) {
      return IconButton(
        icon: const Icon(Icons.search),
        tooltip: '検索',
        onPressed: widget.onToggle,
      );
    }

    // 展開状態: TextField + クリアボタン
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        onChanged: widget.onQueryChanged,
        decoration: InputDecoration(
          hintText: 'ファイル名で検索...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close),
            tooltip: '検索を閉じる',
            onPressed: _handleClear,
          ),
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
        ),
      ),
    );
  }
}
