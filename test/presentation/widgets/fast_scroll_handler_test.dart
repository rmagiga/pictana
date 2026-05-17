/// FastScrollHandler ウィジェットテスト
///
/// マウスホイール高速スクロールの動作を検証する。
/// - マウスホイール 1 ノッチでデフォルト 3 倍のスクロール量
/// - 200ms イージングアニメーション付きスクロール
/// - Ctrl 押下中はスクロール無効
/// - ScrollController が未接続の場合は何もしない
///
/// Requirements: 13.1, 13.2, 13.3, 13.4
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pictana/presentation/widgets/gallery/fast_scroll_handler.dart';

// ---------------------------------------------------------------------------
// テスト用ヘルパー
// ---------------------------------------------------------------------------

/// テスト用ウィジェットツリーを構築する
///
/// スクロール可能なリストを FastScrollHandler でラップする。
Widget _createTestWidget({
  required ScrollController scrollController,
  double scrollMultiplier = 3.0,
  Duration animationDuration = const Duration(milliseconds: 200),
}) {
  return MaterialApp(
    home: Scaffold(
      body: FastScrollHandler(
        scrollController: scrollController,
        scrollMultiplier: scrollMultiplier,
        animationDuration: animationDuration,
        child: ListView.builder(
          controller: scrollController,
          physics: const FastScrollPhysics(),
          itemCount: 100,
          itemBuilder: (context, index) =>
              SizedBox(height: 100, child: Text('Item $index')),
        ),
      ),
    ),
  );
}

/// PointerScrollEvent をディスパッチするヘルパー
Future<void> _dispatchScrollEvent(
  WidgetTester tester, {
  Offset scrollDelta = const Offset(0, 100),
  Offset position = Offset.zero,
}) async {
  final center = tester.getCenter(find.byType(FastScrollHandler));
  final testPointer = TestPointer(1, PointerDeviceKind.mouse);
  testPointer.hover(position == Offset.zero ? center : position);
  await tester.sendEventToBinding(testPointer.scroll(scrollDelta));
}

// ---------------------------------------------------------------------------
// テスト本体
// ---------------------------------------------------------------------------

void main() {
  group('FastScrollHandler - スクロール量の増幅', () {
    testWidgets('マウスホイール 1 ノッチでデフォルト 3 倍のスクロール量が適用される (Req 13.1)', (
      tester,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_createTestWidget(scrollController: controller));
      await tester.pumpAndSettle();

      // 初期位置は 0
      expect(controller.offset, 0.0);

      // 下方向にスクロール（dy > 0）
      await _dispatchScrollEvent(tester, scrollDelta: const Offset(0, 100));
      await tester.pumpAndSettle();

      // スクロール量 = 100 * 3 = 300
      expect(controller.offset, 300.0);
    });

    testWidgets('上方向スクロールで負の方向にスクロールする', (tester) async {
      final controller = ScrollController(initialScrollOffset: 500);
      addTearDown(controller.dispose);

      await tester.pumpWidget(_createTestWidget(scrollController: controller));
      await tester.pumpAndSettle();

      expect(controller.offset, 500.0);

      // 上方向にスクロール（dy < 0）
      await _dispatchScrollEvent(tester, scrollDelta: const Offset(0, -100));
      await tester.pumpAndSettle();

      // スクロール量 = -100 * 3 = -300、500 - 300 = 200
      expect(controller.offset, 200.0);
    });

    testWidgets('スクロール量が最小値（0）にクランプされる', (tester) async {
      final controller = ScrollController(initialScrollOffset: 100);
      addTearDown(controller.dispose);

      await tester.pumpWidget(_createTestWidget(scrollController: controller));
      await tester.pumpAndSettle();

      // 大きな上方向スクロール
      await _dispatchScrollEvent(tester, scrollDelta: const Offset(0, -500));
      await tester.pumpAndSettle();

      // 0 にクランプされる
      expect(controller.offset, 0.0);
    });

    testWidgets('スクロール量が最大値にクランプされる', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_createTestWidget(scrollController: controller));
      await tester.pumpAndSettle();

      final maxExtent = controller.position.maxScrollExtent;

      // 非常に大きな下方向スクロール
      await _dispatchScrollEvent(tester, scrollDelta: const Offset(0, 100000));
      await tester.pumpAndSettle();

      // maxScrollExtent にクランプされる
      expect(controller.offset, maxExtent);
    });
  });

  group('FastScrollHandler - アニメーション', () {
    testWidgets('200ms のイージングアニメーションが適用される (Req 13.2)', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_createTestWidget(scrollController: controller));
      await tester.pumpAndSettle();

      // スクロールイベントを送信
      await _dispatchScrollEvent(tester, scrollDelta: const Offset(0, 100));

      // 1 フレーム進めてアニメーションを開始させる
      await tester.pump();

      // アニメーション途中（100ms 経過時点）ではまだ最終位置に到達していない
      await tester.pump(const Duration(milliseconds: 100));
      expect(controller.offset, greaterThan(0.0));
      expect(controller.offset, lessThan(300.0));

      // アニメーション完了（200ms 経過）
      await tester.pumpAndSettle();
      expect(controller.offset, 300.0);
    });
  });

  group('FastScrollHandler - Ctrl キー押下時', () {
    testWidgets('Ctrl 押下中はスクロールが無効になる (Req 13.4)', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_createTestWidget(scrollController: controller));
      await tester.pumpAndSettle();

      expect(controller.offset, 0.0);

      // Ctrl キーを押下状態にする
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);

      // スクロールイベントを送信
      await _dispatchScrollEvent(tester, scrollDelta: const Offset(0, 100));
      await tester.pumpAndSettle();

      // Ctrl 押下中はスクロールされない
      expect(controller.offset, 0.0);

      // Ctrl キーを離す
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    });

    testWidgets('Ctrl を離した後はスクロールが有効になる', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_createTestWidget(scrollController: controller));
      await tester.pumpAndSettle();

      // Ctrl キーを押下して離す
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await _dispatchScrollEvent(tester, scrollDelta: const Offset(0, 100));
      await tester.pumpAndSettle();
      expect(controller.offset, 0.0);

      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);

      // Ctrl を離した後はスクロールが有効
      await _dispatchScrollEvent(tester, scrollDelta: const Offset(0, 100));
      await tester.pumpAndSettle();
      expect(controller.offset, 300.0);
    });
  });

  group('FastScrollHandler - カスタム設定', () {
    testWidgets('scrollMultiplier をカスタマイズできる', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _createTestWidget(scrollController: controller, scrollMultiplier: 5.0),
      );
      await tester.pumpAndSettle();

      await _dispatchScrollEvent(tester, scrollDelta: const Offset(0, 100));
      await tester.pumpAndSettle();

      // スクロール量 = 100 * 5 = 500
      expect(controller.offset, 500.0);
    });
  });
}
