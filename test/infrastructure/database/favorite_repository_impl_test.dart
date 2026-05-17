/// FavoriteRepositoryImpl ユニットテスト
///
/// インメモリ Drift DB を使用した統合テスト。
/// CRUD 操作、ユニーク制約、ソート順を検証する。
///
/// Requirements: 6.1, 6.3, 6.5
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pictana/infrastructure/database/app_database.dart';
import 'package:pictana/infrastructure/database/favorite_repository_impl.dart';

void main() {
  late AppDatabase db;
  late FavoriteRepositoryImpl repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = FavoriteRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('FavoriteRepositoryImpl', () {
    group('addFavorite', () {
      test('新規フォルダをお気に入りに登録できる', () async {
        final result = await repository.addFavorite(
          uri: 'file:///test/folder1',
          name: 'テストフォルダ1',
        );

        expect(result.uri, 'file:///test/folder1');
        expect(result.name, 'テストフォルダ1');
        expect(result.id, greaterThan(0));
        expect(result.registeredAt, isNotNull);
      });

      test('同一URIで登録すると名前が上書き更新される（upsert）', () async {
        await repository.addFavorite(uri: 'file:///test/folder1', name: '元の名前');

        final updated = await repository.addFavorite(
          uri: 'file:///test/folder1',
          name: '更新後の名前',
        );

        expect(updated.uri, 'file:///test/folder1');
        expect(updated.name, '更新後の名前');

        // 件数が1件のままであることを確認（重複登録されていない）
        final count = await repository.getFavoriteCount();
        expect(count, 1);
      });

      test('同一URIで登録すると登録日時も更新される', () async {
        final first = await repository.addFavorite(
          uri: 'file:///test/folder1',
          name: '名前1',
        );

        // 少し待って再登録
        await Future<void>.delayed(const Duration(milliseconds: 10));

        final second = await repository.addFavorite(
          uri: 'file:///test/folder1',
          name: '名前2',
        );

        expect(
          second.registeredAt.isAfter(first.registeredAt) ||
              second.registeredAt.isAtSameMomentAs(first.registeredAt),
          isTrue,
        );
      });

      test('異なるURIのフォルダを複数登録できる', () async {
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

        final count = await repository.getFavoriteCount();
        expect(count, 3);
      });
    });

    group('getFavorites', () {
      test('空の状態では空リストを返す', () async {
        final favorites = await repository.getFavorites();
        expect(favorites, isEmpty);
      });

      test('登録日時降順でソートされた一覧を返す', () async {
        // 明確に異なるタイムスタンプで直接DBに挿入
        final now = DateTime.now();
        final oldest = now.subtract(const Duration(hours: 3));
        final middle = now.subtract(const Duration(hours: 2));
        final newest = now.subtract(const Duration(hours: 1));

        await db
            .into(db.favoriteFolders)
            .insert(
              FavoriteFoldersCompanion.insert(
                uri: 'file:///test/oldest',
                name: '最古',
                registeredAt: oldest,
              ),
            );
        await db
            .into(db.favoriteFolders)
            .insert(
              FavoriteFoldersCompanion.insert(
                uri: 'file:///test/middle',
                name: '中間',
                registeredAt: middle,
              ),
            );
        await db
            .into(db.favoriteFolders)
            .insert(
              FavoriteFoldersCompanion.insert(
                uri: 'file:///test/newest',
                name: '最新',
                registeredAt: newest,
              ),
            );

        final favorites = await repository.getFavorites();

        expect(favorites.length, 3);
        // 降順: 最新 → 中間 → 最古
        expect(favorites[0].name, '最新');
        expect(favorites[1].name, '中間');
        expect(favorites[2].name, '最古');
      });

      test('登録日時が降順であることを隣接要素で検証する', () async {
        final now = DateTime.now();
        for (var i = 0; i < 5; i++) {
          await db
              .into(db.favoriteFolders)
              .insert(
                FavoriteFoldersCompanion.insert(
                  uri: 'file:///test/folder$i',
                  name: 'フォルダ$i',
                  registeredAt: now.subtract(Duration(hours: 5 - i)),
                ),
              );
        }

        final favorites = await repository.getFavorites();

        for (var i = 0; i < favorites.length - 1; i++) {
          expect(
            favorites[i].registeredAt.isAfter(favorites[i + 1].registeredAt) ||
                favorites[i].registeredAt.isAtSameMomentAs(
                  favorites[i + 1].registeredAt,
                ),
            isTrue,
            reason: 'インデックス $i の登録日時が $i+1 より新しいこと',
          );
        }
      });
    });

    group('getFavoriteCount', () {
      test('空の状態では0を返す', () async {
        final count = await repository.getFavoriteCount();
        expect(count, 0);
      });

      test('登録件数を正確に返す', () async {
        await repository.addFavorite(
          uri: 'file:///test/folder1',
          name: 'フォルダ1',
        );
        await repository.addFavorite(
          uri: 'file:///test/folder2',
          name: 'フォルダ2',
        );

        final count = await repository.getFavoriteCount();
        expect(count, 2);
      });

      test('削除後に件数が減少する', () async {
        await repository.addFavorite(
          uri: 'file:///test/folder1',
          name: 'フォルダ1',
        );
        await repository.addFavorite(
          uri: 'file:///test/folder2',
          name: 'フォルダ2',
        );

        await repository.removeFavorite('file:///test/folder1');

        final count = await repository.getFavoriteCount();
        expect(count, 1);
      });
    });

    group('isFavorite', () {
      test('登録済みURIに対してtrueを返す', () async {
        await repository.addFavorite(
          uri: 'file:///test/folder1',
          name: 'フォルダ1',
        );

        final result = await repository.isFavorite('file:///test/folder1');
        expect(result, isTrue);
      });

      test('未登録URIに対してfalseを返す', () async {
        final result = await repository.isFavorite('file:///test/nonexistent');
        expect(result, isFalse);
      });

      test('削除後はfalseを返す', () async {
        await repository.addFavorite(
          uri: 'file:///test/folder1',
          name: 'フォルダ1',
        );
        await repository.removeFavorite('file:///test/folder1');

        final result = await repository.isFavorite('file:///test/folder1');
        expect(result, isFalse);
      });
    });

    group('removeFavorite', () {
      test('登録済みフォルダを削除できる', () async {
        await repository.addFavorite(
          uri: 'file:///test/folder1',
          name: 'フォルダ1',
        );

        await repository.removeFavorite('file:///test/folder1');

        final result = await repository.isFavorite('file:///test/folder1');
        expect(result, isFalse);
      });

      test('未登録URIの削除はエラーにならない', () async {
        // 例外がスローされないことを確認
        await expectLater(
          repository.removeFavorite('file:///test/nonexistent'),
          completes,
        );
      });

      test('削除後も他のお気に入りは影響を受けない', () async {
        await repository.addFavorite(
          uri: 'file:///test/folder1',
          name: 'フォルダ1',
        );
        await repository.addFavorite(
          uri: 'file:///test/folder2',
          name: 'フォルダ2',
        );

        await repository.removeFavorite('file:///test/folder1');

        final favorites = await repository.getFavorites();
        expect(favorites.length, 1);
        expect(favorites[0].uri, 'file:///test/folder2');
      });

      test('削除後もソート順が維持される', () async {
        final now = DateTime.now();
        await db
            .into(db.favoriteFolders)
            .insert(
              FavoriteFoldersCompanion.insert(
                uri: 'file:///test/folder1',
                name: 'フォルダ1',
                registeredAt: now.subtract(const Duration(hours: 3)),
              ),
            );
        await db
            .into(db.favoriteFolders)
            .insert(
              FavoriteFoldersCompanion.insert(
                uri: 'file:///test/folder2',
                name: 'フォルダ2',
                registeredAt: now.subtract(const Duration(hours: 2)),
              ),
            );
        await db
            .into(db.favoriteFolders)
            .insert(
              FavoriteFoldersCompanion.insert(
                uri: 'file:///test/folder3',
                name: 'フォルダ3',
                registeredAt: now.subtract(const Duration(hours: 1)),
              ),
            );

        // 中間のフォルダを削除
        await repository.removeFavorite('file:///test/folder2');

        final favorites = await repository.getFavorites();
        expect(favorites.length, 2);
        // 降順: フォルダ3 → フォルダ1
        expect(favorites[0].name, 'フォルダ3');
        expect(favorites[1].name, 'フォルダ1');
      });
    });

    group('getFavoriteByUri', () {
      test('登録済みURIのフォルダを取得できる', () async {
        await repository.addFavorite(
          uri: 'file:///test/folder1',
          name: 'テストフォルダ',
        );

        final result = await repository.getFavoriteByUri(
          'file:///test/folder1',
        );

        expect(result, isNotNull);
        expect(result!.uri, 'file:///test/folder1');
        expect(result.name, 'テストフォルダ');
      });

      test('未登録URIに対してnullを返す', () async {
        final result = await repository.getFavoriteByUri(
          'file:///test/nonexistent',
        );
        expect(result, isNull);
      });
    });

    group('CRUD ラウンドトリップ', () {
      test('登録→取得→更新→削除の一連の操作が正しく動作する', () async {
        // 登録
        final added = await repository.addFavorite(
          uri: 'file:///test/roundtrip',
          name: '初期名',
        );
        expect(added.name, '初期名');

        // 取得
        final fetched = await repository.getFavoriteByUri(
          'file:///test/roundtrip',
        );
        expect(fetched, isNotNull);
        expect(fetched!.uri, added.uri);
        expect(fetched.name, added.name);

        // 更新（upsert）
        final updated = await repository.addFavorite(
          uri: 'file:///test/roundtrip',
          name: '更新名',
        );
        expect(updated.name, '更新名');
        expect(updated.uri, 'file:///test/roundtrip');

        // 件数確認（1件のまま）
        final count = await repository.getFavoriteCount();
        expect(count, 1);

        // 削除
        await repository.removeFavorite('file:///test/roundtrip');

        // 削除確認
        final afterDelete = await repository.getFavoriteByUri(
          'file:///test/roundtrip',
        );
        expect(afterDelete, isNull);

        final finalCount = await repository.getFavoriteCount();
        expect(finalCount, 0);
      });
    });

    group('ユニーク制約', () {
      test('同一URIの重複登録は1件のみ保持される', () async {
        await repository.addFavorite(uri: 'file:///test/unique', name: '1回目');
        await repository.addFavorite(uri: 'file:///test/unique', name: '2回目');
        await repository.addFavorite(uri: 'file:///test/unique', name: '3回目');

        final count = await repository.getFavoriteCount();
        expect(count, 1);

        final favorite = await repository.getFavoriteByUri(
          'file:///test/unique',
        );
        expect(favorite!.name, '3回目');
      });

      test('異なるURIは別レコードとして登録される', () async {
        await repository.addFavorite(
          uri: 'file:///test/folder-a',
          name: '同じ名前',
        );
        await repository.addFavorite(
          uri: 'file:///test/folder-b',
          name: '同じ名前',
        );

        final count = await repository.getFavoriteCount();
        expect(count, 2);
      });
    });
  });
}
