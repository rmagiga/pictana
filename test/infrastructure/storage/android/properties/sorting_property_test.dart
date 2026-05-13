/// Property 8: フォルダ名ケース非依存ソート
/// Property 6: StorageRoot ソート順序
/// Property 16: デフォルト画像フォルダ優先順位
///
/// Property 8: 任意の FolderEntry リストに対して、ケース非依存昇順ソートを適用した結果、
/// 隣接するすべてのペア (a, b) が a.name.toLowerCase() <= b.name.toLowerCase()
/// を満たすことを検証するプロパティテスト。
///
/// Property 6: 任意の StorageRoot リストに対して、ソート結果が
/// StorageType.internal を StorageType.usb より前に配置し、
/// 各タイプグループ内で名前昇順にソートされることを検証するプロパティテスト。
///
/// Property 16: 任意のディレクトリ存在フラグの組み合わせに対して、
/// getDefaultImageFolder() が DCIM > Pictures > null の優先順位で
/// 正しいフォルダを返すことを検証するプロパティテスト。
///
/// **Validates: Requirements 4.4**
/// **Validates: Requirements 3.1**
/// **Validates: Requirements 11.1, 11.2, 11.3**
@Tags(['android-saf'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, tearDown, test;
import 'package:optrig/domain/entities/entry_id.dart';
import 'package:optrig/domain/entities/folder_entry.dart';
import 'package:optrig/domain/entities/storage_root.dart';

/// フォルダ名のケース非依存ソート関数。
///
/// Kotlin 側の `String.CASE_INSENSITIVE_ORDER` と同等のロジックを
/// Dart 側で再現する。getChildFolders が返すリストはこの順序でソートされる。
List<FolderEntry> sortFoldersCaseInsensitive(List<FolderEntry> folders) {
  final sorted = List<FolderEntry>.from(folders);
  sorted.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return sorted;
}

/// StorageRoot のソート関数。
///
/// Kotlin 側の getStorageRoots と同等のロジックを Dart 側で再現する。
/// ソート順序: StorageType.internal を先に、StorageType.usb を後に配置し、
/// 各タイプグループ内で名前昇順にソートする。
List<StorageRoot> sortStorageRoots(List<StorageRoot> roots) {
  final sorted = List<StorageRoot>.from(roots);
  sorted.sort((a, b) {
    // タイプ優先度: internal=0, usb=1
    final typeOrder = _storageTypeOrder(
      a.type,
    ).compareTo(_storageTypeOrder(b.type));
    if (typeOrder != 0) return typeOrder;
    // 同タイプ内は名前昇順
    return a.name.compareTo(b.name);
  });
  return sorted;
}

/// StorageType のソート優先度を返す。
int _storageTypeOrder(StorageType type) => switch (type) {
  StorageType.internal => 0,
  StorageType.usb => 1,
  StorageType.sdCard => 2,
};

/// デフォルト画像フォルダの優先順位を解決する純粋関数。
///
/// Kotlin 側の SafCommands.getDefaultImageFolder と同等のロジックを
/// Dart 側で再現する。DCIM > Pictures > null の優先順位で返す。
///
/// [dcimExists] DCIM ディレクトリが存在するかどうか
/// [picturesExists] Pictures ディレクトリが存在するかどうか
///
/// 戻り値: 最優先のフォルダ名（'DCIM' or 'Pictures'）、どちらも存在しない場合は null
String? resolveDefaultImageFolder({
  required bool dcimExists,
  required bool picturesExists,
}) {
  if (dcimExists) return 'DCIM';
  if (picturesExists) return 'Pictures';
  return null;
}

/// StorageRoot テストデータ用のシンプルなデータクラス
class StorageRootData {
  final String name;
  final StorageType type;

  StorageRootData(this.name, this.type);

  @override
  String toString() => 'StorageRootData(name: $name, type: ${type.name})';
}

/// StorageRoot データリストのジェネレータ
extension StorageRootGenerators on Any {
  /// internal または usb のランダムな StorageType を生成する
  Generator<StorageType> get storageType =>
      any.choose([StorageType.internal, StorageType.usb]);

  /// ランダムな StorageRootData を生成する
  Generator<StorageRootData> get storageRootData => any.combine2(
    any.nonEmptyLetters,
    any.storageType,
    (String name, StorageType type) => StorageRootData(name, type),
  );

  /// ランダムな StorageRootData リストを生成する
  Generator<List<StorageRootData>> get storageRootDataList =>
      any.list(any.storageRootData);
}

void main() {
  group('Property 8: フォルダ名ケース非依存ソート', () {
    Glados(any.list(any.nonEmptyLetters)).test(
      'ソート結果の隣接ペアが a.name.toLowerCase() <= b.name.toLowerCase() を満たす',
      (names) {
        // ランダムなフォルダ名リストから FolderEntry リストを生成
        final folders = names
            .map(
              (name) => FolderEntry(
                id: EntryId.android('doc:$name'),
                name: name,
                uri: 'content://test/$name',
              ),
            )
            .toList();

        // ケース非依存ソートを適用
        final sorted = sortFoldersCaseInsensitive(folders);

        // 隣接ペアの順序を検証
        for (var i = 0; i < sorted.length - 1; i++) {
          final a = sorted[i].name.toLowerCase();
          final b = sorted[i + 1].name.toLowerCase();
          expect(
            a.compareTo(b) <= 0,
            isTrue,
            reason: 'ソート順序違反: "$a" > "$b" (index $i, ${i + 1})',
          );
        }
      },
    );

    Glados(any.list(any.nonEmptyLetters)).test(
      'ソート結果の要素数が入力と同じである（要素の欠落・重複なし）',
      (names) {
        final folders = names
            .map(
              (name) => FolderEntry(
                id: EntryId.android('doc:$name'),
                name: name,
                uri: 'content://test/$name',
              ),
            )
            .toList();

        final sorted = sortFoldersCaseInsensitive(folders);

        expect(sorted.length, equals(folders.length));
      },
    );

    Glados(any.list(any.nonEmptyLetters)).test('ソート結果が入力と同じ要素を含む（並べ替えのみ）', (
      names,
    ) {
      final folders = names
          .map(
            (name) => FolderEntry(
              id: EntryId.android('doc:$name'),
              name: name,
              uri: 'content://test/$name',
            ),
          )
          .toList();

      final sorted = sortFoldersCaseInsensitive(folders);

      // 入力の名前リストとソート後の名前リストが同じ要素を含むことを検証
      final inputNames = folders.map((f) => f.name).toList()..sort();
      final sortedNames = sorted.map((f) => f.name).toList()..sort();
      expect(sortedNames, equals(inputNames));
    });

    Glados(any.list(any.nonEmptyLetters)).test('ソートは冪等である（2回適用しても結果が変わらない）', (
      names,
    ) {
      final folders = names
          .map(
            (name) => FolderEntry(
              id: EntryId.android('doc:$name'),
              name: name,
              uri: 'content://test/$name',
            ),
          )
          .toList();

      final sorted1 = sortFoldersCaseInsensitive(folders);
      final sorted2 = sortFoldersCaseInsensitive(sorted1);

      // 2回ソートしても同じ順序になることを検証
      for (var i = 0; i < sorted1.length; i++) {
        expect(sorted2[i].name, equals(sorted1[i].name));
      }
    });
  });

  group('Feature: android-saf, Property 6: StorageRoot ソート順序', () {
    Glados(
      any.storageRootDataList,
    ).test('すべての internal エントリが usb エントリより前に配置される', (rootDataList) {
      // StorageRoot リストを生成
      final roots = rootDataList
          .map(
            (data) => StorageRoot(
              id: EntryId.android('vol:${data.name}'),
              name: data.name,
              type: data.type,
              uri: 'content://storage/${data.name}',
            ),
          )
          .toList();

      // ソートを適用
      final sorted = sortStorageRoots(roots);

      // internal エントリのインデックスがすべて usb エントリのインデックスより小さいことを検証
      final lastInternalIndex = sorted.lastIndexWhere(
        (r) => r.type == StorageType.internal,
      );
      final firstUsbIndex = sorted.indexWhere((r) => r.type == StorageType.usb);

      if (lastInternalIndex >= 0 && firstUsbIndex >= 0) {
        expect(
          lastInternalIndex < firstUsbIndex,
          isTrue,
          reason:
              'internal エントリ (index $lastInternalIndex) が usb エントリ (index $firstUsbIndex) より後にある',
        );
      }
    });

    Glados(any.storageRootDataList).test('同タイプグループ内で名前昇順にソートされる', (
      rootDataList,
    ) {
      final roots = rootDataList
          .map(
            (data) => StorageRoot(
              id: EntryId.android('vol:${data.name}'),
              name: data.name,
              type: data.type,
              uri: 'content://storage/${data.name}',
            ),
          )
          .toList();

      final sorted = sortStorageRoots(roots);

      // 各タイプグループ内で名前昇順を検証
      for (final type in [StorageType.internal, StorageType.usb]) {
        final group = sorted.where((r) => r.type == type).toList();
        for (var i = 0; i < group.length - 1; i++) {
          expect(
            group[i].name.compareTo(group[i + 1].name) <= 0,
            isTrue,
            reason:
                '${type.name} グループ内ソート順序違反: "${group[i].name}" > "${group[i + 1].name}"',
          );
        }
      }
    });

    Glados(any.storageRootDataList).test('ソート結果の要素数が入力と同じである', (rootDataList) {
      final roots = rootDataList
          .map(
            (data) => StorageRoot(
              id: EntryId.android('vol:${data.name}'),
              name: data.name,
              type: data.type,
              uri: 'content://storage/${data.name}',
            ),
          )
          .toList();

      final sorted = sortStorageRoots(roots);

      expect(sorted.length, equals(roots.length));
    });

    Glados(any.storageRootDataList).test('ソートは冪等である（2回適用しても結果が変わらない）', (
      rootDataList,
    ) {
      final roots = rootDataList
          .map(
            (data) => StorageRoot(
              id: EntryId.android('vol:${data.name}'),
              name: data.name,
              type: data.type,
              uri: 'content://storage/${data.name}',
            ),
          )
          .toList();

      final sorted1 = sortStorageRoots(roots);
      final sorted2 = sortStorageRoots(sorted1);

      for (var i = 0; i < sorted1.length; i++) {
        expect(sorted2[i].name, equals(sorted1[i].name));
        expect(sorted2[i].type, equals(sorted1[i].type));
      }
    });
  });

  group('Feature: android-saf, Property 16: デフォルト画像フォルダ優先順位', () {
    Glados2(any.bool, any.bool).test('DCIM が存在する場合は常に DCIM を返す', (
      dcimExists,
      picturesExists,
    ) {
      final result = resolveDefaultImageFolder(
        dcimExists: dcimExists,
        picturesExists: picturesExists,
      );

      if (dcimExists) {
        expect(result, isNotNull);
        expect(result, equals('DCIM'));
      }
    });

    Glados2(any.bool, any.bool).test('DCIM が存在しない場合のみ Pictures を返す', (
      dcimExists,
      picturesExists,
    ) {
      final result = resolveDefaultImageFolder(
        dcimExists: dcimExists,
        picturesExists: picturesExists,
      );

      if (!dcimExists && picturesExists) {
        expect(result, isNotNull);
        expect(result, equals('Pictures'));
      }
    });

    Glados2(any.bool, any.bool).test('どちらも存在しない場合は null を返す', (
      dcimExists,
      picturesExists,
    ) {
      final result = resolveDefaultImageFolder(
        dcimExists: dcimExists,
        picturesExists: picturesExists,
      );

      if (!dcimExists && !picturesExists) {
        expect(result, isNull);
      }
    });

    Glados2(any.bool, any.bool).test(
      '優先順位の網羅検証: 結果は DCIM > Pictures > null の順序に従う',
      (dcimExists, picturesExists) {
        final result = resolveDefaultImageFolder(
          dcimExists: dcimExists,
          picturesExists: picturesExists,
        );

        // 全パターンの期待値を網羅的に検証
        if (dcimExists) {
          expect(
            result,
            equals('DCIM'),
            reason:
                'DCIM が存在する場合は Pictures の有無に関わらず DCIM を返すべき '
                '(dcimExists=$dcimExists, picturesExists=$picturesExists)',
          );
        } else if (picturesExists) {
          expect(
            result,
            equals('Pictures'),
            reason:
                'DCIM が存在せず Pictures が存在する場合は Pictures を返すべき '
                '(dcimExists=$dcimExists, picturesExists=$picturesExists)',
          );
        } else {
          expect(
            result,
            isNull,
            reason:
                'どちらも存在しない場合は null を返すべき '
                '(dcimExists=$dcimExists, picturesExists=$picturesExists)',
          );
        }
      },
    );
  });
}
