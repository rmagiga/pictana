/// Property 1: Bug Condition - ソートオプション変更が `_loadInitial()` に上書きされる
///
/// `GallerySortOption` notifier で `updateOption()` を呼んだ後に `_loadInitial()` が
/// 完了するシナリオをテストする。ユーザーが設定した新しいソートオプションが
/// `_loadInitial()` の非同期完了によって上書きされないことを検証する。
///
/// **Validates: Requirements 1.1, 1.2, 1.3**
library;

import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, tearDown, test;
import 'package:optrig/application/providers/repository_providers.dart';
import 'package:optrig/domain/value_objects/sort_option.dart';
import 'package:optrig/infrastructure/database/app_database.dart';
import 'package:optrig/presentation/providers/gallery_providers.dart';

// ---------------------------------------------------------------------------
// テスト用モック: _loadInitial() の遅延をシミュレートする AppDatabase
// ---------------------------------------------------------------------------

/// DB の getSetting を遅延させることで _loadInitial() の非同期完了を制御する。
///
/// 重要: 実際のバグシナリオでは、_loadInitial() が DB から読み取る値は
/// 「古い値」（ユーザー変更前の値）。このモックでは常に [initialDbOption] を返す。
class DelayedAppDatabase extends AppDatabase {
  DelayedAppDatabase({
    required this.loadCompleter,
    required this.initialDbOption,
  }) : super.forTesting(NativeDatabase.memory());

  final Completer<void> loadCompleter;

  /// _loadInitial() が読み取るべき DB の初期値（ユーザー変更前の値）
  final SortOption initialDbOption;

  /// getSetting の呼び出し回数
  int getSettingCallCount = 0;

  @override
  Future<String?> getSetting(String key) async {
    getSettingCallCount++;
    // _loadInitial() の非同期処理を遅延させる
    await loadCompleter.future;
    // 常に「初期 DB 値」を返す（_loadInitial() が読み取る値はユーザー変更前の値）
    if (key == 'sort_field') return initialDbOption.field.name;
    if (key == 'sort_direction') return initialDbOption.direction.name;
    return null;
  }

  @override
  Future<void> setSetting(String key, String value) async {
    // updateOption() → saveSortOption() の呼び出し。
    // _loadInitial() が返す値には影響しない（実際のシナリオを再現）。
  }
}

// ---------------------------------------------------------------------------
// SortOption 用 glados ジェネレータ
// ---------------------------------------------------------------------------

extension SortOptionGenerators on Any {
  /// ランダムな SortField を生成する
  Generator<SortField> get sortField => any.choose(SortField.values);

  /// ランダムな SortDirection を生成する
  Generator<SortDirection> get sortDirection =>
      any.choose(SortDirection.values);

  /// ランダムな SortOption を生成する
  Generator<SortOption> get sortOption => any.combine2(
    any.sortField,
    any.sortDirection,
    (SortField field, SortDirection direction) =>
        SortOption(field: field, direction: direction),
  );
}

// ---------------------------------------------------------------------------
// テスト本体
// ---------------------------------------------------------------------------

void main() {
  // drift の複数インスタンス警告を抑制（テスト用途のため問題なし）
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('Property 1: Bug Condition - _loadInitial() がユーザー設定を上書きする', () {
    test('updateOption() 後に _loadInitial() が完了しても、ユーザー設定が維持される', () async {
      // Arrange: _loadInitial() を遅延させる DB を作成
      // DB の初期値は defaultOption（名前昇順）
      final loadCompleter = Completer<void>();
      final delayedDb = DelayedAppDatabase(
        loadCompleter: loadCompleter,
        initialDbOption: SortOption.defaultOption,
      );

      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(delayedDb)],
      );
      addTearDown(container.dispose);

      // Act: GallerySortOption notifier を読み取る（build() が呼ばれ、_loadInitial() 開始）
      final notifier = container.read(gallerySortOptionProvider.notifier);

      // 初期状態は defaultOption
      expect(
        container.read(gallerySortOptionProvider),
        equals(SortOption.defaultOption),
      );

      // ユーザーがソートオプションを変更する（名前降順に変更）
      final userOption = const SortOption(
        field: SortField.name,
        direction: SortDirection.descending,
      );
      await notifier.updateOption(userOption);

      // state がユーザー設定に更新されたことを確認
      expect(container.read(gallerySortOptionProvider), equals(userOption));

      // _loadInitial() の非同期処理を完了させる
      // → _loadInitial() は DB の古い値（defaultOption = 名前昇順）を state に設定しようとする
      loadCompleter.complete();
      // マイクロタスクを処理して _loadInitial() の await 後の処理を実行させる
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      // Assert: ユーザー設定が維持されるべき（_loadInitial() に上書きされない）
      expect(
        container.read(gallerySortOptionProvider),
        equals(userOption),
        reason:
            '_loadInitial() 完了後もユーザーが設定した SortOption が維持されるべき。'
            '実際の state: ${container.read(gallerySortOptionProvider)}',
      );
    });

    // Property-based test: 任意の SortOption で同じバグが再現する
    // glados は shrink 時に同じ入力を再実行するため、各実行で独立した
    // Completer と Container を使い、決定論的に動作させる。
    Glados(any.sortOption).test(
      'glados: 任意の SortOption で updateOption() 後に _loadInitial() が完了しても state が維持される',
      (generatedOption) async {
        // デフォルトと同じ場合はスキップ（上書きされても検出できない）
        if (generatedOption == SortOption.defaultOption) return;

        // Arrange: _loadInitial() を即座に完了させるが、
        // getSetting の await で一度 microtask に譲ることで
        // updateOption() が先に実行されるシナリオを再現する。
        //
        // 戦略: completer を事前に complete しておき、getSetting 内の
        // await loadCompleter.future が即座に解決するようにする。
        // ただし await 自体が microtask を1つ消費するため、
        // _loadInitial() の state 設定は updateOption() の後になる。
        final loadCompleter = Completer<void>();
        final delayedDb = DelayedAppDatabase(
          loadCompleter: loadCompleter,
          initialDbOption: SortOption.defaultOption,
        );

        final container = ProviderContainer(
          overrides: [appDatabaseProvider.overrideWithValue(delayedDb)],
        );

        try {
          // Act: GallerySortOption notifier を読み取る（_loadInitial() 開始）
          final notifier = container.read(gallerySortOptionProvider.notifier);

          // ユーザーがソートオプションを変更する
          await notifier.updateOption(generatedOption);

          // _loadInitial() を完了させる
          loadCompleter.complete();
          await Future<void>.delayed(Duration.zero);
          await Future<void>.delayed(Duration.zero);
          await Future<void>.delayed(Duration.zero);

          // Assert: ユーザー設定が維持されるべき
          expect(
            container.read(gallerySortOptionProvider),
            equals(generatedOption),
            reason:
                '_loadInitial() 完了後もユーザーが設定した SortOption($generatedOption) が維持されるべき。'
                '実際の state: ${container.read(gallerySortOptionProvider)}',
          );
        } finally {
          container.dispose();
        }
      },
    );
  });
}
