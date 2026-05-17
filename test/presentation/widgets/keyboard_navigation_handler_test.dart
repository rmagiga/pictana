/// KeyboardNavigationHandler ウィジェットテスト
///
/// キーボードナビゲーションの動作を検証する。
/// - ArrowLeft / PageUp で前の画像へ遷移
/// - ArrowRight / PageDown で次の画像へ遷移
/// - ズーム中はキーイベントを消費するが遷移しない
/// - 境界条件ではキーイベントを消費するが遷移しない
/// - autofocus: true でフォーカスを自動取得
///
/// Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pictana/presentation/widgets/viewer/keyboard_navigation_handler.dart';

// ---------------------------------------------------------------------------
// テスト用ヘルパー
// ---------------------------------------------------------------------------

/// テスト用ウィジェットツリーを構築する
Widget _createTestWidget({
  int currentIndex = 2,
  int totalCount = 5,
  bool isZoomed = false,
  ValueChanged<int>? onNavigate,
}) {
  return MaterialApp(
    home: Scaffold(
      body: KeyboardNavigationHandler(
        currentIndex: currentIndex,
        totalCount: totalCount,
        isZoomed: isZoomed,
        onNavigate: onNavigate ?? (_) {},
        child: const SizedBox(width: 800, height: 600),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// テスト本体
// ---------------------------------------------------------------------------

void main() {
  group('KeyboardNavigationHandler - 前の画像へ遷移', () {
    testWidgets('ArrowLeft で前の画像へ遷移する (Req 2.1)', (tester) async {
      int? navigatedIndex;

      await tester.pumpWidget(
        _createTestWidget(
          currentIndex: 2,
          totalCount: 5,
          onNavigate: (index) => navigatedIndex = index,
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();

      expect(navigatedIndex, 1);
    });

    testWidgets('PageUp で前の画像へ遷移する (Req 2.3)', (tester) async {
      int? navigatedIndex;

      await tester.pumpWidget(
        _createTestWidget(
          currentIndex: 3,
          totalCount: 5,
          onNavigate: (index) => navigatedIndex = index,
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await tester.pump();

      expect(navigatedIndex, 2);
    });
  });

  group('KeyboardNavigationHandler - 次の画像へ遷移', () {
    testWidgets('ArrowRight で次の画像へ遷移する (Req 2.2)', (tester) async {
      int? navigatedIndex;

      await tester.pumpWidget(
        _createTestWidget(
          currentIndex: 2,
          totalCount: 5,
          onNavigate: (index) => navigatedIndex = index,
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      expect(navigatedIndex, 3);
    });

    testWidgets('PageDown で次の画像へ遷移する (Req 2.4)', (tester) async {
      int? navigatedIndex;

      await tester.pumpWidget(
        _createTestWidget(
          currentIndex: 1,
          totalCount: 5,
          onNavigate: (index) => navigatedIndex = index,
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.pump();

      expect(navigatedIndex, 2);
    });
  });

  group('KeyboardNavigationHandler - 境界条件', () {
    testWidgets('先頭で ArrowLeft を押しても遷移しない (Req 2.5)', (tester) async {
      int? navigatedIndex;

      await tester.pumpWidget(
        _createTestWidget(
          currentIndex: 0,
          totalCount: 5,
          onNavigate: (index) => navigatedIndex = index,
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();

      expect(navigatedIndex, isNull);
    });

    testWidgets('先頭で PageUp を押しても遷移しない (Req 2.5)', (tester) async {
      int? navigatedIndex;

      await tester.pumpWidget(
        _createTestWidget(
          currentIndex: 0,
          totalCount: 5,
          onNavigate: (index) => navigatedIndex = index,
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await tester.pump();

      expect(navigatedIndex, isNull);
    });

    testWidgets('末尾で ArrowRight を押しても遷移しない (Req 2.6)', (tester) async {
      int? navigatedIndex;

      await tester.pumpWidget(
        _createTestWidget(
          currentIndex: 4,
          totalCount: 5,
          onNavigate: (index) => navigatedIndex = index,
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      expect(navigatedIndex, isNull);
    });

    testWidgets('末尾で PageDown を押しても遷移しない (Req 2.6)', (tester) async {
      int? navigatedIndex;

      await tester.pumpWidget(
        _createTestWidget(
          currentIndex: 4,
          totalCount: 5,
          onNavigate: (index) => navigatedIndex = index,
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.pump();

      expect(navigatedIndex, isNull);
    });

    testWidgets('画像1枚のみでキーを押しても遷移しない', (tester) async {
      int? navigatedIndex;

      await tester.pumpWidget(
        _createTestWidget(
          currentIndex: 0,
          totalCount: 1,
          onNavigate: (index) => navigatedIndex = index,
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      expect(navigatedIndex, isNull);
    });
  });

  group('KeyboardNavigationHandler - ズーム中の動作', () {
    testWidgets('ズーム中は ArrowLeft で遷移しない (Req 2.7)', (tester) async {
      int? navigatedIndex;

      await tester.pumpWidget(
        _createTestWidget(
          currentIndex: 2,
          totalCount: 5,
          isZoomed: true,
          onNavigate: (index) => navigatedIndex = index,
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();

      expect(navigatedIndex, isNull);
    });

    testWidgets('ズーム中は ArrowRight で遷移しない (Req 2.7)', (tester) async {
      int? navigatedIndex;

      await tester.pumpWidget(
        _createTestWidget(
          currentIndex: 2,
          totalCount: 5,
          isZoomed: true,
          onNavigate: (index) => navigatedIndex = index,
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      expect(navigatedIndex, isNull);
    });

    testWidgets('ズーム中は PageUp/PageDown で遷移しない (Req 2.7)', (tester) async {
      int? navigatedIndex;

      await tester.pumpWidget(
        _createTestWidget(
          currentIndex: 2,
          totalCount: 5,
          isZoomed: true,
          onNavigate: (index) => navigatedIndex = index,
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.pump();

      expect(navigatedIndex, isNull);
    });
  });

  group('KeyboardNavigationHandler - autofocus', () {
    testWidgets('画面表示時にフォーカスを自動取得する (Req 2.8)', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();

      // KeyboardNavigationHandler の直下の Focus ウィジェットが autofocus: true
      final handlerFinder = find.byType(KeyboardNavigationHandler);
      expect(handlerFinder, findsOneWidget);

      // KeyboardNavigationHandler の子孫に autofocus な Focus がある
      final focusFinder = find.descendant(
        of: handlerFinder,
        matching: find.byWidgetPredicate(
          (widget) => widget is Focus && widget.autofocus == true,
        ),
      );
      expect(focusFinder, findsOneWidget);
    });

    testWidgets('フォーカスがある状態でキー入力を受け付ける (Req 2.8)', (tester) async {
      int? navigatedIndex;

      await tester.pumpWidget(
        _createTestWidget(
          currentIndex: 2,
          totalCount: 5,
          onNavigate: (index) => navigatedIndex = index,
        ),
      );
      await tester.pumpAndSettle();

      // タップなしでキー入力が受け付けられる
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();

      expect(navigatedIndex, 3);
    });
  });

  group('KeyboardNavigationHandler - 無関係なキー', () {
    testWidgets('対応キー以外は無視される', (tester) async {
      int? navigatedIndex;

      await tester.pumpWidget(
        _createTestWidget(
          currentIndex: 2,
          totalCount: 5,
          onNavigate: (index) => navigatedIndex = index,
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(navigatedIndex, isNull);
    });
  });
}
