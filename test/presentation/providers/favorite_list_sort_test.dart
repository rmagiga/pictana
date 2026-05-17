/// お気に入り一覧の降順ソート プロパティテスト
///
/// 任意の FavoriteFolder リストに対して、表示順が
/// registeredAt 降順（新しい順）であることを検証する。
///
/// **Validates: Requirements 1.1**
@Tags(['property-test'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, tearDown, test;
import 'package:pictana/domain/entities/favorite_folder.dart';

// ---------------------------------------------------------------------------
// glados 用カスタムジェネレータ
// ---------------------------------------------------------------------------

/// ユニークな registeredAt を持つ FavoriteFolder リストを生成するジェネレータ
///
/// 0〜50 件のリストを生成し、各要素は異なる registeredAt を持つ。
/// id と uri もユニークに生成する。
Generator<List<FavoriteFolder>> get _favoriteFolderListGenerator =>
    any.listWithLengthInRange(0, 50, any.intInRange(0, 1000000)).map((offsets) {
      final baseTime = DateTime(2020);
      final folders = <FavoriteFolder>[];
      for (var i = 0; i < offsets.length; i++) {
        // オフセットをユニークにするため、インデックスを加算
        final uniqueOffset = offsets[i] * offsets.length + i;
        folders.add(
          FavoriteFolder(
            id: i + 1,
            uri: 'file:///test/folder_$i',
            name: 'フォルダ $i',
            registeredAt: baseTime.add(Duration(seconds: uniqueOffset)),
          ),
        );
      }
      // リストをシャッフルして返す（ソート前の状態をシミュレート）
      folders.shuffle();
      return folders;
    });

// ---------------------------------------------------------------------------
// ソートロジック（Provider/Repository と同じロジック）
// ---------------------------------------------------------------------------

/// registeredAt 降順でソートする（Provider が返す順序と同じ）
///
/// FavoriteRepositoryImpl.getFavorites() は
/// `orderBy desc(registeredAt)` でソートしている。
List<FavoriteFolder> sortByRegisteredAtDescending(
  List<FavoriteFolder> folders,
) {
  final sorted = List<FavoriteFolder>.from(folders);
  sorted.sort((a, b) => b.registeredAt.compareTo(a.registeredAt));
  return sorted;
}

void main() {
  // =========================================================================
  // プロパティベーステスト
  // =========================================================================
  group('Feature: favorites-folder-grid, Property 2: お気に入り一覧の降順ソート', () {
    Glados(_favoriteFolderListGenerator).test(
      '任意の FavoriteFolder リストをソートした結果は registeredAt 降順である',
      (folders) {
        final sorted = sortByRegisteredAtDescending(folders);

        // 空リストまたは1件のリストは常にソート済み
        if (sorted.length <= 1) return;

        // 連続する全てのペアについて、前の要素の registeredAt が
        // 後の要素の registeredAt より大きい（降順）ことを検証
        for (var i = 0; i < sorted.length - 1; i++) {
          expect(
            sorted[i].registeredAt.isAfter(sorted[i + 1].registeredAt),
            isTrue,
            reason:
                'インデックス $i と ${i + 1} の間でソート順が不正: '
                '${sorted[i].registeredAt} は '
                '${sorted[i + 1].registeredAt} より後であるべき',
          );
        }
      },
    );

    Glados(
      _favoriteFolderListGenerator,
    ).test('ソート後のリストは元のリストと同じ要素を含む（要素の欠落・重複がない）', (folders) {
      final sorted = sortByRegisteredAtDescending(folders);

      // 要素数が同じ
      expect(
        sorted.length,
        equals(folders.length),
        reason: 'ソート後の要素数が元のリストと異なる',
      );

      // 全ての元要素がソート後にも存在する
      final sortedIds = sorted.map((f) => f.id).toSet();
      final originalIds = folders.map((f) => f.id).toSet();
      expect(sortedIds, equals(originalIds), reason: 'ソート後の要素IDセットが元のリストと異なる');
    });

    Glados(_favoriteFolderListGenerator).test('ソートは冪等である（2回ソートしても結果が同じ）', (
      folders,
    ) {
      final sorted1 = sortByRegisteredAtDescending(folders);
      final sorted2 = sortByRegisteredAtDescending(sorted1);

      expect(
        sorted2.length,
        equals(sorted1.length),
        reason: '2回目のソート後の要素数が1回目と異なる',
      );

      for (var i = 0; i < sorted1.length; i++) {
        expect(
          sorted2[i].id,
          equals(sorted1[i].id),
          reason: 'インデックス $i で2回目のソート結果が1回目と異なる',
        );
      }
    });
  });
}
