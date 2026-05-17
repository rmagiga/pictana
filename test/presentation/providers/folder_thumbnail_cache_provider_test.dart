/// FolderThumbnailCache プロパティテスト
///
/// 任意の put 操作シーケンスに対してキャッシュサイズが
/// maxCacheSize（50）を超えないことを検証する。
///
/// **Validates: Requirements 8.2**
@Tags(['property-test'])
library;

import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, tearDown, test;
import 'package:pictana/presentation/providers/folder_thumbnail_cache_provider.dart';

// ---------------------------------------------------------------------------
// glados 用カスタムジェネレータ
// ---------------------------------------------------------------------------

/// put 操作を表すデータクラス
class PutOperation {
  const PutOperation(this.key, this.bytesLength);

  /// キャッシュキー（フォルダ URI）
  final String key;

  /// サムネイルバイト列の長さ
  final int bytesLength;

  @override
  String toString() => 'PutOperation(key: "$key", bytesLength: $bytesLength)';
}

/// put 操作のリストを生成するジェネレータ
///
/// 1〜200 個の操作を生成し、キーは 0〜99 の範囲で
/// 重複を含む現実的なシナリオをカバーする。
Generator<List<PutOperation>> get _putOperationsGenerator =>
    any.listWithLengthInRange(1, 200, _putOperationGenerator);

/// 個別の put 操作を生成するジェネレータ
Generator<PutOperation> get _putOperationGenerator => any
    .intInRange(0, 99)
    .bind(
      (key) => any
          .intInRange(1, 100)
          .map((bytesLength) => PutOperation('folder://$key', bytesLength)),
    );

void main() {
  // =========================================================================
  // プロパティベーステスト
  // =========================================================================
  group('Feature: favorites-folder-grid, Property 4: サムネイルキャッシュサイズ上限', () {
    Glados(_putOperationsGenerator).test(
      '任意の put 操作シーケンスに対してキャッシュサイズが50を超えない',
      (operations) {
        // ProviderContainer を作成してキャッシュ Notifier を取得
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(folderThumbnailCacheProvider.notifier);

        // 各 put 操作を実行し、毎回キャッシュサイズを検証
        for (final op in operations) {
          final bytes = Uint8List(op.bytesLength);
          notifier.put(op.key, bytes);

          final state = container.read(folderThumbnailCacheProvider);
          expect(
            state.length,
            lessThanOrEqualTo(FolderThumbnailCache.maxCacheSize),
            reason:
                '操作 $op の後、キャッシュサイズ ${state.length} が '
                '上限 ${FolderThumbnailCache.maxCacheSize} を超えている',
          );
        }
      },
    );

    Glados(any.intInRange(51, 100)).test(
      '50件を超えるユニークキーを put した場合、最初に挿入したキーが削除される（LRU）',
      (count) {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(folderThumbnailCacheProvider.notifier);

        // 完全にユニークなキーを順番に挿入（重複なし）
        for (var i = 0; i < count; i++) {
          notifier.put('unique-folder://$i', Uint8List(1));
        }

        final state = container.read(folderThumbnailCacheProvider);

        // キャッシュサイズは常に50以下
        expect(
          state.length,
          equals(FolderThumbnailCache.maxCacheSize),
          reason: '$count 件のユニークキー挿入後、キャッシュサイズは50であるべき',
        );

        // 最初に挿入したキーは削除されているはず
        expect(
          state.containsKey('unique-folder://0'),
          isFalse,
          reason:
              '$count 件のユニークキー挿入後、'
              '最初のキー "unique-folder://0" はLRU削除されているべき',
        );

        // 最後に挿入したキーは残っているはず
        expect(
          state.containsKey('unique-folder://${count - 1}'),
          isTrue,
          reason:
              '$count 件のユニークキー挿入後、'
              '最後のキー "unique-folder://${count - 1}" は残っているべき',
        );
      },
    );
  });
}
