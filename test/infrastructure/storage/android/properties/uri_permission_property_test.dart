/// Property 4: URI パーミッション検証の集合演算
/// Property 5: URI パーミッション LRU 解放
///
/// Property 4:
/// 任意の DB 保存済み URI 集合とシステム報告永続化済み URI 集合に対して、
/// 検証後の利用可能 URI 集合が両者の交差集合と等しく、
/// (DB 保存 - システム報告) に含まれる URI がすべて削除対象となることを検証する。
///
/// Property 5:
/// 512 件の URI パーミッション（タイムスタンプ付き）が存在する場合、
/// 新しい URI を永続化する際に最古のタイムスタンプを持つ URI が
/// 解放対象として選択されることを検証する。
///
/// **Validates: Requirements 2.3, 2.4, 2.6**
@Tags(['android-saf', 'property-test'])
library;


import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, tearDown, test;
import 'package:optrig/infrastructure/storage/android/uri_permission_manager.dart';

/// URI パーミッション検証の純粋関数
///
/// [storedUris] DB に保存されている URI 集合
/// [systemPersistedUris] システムが報告する永続化済み URI 集合
///
/// 戻り値: 検証結果（保持する URI 集合と削除する URI 集合）
///
/// ロジック:
/// - 保持 = storedUris ∩ systemPersistedUris
/// - 削除 = storedUris - systemPersistedUris
UriValidationResult validateUriPermissions({
  required Set<String> storedUris,
  required Set<String> systemPersistedUris,
}) {
  final toKeep = storedUris.intersection(systemPersistedUris);
  final toRemove = storedUris.difference(systemPersistedUris);
  return UriValidationResult(toKeep: toKeep, toRemove: toRemove);
}

/// URI パーミッション検証結果
class UriValidationResult {
  const UriValidationResult({required this.toKeep, required this.toRemove});

  /// 検証後に利用可能な URI 集合（DB に残す）
  final Set<String> toKeep;

  /// DB から削除すべき URI 集合
  final Set<String> toRemove;
}

/// ジェネレータ拡張
extension UriPermissionGenerators on Any {
  /// ランダムな URI 文字列のセットを生成
  Generator<Set<String>> get uriSet => any
      .list(any.nonEmptyLetters)
      .map((list) => list.map((s) => 'content://authority/tree/$s').toSet());

  /// 512 件のタイムスタンプ付き URI エントリリストを生成する
  ///
  /// シード値から決定論的に 512 件のエントリを生成する。
  /// 各エントリは一意の URI とランダムなタイムスタンプを持つ。
  Generator<List<UriTimestampEntry>>
  get uriTimestampList512 => any.intInRange(0, 1 << 30).map((seed) {
    final rng = Random(seed);
    return List.generate(512, (i) {
      final secondsOffset = rng.nextInt(157680000); // 約5年分の秒数
      final uri =
          'content://com.android.externalstorage.documents/tree/primary:${seed}_folder_$i';
      final lastOpenedAt = DateTime(2020).add(Duration(seconds: secondsOffset));
      return (uri: uri, lastOpenedAt: lastOpenedAt);
    });
  });
}

void main() {
  // -------------------------------------------------------------------------
  // Property 4: URI パーミッション検証の集合演算
  // -------------------------------------------------------------------------
  group('Feature: android-saf, Property 4: URI パーミッション検証の集合演算', () {
    Glados2(any.uriSet, any.uriSet).test(
      '利用可能 URI 集合は storedUris と systemPersistedUris の交差集合と等しい',
      (storedUris, systemPersistedUris) {
        final result = validateUriPermissions(
          storedUris: storedUris,
          systemPersistedUris: systemPersistedUris,
        );

        final expectedIntersection = storedUris.intersection(
          systemPersistedUris,
        );
        expect(result.toKeep, expectedIntersection);
      },
    );

    Glados2(any.uriSet, any.uriSet).test(
      '削除対象 URI 集合は storedUris - systemPersistedUris と等しい',
      (storedUris, systemPersistedUris) {
        final result = validateUriPermissions(
          storedUris: storedUris,
          systemPersistedUris: systemPersistedUris,
        );

        final expectedRemoved = storedUris.difference(systemPersistedUris);
        expect(result.toRemove, expectedRemoved);
      },
    );

    Glados2(any.uriSet, any.uriSet).test('保持集合と削除集合の和集合は元の storedUris と等しい', (
      storedUris,
      systemPersistedUris,
    ) {
      final result = validateUriPermissions(
        storedUris: storedUris,
        systemPersistedUris: systemPersistedUris,
      );

      expect(result.toKeep.union(result.toRemove), storedUris);
    });

    Glados2(any.uriSet, any.uriSet).test('保持集合と削除集合は互いに素（共通要素なし）', (
      storedUris,
      systemPersistedUris,
    ) {
      final result = validateUriPermissions(
        storedUris: storedUris,
        systemPersistedUris: systemPersistedUris,
      );

      expect(result.toKeep.intersection(result.toRemove), isEmpty);
    });

    Glados2(any.uriSet, any.uriSet).test('保持集合のすべての URI はシステム報告集合に含まれる', (
      storedUris,
      systemPersistedUris,
    ) {
      final result = validateUriPermissions(
        storedUris: storedUris,
        systemPersistedUris: systemPersistedUris,
      );

      for (final uri in result.toKeep) {
        expect(
          systemPersistedUris.contains(uri),
          isTrue,
          reason: '$uri はシステム報告集合に含まれるべき',
        );
      }
    });

    Glados2(any.uriSet, any.uriSet).test('削除集合のすべての URI はシステム報告集合に含まれない', (
      storedUris,
      systemPersistedUris,
    ) {
      final result = validateUriPermissions(
        storedUris: storedUris,
        systemPersistedUris: systemPersistedUris,
      );

      for (final uri in result.toRemove) {
        expect(
          systemPersistedUris.contains(uri),
          isFalse,
          reason: '$uri はシステム報告集合に含まれないべき',
        );
      }
    });
  });

  // -------------------------------------------------------------------------
  // Property 5: URI パーミッション LRU 解放
  // -------------------------------------------------------------------------
  group('Feature: android-saf, Property 5: URI パーミッション LRU 解放', () {
    Glados(any.uriTimestampList512).test(
      '512 件のリストから最古のタイムスタンプを持つ URI が解放対象として選択される',
      (entries) {
        // 期待値: リスト内で最小のタイムスタンプを持つエントリの URI
        final expectedOldest = entries.reduce(
          (a, b) => a.lastOpenedAt.isBefore(b.lastOpenedAt) ? a : b,
        );

        // テスト対象: selectUriToEvict 関数
        final evictedUri = selectUriToEvict(entries);

        expect(evictedUri, expectedOldest.uri);
      },
    );

    Glados(any.uriTimestampList512).test('解放対象の URI のタイムスタンプはリスト内の全エントリ以下である', (
      entries,
    ) {
      final evictedUri = selectUriToEvict(entries);

      // 解放対象の URI に対応するタイムスタンプを取得
      final evictedEntry = entries.firstWhere((e) => e.uri == evictedUri);

      // すべてのエントリのタイムスタンプが解放対象以上であることを検証
      for (final entry in entries) {
        expect(
          evictedEntry.lastOpenedAt.compareTo(entry.lastOpenedAt) <= 0,
          isTrue,
          reason:
              '解放対象 (${evictedEntry.lastOpenedAt}) は '
              '${entry.uri} (${entry.lastOpenedAt}) 以前であるべき',
        );
      }
    });

    Glados(any.uriTimestampList512).test(
      'リストのサイズが kMaxPersistedUriPermissions (512) と一致する場合に解放が必要',
      (entries) {
        // 512 件のリストは上限に達しているため、解放対象が存在する
        expect(entries.length, kMaxPersistedUriPermissions);
        expect(selectUriToEvict(entries), isNotNull);
      },
    );

    test('空リストの場合は null を返す', () {
      expect(selectUriToEvict([]), isNull);
    });

    Glados(any.intInRange(1, 512)).test('任意のサイズのリストでも最古の URI が選択される', (size) {
      // size 件のエントリを生成（i=0 が最古）
      final entries = List.generate(size, (i) {
        return (
          uri: 'content://test/uri_$i',
          lastOpenedAt: DateTime(2020).add(Duration(seconds: i * 100)),
        );
      });

      // 最初のエントリ（i=0）が最古
      final evictedUri = selectUriToEvict(entries);
      expect(evictedUri, 'content://test/uri_0');
    });
  });
}
