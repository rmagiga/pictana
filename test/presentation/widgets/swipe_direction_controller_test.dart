/// SwipeDirectionController ウィジェットテスト
///
/// スワイプ方向制御ウィジェットの UI 動作を検証する。
/// - horizontal モード: PageView が Axis.horizontal で動作
/// - vertical モード: PageView が Axis.vertical で動作
/// - both モード: 横方向 PageView + 縦方向 GestureDetector の合成
/// - ズーム中: NeverScrollableScrollPhysics でスワイプ無効化
///
/// Requirements: 4.1, 4.2, 4.3, 4.4
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pictana/domain/value_objects/swipe_direction.dart';
import 'package:pictana/presentation/widgets/viewer/swipe_direction_controller.dart';

// ---------------------------------------------------------------------------
// テスト用ヘルパー
// ---------------------------------------------------------------------------

/// テスト用ウィジェットツリーを構築する
Widget _createTestWidget({
  SwipeDirection direction = SwipeDirection.horizontal,
  bool isZoomed = false,
  int itemCount = 5,
  int initialPage = 0,
  ValueChanged<int>? onPageChanged,
}) {
  final pageController = PageController(initialPage: initialPage);
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 400,
        height: 600,
        child: SwipeDirectionController(
          direction: direction,
          isZoomed: isZoomed,
          pageController: pageController,
          itemCount: itemCount,
          onPageChanged: onPageChanged,
          itemBuilder: (context, index) => Center(child: Text('Page $index')),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// テスト本体
// ---------------------------------------------------------------------------

void main() {
  group('SwipeDirectionController - horizontal モード (Req 4.3)', () {
    testWidgets('horizontal モードで PageView が Axis.horizontal を使用する', (
      tester,
    ) async {
      await tester.pumpWidget(
        _createTestWidget(direction: SwipeDirection.horizontal),
      );
      await tester.pumpAndSettle();

      // PageView が存在する
      final pageViewFinder = find.byType(PageView);
      expect(pageViewFinder, findsOneWidget);

      // PageView の scrollDirection が horizontal
      final pageView = tester.widget<PageView>(pageViewFinder);
      expect(pageView.scrollDirection, Axis.horizontal);
    });

    testWidgets('horizontal モードで GestureDetector が存在しない', (tester) async {
      await tester.pumpWidget(
        _createTestWidget(direction: SwipeDirection.horizontal),
      );
      await tester.pumpAndSettle();

      // SwipeDirectionController 直下に GestureDetector がないことを確認
      // （PageView 内部の GestureDetector は除外）
      final gestureDetectors = tester.widgetList<GestureDetector>(
        find.descendant(
          of: find.byType(SwipeDirectionController),
          matching: find.byType(GestureDetector),
        ),
      );
      // GestureDetector が onVerticalDragStart を持つものがないことを確認
      final verticalGestureDetectors = gestureDetectors.where(
        (gd) => gd.onVerticalDragStart != null,
      );
      expect(verticalGestureDetectors, isEmpty);
    });

    testWidgets('horizontal モードで BouncingScrollPhysics が適用される', (tester) async {
      await tester.pumpWidget(
        _createTestWidget(direction: SwipeDirection.horizontal),
      );
      await tester.pumpAndSettle();

      final pageView = tester.widget<PageView>(find.byType(PageView));
      expect(pageView.physics, isA<BouncingScrollPhysics>());
    });
  });

  group('SwipeDirectionController - vertical モード (Req 4.1)', () {
    testWidgets('vertical モードで PageView が Axis.vertical を使用する', (tester) async {
      await tester.pumpWidget(
        _createTestWidget(direction: SwipeDirection.vertical),
      );
      await tester.pumpAndSettle();

      // PageView が存在する
      final pageViewFinder = find.byType(PageView);
      expect(pageViewFinder, findsOneWidget);

      // PageView の scrollDirection が vertical
      final pageView = tester.widget<PageView>(pageViewFinder);
      expect(pageView.scrollDirection, Axis.vertical);
    });

    testWidgets('vertical モードで BouncingScrollPhysics が適用される', (tester) async {
      await tester.pumpWidget(
        _createTestWidget(direction: SwipeDirection.vertical),
      );
      await tester.pumpAndSettle();

      final pageView = tester.widget<PageView>(find.byType(PageView));
      expect(pageView.physics, isA<BouncingScrollPhysics>());
    });
  });

  group('SwipeDirectionController - both モード (Req 4.2)', () {
    testWidgets('both モードで PageView が Axis.horizontal を使用する', (tester) async {
      await tester.pumpWidget(
        _createTestWidget(direction: SwipeDirection.both),
      );
      await tester.pumpAndSettle();

      // PageView が存在する
      final pageViewFinder = find.byType(PageView);
      expect(pageViewFinder, findsOneWidget);

      // PageView の scrollDirection が horizontal（横方向は PageView で処理）
      final pageView = tester.widget<PageView>(pageViewFinder);
      expect(pageView.scrollDirection, Axis.horizontal);
    });

    testWidgets('both モードで縦方向 GestureDetector が存在する', (tester) async {
      await tester.pumpWidget(
        _createTestWidget(direction: SwipeDirection.both),
      );
      await tester.pumpAndSettle();

      // SwipeDirectionController 直下に GestureDetector が存在する
      final gestureDetectors = tester.widgetList<GestureDetector>(
        find.descendant(
          of: find.byType(SwipeDirectionController),
          matching: find.byType(GestureDetector),
        ),
      );
      // onVerticalDragStart を持つ GestureDetector が存在する
      final verticalGestureDetectors = gestureDetectors.where(
        (gd) => gd.onVerticalDragStart != null,
      );
      expect(verticalGestureDetectors, isNotEmpty);
    });

    testWidgets('both モードで BouncingScrollPhysics が適用される', (tester) async {
      await tester.pumpWidget(
        _createTestWidget(direction: SwipeDirection.both),
      );
      await tester.pumpAndSettle();

      final pageView = tester.widget<PageView>(find.byType(PageView));
      expect(pageView.physics, isA<BouncingScrollPhysics>());
    });
  });

  group('SwipeDirectionController - ズーム中の無効化 (Req 4.4)', () {
    testWidgets('isZoomed=true で NeverScrollableScrollPhysics が適用される', (
      tester,
    ) async {
      await tester.pumpWidget(
        _createTestWidget(direction: SwipeDirection.horizontal, isZoomed: true),
      );
      await tester.pumpAndSettle();

      final pageView = tester.widget<PageView>(find.byType(PageView));
      expect(pageView.physics, isA<NeverScrollableScrollPhysics>());
    });

    testWidgets(
      'isZoomed=true で vertical モードでも NeverScrollableScrollPhysics が適用される',
      (tester) async {
        await tester.pumpWidget(
          _createTestWidget(direction: SwipeDirection.vertical, isZoomed: true),
        );
        await tester.pumpAndSettle();

        final pageView = tester.widget<PageView>(find.byType(PageView));
        expect(pageView.physics, isA<NeverScrollableScrollPhysics>());
      },
    );

    testWidgets(
      'isZoomed=true で both モードでも NeverScrollableScrollPhysics が適用される',
      (tester) async {
        await tester.pumpWidget(
          _createTestWidget(direction: SwipeDirection.both, isZoomed: true),
        );
        await tester.pumpAndSettle();

        final pageView = tester.widget<PageView>(find.byType(PageView));
        expect(pageView.physics, isA<NeverScrollableScrollPhysics>());
      },
    );

    testWidgets('isZoomed=true で GestureDetector（縦方向）が存在しない', (tester) async {
      await tester.pumpWidget(
        _createTestWidget(direction: SwipeDirection.both, isZoomed: true),
      );
      await tester.pumpAndSettle();

      // ズーム中は both モードでも GestureDetector が無効
      final gestureDetectors = tester.widgetList<GestureDetector>(
        find.descendant(
          of: find.byType(SwipeDirectionController),
          matching: find.byType(GestureDetector),
        ),
      );
      final verticalGestureDetectors = gestureDetectors.where(
        (gd) => gd.onVerticalDragStart != null,
      );
      expect(verticalGestureDetectors, isEmpty);
    });

    testWidgets('isZoomed=false に戻るとスワイプが再有効化される', (tester) async {
      // まずズーム中で構築
      await tester.pumpWidget(
        _createTestWidget(direction: SwipeDirection.horizontal, isZoomed: true),
      );
      await tester.pumpAndSettle();

      var pageView = tester.widget<PageView>(find.byType(PageView));
      expect(pageView.physics, isA<NeverScrollableScrollPhysics>());

      // ズーム解除で再構築
      await tester.pumpWidget(
        _createTestWidget(
          direction: SwipeDirection.horizontal,
          isZoomed: false,
        ),
      );
      await tester.pumpAndSettle();

      pageView = tester.widget<PageView>(find.byType(PageView));
      expect(pageView.physics, isA<BouncingScrollPhysics>());
    });
  });

  group('SwipeDirectionController - ページ表示', () {
    testWidgets('itemBuilder で指定したコンテンツが表示される', (tester) async {
      await tester.pumpWidget(_createTestWidget(initialPage: 0));
      await tester.pumpAndSettle();

      // 最初のページが表示される
      expect(find.text('Page 0'), findsOneWidget);
    });

    testWidgets('initialPage で指定したページが表示される', (tester) async {
      await tester.pumpWidget(_createTestWidget(initialPage: 2));
      await tester.pumpAndSettle();

      // 指定したページが表示される
      expect(find.text('Page 2'), findsOneWidget);
    });
  });
}
