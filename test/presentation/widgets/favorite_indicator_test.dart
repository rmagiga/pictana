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
import 'package:optrig/presentation/providers/favorite_toggle_state.dart';
import 'package:optrig/presentation/widgets/favorite_indicator.dart';

// ---------------------------------------------------------------------------
// テスト用モック
// ---------------------------------------------------------------------------

/// テスト用 FavoriteRepository（最小実装）
class FakeFavoriteRepository implements FavoriteRepository {
  final List<FavoriteFolder> _favorites = [];
  bool shouldThrow = false;

  /// toggle 操作の呼び出し記録（テスト検証用）
  final List<String> toggleCalls = [];

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
    toggleCalls.add('add:$uri');
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
    toggleCalls.add('remove:$uri');
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
// テスト用フェイク Notifier
// ---------------------------------------------------------------------------

/// テスト用 FavoriteToggle Notifier
///
/// 固定の FavoriteToggleState を返すことで、
/// FavoriteIndicator の表示ロジックを独立してテスト可能にする。
class _FakeFavoriteToggle extends FavoriteToggle {
  final FavoriteToggleState _initialState;

  _FakeFavoriteToggle(this._initialState);

  @override
  FavoriteToggleState build() => _initialState;

  @override
  Future<void> toggle({required String uri, required String name}) async {
    // テスト用: 何もしない
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

  group('FavoriteIndicator targetUri フォールバック', () {
    testWidgets('targetUri が異なる URI の場合、楽観的状態を無視して DB 状態にフォールバックする', (
      tester,
    ) async {
      // テスト対象: 現在表示中のフォルダ URI
      const currentUri = 'file:///current/folder';
      const currentName = '現在のフォルダ';
      // 楽観的状態が別のフォルダ（targetUri）に対するものである場合
      const differentUri = 'file:///different/folder';

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            favoriteRepositoryProvider.overrideWithValue(fakeRepository),
            // DB 状態: 現在のフォルダは未登録（false）
            isFolderFavoriteProvider(
              currentUri,
            ).overrideWith((_) async => false),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: FavoriteIndicator(uri: currentUri, name: currentName),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // FavoriteToggle Provider の状態を直接操作:
      // optimisticIsFavorite=true だが targetUri は別のフォルダ
      final container = ProviderScope.containerOf(
        tester.element(find.byType(FavoriteIndicator)),
      );
      container
          .read(favoriteToggleProvider.notifier)
          .state = const FavoriteToggleState(
        optimisticIsFavorite: true,
        targetUri: differentUri, // 現在のフォルダとは異なる URI
      );

      await tester.pump();

      // targetUri が現在の URI と一致しないため、
      // optimisticIsFavorite(true) は無視され、DB 状態(false) が使用される
      expect(find.byIcon(Icons.star_border), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNothing);
    });

    testWidgets('targetUri が現在の URI と一致する場合、楽観的状態が適用される', (tester) async {
      // テスト対象: 現在表示中のフォルダ URI
      const currentUri = 'file:///current/folder';
      const currentName = '現在のフォルダ';

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            favoriteRepositoryProvider.overrideWithValue(fakeRepository),
            // DB 状態: 現在のフォルダは未登録（false）
            isFolderFavoriteProvider(
              currentUri,
            ).overrideWith((_) async => false),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: FavoriteIndicator(uri: currentUri, name: currentName),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // FavoriteToggle Provider の状態を直接操作:
      // optimisticIsFavorite=true かつ targetUri が現在のフォルダと一致
      final container = ProviderScope.containerOf(
        tester.element(find.byType(FavoriteIndicator)),
      );
      container
          .read(favoriteToggleProvider.notifier)
          .state = const FavoriteToggleState(
        optimisticIsFavorite: true,
        targetUri: currentUri, // 現在のフォルダと一致する URI
      );

      await tester.pump();

      // targetUri が一致するため、楽観的状態(true) が適用される
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.star_border), findsNothing);
    });
  });

  group('FavoriteIndicator targetUri 一致判定', () {
    testWidgets(
      'targetUri が現在の URI と一致する場合、楽観的状態（optimisticIsFavorite）が適用される',
      (tester) async {
        // DB 状態は「未登録(false)」だが、楽観的状態は「登録済み(true)」
        // targetUri が一致するため、楽観的状態が優先される
        const testUri = 'file:///test/folder-a';
        const testName = 'フォルダA';

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              favoriteRepositoryProvider.overrideWithValue(fakeRepository),
              // DB 状態: 未登録
              isFolderFavoriteProvider(
                testUri,
              ).overrideWith((_) async => false),
              // 楽観的状態: targetUri が一致し、optimisticIsFavorite = true
              favoriteToggleProvider.overrideWith(() {
                return _FakeFavoriteToggle(
                  const FavoriteToggleState(
                    isProcessing: true,
                    optimisticIsFavorite: true,
                    targetUri: testUri,
                  ),
                );
              }),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: FavoriteIndicator(uri: testUri, name: testName),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 楽観的状態（true）が適用され、塗りつぶしスターが表示される
        expect(find.byIcon(Icons.star), findsOneWidget);
        expect(find.byIcon(Icons.star_border), findsNothing);
      },
    );

    testWidgets('targetUri が現在の URI と一致しない場合、DB 状態にフォールバックする', (tester) async {
      // 楽観的状態は「登録済み(true)」だが、targetUri が別フォルダを指している
      // DB 状態（未登録）が使用される
      const currentUri = 'file:///test/folder-b';
      const otherUri = 'file:///test/folder-a';
      const testName = 'フォルダB';

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            favoriteRepositoryProvider.overrideWithValue(fakeRepository),
            // DB 状態: 未登録
            isFolderFavoriteProvider(
              currentUri,
            ).overrideWith((_) async => false),
            // 楽観的状態: targetUri が別フォルダ（不一致）
            favoriteToggleProvider.overrideWith(() {
              return _FakeFavoriteToggle(
                const FavoriteToggleState(
                  isProcessing: true,
                  optimisticIsFavorite: true,
                  targetUri: otherUri,
                ),
              );
            }),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: FavoriteIndicator(uri: currentUri, name: testName),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // targetUri 不一致のため DB 状態（未登録）にフォールバック
      expect(find.byIcon(Icons.star_border), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNothing);
    });

    testWidgets('targetUri が一致し optimisticIsFavorite=false の場合、未登録アイコンが表示される', (
      tester,
    ) async {
      // DB 状態は「登録済み(true)」だが、楽観的状態は「未登録(false)」
      // targetUri が一致するため、楽観的状態が優先される
      const testUri = 'file:///test/folder-c';
      const testName = 'フォルダC';

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            favoriteRepositoryProvider.overrideWithValue(fakeRepository),
            // DB 状態: 登録済み
            isFolderFavoriteProvider(testUri).overrideWith((_) async => true),
            // 楽観的状態: targetUri が一致し、optimisticIsFavorite = false
            favoriteToggleProvider.overrideWith(() {
              return _FakeFavoriteToggle(
                const FavoriteToggleState(
                  isProcessing: true,
                  optimisticIsFavorite: false,
                  targetUri: testUri,
                ),
              );
            }),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: FavoriteIndicator(uri: testUri, name: testName),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 楽観的状態（false）が適用され、アウトラインスターが表示される
      expect(find.byIcon(Icons.star_border), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNothing);
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
      await tester.pumpAndSettle();

      // FakeRepository の呼び出し記録を確認して
      // toggle 操作が実行されたことを検証する
      // （未登録状態からのトグルなので addFavorite が呼ばれる）
      expect(fakeRepository.toggleCalls, contains('add:$testUri'));
    });
  });
}
