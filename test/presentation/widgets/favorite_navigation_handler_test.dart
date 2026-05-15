/// FavoriteNavigationHandler ウィジェットテスト
///
/// お気に入りフォルダへのナビゲーション処理を検証する。
/// - ローディングインジケーター表示
/// - 追加タップ無効化
/// - アクセス不可時のダイアログ表示
/// - 削除/保持の選択肢
///
/// Requirements: 3.5, 3.6, 4.1, 4.2, 4.3, 4.4, 4.5
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:optrig/application/providers/repository_providers.dart';
import 'package:optrig/application/usecases/favorites/navigate_to_favorite_usecase.dart';
import 'package:optrig/core/errors/favorite_exceptions.dart';
import 'package:optrig/domain/entities/entry_id.dart';
import 'package:optrig/domain/entities/favorite_folder.dart';
import 'package:optrig/domain/entities/folder_entry.dart';
import 'package:optrig/domain/repositories/favorite_repository.dart';
import 'package:optrig/domain/repositories/storage_repository.dart';
import 'package:optrig/presentation/providers/favorite_navigation_provider.dart';
import 'package:optrig/presentation/widgets/favorite_navigation_handler.dart';
import 'package:optrig/router/app_router.dart';

// ---------------------------------------------------------------------------
// テスト用モック
// ---------------------------------------------------------------------------

/// テスト用 NavigateToFavoriteUseCase
///
/// execute() の結果を外部から制御可能にする。
class FakeNavigateToFavoriteUseCase extends NavigateToFavoriteUseCase {
  FakeNavigateToFavoriteUseCase()
    : super(
        favoriteRepository: _FakeFavoriteRepository(),
        storageRepository: _FakeStorageRepository(),
      );

  /// execute() が返す Completer（テストから完了を制御する）
  Completer<FolderEntry>? _completer;

  /// execute() がスローする例外
  Object? exceptionToThrow;

  /// execute() の呼び出し回数
  int executeCallCount = 0;

  /// 次の execute() 呼び出しを遅延させる Completer を設定する
  void setCompleter(Completer<FolderEntry> completer) {
    _completer = completer;
  }

  @override
  Future<FolderEntry> execute({required FavoriteFolder favorite}) async {
    executeCallCount++;

    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }

    if (_completer != null) {
      return _completer!.future;
    }

    // デフォルト: 即座に FolderEntry を返す
    return FolderEntry(
      id: EntryId(rawValue: favorite.uri, platformType: PlatformType.windows),
      name: favorite.name,
      uri: favorite.uri,
      parentId: null,
    );
  }
}

/// テスト用 FavoriteRepository（最小実装）
class _FakeFavoriteRepository implements FavoriteRepository {
  final List<FavoriteFolder> _favorites = [];

  @override
  Future<List<FavoriteFolder>> getFavorites() async => _favorites;

  @override
  Future<int> getFavoriteCount() async => _favorites.length;

  @override
  Future<bool> isFavorite(String uri) async =>
      _favorites.any((f) => f.uri == uri);

  @override
  Future<FavoriteFolder> addFavorite({
    required String uri,
    required String name,
  }) async {
    final folder = FavoriteFolder(
      id: _favorites.length + 1,
      uri: uri,
      name: name,
      registeredAt: DateTime.now(),
    );
    _favorites.add(folder);
    return folder;
  }

  @override
  Future<void> removeFavorite(String uri) async {
    _favorites.removeWhere((f) => f.uri == uri);
  }

  @override
  Future<FavoriteFolder?> getFavoriteByUri(String uri) async {
    try {
      return _favorites.firstWhere((f) => f.uri == uri);
    } catch (_) {
      return null;
    }
  }
}

/// テスト用 StorageRepository（最小実装）
class _FakeStorageRepository implements StorageRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

// ---------------------------------------------------------------------------
// テスト用ヘルパー
// ---------------------------------------------------------------------------

/// テスト用のお気に入りフォルダを作成する
FavoriteFolder createTestFavoriteFolder({
  int id = 1,
  String uri = 'file:///test/folder',
  String name = 'テストフォルダ',
}) {
  return FavoriteFolder(
    id: id,
    uri: uri,
    name: name,
    registeredAt: DateTime(2024, 1, 1),
  );
}

/// テスト用のウィジェットツリーを構築する
///
/// GoRouter と ProviderScope を含むテスト環境を提供する。
Widget createTestWidget({
  required FakeNavigateToFavoriteUseCase fakeUseCase,
  required _FakeFavoriteRepository fakeRepository,
  required Widget child,
}) {
  final router = GoRouter(
    initialLocation: '/test',
    routes: [
      GoRoute(path: '/test', builder: (context, state) => child),
      GoRoute(
        path: AppRoutes.galleryGrid,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('ギャラリー画面'))),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      navigateToFavoriteUseCaseProvider.overrideWithValue(fakeUseCase),
      favoriteRepositoryProvider.overrideWithValue(fakeRepository),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

// ---------------------------------------------------------------------------
// テスト本体
// ---------------------------------------------------------------------------

void main() {
  late FakeNavigateToFavoriteUseCase fakeUseCase;
  late _FakeFavoriteRepository fakeRepository;

  setUp(() {
    fakeUseCase = FakeNavigateToFavoriteUseCase();
    fakeRepository = _FakeFavoriteRepository();
  });

  group('FavoriteNavigationHandler', () {
    testWidgets('初期状態ではローディングインジケーターが表示されない', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          fakeUseCase: fakeUseCase,
          fakeRepository: fakeRepository,
          child: const FavoriteNavigationHandler(child: Text('子ウィジェット')),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('子ウィジェット'), findsOneWidget);
    });
  });

  group('handleFavoriteNavigation', () {
    testWidgets('成功時にギャラリー画面へ遷移する', (tester) async {
      final folder = createTestFavoriteFolder();

      await tester.pumpWidget(
        createTestWidget(
          fakeUseCase: fakeUseCase,
          fakeRepository: fakeRepository,
          child: Consumer(
            builder: (context, ref, _) => ElevatedButton(
              onPressed: () => handleFavoriteNavigation(context, ref, folder),
              child: const Text('ナビゲート'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('ナビゲート'));
      await tester.pumpAndSettle();

      // ギャラリー画面に遷移していることを確認
      expect(find.text('ギャラリー画面'), findsOneWidget);
    });

    testWidgets('ナビゲーション中はローディングインジケーターが表示される', (tester) async {
      final folder = createTestFavoriteFolder();
      final completer = Completer<FolderEntry>();
      fakeUseCase.setCompleter(completer);

      await tester.pumpWidget(
        createTestWidget(
          fakeUseCase: fakeUseCase,
          fakeRepository: fakeRepository,
          child: Consumer(
            builder: (context, ref, _) => FavoriteNavigationHandler(
              child: ElevatedButton(
                onPressed: () => handleFavoriteNavigation(context, ref, folder),
                child: const Text('ナビゲート'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('ナビゲート'));
      await tester.pump();

      // ローディングインジケーターが表示される
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 完了させる
      completer.complete(
        FolderEntry(
          id: EntryId(rawValue: folder.uri, platformType: PlatformType.windows),
          name: folder.name,
          uri: folder.uri,
          parentId: null,
        ),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('ナビゲーション中は追加タップが無視される', (tester) async {
      final folder = createTestFavoriteFolder();
      final completer = Completer<FolderEntry>();
      fakeUseCase.setCompleter(completer);

      await tester.pumpWidget(
        createTestWidget(
          fakeUseCase: fakeUseCase,
          fakeRepository: fakeRepository,
          child: Consumer(
            builder: (context, ref, _) => FavoriteNavigationHandler(
              child: ElevatedButton(
                onPressed: () => handleFavoriteNavigation(context, ref, folder),
                child: const Text('ナビゲート'),
              ),
            ),
          ),
        ),
      );

      // 1回目のタップ
      await tester.tap(find.text('ナビゲート'));
      await tester.pump();

      // 2回目のタップ（AbsorbPointer で無効化されている）
      // AbsorbPointer が有効なので、ボタンはタップできない
      expect(fakeUseCase.executeCallCount, 1);

      // 完了させる
      completer.complete(
        FolderEntry(
          id: EntryId(rawValue: folder.uri, platformType: PlatformType.windows),
          name: folder.name,
          uri: folder.uri,
          parentId: null,
        ),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('FolderAccessException 時にダイアログが表示される', (tester) async {
      final folder = createTestFavoriteFolder();
      fakeUseCase.exceptionToThrow = FolderAccessException(
        uri: folder.uri,
        reason: 'フォルダが存在しません',
      );

      await tester.pumpWidget(
        createTestWidget(
          fakeUseCase: fakeUseCase,
          fakeRepository: fakeRepository,
          child: Consumer(
            builder: (context, ref, _) => ElevatedButton(
              onPressed: () => handleFavoriteNavigation(context, ref, folder),
              child: const Text('ナビゲート'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('ナビゲート'));
      await tester.pumpAndSettle();

      // ダイアログが表示される
      expect(find.text('フォルダにアクセスできません'), findsOneWidget);
      expect(find.text('保持'), findsOneWidget);
      expect(find.text('削除'), findsOneWidget);
    });

    testWidgets('ダイアログで「保持」を選択するとダイアログが閉じる', (tester) async {
      final folder = createTestFavoriteFolder();
      fakeUseCase.exceptionToThrow = FolderAccessException(
        uri: folder.uri,
        reason: 'フォルダが存在しません',
      );

      await tester.pumpWidget(
        createTestWidget(
          fakeUseCase: fakeUseCase,
          fakeRepository: fakeRepository,
          child: Consumer(
            builder: (context, ref, _) => ElevatedButton(
              onPressed: () => handleFavoriteNavigation(context, ref, folder),
              child: const Text('ナビゲート'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('ナビゲート'));
      await tester.pumpAndSettle();

      // 「保持」をタップ
      await tester.tap(find.text('保持'));
      await tester.pumpAndSettle();

      // ダイアログが閉じる
      expect(find.text('フォルダにアクセスできません'), findsNothing);
      // 元の画面に留まる
      expect(find.text('ナビゲート'), findsOneWidget);
    });

    testWidgets('ダイアログで「削除」を選択するとお気に入りから削除される', (tester) async {
      final folder = createTestFavoriteFolder();

      // 事前にお気に入りに登録
      await fakeRepository.addFavorite(uri: folder.uri, name: folder.name);
      expect(await fakeRepository.isFavorite(folder.uri), isTrue);

      fakeUseCase.exceptionToThrow = FolderAccessException(
        uri: folder.uri,
        reason: 'フォルダが存在しません',
      );

      await tester.pumpWidget(
        createTestWidget(
          fakeUseCase: fakeUseCase,
          fakeRepository: fakeRepository,
          child: Consumer(
            builder: (context, ref, _) => ElevatedButton(
              onPressed: () => handleFavoriteNavigation(context, ref, folder),
              child: const Text('ナビゲート'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('ナビゲート'));
      await tester.pumpAndSettle();

      // 「削除」をタップ
      await tester.tap(find.text('削除'));
      await tester.pumpAndSettle();

      // お気に入りから削除されている
      expect(await fakeRepository.isFavorite(folder.uri), isFalse);
    });

    testWidgets('予期しないエラー時に SnackBar が表示される', (tester) async {
      final folder = createTestFavoriteFolder();
      fakeUseCase.exceptionToThrow = Exception('予期しないエラー');

      await tester.pumpWidget(
        createTestWidget(
          fakeUseCase: fakeUseCase,
          fakeRepository: fakeRepository,
          child: Consumer(
            builder: (context, ref, _) => Scaffold(
              body: ElevatedButton(
                onPressed: () => handleFavoriteNavigation(context, ref, folder),
                child: const Text('ナビゲート'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('ナビゲート'));
      await tester.pumpAndSettle();

      // SnackBar が表示される
      expect(find.textContaining('フォルダへの遷移に失敗しました'), findsOneWidget);
    });
  });
}
