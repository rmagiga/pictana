/// NavigationOverlay ウィジェットテスト
///
/// Windows 矢印ボタンオーバーレイの UI 動作を検証する。
/// - マウスホバーでフェードイン/アウト (200ms)
/// - 左右端 16dp・垂直中央・48x48dp 最小領域
/// - navigationBounds で表示/非表示を制御
/// - アニメーション中はタップ無視
///
/// Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optrig/presentation/widgets/viewer/navigation_overlay.dart';

// ---------------------------------------------------------------------------
// テスト用ヘルパー
// ---------------------------------------------------------------------------

/// テスト用ウィジェットツリーを構築する
Widget _createTestWidget({
  int currentIndex = 1,
  int totalCount = 5,
  bool isAnimating = false,
  VoidCallback? onPrevious,
  VoidCallback? onNext,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 800,
        height: 600,
        child: NavigationOverlay(
          currentIndex: currentIndex,
          totalCount: totalCount,
          isAnimating: isAnimating,
          onPrevious: onPrevious ?? () {},
          onNext: onNext ?? () {},
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// テスト本体
// ---------------------------------------------------------------------------

void main() {
  group('NavigationOverlay - マウスホバーでフェードイン/アウト', () {
    testWidgets('マウスホバーで矢印ボタンがフェードインする (Req 1.1)', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();

      // ホバー前: opacity が 0.0
      final opacityWidgets = tester.widgetList<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      for (final widget in opacityWidgets) {
        expect(widget.opacity, 0.0);
      }

      // マウスポインタを作成してウィジェット中央に移動
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();

      await gesture.moveTo(tester.getCenter(find.byType(NavigationOverlay)));
      await tester.pump();

      // ホバー後: opacity が 1.0
      final opacityWidgetsAfter = tester.widgetList<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      for (final widget in opacityWidgetsAfter) {
        expect(widget.opacity, 1.0);
      }
    });

    testWidgets('マウスが離れると矢印ボタンがフェードアウトする (Req 1.2)', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();

      // マウスポインタを作成してウィジェット中央に移動
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();

      await gesture.moveTo(tester.getCenter(find.byType(NavigationOverlay)));
      await tester.pump();

      // ホバー中: opacity が 1.0
      var opacityWidgets = tester.widgetList<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      for (final widget in opacityWidgets) {
        expect(widget.opacity, 1.0);
      }

      // マウスをウィジェット外に移動
      await gesture.moveTo(const Offset(900, 900));
      await tester.pump();

      // ホバー解除後: opacity が 0.0
      opacityWidgets = tester.widgetList<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      for (final widget in opacityWidgets) {
        expect(widget.opacity, 0.0);
      }
    });

    testWidgets('AnimatedOpacity の duration が 200ms である', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();

      final opacityWidgets = tester.widgetList<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      for (final widget in opacityWidgets) {
        expect(widget.duration, const Duration(milliseconds: 200));
      }
    });
  });

  group('NavigationOverlay - ボタン配置', () {
    testWidgets('左ボタンが左端 16dp に配置される', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();

      // Positioned ウィジェットの left が 16.0
      final positioned = tester.widgetList<Positioned>(find.byType(Positioned));
      final leftPositioned = positioned.where((p) => p.left == 16.0);
      expect(leftPositioned, isNotEmpty);
    });

    testWidgets('右ボタンが右端 16dp に配置される', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();

      // Positioned ウィジェットの right が 16.0
      final positioned = tester.widgetList<Positioned>(find.byType(Positioned));
      final rightPositioned = positioned.where((p) => p.right == 16.0);
      expect(rightPositioned, isNotEmpty);
    });

    testWidgets('ボタンの最小タップ領域が 48x48dp', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();

      // SizedBox が 48x48 で存在する
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final tapAreaBoxes = sizedBoxes.where(
        (box) => box.width == 48.0 && box.height == 48.0,
      );
      // 左右2つのボタン
      expect(tapAreaBoxes.length, 2);
    });
  });

  group('NavigationOverlay - navigationBounds による表示制御', () {
    testWidgets('先頭画像で ◀ ボタンが非表示 (Req 1.5)', (tester) async {
      await tester.pumpWidget(
        _createTestWidget(currentIndex: 0, totalCount: 5),
      );
      await tester.pumpAndSettle();

      // chevron_left アイコンが存在しない
      expect(find.byIcon(Icons.chevron_left), findsNothing);
      // chevron_right アイコンは存在する
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('末尾画像で ▶ ボタンが非表示 (Req 1.6)', (tester) async {
      await tester.pumpWidget(
        _createTestWidget(currentIndex: 4, totalCount: 5),
      );
      await tester.pumpAndSettle();

      // chevron_right アイコンが存在しない
      expect(find.byIcon(Icons.chevron_right), findsNothing);
      // chevron_left アイコンは存在する
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    });

    testWidgets('画像1枚のみで両方非表示 (Req 1.8)', (tester) async {
      await tester.pumpWidget(
        _createTestWidget(currentIndex: 0, totalCount: 1),
      );
      await tester.pumpAndSettle();

      // 両方のアイコンが存在しない
      expect(find.byIcon(Icons.chevron_left), findsNothing);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('中間画像で両方表示', (tester) async {
      await tester.pumpWidget(
        _createTestWidget(currentIndex: 2, totalCount: 5),
      );
      await tester.pumpAndSettle();

      // 両方のアイコンが存在する
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });
  });

  group('NavigationOverlay - コールバック', () {
    testWidgets('◀ ボタンクリックで onPrevious が呼ばれる (Req 1.3)', (tester) async {
      var previousCalled = false;

      await tester.pumpWidget(
        _createTestWidget(onPrevious: () => previousCalled = true),
      );
      await tester.pumpAndSettle();

      // マウスホバーでボタンを表示
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();

      await gesture.moveTo(tester.getCenter(find.byType(NavigationOverlay)));
      await tester.pumpAndSettle();

      // ◀ ボタンをタップ
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();

      expect(previousCalled, isTrue);
    });

    testWidgets('▶ ボタンクリックで onNext が呼ばれる (Req 1.4)', (tester) async {
      var nextCalled = false;

      await tester.pumpWidget(
        _createTestWidget(onNext: () => nextCalled = true),
      );
      await tester.pumpAndSettle();

      // マウスホバーでボタンを表示
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();

      await gesture.moveTo(tester.getCenter(find.byType(NavigationOverlay)));
      await tester.pumpAndSettle();

      // ▶ ボタンをタップ
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();

      expect(nextCalled, isTrue);
    });
  });

  group('NavigationOverlay - アニメーション中のタップ無視', () {
    testWidgets('isAnimating=true でタップが無視される (Req 1.9)', (tester) async {
      var previousCalled = false;
      var nextCalled = false;

      await tester.pumpWidget(
        _createTestWidget(
          isAnimating: true,
          onPrevious: () => previousCalled = true,
          onNext: () => nextCalled = true,
        ),
      );
      await tester.pumpAndSettle();

      // マウスホバーでボタンを表示
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();

      await gesture.moveTo(tester.getCenter(find.byType(NavigationOverlay)));
      await tester.pumpAndSettle();

      // IgnorePointer が有効なのでタップしても反応しない
      await tester.tap(find.byIcon(Icons.chevron_left), warnIfMissed: false);
      await tester.tap(find.byIcon(Icons.chevron_right), warnIfMissed: false);
      await tester.pump();

      expect(previousCalled, isFalse);
      expect(nextCalled, isFalse);
    });
  });
}
