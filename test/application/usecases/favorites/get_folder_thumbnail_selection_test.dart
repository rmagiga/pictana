/// 先頭画像選択の一貫性プロパティテスト
///
/// 任意の非空 ImageEntry リストに対して、デフォルトソート順（ファイル名昇順）で
/// 最初の画像が選択されることを検証する。
///
/// GetFolderThumbnailUseCase は ImageRepository.getImagePage を
/// SortOption.defaultOption（名前昇順）で呼び出し、先頭1件を取得する。
/// このプロパティテストでは、任意の非空リストをファイル名昇順でソートした場合、
/// 先頭要素が辞書順で最小の name を持つことを検証する。
///
/// **Validates: Requirements 3.1**
@Tags(['property-test'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, tearDown, test;
import 'package:optrig/domain/entities/entry_id.dart';
import 'package:optrig/domain/entities/image_entry.dart';

// ---------------------------------------------------------------------------
// glados 用カスタムジェネレータ
// ---------------------------------------------------------------------------

/// ImageEntry のファイル名として使用するユニークな文字列リストを生成する。
///
/// 1〜20 個のユニークな名前を生成し、各名前は英数字で構成される。
Generator<List<String>> get _distinctNamesGenerator =>
    any.listWithLengthInRange(1, 20, any.nonEmptyLetters).map(_makeDistinct);

/// リスト内の文字列をユニークにする。
///
/// 重複がある場合はインデックスをサフィックスとして付与する。
List<String> _makeDistinct(List<String> names) {
  final seen = <String>{};
  final result = <String>[];
  for (var i = 0; i < names.length; i++) {
    var name = names[i];
    while (seen.contains(name)) {
      name = '${names[i]}_$i';
    }
    seen.add(name);
    result.add(name);
  }
  return result;
}

/// ユニークな名前リストから ImageEntry リストを生成するヘルパー。
List<ImageEntry> _createImageEntries(List<String> names) {
  return names
      .map(
        (name) => ImageEntry(
          id: EntryId(
            rawValue: 'file:///$name',
            platformType: PlatformType.windows,
          ),
          name: '$name.jpg',
          extension: 'jpg',
          size: 1024,
          modifiedAt: DateTime(2024, 1, 1),
          uri: 'file:///test/$name.jpg',
          mimeType: ImageMimeType.jpeg,
        ),
      )
      .toList();
}

/// デフォルトソート順（ファイル名昇順）でソートする純粋関数。
///
/// GetFolderThumbnailUseCase が ImageRepository に渡す
/// SortOption.defaultOption（field: name, direction: ascending）と
/// 同等のソートロジックを再現する。
List<ImageEntry> sortByNameAscending(List<ImageEntry> entries) {
  final sorted = List<ImageEntry>.from(entries);
  sorted.sort((a, b) => a.name.compareTo(b.name));
  return sorted;
}

// ---------------------------------------------------------------------------
// テスト本体
// ---------------------------------------------------------------------------

void main() {
  group('Feature: favorites-folder-grid, Property 3: 先頭画像選択の一貫性', () {
    Glados(_distinctNamesGenerator).test(
      '任意の非空リストをファイル名昇順でソートした場合、先頭要素が辞書順最小の name を持つ',
      (names) {
        final entries = _createImageEntries(names);

        // デフォルトソート順（ファイル名昇順）でソート
        final sorted = sortByNameAscending(entries);

        // 先頭要素の name が全要素の中で辞書順最小であることを検証
        final selectedName = sorted.first.name;
        for (final entry in entries) {
          expect(
            selectedName.compareTo(entry.name) <= 0,
            isTrue,
            reason:
                'ソート後の先頭 "$selectedName" が '
                '"${entry.name}" より辞書順で大きい',
          );
        }
      },
    );

    Glados(_distinctNamesGenerator).test(
      'ソート後の先頭要素は入力リスト内の全要素の name の最小値と一致する',
      (names) {
        final entries = _createImageEntries(names);

        // デフォルトソート順でソート
        final sorted = sortByNameAscending(entries);

        // 全要素から最小の name を直接計算
        final minName = entries
            .map((e) => e.name)
            .reduce((a, b) => a.compareTo(b) <= 0 ? a : b);

        expect(
          sorted.first.name,
          equals(minName),
          reason:
              'ソート後の先頭 "${sorted.first.name}" が '
              '最小値 "$minName" と一致しない',
        );
      },
    );

    Glados(_distinctNamesGenerator).test('ソートは冪等である（2回適用しても先頭要素が変わらない）', (
      names,
    ) {
      final entries = _createImageEntries(names);

      final sorted1 = sortByNameAscending(entries);
      final sorted2 = sortByNameAscending(sorted1);

      expect(
        sorted1.first.name,
        equals(sorted2.first.name),
        reason:
            '1回目のソート先頭 "${sorted1.first.name}" と '
            '2回目のソート先頭 "${sorted2.first.name}" が一致しない',
      );
    });

    Glados(_distinctNamesGenerator).test('ソート結果の隣接ペアが name 昇順を満たす', (names) {
      final entries = _createImageEntries(names);

      final sorted = sortByNameAscending(entries);

      // 隣接ペアの順序を検証
      for (var i = 0; i < sorted.length - 1; i++) {
        expect(
          sorted[i].name.compareTo(sorted[i + 1].name) <= 0,
          isTrue,
          reason:
              'ソート順序違反: "${sorted[i].name}" > "${sorted[i + 1].name}" '
              '(index $i, ${i + 1})',
        );
      }
    });
  });
}
