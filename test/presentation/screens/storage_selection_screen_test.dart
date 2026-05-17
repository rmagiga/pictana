import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:optrig/application/providers/repository_providers.dart';
import 'package:optrig/domain/entities/entry_id.dart';
import 'package:optrig/domain/entities/folder_entry.dart';
import 'package:optrig/domain/entities/storage_root.dart';
import 'package:optrig/domain/repositories/storage_repository.dart';
import 'package:optrig/presentation/screens/storage_selection_screen.dart';
import 'package:optrig/router/app_router.dart';

/// テスト用 Fake StorageRepository
class _FakeStorageRepository implements StorageRepository {
  @override
  Future<List<FolderEntry>> getRecentFolders() async => [];

  @override
  Future<FolderEntry?> getDefaultImageFolder() async => null;

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

  @override
  FolderEntry restoreFolderFromUri({
    required String uri,
    required String name,
  }) {
    return FolderEntry(
      id: EntryId.windows(uri),
      name: name,
      uri: uri,
      parentId: null,
    );
  }
}

/// テスト用ルーターの作成
GoRouter _createTestRouter({required List<String> navigatedPaths}) {
  return GoRouter(
    initialLocation: AppRoutes.storageSelection,
    routes: [
      GoRoute(
        path: AppRoutes.storageSelection,
        builder: (context, state) => const StorageSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) {
          navigatedPaths.add(AppRoutes.settings);
          return const Scaffold(body: Text('Settings'));
        },
      ),
    ],
  );
}

/// テスト用ウィジェットの構築
Widget _createTestWidget({
  required List<String> navigatedPaths,
}) {
  final router = _createTestRouter(navigatedPaths: navigatedPaths);
  return ProviderScope(
    overrides: [
      storageRepositoryProvider.overrideWithValue(_FakeStorageRepository()),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  group('StorageSelectionScreen - UI表示とナビゲーション', () {
    testWidgets('設定ボタンがAppBarに表示され、タップすると設定画面に遷移する', (tester) async {
      final navigatedPaths = <String>[];

      await tester.pumpWidget(
        _createTestWidget(navigatedPaths: navigatedPaths),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // AppBarに「フォルダを選択」と表示されていることを確認
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('フォルダを選択'),
        ),
        findsOneWidget,
      );

      // 設定アイコンボタンが存在することを確認
      final settingsButtonFinder = find.byWidgetPredicate(
        (widget) => widget is IconButton && widget.icon is Icon && (widget.icon as Icon).icon == Icons.settings,
      );
      expect(settingsButtonFinder, findsOneWidget);

      // 設定ボタンをタップ
      await tester.tap(settingsButtonFinder);
      await tester.pump(const Duration(milliseconds: 100));

      // GoRouter経由で /settings に遷移したことを確認
      expect(navigatedPaths, contains(AppRoutes.settings));
    });
  });
}
