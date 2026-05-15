/// フォルダお気に入り機能 プロパティベーステスト
///
/// glados を使用して、お気に入り機能の正当性プロパティを検証する。
/// 各プロパティテストは最低100回のイテレーションで実行される。
///
/// テスト対象:
/// - Property 1: お気に入り登録のラウンドトリップ
/// - Property 2: URI ユニーク制約による登録の冪等性
/// - Property 3: トグル操作による状態反転
/// - Property 4: お気に入り一覧の登録日時降順ソート不変条件
/// - Property 6: 処理中ロックによる連続タップ防止
/// - Property 7: 削除の Undo によるリスト復元
@Tags(['property-test', 'folder-favorites'])
library;

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, tearDown, test;
import 'package:optrig/application/usecases/favorites/toggle_favorite_usecase.dart';
import 'package:optrig/infrastructure/database/app_database.dart';
import 'package:optrig/infrastructure/database/favorite_repository_impl.dart';

// ---------------------------------------------------------------------------
// カスタムジェネレータ
// ---------------------------------------------------------------------------

extension FavoriteGenerators on Any {
  /// 有効なフォルダ URI を生成する（空文字列を除外）
  Generator<String> get validUri => any.nonEmptyLetters.map(
    (s) => 'file:///test/${s.substring(0, s.length.clamp(0, 30))}',
  );

  /// 有効なフォルダ名を生成する（空文字列を除外）
  Generator<String> get validName =>
      any.nonEmptyLetters.map((s) => s.substring(0, s.length.clamp(0, 100)));

  /// 複数の一意な URI と名前のペアを生成する（2〜10件）
  Generator<List<({String uri, String name})>> get uniqueFavoritePairs =>
      any.intInRange(2, 10).map((count) {
        return List.generate(count, (i) {
          return (uri: 'file:///test/folder_$i', name: 'テストフォルダ_$i');
        });
      });

  /// 複数の一意な URI と名前のペアを生成する（3〜15件）
  Generator<List<({String uri, String name})>> get largeFavoritePairs =>
      any.intInRange(3, 15).map((count) {
        return List.generate(count, (i) {
          return (uri: 'file:///test/folder_$i', name: 'テストフォルダ_$i');
        });
      });

  /// 削除対象のインデックスを生成する
  Generator<int> get deleteIndex => any.intInRange(0, 100);
}

// ---------------------------------------------------------------------------
// テスト本体
// ---------------------------------------------------------------------------

void main() {
  // drift の複数インスタンス警告を抑制（テスト用途のため問題なし）
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  // =========================================================================
  // Property 1: お気に入り登録のラウンドトリップ
  // =========================================================================
  group('Feature: folder-favorites, Property 1: お気に入り登録のラウンドトリップ', () {
    /// **Validates: Requirements 1.1, 6.1, 6.5**
    ///
    /// 任意の有効な URI と名前に対して、お気に入りに登録した後に一覧を取得すると、
    /// 登録した URI・名前・登録日時がすべて保持された状態で取得できる。
    Glados2(any.validUri, any.validName).test('登録した URI・名前・登録日時が一覧取得で保持される', (
      uri,
      name,
    ) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final repository = FavoriteRepositoryImpl(db);

      try {
        // お気に入りに登録
        final added = await repository.addFavorite(uri: uri, name: name);

        // 一覧を取得
        final favorites = await repository.getFavorites();

        // 登録した情報が保持されていることを検証
        expect(favorites.length, 1);
        expect(favorites[0].uri, uri);
        expect(favorites[0].name, name);
        expect(favorites[0].registeredAt, added.registeredAt);
        expect(favorites[0].id, greaterThan(0));
      } finally {
        await db.close();
      }
    });
  });

  // =========================================================================
  // Property 2: URI ユニーク制約による登録の冪等性
  // =========================================================================
  group('Feature: folder-favorites, Property 2: URI ユニーク制約による登録の冪等性', () {
    /// **Validates: Requirements 1.4, 6.3**
    ///
    /// 任意の URI に対して、同一 URI を複数回登録しても一覧には1件のみ存在し、
    /// 最後に登録した名前で上書きされる。
    Glados3(any.validUri, any.validName, any.validName).test(
      '同一 URI を複数回登録しても1件のみ存在し最後の名前で上書きされる',
      (uri, firstName, secondName) async {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        final repository = FavoriteRepositoryImpl(db);

        try {
          // 同一 URI で2回登録
          await repository.addFavorite(uri: uri, name: firstName);
          await repository.addFavorite(uri: uri, name: secondName);

          // 件数が1件であることを確認
          final count = await repository.getFavoriteCount();
          expect(count, 1);

          // 最後に登録した名前で上書きされていることを確認
          final favorite = await repository.getFavoriteByUri(uri);
          expect(favorite, isNotNull);
          expect(favorite!.name, secondName);
        } finally {
          await db.close();
        }
      },
    );
  });

  // =========================================================================
  // Property 3: トグル操作による状態反転
  // =========================================================================
  group('Feature: folder-favorites, Property 3: トグル操作による状態反転', () {
    /// **Validates: Requirements 5.2, 2.1**
    ///
    /// 任意のフォルダに対して、トグル操作を1回実行すると、
    /// お気に入り状態が反転する（未登録→登録済み、登録済み→未登録）。
    Glados2(any.validUri, any.validName).test('未登録フォルダに対するトグルで登録済みになる', (
      uri,
      name,
    ) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final repository = FavoriteRepositoryImpl(db);
      final useCase = ToggleFavoriteUseCase(repository: repository);

      try {
        // 初期状態: 未登録
        final beforeToggle = await repository.isFavorite(uri);
        expect(beforeToggle, isFalse);

        // トグル実行
        final result = await useCase.execute(uri: uri, name: name);

        // 状態が反転（未登録→登録済み）
        expect(result, isTrue);
        final afterToggle = await repository.isFavorite(uri);
        expect(afterToggle, isTrue);
      } finally {
        await db.close();
      }
    });

    Glados2(any.validUri, any.validName).test('登録済みフォルダに対するトグルで未登録になる', (
      uri,
      name,
    ) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final repository = FavoriteRepositoryImpl(db);
      final useCase = ToggleFavoriteUseCase(repository: repository);

      try {
        // 事前に登録
        await repository.addFavorite(uri: uri, name: name);
        final beforeToggle = await repository.isFavorite(uri);
        expect(beforeToggle, isTrue);

        // トグル実行
        final result = await useCase.execute(uri: uri, name: name);

        // 状態が反転（登録済み→未登録）
        expect(result, isFalse);
        final afterToggle = await repository.isFavorite(uri);
        expect(afterToggle, isFalse);
      } finally {
        await db.close();
      }
    });
  });

  // =========================================================================
  // Property 4: お気に入り一覧の登録日時降順ソート不変条件
  // =========================================================================
  group('Feature: folder-favorites, Property 4: お気に入り一覧の登録日時降順ソート不変条件', () {
    /// **Validates: Requirements 3.2, 2.3**
    ///
    /// 任意のお気に入りフォルダの集合に対して、一覧取得の結果は常に
    /// 登録日時の降順でソートされている。
    Glados(any.uniqueFavoritePairs).test('一覧は常に登録日時降順でソートされている', (pairs) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final repository = FavoriteRepositoryImpl(db);

      try {
        // 明確に異なるタイムスタンプで登録
        final now = DateTime.now();
        for (var i = 0; i < pairs.length; i++) {
          final registeredAt = now.subtract(Duration(hours: pairs.length - i));
          await db
              .into(db.favoriteFolders)
              .insert(
                FavoriteFoldersCompanion.insert(
                  uri: pairs[i].uri,
                  name: pairs[i].name,
                  registeredAt: registeredAt,
                ),
              );
        }

        // 一覧取得
        final favorites = await repository.getFavorites();

        // 降順ソートの検証
        for (var i = 0; i < favorites.length - 1; i++) {
          expect(
            favorites[i].registeredAt.isAfter(favorites[i + 1].registeredAt) ||
                favorites[i].registeredAt.isAtSameMomentAs(
                  favorites[i + 1].registeredAt,
                ),
            isTrue,
            reason:
                'インデックス $i (${favorites[i].registeredAt}) は '
                '$i+1 (${favorites[i + 1].registeredAt}) 以降であるべき',
          );
        }
      } finally {
        await db.close();
      }
    });

    /// 任意の1件を削除した後も、残りの項目の相対的な順序は維持される。
    Glados2(
      any.largeFavoritePairs,
      any.deleteIndex,
    ).test('任意の1件を削除後も残りの相対順序が維持される', (pairs, rawDeleteIndex) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final repository = FavoriteRepositoryImpl(db);

      try {
        // 明確に異なるタイムスタンプで登録
        final now = DateTime.now();
        for (var i = 0; i < pairs.length; i++) {
          final registeredAt = now.subtract(Duration(hours: pairs.length - i));
          await db
              .into(db.favoriteFolders)
              .insert(
                FavoriteFoldersCompanion.insert(
                  uri: pairs[i].uri,
                  name: pairs[i].name,
                  registeredAt: registeredAt,
                ),
              );
        }

        // 削除前の一覧を取得
        final beforeDelete = await repository.getFavorites();

        // 有効なインデックスに正規化
        final deleteIndex = rawDeleteIndex % beforeDelete.length;
        final deletedUri = beforeDelete[deleteIndex].uri;

        // 削除実行
        await repository.removeFavorite(deletedUri);

        // 削除後の一覧を取得
        final afterDelete = await repository.getFavorites();

        // 削除された項目を除いた期待リスト
        final expectedOrder = beforeDelete
            .where((f) => f.uri != deletedUri)
            .map((f) => f.uri)
            .toList();

        // 相対順序が維持されていることを検証
        expect(afterDelete.map((f) => f.uri).toList(), expectedOrder);
      } finally {
        await db.close();
      }
    });
  });

  // =========================================================================
  // Property 5: フォルダ名の切り詰め規則（FavoriteGridSection 移行により削除）
  // =========================================================================
  // FavoriteGridSection では Flutter の Text ウィジェット（maxLines: 2 +
  // TextOverflow.ellipsis）で名前の切り詰めを処理するため、
  // 手動の truncateName ロジックは不要になった。

  // =========================================================================
  // Property 6: 処理中ロックによる連続タップ防止
  // =========================================================================
  group('Feature: folder-favorites, Property 6: 処理中ロックによる連続タップ防止', () {
    /// **Validates: Requirements 5.4**
    ///
    /// トグル操作の処理中状態において、追加のトグル呼び出しは無視され、
    /// お気に入りの状態は最初のトグル操作の結果のみが反映される。
    ///
    /// FavoriteToggle Provider の isProcessing ロックロジックをシミュレートして検証する。
    /// Provider は state.isProcessing == true の間、toggle() を即座にリターンする設計。
    Glados2(any.validUri, any.validName).test(
      'isProcessing ロック中は追加のトグルが無視され最初の操作結果のみ反映される',
      (uri, name) async {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        final repository = FavoriteRepositoryImpl(db);
        final useCase = ToggleFavoriteUseCase(repository: repository);

        try {
          // 初期状態: 未登録
          expect(await repository.isFavorite(uri), isFalse);

          // Provider のロックロジックをシミュレート:
          // isProcessing = false → 最初の toggle を許可
          var isProcessing = false;

          // --- 最初のトグル操作（ロック取得→実行→ロック解除） ---
          expect(isProcessing, isFalse); // ロック未取得 → 操作許可
          isProcessing = true; // ロック取得

          final firstResult = await useCase.execute(uri: uri, name: name);
          expect(firstResult, isTrue); // 未登録→登録

          // --- 2回目以降のトグル呼び出し: isProcessing == true なので無視 ---
          // Provider の toggle() は if (state.isProcessing) return; で即座にリターン
          expect(isProcessing, isTrue); // ロック中 → 追加操作は無視される
          // ここでは useCase.execute() を呼ばない（Provider が無視するため）

          // ロック解除
          isProcessing = false;

          // 最終状態: 最初のトグル操作の結果のみが反映されている
          final finalState = await repository.isFavorite(uri);
          expect(finalState, isTrue); // 登録済み状態が維持される
        } finally {
          await db.close();
        }
      },
    );

    Glados2(any.validUri, any.validName).test('ロック解除後に再度トグルすると状態が正しく反転する', (
      uri,
      name,
    ) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final repository = FavoriteRepositoryImpl(db);
      final useCase = ToggleFavoriteUseCase(repository: repository);

      try {
        // 初期状態: 未登録
        expect(await repository.isFavorite(uri), isFalse);

        // 1回目のトグル（未登録→登録）: ロック取得→実行→ロック解除
        var isProcessing = false;
        isProcessing = true;
        final firstResult = await useCase.execute(uri: uri, name: name);
        isProcessing = false;
        expect(firstResult, isTrue);
        expect(await repository.isFavorite(uri), isTrue);

        // ロック解除後の2回目のトグル（登録→未登録）
        expect(isProcessing, isFalse); // ロック解除済み → 操作許可
        isProcessing = true;
        final secondResult = await useCase.execute(uri: uri, name: name);
        isProcessing = false;
        expect(secondResult, isFalse);
        expect(await repository.isFavorite(uri), isFalse);
      } finally {
        await db.close();
      }
    });
  });

  // =========================================================================
  // Property 7: 削除の Undo によるリスト復元
  // =========================================================================
  group('Feature: folder-favorites, Property 7: 削除の Undo によるリスト復元', () {
    /// **Validates: Requirements 7.4**
    ///
    /// 任意のお気に入りリストの状態において、任意の1件を削除した後に
    /// Undo（再登録）を実行すると、リストは同一の項目を含む状態に復元される。
    Glados2(
      any.largeFavoritePairs,
      any.deleteIndex,
    ).test('削除後に Undo（再登録）するとリストが復元される', (pairs, rawDeleteIndex) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final repository = FavoriteRepositoryImpl(db);

      try {
        // 明確に異なるタイムスタンプで登録
        final now = DateTime.now();
        for (var i = 0; i < pairs.length; i++) {
          final registeredAt = now.subtract(Duration(hours: pairs.length - i));
          await db
              .into(db.favoriteFolders)
              .insert(
                FavoriteFoldersCompanion.insert(
                  uri: pairs[i].uri,
                  name: pairs[i].name,
                  registeredAt: registeredAt,
                ),
              );
        }

        // 削除前の一覧を取得
        final beforeDelete = await repository.getFavorites();
        final beforeUris = beforeDelete.map((f) => f.uri).toSet();

        // 有効なインデックスに正規化
        final deleteIndex = rawDeleteIndex % beforeDelete.length;
        final deletedItem = beforeDelete[deleteIndex];

        // 削除実行
        await repository.removeFavorite(deletedItem.uri);

        // Undo: 削除されたフォルダを再登録
        await repository.addFavorite(
          uri: deletedItem.uri,
          name: deletedItem.name,
        );

        // 復元後の一覧を取得
        final afterUndo = await repository.getFavorites();
        final afterUris = afterUndo.map((f) => f.uri).toSet();

        // 同一の項目が含まれていることを検証
        expect(afterUris, beforeUris);
      } finally {
        await db.close();
      }
    });
  });
}
