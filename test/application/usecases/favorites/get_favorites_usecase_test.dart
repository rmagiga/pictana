/// GetFavoritesUseCase ユニットテスト
///
/// インメモリ Drift DB を使用した統合テスト。
/// 一覧取得、件数取得、空リストの検証を行う。
///
/// Requirements: 3.1, 3.2, 3.3
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pictana/application/usecases/favorites/get_favorites_usecase.dart';
import 'package:pictana/infrastructure/database/app_database.dart';
import 'package:pictana/infrastructure/database/favorite_repository_impl.dart';

void main() {
  late AppDatabase db;
  late FavoriteRepositoryImpl repository;
  late GetFavoritesUseCase useCase;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = FavoriteRepositoryImpl(db);
    useCase = GetFavoritesUseCase(repository: repository);
  });

  tearDown(() async {
    await db.close();
  });

  group('GetFavoritesUseCase', () {
    group('execute() - お気に入り一覧取得', () {
      test('お気に入りが0件の場合、空リストを返す', () async {
        final result = await useCase.execute();

        expect(result, isEmpty);
      });

      test('登録済みのお気に入りフォルダを返す', () async {
        await repository.addFavorite(
          uri: 'file:///test/folder1',
          name: 'フォルダ1',
        );

        final result = await useCase.execute();

        expect(result, hasLength(1));
        expect(result.first.uri, 'file:///test/folder1');
        expect(result.first.name, 'フォルダ1');
      });

      test('登録日時の降順（新しい順）でソートされて返される', () async {
        // 明確に異なるタイムスタンプで直接DBに挿入
        final now = DateTime.now();
        final oldest = now.subtract(const Duration(hours: 3));
        final middle = now.subtract(const Duration(hours: 2));
        final newest = now.subtract(const Duration(hours: 1));

        await db
            .into(db.favoriteFolders)
            .insert(
              FavoriteFoldersCompanion.insert(
                uri: 'file:///test/folder1',
                name: 'フォルダ1',
                registeredAt: oldest,
              ),
            );
        await db
            .into(db.favoriteFolders)
            .insert(
              FavoriteFoldersCompanion.insert(
                uri: 'file:///test/folder2',
                name: 'フォルダ2',
                registeredAt: middle,
              ),
            );
        await db
            .into(db.favoriteFolders)
            .insert(
              FavoriteFoldersCompanion.insert(
                uri: 'file:///test/folder3',
                name: 'フォルダ3',
                registeredAt: newest,
              ),
            );

        final result = await useCase.execute();

        expect(result, hasLength(3));
        // 降順: 最新が先頭
        expect(result[0].uri, 'file:///test/folder3');
        expect(result[1].uri, 'file:///test/folder2');
        expect(result[2].uri, 'file:///test/folder1');
      });

      test('複数件登録後に一覧取得すると全件返される', () async {
        for (var i = 0; i < 5; i++) {
          await repository.addFavorite(
            uri: 'file:///test/folder$i',
            name: 'フォルダ$i',
          );
        }

        final result = await useCase.execute();

        expect(result, hasLength(5));
      });
    });

    group('count() - 件数取得', () {
      test('お気に入りが0件の場合、0を返す', () async {
        final result = await useCase.count();

        expect(result, 0);
      });

      test('登録件数に応じた正しい件数を返す', () async {
        await repository.addFavorite(
          uri: 'file:///test/folder1',
          name: 'フォルダ1',
        );
        await repository.addFavorite(
          uri: 'file:///test/folder2',
          name: 'フォルダ2',
        );
        await repository.addFavorite(
          uri: 'file:///test/folder3',
          name: 'フォルダ3',
        );

        final result = await useCase.count();

        expect(result, 3);
      });

      test('お気に入り追加後に件数が増加する', () async {
        expect(await useCase.count(), 0);

        await repository.addFavorite(
          uri: 'file:///test/folder1',
          name: 'フォルダ1',
        );
        expect(await useCase.count(), 1);

        await repository.addFavorite(
          uri: 'file:///test/folder2',
          name: 'フォルダ2',
        );
        expect(await useCase.count(), 2);
      });

      test('お気に入り削除後に件数が減少する', () async {
        await repository.addFavorite(
          uri: 'file:///test/folder1',
          name: 'フォルダ1',
        );
        await repository.addFavorite(
          uri: 'file:///test/folder2',
          name: 'フォルダ2',
        );
        expect(await useCase.count(), 2);

        await repository.removeFavorite('file:///test/folder1');
        expect(await useCase.count(), 1);
      });
    });
  });
}
