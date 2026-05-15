/// FavoriteIndicator ウィジェットテスト
///
/// お気に入りスターアイコンの状態切替表示とアクセシビリティラベルの正確性を検証する。
///
/// Requirements: 5.1, 5.5
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optrig/application/providers/repository_providers.dart';
import 'package:optrig/domain/repositories/favorite_repository.dart';
import 'package:optrig/domain/entities/favorite_folder.dart';
import 'package:optrig/presentation/providers/favorite_helper_providers.dart';
import 'package:optrig/presentation/providers/favorite_toggle_provider.dart';
import 'package:optrig/presentation/widgets/favorite_indicator.dart';

// ---------------------------------------------------------------------------
// テスト用モック
// ---------------------------------------------------------------------------

/// テスト用 FavoriteRepository（最小実装）
class FakeFavoriteRepository implements FavoriteRepository {
  final List<FavoriteFolder> _favorites = [];
  bool shouldThrow = false;

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
    if (shouldThrow) throw Exception('DB エラー');
    final folder = FavoriteFolder(
      id: _favorites.length + 1,
      uri: uri,
      name: name,
      registeredAt: DateTime.now(),
    );
    _favorites.removeWhere((f) => f.uri == uri);
    _favorites.add(folder);
    return folder;
  }

  @override
  Future<void> removeFavorite(String uri) async {
    if (shouldThrow) throw Exception('DB エラー');
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

// ---------------------------------------------------------------------------
// テスト用ヘルパー
// ---------------------------------------------------------------------------

/// テスト用ウィジェットツリーを構築する
///
/// [isFavorite] でお気に入り状態を制御する。
/// Provider のオーバーライドにより、DB アクセスなしでテスト可能にする。
Widget createTestWidget({
  required bool isFavorite,
  required FakeFavoriteRepository fakeRepository,
  String uri = 'file:///test/folder',
  String name = 'テストフォルダ',
}) {
  return ProviderScope(
    overrides: [
      favoriteRepositoryProvider.overrideWithValue(fakeRepository),
      // isFolderFavoriteProvider を固定値でオーバーライド
      isFolderFavoriteProvider(uri).overrideWith((_) async => isFavorite),
    ],
    child: MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          actions: [FavoriteIndicator(uri: uri, name: name)],
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// テスト本体
// ---------------------------------------------------------------------------

void main() {
  late FakeFavoriteRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeFavoriteRepository();
  });

  group('FavoriteIndicator アイコン状態表示', () {
    testWidgets('未登録状態ではアウトラインスターアイコン（Icons.star_border）が表示される', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(isFavorite: false, fakeRepository: fakeRepository),
      );
      await tester.pumpAndSettle();

      // アウトラインスターアイコンが表示される
      expect(find.byIcon(Icons.star_border), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNothing);
    });

    testWidgets('登録済み状態では塗りつぶしスターアイコン（Icons.star）が表示される', (tester) async {
      await tester.pumpWidget(
        createTestWidget(isFavorite: true, fakeRepository: fakeRepository),
      );
      await tester.pumpAndSettle();

      // 塗りつぶしスターアイコンが表示される
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.star_border), findsNothing);
    });
  });

  group('FavoriteIndicator アクセシビリティラベル', () {
    testWidgets('未登録状態のアクセシビリティラベルが「お気に入り登録」である', (tester) async {
      await tester.pumpWidget(
        createTestWidget(isFavorite: false, fakeRepository: fakeRepository),
      );
      await tester.pumpAndSettle();

      // ツールチップ（アクセシビリティラベル）が「お気に入り登録」
      expect(find.byTooltip('お気に入り登録'), findsOneWidget);
    });

    testWidgets('登録済み状態のアクセシビリティラベルが「お気に入り解除」である', (tester) async {
      await tester.pumpWidget(
        createTestWidget(isFavorite: true, fakeRepository: fakeRepository),
      );
      await tester.pumpAndSettle();

      // ツールチップ（アクセシビリティラベル）が「お気に入り解除」
      expect(find.byTooltip('お気に入り解除'), findsOneWidget);
    });
  });

  group('FavoriteIndicator タップ操作', () {
    testWidgets('タップ時にトグル操作が呼び出される', (tester) async {
      const testUri = 'file:///test/folder';
      const testName = 'テストフォルダ';

      await tester.pumpWidget(
        createTestWidget(
          isFavorite: false,
          fakeRepository: fakeRepository,
          uri: testUri,
          name: testName,
        ),
      );
      await tester.pumpAndSettle();

      // スターアイコンをタップ
      await tester.tap(find.byIcon(Icons.star_border));
      await tester.pump();

      // FavoriteToggle Provider の状態が変化する（楽観的UI更新）
      // タップ後に処理が開始されたことを確認
      // （実際のトグル処理は FavoriteToggle Provider 内で実行される）
      // ここでは IconButton の onPressed が呼ばれたことを
      // アイコン状態の変化で間接的に検証する
      final container = ProviderScope.containerOf(
        tester.element(find.byType(FavoriteIndicator)),
      );
      final toggleState = container.read(favoriteToggleProvider);

      // toggle() が呼ばれると isProcessing が true になるか、
      // 処理完了後に optimisticIsFavorite が設定される
      expect(
        toggleState.isProcessing || toggleState.optimisticIsFavorite != null,
        isTrue,
      );
    });
  });
}
