import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pictana/presentation/providers/app_lifecycle_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('appLifecycleProvider - ライフサイクル状態の変更を検知して更新する', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // 初期状態はデフォルト値（通常は resumed）
    var state = container.read(appLifecycleProvider);
    expect(state, AppLifecycleState.resumed);

    // ライフサイクルを paused に変更
    TestWidgetsFlutterBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    state = container.read(appLifecycleProvider);
    expect(state, AppLifecycleState.paused);

    // ライフサイクルを resumed に戻す
    TestWidgetsFlutterBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    state = container.read(appLifecycleProvider);
    expect(state, AppLifecycleState.resumed);
  });
}
