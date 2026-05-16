/// 設定 Provider ユニットテスト
///
/// SwipeDirectionSetting, ThumbnailSizeSetting, CacheSizeLimitSetting の
/// 初期値・更新・永続化を検証する。
///
/// **Validates: Requirements 7.3, 8.3, 9.2**
library;

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optrig/application/providers/repository_providers.dart';
import 'package:optrig/application/usecases/settings/cache_size_limit_setting.dart';
import 'package:optrig/application/usecases/settings/swipe_direction_setting.dart';
import 'package:optrig/application/usecases/settings/thumbnail_size_setting.dart';
import 'package:optrig/domain/repositories/thumbnail_repository.dart';
import 'package:optrig/domain/value_objects/cache_size_limit.dart';
import 'package:optrig/domain/value_objects/swipe_direction.dart';
import 'package:optrig/domain/value_objects/thumbnail_size_option.dart';
import 'package:optrig/infrastructure/database/app_database.dart';

// ---------------------------------------------------------------------------
// テスト用 Fake ThumbnailRepository
// ---------------------------------------------------------------------------

/// テスト用 ThumbnailRepository
///
/// setCacheSizeLimit の呼び出しを記録する。
class FakeThumbnailRepository implements ThumbnailRepository {
  int? lastSetCacheSizeLimit;
  int setCacheSizeLimitCallCount = 0;

  @override
  Future<void> setCacheSizeLimit(int limitBytes) async {
    lastSetCacheSizeLimit = limitBytes;
    setCacheSizeLimitCallCount++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

// ---------------------------------------------------------------------------
// テスト本体
// ---------------------------------------------------------------------------

void main() {
  // drift の複数インスタンス警告を抑制
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  // =========================================================================
  // SwipeDirectionSetting テスト
  // =========================================================================
  group('SwipeDirectionSetting', () {
    test('初期値は SwipeDirection.horizontal である', () {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );

      final state = container.read(swipeDirectionSettingProvider);

      expect(state, equals(SwipeDirection.horizontal));

      container.dispose();
      db.close();
    });

    test('update で状態が変更される', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );

      final notifier = container.read(swipeDirectionSettingProvider.notifier);
      await notifier.update(SwipeDirection.vertical);

      final state = container.read(swipeDirectionSettingProvider);
      expect(state, equals(SwipeDirection.vertical));

      container.dispose();
      await db.close();
    });

    test('update で DB に永続化される', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );

      final notifier = container.read(swipeDirectionSettingProvider.notifier);
      await notifier.update(SwipeDirection.both);

      // DB から直接読み取って確認
      final savedValue = await db.getSetting('swipe_direction');
      expect(savedValue, equals('both'));

      container.dispose();
      await db.close();
    });

    test('DB に保存済みの値がある場合、起動時に復元される', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      // 事前に DB に値を設定
      await db.setSetting('swipe_direction', 'vertical');

      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );

      // Provider を初期化して _loadInitial の非同期処理が完了するのを待つ
      container.read(swipeDirectionSettingProvider);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final state = container.read(swipeDirectionSettingProvider);
      expect(state, equals(SwipeDirection.vertical));

      container.dispose();
      await db.close();
    });
  });

  // =========================================================================
  // ThumbnailSizeSetting テスト
  // =========================================================================
  group('ThumbnailSizeSetting', () {
    test('初期値は ThumbnailSizeOption.medium である', () {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );

      final state = container.read(thumbnailSizeSettingProvider);

      expect(state, equals(ThumbnailSizeOption.medium));

      container.dispose();
      db.close();
    });

    test('update で状態が変更される', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );

      final notifier = container.read(thumbnailSizeSettingProvider.notifier);
      await notifier.update(ThumbnailSizeOption.large);

      final state = container.read(thumbnailSizeSettingProvider);
      expect(state, equals(ThumbnailSizeOption.large));

      container.dispose();
      await db.close();
    });

    test('update で DB に永続化される', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );

      final notifier = container.read(thumbnailSizeSettingProvider.notifier);
      await notifier.update(ThumbnailSizeOption.small);

      // DB から直接読み取って確認
      final savedValue = await db.getSetting('thumbnail_size');
      expect(savedValue, equals('small'));

      container.dispose();
      await db.close();
    });

    test('DB に保存済みの値がある場合、起動時に復元される', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      // 事前に DB に値を設定
      await db.setSetting('thumbnail_size', 'large');

      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );

      // Provider を初期化して _loadInitial の非同期処理が完了するのを待つ
      container.read(thumbnailSizeSettingProvider);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final state = container.read(thumbnailSizeSettingProvider);
      expect(state, equals(ThumbnailSizeOption.large));

      container.dispose();
      await db.close();
    });
  });

  // =========================================================================
  // CacheSizeLimitSetting テスト
  // =========================================================================
  group('CacheSizeLimitSetting', () {
    test('初期値は CacheSizeLimit.mb500 である', () {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final fakeThumbnailRepo = FakeThumbnailRepository();
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          thumbnailRepositoryProvider.overrideWithValue(fakeThumbnailRepo),
        ],
      );

      final state = container.read(cacheSizeLimitSettingProvider);

      expect(state, equals(CacheSizeLimit.mb500));

      container.dispose();
      db.close();
    });

    test('update で状態が変更される', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final fakeThumbnailRepo = FakeThumbnailRepository();
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          thumbnailRepositoryProvider.overrideWithValue(fakeThumbnailRepo),
        ],
      );

      final notifier = container.read(cacheSizeLimitSettingProvider.notifier);
      await notifier.update(CacheSizeLimit.gb1);

      final state = container.read(cacheSizeLimitSettingProvider);
      expect(state, equals(CacheSizeLimit.gb1));

      container.dispose();
      await db.close();
    });

    test('update で DB に永続化される', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final fakeThumbnailRepo = FakeThumbnailRepository();
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          thumbnailRepositoryProvider.overrideWithValue(fakeThumbnailRepo),
        ],
      );

      final notifier = container.read(cacheSizeLimitSettingProvider.notifier);
      await notifier.update(CacheSizeLimit.mb250);

      // DB から直接読み取って確認
      final savedValue = await db.getSetting('cache_size_limit');
      expect(savedValue, equals('mb250'));

      container.dispose();
      await db.close();
    });

    test('update で ThumbnailRepository に上限が設定される', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final fakeThumbnailRepo = FakeThumbnailRepository();
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          thumbnailRepositoryProvider.overrideWithValue(fakeThumbnailRepo),
        ],
      );

      final notifier = container.read(cacheSizeLimitSettingProvider.notifier);
      await notifier.update(CacheSizeLimit.mb100);

      expect(
        fakeThumbnailRepo.lastSetCacheSizeLimit,
        equals(CacheSizeLimit.mb100.bytes),
      );
      expect(fakeThumbnailRepo.setCacheSizeLimitCallCount, equals(1));

      container.dispose();
      await db.close();
    });

    test('DB に保存済みの値がある場合、起動時に復元される', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      // 事前に DB に値を設定
      await db.setSetting('cache_size_limit', 'gb1');

      final fakeThumbnailRepo = FakeThumbnailRepository();
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          thumbnailRepositoryProvider.overrideWithValue(fakeThumbnailRepo),
        ],
      );

      // Provider を初期化して _loadInitial の非同期処理が完了するのを待つ
      container.read(cacheSizeLimitSettingProvider);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final state = container.read(cacheSizeLimitSettingProvider);
      expect(state, equals(CacheSizeLimit.gb1));

      container.dispose();
      await db.close();
    });
  });
}
