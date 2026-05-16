/// SearchBarWidget ウィジェットテスト
///
/// ギャラリー検索バーの UI 動作を検証する。
/// - 折りたたみ状態: 検索アイコンボタンのみ表示
/// - 展開状態: TextField + 「×」クリアボタン表示
/// - テキスト入力で onQueryChanged コールバック呼び出し
/// - 「×」ボタンで onClear コールバック呼び出し
///
/// Requirements: 11.1, 11.4, 11.5, 11.6
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optrig/presentation/widgets/gallery/search_bar_widget.dart';

// ---------------------------------------------------------------------------
// テスト用ヘルパー
// ---------------------------------------------------------------------------

/// テスト用ウィジェットツリーを構築する
Widget _createTestWidget({
  bool isExpanded = false,
  VoidCallback? onToggle,
  ValueChanged<String>? onQueryChanged,
  VoidCallback? onClear,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SearchBarWidget(
        isExpanded: isExpanded,
        onToggle: onToggle ?? () {},
        onQueryChanged: onQueryChanged ?? (_) {},
        onClear: onClear ?? () {},
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// テスト本体
// ---------------------------------------------------------------------------

void main() {
  group('SearchBarWidget - 折りたたみ状態', () {
    testWidgets('折りたたみ時は検索アイコンボタンのみ表示される (Req 11.1)', (tester) async {
      await tester.pumpWidget(_createTestWidget(isExpanded: false));
      await tester.pumpAndSettle();

      // 検索アイコンが表示される
      expect(find.byIcon(Icons.search), findsOneWidget);
      // TextField は表示されない
      expect(find.byType(TextField), findsNothing);
      // クリアボタンは表示されない
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('検索アイコンタップで onToggle が呼ばれる (Req 11.1)', (tester) async {
      var toggleCalled = false;

      await tester.pumpWidget(
        _createTestWidget(
          isExpanded: false,
          onToggle: () => toggleCalled = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      expect(toggleCalled, isTrue);
    });
  });

  group('SearchBarWidget - 展開状態', () {
    testWidgets('展開時は TextField とクリアボタンが表示される (Req 11.1)', (tester) async {
      await tester.pumpWidget(_createTestWidget(isExpanded: true));
      await tester.pumpAndSettle();

      // TextField が表示される
      expect(find.byType(TextField), findsOneWidget);
      // 検索アイコン（prefixIcon）が表示される
      expect(find.byIcon(Icons.search), findsOneWidget);
      // クリアボタン（×）が表示される
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('ヒントテキストが表示される', (tester) async {
      await tester.pumpWidget(_createTestWidget(isExpanded: true));
      await tester.pumpAndSettle();

      expect(find.text('ファイル名で検索...'), findsOneWidget);
    });

    testWidgets('テキスト入力で onQueryChanged が呼ばれる (Req 11.6)', (tester) async {
      String? lastQuery;

      await tester.pumpWidget(
        _createTestWidget(
          isExpanded: true,
          onQueryChanged: (query) => lastQuery = query,
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      expect(lastQuery, 'test');
    });

    testWidgets('「×」ボタンタップで onClear が呼ばれる (Req 11.4)', (tester) async {
      var clearCalled = false;

      await tester.pumpWidget(
        _createTestWidget(isExpanded: true, onClear: () => clearCalled = true),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(clearCalled, isTrue);
    });

    testWidgets('「×」ボタンタップでテキストがクリアされる (Req 11.4)', (tester) async {
      await tester.pumpWidget(_createTestWidget(isExpanded: true));
      await tester.pumpAndSettle();

      // テキストを入力
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();

      // 「×」ボタンをタップ
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      // TextField のテキストがクリアされている
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });
  });

  group('SearchBarWidget - 状態遷移', () {
    testWidgets('折りたたみ→展開でテキストフィールドが表示される', (tester) async {
      // 折りたたみ状態で開始
      await tester.pumpWidget(_createTestWidget(isExpanded: false));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);

      // 展開状態に変更
      await tester.pumpWidget(_createTestWidget(isExpanded: true));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('展開→折りたたみでテキストフィールドが非表示になる', (tester) async {
      // 展開状態で開始
      await tester.pumpWidget(_createTestWidget(isExpanded: true));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);

      // 折りたたみ状態に変更
      await tester.pumpWidget(_createTestWidget(isExpanded: false));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });
  });
}
