/// FavoriteProviders ユニットテスト
///
/// FavoriteToggle Provider の楽観的 UI 更新、ロールバック、
/// 処理中ロックの状態遷移を検証する。
///
/// Requirements: 5.3, 5.4, 1.3, 2.4, 8.3
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optrig/application/providers/repository_providers.dart';
import 'package:optrig/core/errors/favorite_exceptions.dart';
import 'package:optrig/domain/entities/favorite_folder.dart';
import 'package:optrig/domain/repositories/favorite_repository.dart';
import 'package:optrig/presentation/providers/favorite_toggle_provider.dart';
import 'package:optrig/presentation/providers/favorite_toggle_state.dart';

// ---------------------------------------------------------------------------
// テスト用フェイクリポジトリ
// ---------------------------------------------------------------------------

/// テスト用 FavoriteRepository
///
/// 遅延・エラーを外部から制御可能にし、
/// Provider の状態遷移を検証できるようにする。
class FakeFavoriteRepository implements FavoriteRepository {
  final List<FavoriteFolder> _favorites = [];

  /// addFavorite / removeFavorite の完了を制御する Completer
  Completer<void>? operationCompleter;

  /// addFavorite 時にスローする例外
  Object? addException;

  /// removeFavorite 時にスローする例外
  Object? removeException;

  /// isFavorite の結果を強制的に返す（null の場合は実際のデータを使用）
  bool? forcedIsFavorite;

  /// getFavoriteCount の結果を強制的に返す（null の場合は実際のデータを使用）
  int? forcedCount;

  @override
  Future<List<FavoriteFolder>> getFavorites() async =>
      List.unmodifiable(_favorites);

  @override
  Future<int> getFavoriteCount() async => forcedCount ?? _favorites.length;

  @override
  Future<bool> isFavorite(String uri) async =>
      forcedIsFavorite ?? _favorites.any((f) => f.uri == uri);

  @override
  Future<FavoriteFolder> addFavorite({
    required String uri,
    required String name,
  }) async {
    // 遅延制御
    if (operationCompleter != null) {
      await operationCompleter!.future;
    }

    // エラー制御
    if (addException != null) {
      throw addException!;
    }

    final folder = FavoriteFolder(
      id: _favorites.length + 1,
      uri: uri,
      name: name,
      registeredAt: DateTime.now(),
    );
    // URI 重複時は上書き
    _favorites.removeWhere((f) => f.uri == uri);
    _favorites.add(folder);
    return folder;
  }

  @override
  Future<void> removeFavorite(String uri) async {
    // 遅延制御
    if (operationCompleter != null) {
      await operationCompleter!.future;
    }

    // エラー制御
    if (removeException != null) {
      throw removeException!;
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

  /// テスト用: お気に入りを直接追加する（遅延・エラー制御なし）
  void seedFavorite({
    required String uri,
    required String name,
    DateTime? registeredAt,
  }) {
    _favorites.add(
      FavoriteFolder(
        id: _favorites.length + 1,
        uri: uri,
        name: name,
        registeredAt: registeredAt ?? DateTime.now(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// テスト本体
// ---------------------------------------------------------------------------

void main() {
  late FakeFavoriteRepository fakeRepository;
  late ProviderContainer container;

  setUp(() {
    fakeRepository = FakeFavoriteRepository();
    container = ProviderContainer(
      overrides: [favoriteRepositoryProvider.overrideWithValue(fakeRepository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('FavoriteToggle', () {
    group('初期状態', () {
      test('初期状態は isProcessing=false, optimisticIsFavorite=null', () {
        // Requirements: 5.3, 5.4
        final state = container.read(favoriteToggleProvider);

        expect(state.isProcessing, isFalse);
        expect(state.optimisticIsFavorite, isNull);
        expect(state.errorMessage, isNull);
      });
    });

    group('楽観的UI更新', () {
      test('toggle() 呼び出し時に isProcessing が true になる', () async {
        // Requirements: 5.4
        final completer = Completer<void>();
        fakeRepository.operationCompleter = completer;

        // toggle を開始（完了を待たない）
        final toggleFuture = container
            .read(favoriteToggleProvider.notifier)
            .toggle(uri: 'file:///test/folder', name: 'テスト');

        // isFavorite の確認後に状態が更新されるのを待つ
        await Future<void>.delayed(Duration.zero);

        final state = container.read(favoriteToggleProvider);
        expect(state.isProcessing, isTrue);

        // クリーンアップ
        completer.complete();
        await toggleFuture;
      });

      test('toggle() 呼び出し時に optimisticIsFavorite が反転する（未登録→登録）', () async {
        // Requirements: 5.3
        final completer = Completer<void>();
        fakeRepository.operationCompleter = completer;

        // 未登録状態で toggle
        final toggleFuture = container
            .read(favoriteToggleProvider.notifier)
            .toggle(uri: 'file:///test/folder', name: 'テスト');

        await Future<void>.delayed(Duration.zero);

        final state = container.read(favoriteToggleProvider);
        // 未登録(false) → 登録(true) に反転
        expect(state.optimisticIsFavorite, isTrue);

        completer.complete();
        await toggleFuture;
      });

      test('toggle() 呼び出し時に optimisticIsFavorite が反転する（登録済み→未登録）', () async {
        // Requirements: 5.3
        // 事前にお気に入り登録
        fakeRepository.seedFavorite(uri: 'file:///test/folder', name: 'テスト');

        final completer = Completer<void>();
        fakeRepository.operationCompleter = completer;

        // 登録済み状態で toggle
        final toggleFuture = container
            .read(favoriteToggleProvider.notifier)
            .toggle(uri: 'file:///test/folder', name: 'テスト');

        await Future<void>.delayed(Duration.zero);

        final state = container.read(favoriteToggleProvider);
        // 登録済み(true) → 未登録(false) に反転
        expect(state.optimisticIsFavorite, isFalse);

        completer.complete();
        await toggleFuture;
      });
    });

    group('処理完了', () {
      test('処理完了後に isProcessing が false になる', () async {
        // Requirements: 5.4
        await container
            .read(favoriteToggleProvider.notifier)
            .toggle(uri: 'file:///test/folder', name: 'テスト');

        final state = container.read(favoriteToggleProvider);
        expect(state.isProcessing, isFalse);
      });
    });

    group('処理中ロック', () {
      test('isProcessing が true の間は追加の toggle() が無視される', () async {
        // Requirements: 5.4
        final completer = Completer<void>();
        fakeRepository.operationCompleter = completer;

        // 1回目の toggle を開始
        final firstToggle = container
            .read(favoriteToggleProvider.notifier)
            .toggle(uri: 'file:///test/folder', name: 'テスト');

        await Future<void>.delayed(Duration.zero);

        // 処理中であることを確認
        expect(container.read(favoriteToggleProvider).isProcessing, isTrue);

        // 2回目の toggle を試みる（無視されるべき）
        final secondToggle = container
            .read(favoriteToggleProvider.notifier)
            .toggle(uri: 'file:///test/folder2', name: 'テスト2');

        await secondToggle;
        await Future<void>.delayed(Duration.zero);

        // 状態は最初の toggle のまま（optimisticIsFavorite = true）
        final state = container.read(favoriteToggleProvider);
        expect(state.optimisticIsFavorite, isTrue);
        expect(state.isProcessing, isTrue);

        // クリーンアップ
        completer.complete();
        await firstToggle;
      });
    });

    group('エラー時ロールバック', () {
      test('エラー時に optimisticIsFavorite がロールバックされる', () async {
        // Requirements: 1.3, 2.4
        // DB書き込みエラーをシミュレート
        fakeRepository.addException = Exception('DB書き込みエラー');

        await container
            .read(favoriteToggleProvider.notifier)
            .toggle(uri: 'file:///test/folder', name: 'テスト');

        final state = container.read(favoriteToggleProvider);
        // 未登録状態(false)にロールバック
        expect(state.optimisticIsFavorite, isFalse);
        expect(state.isProcessing, isFalse);
      });

      test('エラー時に errorMessage が設定される', () async {
        // Requirements: 1.3, 2.4
        fakeRepository.addException = Exception('DB書き込みエラー');

        await container
            .read(favoriteToggleProvider.notifier)
            .toggle(uri: 'file:///test/folder', name: 'テスト');

        final state = container.read(favoriteToggleProvider);
        expect(state.errorMessage, isNotNull);
        expect(state.errorMessage, contains('DB書き込みエラー'));
      });

      test('上限到達時のロールバック（FavoriteLimitExceededException）', () async {
        // Requirements: 8.3
        // 上限到達をシミュレート: isFavorite=false, count=50
        fakeRepository.forcedIsFavorite = false;
        fakeRepository.addException = const FavoriteLimitExceededException(
          currentCount: 50,
          maxCount: 50,
        );

        await container
            .read(favoriteToggleProvider.notifier)
            .toggle(uri: 'file:///test/new-folder', name: '新しいフォルダ');

        final state = container.read(favoriteToggleProvider);
        // 未登録状態(false)にロールバック
        expect(state.optimisticIsFavorite, isFalse);
        expect(state.isProcessing, isFalse);
        expect(state.errorMessage, isNotNull);
        expect(state.errorMessage, contains('FavoriteLimitExceededException'));
      });

      test('解除エラー時に登録済み状態にロールバックされる', () async {
        // Requirements: 2.4
        // 事前にお気に入り登録
        fakeRepository.seedFavorite(uri: 'file:///test/folder', name: 'テスト');

        // DB削除エラーをシミュレート
        fakeRepository.removeException = Exception('DB削除エラー');

        await container
            .read(favoriteToggleProvider.notifier)
            .toggle(uri: 'file:///test/folder', name: 'テスト');

        final state = container.read(favoriteToggleProvider);
        // 登録済み状態(true)にロールバック
        expect(state.optimisticIsFavorite, isTrue);
        expect(state.isProcessing, isFalse);
        expect(state.errorMessage, isNotNull);
      });
    });
  });
}
