/// DisconnectBanner ウィジェットテスト
///
/// USB 切断インラインバナーの表示/非表示、ボタン動作、再接続時の自動非表示を検証する。
/// - isBannerVisible=false で SizedBox.shrink が表示される
/// - isBannerVisible=true で警告アイコン・メッセージ・ボタンが表示される
/// - 「別のフォルダを開く」ボタンタップで onOpenFolder が呼ばれる
/// - 「×」ボタンタップで dismissBanner が呼ばれる
/// - maxRetryReached=true でメッセージが変わる
/// - isRetrying=true でリトライ進捗が表示される
///
/// Requirements: 14.1, 14.5, 14.6
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pictana/application/usecases/storage/storage_monitor.dart';
import 'package:pictana/domain/entities/folder_entry.dart';
import 'package:pictana/domain/entities/storage_monitor_state.dart';
import 'package:pictana/presentation/widgets/gallery/disconnect_banner.dart';

// ---------------------------------------------------------------------------
// テスト用モック
// ---------------------------------------------------------------------------

/// テスト用 StorageMonitor Notifier
///
/// 初期状態を外部から注入可能にし、dismissBanner 呼び出しを記録する。
class _FakeStorageMonitor extends StorageMonitor {
  _FakeStorageMonitor({required this.initialState});

  final StorageMonitorState initialState;

  /// dismissBanner が呼ばれた回数
  int dismissBannerCallCount = 0;

  @override
  StorageMonitorState build() => initialState;

  @override
  void dismissBanner() {
    dismissBannerCallCount++;
    state = state.copyWith(isBannerVisible: false);
  }

  @override
  Future<FolderEntry?> detectDefaultFolder() async => null;
}

// ---------------------------------------------------------------------------
// テスト用ヘルパー
// ---------------------------------------------------------------------------

/// テスト用ウィジェットツリーを構築する
Widget _createTestWidget({
  required StorageMonitorState monitorState,
  VoidCallback? onOpenFolder,
  _FakeStorageMonitor? fakeMonitor,
}) {
  final monitor = fakeMonitor ??
      _FakeStorageMonitor(initialState: monitorState);

  return ProviderScope(
    overrides: [
      storageMonitorProvider.overrideWith(() => monitor),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: DisconnectBanner(
          onOpenFolder: onOpenFolder ?? () {},
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// テスト本体
// ---------------------------------------------------------------------------

void main() {
  group('DisconnectBanner - バナー非表示 (Req 14.6)', () {
    testWidgets('isBannerVisible=false で SizedBox.shrink が表示される', (
      tester,
    ) async {
      await tester.pumpWidget(
        _createTestWidget(
          monitorState: const StorageMonitorState(isBannerVisible: false),
        ),
      );
      await tester.pumpAndSettle();

      // バナーの内容が表示されていないことを確認
      expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
      expect(find.text('ストレージが切断されました'), findsNothing);
      expect(find.text('別のフォルダを開く'), findsNothing);

      // SizedBox.shrink が使われていることを確認
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, 0.0);
      expect(sizedBox.height, 0.0);
    });
  });

  group('DisconnectBanner - バナー表示 (Req 14.1)', () {
    testWidgets('isBannerVisible=true で警告アイコンが表示される', (tester) async {
      await tester.pumpWidget(
        _createTestWidget(
          monitorState: const StorageMonitorState(isBannerVisible: true),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('isBannerVisible=true で切断メッセージが表示される', (tester) async {
      await tester.pumpWidget(
        _createTestWidget(
          monitorState: const StorageMonitorState(isBannerVisible: true),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ストレージが切断されました'), findsOneWidget);
    });

    testWidgets('isBannerVisible=true で「別のフォルダを開く」ボタンが表示される', (
      tester,
    ) async {
      await tester.pumpWidget(
        _createTestWidget(
          monitorState: const StorageMonitorState(isBannerVisible: true),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('別のフォルダを開く'), findsOneWidget);
    });

    testWidgets('isBannerVisible=true で「×」閉じるボタンが表示される', (tester) async {
      await tester.pumpWidget(
        _createTestWidget(
          monitorState: const StorageMonitorState(isBannerVisible: true),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });

  group('DisconnectBanner - ボタン動作 (Req 14.5)', () {
    testWidgets('「別のフォルダを開く」ボタンタップで onOpenFolder が呼ばれる', (
      tester,
    ) async {
      var openFolderCalled = false;

      await tester.pumpWidget(
        _createTestWidget(
          monitorState: const StorageMonitorState(isBannerVisible: true),
          onOpenFolder: () => openFolderCalled = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('別のフォルダを開く'));
      await tester.pumpAndSettle();

      expect(openFolderCalled, isTrue);
    });

    testWidgets('「×」ボタンタップで dismissBanner が呼ばれる', (tester) async {
      final fakeMonitor = _FakeStorageMonitor(
        initialState: const StorageMonitorState(isBannerVisible: true),
      );

      await tester.pumpWidget(
        _createTestWidget(
          monitorState: const StorageMonitorState(isBannerVisible: true),
          fakeMonitor: fakeMonitor,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(fakeMonitor.dismissBannerCallCount, 1);
    });

    testWidgets('「×」ボタンタップ後にバナーが非表示になる', (tester) async {
      final fakeMonitor = _FakeStorageMonitor(
        initialState: const StorageMonitorState(isBannerVisible: true),
      );

      await tester.pumpWidget(
        _createTestWidget(
          monitorState: const StorageMonitorState(isBannerVisible: true),
          fakeMonitor: fakeMonitor,
        ),
      );
      await tester.pumpAndSettle();

      // バナーが表示されていることを確認
      expect(find.text('ストレージが切断されました'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // バナーが非表示になったことを確認
      expect(find.text('ストレージが切断されました'), findsNothing);
    });
  });

  group('DisconnectBanner - 最大リトライ到達 (Req 14.1)', () {
    testWidgets('maxRetryReached=true でメッセージが変わる', (tester) async {
      await tester.pumpWidget(
        _createTestWidget(
          monitorState: const StorageMonitorState(
            isBannerVisible: true,
            maxRetryReached: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 通常メッセージではなく手動再接続メッセージが表示される
      expect(find.text('ストレージが切断されました'), findsNothing);
      expect(
        find.text('ストレージが切断されました。手動で再接続してください。'),
        findsOneWidget,
      );
    });
  });

  group('DisconnectBanner - リトライ進捗表示 (Req 14.1)', () {
    testWidgets('isRetrying=true でリトライ進捗が表示される', (tester) async {
      await tester.pumpWidget(
        _createTestWidget(
          monitorState: const StorageMonitorState(
            isBannerVisible: true,
            isRetrying: true,
            retryCount: 5,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('再接続を試行中... (5/60)'), findsOneWidget);
    });

    testWidgets('isRetrying=false でリトライ進捗が非表示', (tester) async {
      await tester.pumpWidget(
        _createTestWidget(
          monitorState: const StorageMonitorState(
            isBannerVisible: true,
            isRetrying: false,
            retryCount: 0,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('再接続を試行中'), findsNothing);
    });
  });

  group('DisconnectBanner - 再接続時の自動非表示 (Req 14.6)', () {
    testWidgets('状態が isBannerVisible=false に変わるとバナーが消える', (
      tester,
    ) async {
      final fakeMonitor = _FakeStorageMonitor(
        initialState: const StorageMonitorState(isBannerVisible: true),
      );

      await tester.pumpWidget(
        _createTestWidget(
          monitorState: const StorageMonitorState(isBannerVisible: true),
          fakeMonitor: fakeMonitor,
        ),
      );
      await tester.pumpAndSettle();

      // バナーが表示されていることを確認
      expect(find.text('ストレージが切断されました'), findsOneWidget);

      // dismissBanner を呼んで再接続をシミュレート
      fakeMonitor.dismissBanner();
      await tester.pumpAndSettle();

      // バナーが非表示になったことを確認
      expect(find.text('ストレージが切断されました'), findsNothing);
      expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
    });
  });
}
