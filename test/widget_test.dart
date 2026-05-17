import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pictana/main.dart';

void main() {
  testWidgets('App starts smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: OptrigApp()));

    // Verify that the app starts without errors.
    expect(find.byType(OptrigApp), findsOneWidget);

    // スプラッシュ画面のタイムアウトなどの非同期処理を完了させる
    await tester.pump(const Duration(seconds: 3));
  });
}
