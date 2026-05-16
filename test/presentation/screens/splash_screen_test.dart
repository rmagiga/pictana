/// SplashScreen ウィジェットテスト
///
/// 起動時の自動フォルダ検出フローを検証する。
/// - StorageMonitor.detectDefaultFolder を起動時に呼び出し (Req 16.1)
/// - 3 秒タイムアウト、検出失敗時は Storage Selection 画面表示 (Req 16.3)
/// - 最近開いたフォルダ履歴を優先 (Req 16.5)
/// - 検出完了まで読み込み中インジケーターを表示 (Req 16.1)
///
/// Requirements: 16.1, 16.2, 16.3, 16.4, 16.5, 16.6
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:optrig/application/providers/repository_providers.dart';
import 'package:optrig/application/usecases/storage/storage_monitor.dart';
import 'package:optrig/domain/entities/entry_id.dart';
import 'package:optrig/domain/entities/folder_entry.dart';
import 'package:optrig/domain/entities/storage_monitor_state.dart';
import 'package:optrig/domain/entities/storage_root.dart';
import 'package:optrig/domain/repositories/storage_repository.dart';
import 'package:optrig/presentation/providers/gallery_providers.dart';
import 'package:optrig/presentation/screens/splash_screen.dart';
import 'package:optrig/router/app_router.dart';

// ---------------------------------------------------------------------------
// テスト用モック
// ---------------------------------------------------------------------------

/// テスト用 StorageRepository
class _FakeStorageRepository implements StorageRepository {
  _FakeStorageRepository({
    this.recentFolders = const [],
    this.getRecentFoldersDelay = Duration.zero,
    this.shouldThrow = false,
  });

  final List<FolderEntry> recentFolders;
  final Duration getRecentFoldersDelay;
  final bool shouldThrow;

  @override
  Future<List<FolderEntry>> getRecentFolders() async {
    if (shouldThrow) throw Exception('テスト用エラー');
    if (getRecentFoldersDelay > Duration.zero) {
      await Future.delayed(getRecentFoldersDelay);
    }
    return recentFolders;
  }

  @override
  Future<FolderEntry?> getDefaultImageFolder() async {
    if (shouldThrow) throw Exception('テスト用エラー');
    return null;
  }

  @override
  Future<List<StorageRoot>> getStorageRoots() async => [];

  @override
  Future<List<FolderEntry>> getFolders(StorageRoot root) async => [];

  @override
  Future<List<FolderEntry>> getSubFolders(FolderEntry folder) async => [];

  @override
  Future<FolderEntry?> selectFolder() async => null;

  @override
  Future<void> persistUriPermission(String uri) async {}

  @override
  Stream<List<StorageRoot>> watchStorageRoots() => const Stream.empty();

  @override
  Future<void> recordRecentFolder(FolderEntry folder) async {}
}

/// テスト用 StorageMonitor Notifier
class _FakeStorageMonitor extends StorageMonitor {
  _FakeStorageMonitor({this.detectedFolder});

  final FolderEntry? detectedFolder;

  @override
  StorageMonitorState build() => const StorageMonitorState();

  @override
  Future<FolderEntry?> detectDefaultFolder() async => detectedFolder;
}

/// テスト用 CurrentFolder Notifier
class _FakeCurrentFolder extends CurrentFolder {
  FolderEntry? lastSetFolder;

  @override
  FolderEntry? build() => null;

  @override
  void setFolder(FolderEntry folder) {
    lastSetFolder = folder;
    state = folder;
  }
}

// ---------------------------------------------------------------------------
// テスト用ヘルパー
// ---------------------------------------------------------------------------

/// テスト用のフォルダエントリを生成する
FolderEntry _createTestFolder({
  String name = 'Pictures',
  String uri = 'file:///C:/Users/test/Pictures',
}) {
  return FolderEntry(id: EntryId.windows(uri), name: name, uri: uri);
}

/// テスト用ルーター（遷移先を記録する）
GoRouter _createTestRouter({required List<String> navigatedPaths}) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.storageSelection,
        builder: (context, state) {
          navigatedPaths.add(AppRoutes.storageSelection);
          return const Scaffold(body: Text('Storage Selection'));
        },
      ),
      GoRoute(
        path: AppRoutes.galleryGrid,
        builder: (context, state) {
          navigatedPaths.add(AppRoutes.galleryGrid);
          return const Scaffold(body: Text('Gallery Grid'));
        },
      ),
    ],
  );
}

/// テスト用ウィジェットツリーを構築する
Widget _createTestWidget({
  required _FakeStorageRepository fakeRepo,
  FolderEntry? detectedFolder,
  required List<String> navigatedPaths,
}) {
  final router = _createTestRouter(navigatedPaths: navigatedPaths);

  return ProviderScope(
    overrides: [
      storageRepositoryProvider.overrideWithValue(fakeRepo),
      storageMonitorProvider.overrideWith(
        () => _FakeStorageMonitor(detectedFolder: detectedFolder),
      ),
      currentFolderProvider.overrideWith(() => _FakeCurrentFolder()),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

// ---------------------------------------------------------------------------
// テスト本体
// ---------------------------------------------------------------------------

void main() {
  group('SplashScreen - 読み込み中インジケーター (Req 16.1)', () {
    testWidgets('起動時に読み込み中インジケーターが表示される', (tester) async {
      final navigatedPaths = <String>[];
      final fakeRepo = _FakeStorageRepository(
        getRecentFoldersDelay: const Duration(seconds: 5),
      );

      await tester.pumpWidget(
        _createTestWidget(fakeRepo: fakeRepo, navigatedPaths: navigatedPaths),
      );

      // 初期表示: ロゴ + インジケーター + テキスト
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Optrig'), findsOneWidget);
      expect(find.text('画像フォルダを検出中...'), findsOneWidget);
    });
  });

  group('SplashScreen - 最近フォルダ優先 (Req 16.5)', () {
    testWidgets('最近開いたフォルダがあればそれを使用してギャラリーへ遷移する', (tester) async {
      final navigatedPaths = <String>[];
      final recentFolder = _createTestFolder(
        name: 'Recent',
        uri: 'file:///C:/Users/test/Recent',
      );
      final fakeRepo = _FakeStorageRepository(recentFolders: [recentFolder]);

      await tester.pumpWidget(
        _createTestWidget(fakeRepo: fakeRepo, navigatedPaths: navigatedPaths),
      );
      await tester.pumpAndSettle();

      // ギャラリー画面へ遷移
      expect(navigatedPaths, contains(AppRoutes.galleryGrid));
    });
  });

  group('SplashScreen - OS 既定フォルダ検出 (Req 16.1, 16.2, 16.4)', () {
    testWidgets('最近フォルダがなく既定フォルダが見つかればギャラリーへ遷移する', (tester) async {
      final navigatedPaths = <String>[];
      final defaultFolder = _createTestFolder(
        name: 'Pictures',
        uri: 'file:///C:/Users/test/Pictures',
      );
      final fakeRepo = _FakeStorageRepository();

      await tester.pumpWidget(
        _createTestWidget(
          fakeRepo: fakeRepo,
          detectedFolder: defaultFolder,
          navigatedPaths: navigatedPaths,
        ),
      );
      await tester.pumpAndSettle();

      // ギャラリー画面へ遷移 (Req 16.2)
      expect(navigatedPaths, contains(AppRoutes.galleryGrid));
    });
  });

  group('SplashScreen - 検出失敗時 (Req 16.3)', () {
    testWidgets('既定フォルダが見つからなければ Storage Selection へ遷移する', (tester) async {
      final navigatedPaths = <String>[];
      final fakeRepo = _FakeStorageRepository();

      await tester.pumpWidget(
        _createTestWidget(
          fakeRepo: fakeRepo,
          detectedFolder: null,
          navigatedPaths: navigatedPaths,
        ),
      );
      await tester.pumpAndSettle();

      // Storage Selection 画面へ遷移 (Req 16.3)
      expect(navigatedPaths, contains(AppRoutes.storageSelection));
    });

    testWidgets('例外発生時は Storage Selection へ遷移する', (tester) async {
      final navigatedPaths = <String>[];
      final fakeRepo = _FakeStorageRepository(shouldThrow: true);

      await tester.pumpWidget(
        _createTestWidget(fakeRepo: fakeRepo, navigatedPaths: navigatedPaths),
      );
      await tester.pumpAndSettle();

      // エラー時も Storage Selection 画面へ遷移 (Req 16.3)
      expect(navigatedPaths, contains(AppRoutes.storageSelection));
    });
  });

  group('SplashScreen - 3 秒タイムアウト (Req 16.3)', () {
    testWidgets('検出が 3 秒以内に完了しなければ Storage Selection へ遷移する', (tester) async {
      final navigatedPaths = <String>[];
      // 5 秒かかるリポジトリ（3 秒タイムアウトを超過）
      final fakeRepo = _FakeStorageRepository(
        getRecentFoldersDelay: const Duration(seconds: 5),
      );

      await tester.pumpWidget(
        _createTestWidget(fakeRepo: fakeRepo, navigatedPaths: navigatedPaths),
      );

      // 3 秒経過をシミュレート
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // タイムアウトにより Storage Selection 画面へ遷移 (Req 16.3)
      expect(navigatedPaths, contains(AppRoutes.storageSelection));
    });
  });
}
