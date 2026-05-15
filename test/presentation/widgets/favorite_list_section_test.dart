/// FavoriteListSection ウィジェットテスト
///
/// お気に入りフォルダ一覧セクションの UI 動作を検証する。
/// - お気に入りが0件の場合のプレースホルダー表示
/// - お気に入りフォルダの一覧表示
/// - フォルダ名の切り詰め表示
/// - 件数表示「N / 50」フォーマット
/// - フォルダ項目タップ時のコールバック
/// - スワイプ削除操作
/// - 削除後の Undo SnackBar 表示
/// - ローディング中の CircularProgressIndicator 表示
///
/// Requirements: 4.2, 7.1, 7.3, 8.4
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optrig/application/providers/repository_providers.dart';
import 'package:optrig/domain/entities/favorite_folder.dart';
import 'package:optrig/domain/repositories/favorite_repository.dart';
import 'package:optrig/presentation/providers/favorite_helper_providers.dart';
import 'package:optrig/presentation/providers/favorite_list_provider.dart';
import 'package:optrig/presentation/widgets/favorite_list_section.dart';

// ---------------------------------------------------------------------------
// テスト用モック
// ---------------------------------------------------------------------------

/// テスト用 FavoriteRepository
///
/// お気に入りの追加・削除操作を記録し、テストから結果を制御可能にする。
class FakeFavoriteRepository implements FavoriteRepository {
  final List<FavoriteFolder> _favorites = [];

  /// removeFavorite の呼び出し回数
  int removeCallCount = 0;

  /// removeFavorite で例外をスローするかどうか
  bool shouldThrowOnRemove = false;

  @override
  Future<List<FavoriteFolder>> getFavorites() async =>
      List.unmodifiable(_favorites);

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
    // 既存の同一 URI を削除してから追加（upsert 動作）
    _favorites.removeWhere((f) => f.uri == uri);
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
    removeCallCount++;
    if (shouldThrowOnRemove) {
      throw Exception('削除エラー');
    }
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

  /// テスト用にお気に入りリストを直接設定する
  void setFavorites(List<FavoriteFolder> favorites) {
    _favorites
      ..clear()
      ..addAll(favorites);
  }
}

// ---------------------------------------------------------------------------
// テスト用ヘルパー
// ---------------------------------------------------------------------------

/// テスト用のお気に入りフォルダを作成する
FavoriteFolder createTestFolder({
  int id = 1,
  String uri = 'file:///test/folder',
  String name = 'テストフォルダ',
  DateTime? registeredAt,
}) {
  return FavoriteFolder(
    id: id,
    uri: uri,
    name: name,
    registeredAt: registeredAt ?? DateTime(2024, 1, 1),
  );
}

/// テスト用ウィジェットツリーを構築する
///
/// ProviderScope でお気に入り関連 Provider をオーバーライドし、
/// Scaffold + ScaffoldMessenger を含むテスト環境を提供する。
Widget createTestWidget({
  required List<FavoriteFolder> favorites,
  required int count,
  required FakeFavoriteRepository fakeRepository,
  void Function(FavoriteFolder)? onFolderTap,
  bool isLoading = false,
}) {
  return ProviderScope(
    overrides: [
      favoriteListProvider.overrideWith(
        () => isLoading ? _LoadingFavoriteList() : _TestFavoriteList(favorites),
      ),
      favoriteCountProvider.overrideWith((ref) => Future.value(count)),
      favoriteRepositoryProvider.overrideWithValue(fakeRepository),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: FavoriteListSection(onFolderTap: onFolderTap ?? (_) {}),
        ),
      ),
    ),
  );
}

/// テスト用 FavoriteList Notifier
///
/// 初期データを外部から注入可能にする。
class _TestFavoriteList extends FavoriteList {
  _TestFavoriteList(this._initialData);

  final List<FavoriteFolder> _initialData;

  @override
  Future<List<FavoriteFolder>> build() async {
    return _initialData;
  }

  @override
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(_initialData);
  }
}

/// テスト用 FavoriteList Notifier（ローディング状態を維持する）
///
/// build() で Completer を使い、永遠に完了しない Future を返す。
/// テスト終了時に addTearDown で完了させることでタイマー問題を回避する。
class _LoadingFavoriteList extends FavoriteList {
  @override
  Future<List<FavoriteFolder>> build() {
    // 完了しない Completer を使用（タイマーを作成しない）
    return Completer<List<FavoriteFolder>>().future;
  }

  @override
  Future<void> refresh() async {
    state = const AsyncLoading();
  }
}

// ---------------------------------------------------------------------------
// テスト本体
// ---------------------------------------------------------------------------

void main() {
  late FakeFavoriteRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeFavoriteRepository();
  });

  group('FavoriteListSection - 空リスト表示', () {
    testWidgets('お気に入りが0件の場合、プレースホルダーメッセージが表示される', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          favorites: [],
          count: 0,
          fakeRepository: fakeRepository,
        ),
      );
      await tester.pumpAndSettle();

      // プレースホルダーメッセージが表示される
      expect(find.text('お気に入りフォルダはありません'), findsOneWidget);
    });
  });

  group('FavoriteListSection - 一覧表示', () {
    testWidgets('お気に入りフォルダが一覧表示される', (tester) async {
      final folders = [
        createTestFolder(id: 1, uri: 'file:///a', name: 'フォルダA'),
        createTestFolder(id: 2, uri: 'file:///b', name: 'フォルダB'),
        createTestFolder(id: 3, uri: 'file:///c', name: 'フォルダC'),
      ];

      await tester.pumpWidget(
        createTestWidget(
          favorites: folders,
          count: 3,
          fakeRepository: fakeRepository,
        ),
      );
      await tester.pumpAndSettle();

      // 全フォルダが表示される
      expect(find.text('フォルダA'), findsOneWidget);
      expect(find.text('フォルダB'), findsOneWidget);
      expect(find.text('フォルダC'), findsOneWidget);
    });

    testWidgets('フォルダ名が60文字を超える場合、省略記号で切り詰められる', (tester) async {
      // 61文字のフォルダ名
      final longName = 'あ' * 61;
      final expectedDisplay = '${'あ' * 60}…';

      final folders = [
        createTestFolder(id: 1, uri: 'file:///long', name: longName),
      ];

      await tester.pumpWidget(
        createTestWidget(
          favorites: folders,
          count: 1,
          fakeRepository: fakeRepository,
        ),
      );
      await tester.pumpAndSettle();

      // 切り詰められた名前が表示される
      expect(find.text(expectedDisplay), findsOneWidget);
      // 元の名前は表示されない
      expect(find.text(longName), findsNothing);
    });
  });

  group('FavoriteListSection - 件数表示', () {
    testWidgets('件数表示が「N / 50」フォーマットで表示される', (tester) async {
      final folders = [
        createTestFolder(id: 1, uri: 'file:///a', name: 'フォルダA'),
        createTestFolder(id: 2, uri: 'file:///b', name: 'フォルダB'),
        createTestFolder(id: 3, uri: 'file:///c', name: 'フォルダC'),
      ];

      await tester.pumpWidget(
        createTestWidget(
          favorites: folders,
          count: 3,
          fakeRepository: fakeRepository,
        ),
      );
      await tester.pumpAndSettle();

      // 件数表示が正しいフォーマットで表示される
      expect(find.text('3 / 50'), findsOneWidget);
    });
  });

  group('FavoriteListSection - フォルダタップ', () {
    testWidgets('フォルダ項目タップ時にonFolderTapコールバックが呼ばれる', (tester) async {
      FavoriteFolder? tappedFolder;
      final folders = [
        createTestFolder(id: 1, uri: 'file:///a', name: 'フォルダA'),
      ];

      await tester.pumpWidget(
        createTestWidget(
          favorites: folders,
          count: 1,
          fakeRepository: fakeRepository,
          onFolderTap: (folder) => tappedFolder = folder,
        ),
      );
      await tester.pumpAndSettle();

      // フォルダ項目をタップ
      await tester.tap(find.text('フォルダA'));
      await tester.pump();

      // コールバックが正しいフォルダで呼ばれる
      expect(tappedFolder, isNotNull);
      expect(tappedFolder!.uri, 'file:///a');
      expect(tappedFolder!.name, 'フォルダA');
    });
  });

  group('FavoriteListSection - スワイプ削除', () {
    testWidgets('スワイプ削除操作で削除が実行される', (tester) async {
      final folders = [
        createTestFolder(id: 1, uri: 'file:///a', name: 'フォルダA'),
        createTestFolder(id: 2, uri: 'file:///b', name: 'フォルダB'),
      ];
      fakeRepository.setFavorites(List.from(folders));

      await tester.pumpWidget(
        createTestWidget(
          favorites: folders,
          count: 2,
          fakeRepository: fakeRepository,
        ),
      );
      await tester.pumpAndSettle();

      // フォルダAを左スワイプ（endToStart）
      await tester.drag(find.text('フォルダA'), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // removeFavorite が呼ばれたことを確認
      expect(fakeRepository.removeCallCount, 1);
    });

    testWidgets('削除後にUndo SnackBarが表示される', (tester) async {
      final folders = [
        createTestFolder(id: 1, uri: 'file:///a', name: 'フォルダA'),
      ];
      fakeRepository.setFavorites(List.from(folders));

      await tester.pumpWidget(
        createTestWidget(
          favorites: folders,
          count: 1,
          fakeRepository: fakeRepository,
        ),
      );
      await tester.pumpAndSettle();

      // フォルダAを左スワイプ
      await tester.drag(find.text('フォルダA'), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Undo SnackBar が表示される
      expect(find.text('お気に入りから削除しました'), findsOneWidget);
      expect(find.text('元に戻す'), findsOneWidget);
    });
  });

  group('FavoriteListSection - ローディング', () {
    testWidgets('ローディング中はCircularProgressIndicatorが表示される', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          favorites: [],
          count: 0,
          fakeRepository: fakeRepository,
          isLoading: true,
        ),
      );
      // pump() のみで settle しない（ローディング状態を維持するため）
      await tester.pump();

      // ローディングインジケーターが表示される
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
