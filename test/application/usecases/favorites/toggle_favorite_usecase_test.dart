/// ToggleFavoriteUseCase ユニットテスト
///
/// インメモリ Drift DB を使用した統合テスト。
/// トグル操作、上限チェック、状態反転を検証する。
///
/// Requirements: 1.1, 1.5, 2.1, 5.2, 8.1, 8.2
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optrig/application/usecases/favorites/toggle_favorite_usecase.dart';
import 'package:optrig/core/errors/favorite_exceptions.dart';
import 'package:optrig/infrastructure/database/app_database.dart';
import 'package:optrig/infrastructure/database/favorite_repository_impl.dart';

void main() {
  late AppDatabase db;
  late FavoriteRepositoryImpl repository;
  late ToggleFavoriteUseCase useCase;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = FavoriteRepositoryImpl(db);
    useCase = ToggleFavoriteUseCase(repository: repository);
  });

  tearDown(() async {
    await db.close();
  });

  group('ToggleFavoriteUseCase', () {
    group('未登録フォルダのトグル（登録）', () {
      test('未登録フォルダをトグルするとtrueを返す', () async {
        final result = await useCase.execute(
          uri: 'file:///test/folder1',
          name: 'テストフォルダ',
        );

        expect(result, isTrue);
      });

      test('未登録フォルダをトグルするとお気に入りに登録される', () async {
        await useCase.execute(uri: 'file:///test/folder1', name: 'テストフォルダ');

        final isFavorite = await repository.isFavorite('file:///test/folder1');
        expect(isFavorite, isTrue);
      });

      test('登録されたフォルダのURI・名前が正しく保存される', () async {
        await useCase.execute(uri: 'file:///test/folder1', name: 'テストフォルダ');

        final favorite = await repository.getFavoriteByUri(
          'file:///test/folder1',
        );
        expect(favorite, isNotNull);
        expect(favorite!.uri, 'file:///test/folder1');
        expect(favorite.name, 'テストフォルダ');
      });
    });

    group('登録済みフォルダのトグル（解除）', () {
      test('登録済みフォルダをトグルするとfalseを返す', () async {
        // 事前に登録
        await repository.addFavorite(
          uri: 'file:///test/folder1',
          name: 'テストフォルダ',
        );

        final result = await useCase.execute(
          uri: 'file:///test/folder1',
          name: 'テストフォルダ',
        );

        expect(result, isFalse);
      });

      test('登録済みフォルダをトグルするとお気に入りから解除される', () async {
        // 事前に登録
        await repository.addFavorite(
          uri: 'file:///test/folder1',
          name: 'テストフォルダ',
        );

        await useCase.execute(uri: 'file:///test/folder1', name: 'テストフォルダ');

        final isFavorite = await repository.isFavorite('file:///test/folder1');
        expect(isFavorite, isFalse);
      });
    });

    group('上限チェック', () {
      test('maxFavoritesが50であること', () {
        expect(ToggleFavoriteUseCase.maxFavorites, 50);
      });

      test('50件登録済みの状態で新規登録するとFavoriteLimitExceededExceptionをスローする', () async {
        // 50件登録
        for (var i = 0; i < 50; i++) {
          await repository.addFavorite(
            uri: 'file:///test/folder$i',
            name: 'フォルダ$i',
          );
        }

        // 51件目の登録を試みる
        expect(
          () => useCase.execute(uri: 'file:///test/folder50', name: 'フォルダ50'),
          throwsA(isA<FavoriteLimitExceededException>()),
        );
      });

      test('上限例外にcurrentCountとmaxCountが含まれる', () async {
        // 50件登録
        for (var i = 0; i < 50; i++) {
          await repository.addFavorite(
            uri: 'file:///test/folder$i',
            name: 'フォルダ$i',
          );
        }

        try {
          await useCase.execute(uri: 'file:///test/folder50', name: 'フォルダ50');
          fail('例外がスローされるべき');
        } on FavoriteLimitExceededException catch (e) {
          expect(e.currentCount, 50);
          expect(e.maxCount, 50);
        }
      });

      test('49件登録済みの状態では新規登録が成功する', () async {
        // 49件登録
        for (var i = 0; i < 49; i++) {
          await repository.addFavorite(
            uri: 'file:///test/folder$i',
            name: 'フォルダ$i',
          );
        }

        // 50件目は成功する
        final result = await useCase.execute(
          uri: 'file:///test/folder49',
          name: 'フォルダ49',
        );

        expect(result, isTrue);
        final count = await repository.getFavoriteCount();
        expect(count, 50);
      });

      test('上限到達後に1件解除すると新規登録が可能になる', () async {
        // 50件登録
        for (var i = 0; i < 50; i++) {
          await repository.addFavorite(
            uri: 'file:///test/folder$i',
            name: 'フォルダ$i',
          );
        }

        // 1件解除
        await useCase.execute(uri: 'file:///test/folder0', name: 'フォルダ0');

        // 新規登録が成功する
        final result = await useCase.execute(
          uri: 'file:///test/new-folder',
          name: '新しいフォルダ',
        );

        expect(result, isTrue);
      });
    });

    group('トグルの状態反転', () {
      test('2回トグルすると元の状態に戻る', () async {
        // 1回目: 登録
        final first = await useCase.execute(
          uri: 'file:///test/folder1',
          name: 'テストフォルダ',
        );
        expect(first, isTrue);

        // 2回目: 解除
        final second = await useCase.execute(
          uri: 'file:///test/folder1',
          name: 'テストフォルダ',
        );
        expect(second, isFalse);

        // お気に入りから解除されている
        final isFavorite = await repository.isFavorite('file:///test/folder1');
        expect(isFavorite, isFalse);
      });
    });
  });
}
