/// FilterChipsWidget ウィジェットテスト
///
/// 種類フィルターチップの UI 動作を検証する。
/// - 7 つのチップが表示される（全て, JPEG, PNG, WebP, GIF, HEIC, AVIF）
/// - selectedMimeType=null で「全て」がハイライトされる
/// - チップタップで onMimeTypeSelected コールバックが正しく呼ばれる
/// - 水平スクロール可能であること
///
/// Requirements: 12.1, 12.2, 12.4, 12.5
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optrig/domain/entities/image_entry.dart';
import 'package:optrig/presentation/widgets/gallery/filter_chips_widget.dart';

// ---------------------------------------------------------------------------
// テスト用ヘルパー
// ---------------------------------------------------------------------------

/// テスト用ウィジェットツリーを構築する
Widget _createTestWidget({
  ImageMimeType? selectedMimeType,
  ValueChanged<ImageMimeType?>? onMimeTypeSelected,
}) {
  return MaterialApp(
    home: Scaffold(
      body: FilterChipsWidget(
        selectedMimeType: selectedMimeType,
        onMimeTypeSelected: onMimeTypeSelected ?? (_) {},
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// テスト本体
// ---------------------------------------------------------------------------

void main() {
  group('FilterChipsWidget - チップ表示', () {
    testWidgets('7 つのチップが表示される (Req 12.1)', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();

      // 各ラベルが表示されていることを確認
      expect(find.text('全て'), findsOneWidget);
      expect(find.text('JPEG'), findsOneWidget);
      expect(find.text('PNG'), findsOneWidget);
      expect(find.text('WebP'), findsOneWidget);
      expect(find.text('GIF'), findsOneWidget);
      expect(find.text('HEIC'), findsOneWidget);
      expect(find.text('AVIF'), findsOneWidget);
    });

    testWidgets('selectedMimeType=null で「全て」が選択状態になる (Req 12.1)', (
      tester,
    ) async {
      await tester.pumpWidget(_createTestWidget(selectedMimeType: null));
      await tester.pumpAndSettle();

      // 「全て」チップが selected 状態
      final allChip = tester.widget<FilterChip>(
        find.ancestor(of: find.text('全て'), matching: find.byType(FilterChip)),
      );
      expect(allChip.selected, isTrue);

      // 他のチップは非選択状態
      final jpegChip = tester.widget<FilterChip>(
        find.ancestor(of: find.text('JPEG'), matching: find.byType(FilterChip)),
      );
      expect(jpegChip.selected, isFalse);
    });

    testWidgets('selectedMimeType=jpeg で JPEG チップが選択状態になる (Req 12.2)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _createTestWidget(selectedMimeType: ImageMimeType.jpeg),
      );
      await tester.pumpAndSettle();

      // JPEG チップが selected 状態
      final jpegChip = tester.widget<FilterChip>(
        find.ancestor(of: find.text('JPEG'), matching: find.byType(FilterChip)),
      );
      expect(jpegChip.selected, isTrue);

      // 「全て」チップは非選択状態
      final allChip = tester.widget<FilterChip>(
        find.ancestor(of: find.text('全て'), matching: find.byType(FilterChip)),
      );
      expect(allChip.selected, isFalse);
    });
  });

  group('FilterChipsWidget - コールバック', () {
    testWidgets(
      'JPEG チップタップで onMimeTypeSelected(ImageMimeType.jpeg) が呼ばれる (Req 12.2)',
      (tester) async {
        ImageMimeType? selectedValue;
        var callbackCalled = false;

        await tester.pumpWidget(
          _createTestWidget(
            selectedMimeType: null,
            onMimeTypeSelected: (value) {
              callbackCalled = true;
              selectedValue = value;
            },
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('JPEG'));
        await tester.pump();

        expect(callbackCalled, isTrue);
        expect(selectedValue, ImageMimeType.jpeg);
      },
    );

    testWidgets('「全て」チップタップで onMimeTypeSelected(null) が呼ばれる (Req 12.4)', (
      tester,
    ) async {
      ImageMimeType? selectedValue = ImageMimeType.jpeg; // 初期値を非 null に
      var callbackCalled = false;

      await tester.pumpWidget(
        _createTestWidget(
          selectedMimeType: ImageMimeType.jpeg,
          onMimeTypeSelected: (value) {
            callbackCalled = true;
            selectedValue = value;
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('全て'));
      await tester.pump();

      expect(callbackCalled, isTrue);
      expect(selectedValue, isNull);
    });

    testWidgets('PNG チップタップで onMimeTypeSelected(ImageMimeType.png) が呼ばれる', (
      tester,
    ) async {
      ImageMimeType? selectedValue;

      await tester.pumpWidget(
        _createTestWidget(onMimeTypeSelected: (value) => selectedValue = value),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('PNG'));
      await tester.pump();

      expect(selectedValue, ImageMimeType.png);
    });
  });

  group('FilterChipsWidget - スクロール', () {
    testWidgets('水平スクロール可能である (Req 12.5)', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();

      // ListView が水平方向に配置されていることを確認
      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.scrollDirection, Axis.horizontal);
    });
  });
}
