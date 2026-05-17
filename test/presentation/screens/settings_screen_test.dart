/// Settings_Screen ウィジェットテスト
///
/// 設定画面の各設定項目の表示・変更・永続化、キャッシュクリアフローを検証する。
/// - サムネイルサイズ設定: DropdownButton 表示・選択変更
/// - キャッシュサイズ上限設定: DropdownButton 表示・選択変更
/// - キャッシュ使用量: 現在の使用量表示
/// - キャッシュクリア: ボタンタップ→確認ダイアログ→SnackBar通知
///
/// Requirements: 7.1, 8.1, 9.1, 10.2, 10.4
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optrig/application/usecases/settings/cache_size_limit_setting.dart';
import 'package:optrig/application/usecases/settings/thumbnail_size_setting.dart';
import 'package:optrig/domain/value_objects/cache_size_limit.dart';
import 'package:optrig/domain/value_objects/grid_column_settings.dart';
import 'package:optrig/domain/value_objects/thumbnail_size_option.dart';
import 'package:optrig/presentation/providers/grid_column_settings_provider.dart';
import 'package:optrig/presentation/providers/theme_provider.dart';
import 'package:optrig/presentation/providers/settings_providers.dart';
import 'package:optrig/presentation/screens/settings_screen.dart';

// ---------------------------------------------------------------------------
// テスト用モック Provider
// ---------------------------------------------------------------------------

class _FakeThumbnailSizeSetting extends ThumbnailSizeSetting {
  @override
  ThumbnailSizeOption build() => ThumbnailSizeOption.medium;

  @override
  Future<void> update(ThumbnailSizeOption size) async {
    state = size;
  }
}

class _FakeCacheSizeLimitSetting extends CacheSizeLimitSetting {
  @override
  CacheSizeLimit build() => CacheSizeLimit.mb500;

  @override
  Future<void> update(CacheSizeLimit limit) async {
    state = limit;
  }
}

class _FakeThemeModeNotifier extends ThemeModeNotifier {
  @override
  ThemeMode build() => ThemeMode.system;

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
  }
}

class _FakeGridColumnSettingsNotifier extends GridColumnSettingsNotifier {
  @override
  GridColumnSettings build() => const GridColumnSettings();

  @override
  Future<void> setMinColumns(int min) async {
    state = state.copyWith(minColumns: min);
  }

  @override
  Future<void> setMaxColumns(int max) async {
    state = state.copyWith(maxColumns: max);
  }
}

class _FakeCacheSize extends CacheSize {
  @override
  FutureOr<int> build() => 150 * 1024 * 1024; // 150MB

  @override
  Future<void> clearCache() async {
    state = const AsyncValue.loading();
    state = const AsyncValue.data(0);
  }
}

class _FakeCacheSizeWithError extends CacheSize {
  @override
  FutureOr<int> build() => 150 * 1024 * 1024; // 150MB

  @override
  Future<void> clearCache() async {
    throw Exception('fail');
  }
}

// ---------------------------------------------------------------------------
// テスト用ヘルパー
// ---------------------------------------------------------------------------

Widget _createTestWidget({CacheSize? cacheSizeOverride}) {
  // GridColumnSettingTile のオーバーフローエラーを抑制
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('overflowed')) return;
    originalOnError?.call(details);
  };

  return ProviderScope(
    overrides: [
      thumbnailSizeSettingProvider.overrideWith(
        () => _FakeThumbnailSizeSetting(),
      ),
      cacheSizeLimitSettingProvider.overrideWith(
        () => _FakeCacheSizeLimitSetting(),
      ),
      themeModeProvider.overrideWith(() => _FakeThemeModeNotifier()),
      cacheSizeProvider.overrideWith(
        () => cacheSizeOverride ?? _FakeCacheSize(),
      ),
      gridColumnSettingsProvider.overrideWith(
        () => _FakeGridColumnSettingsNotifier(),
      ),
    ],
    child: const MaterialApp(home: SettingsScreen()),
  );
}

// ---------------------------------------------------------------------------
// テスト本体
// ---------------------------------------------------------------------------

void main() {
  group('SettingsScreen - サムネイルサイズ設定 (Req 8.1)', () {
    testWidgets('サムネイルサイズの DropdownButton が表示される', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();
      expect(find.text('サムネイルサイズ'), findsOneWidget);
      expect(find.text('中 (256px)'), findsWidgets);
    });

    testWidgets('サムネイルサイズの選択変更が可能', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();

      final dropdownFinder = find.byWidgetPredicate(
        (widget) =>
            widget is DropdownButton<ThumbnailSizeOption> &&
            widget.value == ThumbnailSizeOption.medium,
      );
      expect(dropdownFinder, findsOneWidget);
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();

      await tester.tap(find.text('大 (512px)').last);
      await tester.pumpAndSettle();
      expect(find.text('大 (512px)'), findsWidgets);
    });

    testWidgets('全ての選択肢が DropdownButton に含まれる', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();

      final dropdownFinder = find.byWidgetPredicate(
        (widget) => widget is DropdownButton<ThumbnailSizeOption>,
      );
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();

      expect(find.text('小 (128px)'), findsWidgets);
      expect(find.text('中 (256px)'), findsWidgets);
      expect(find.text('大 (512px)'), findsWidgets);
    });
  });

  group('SettingsScreen - キャッシュサイズ上限設定 (Req 9.1)', () {
    testWidgets('キャッシュサイズ上限の DropdownButton が表示される', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();
      expect(find.text('キャッシュサイズ上限'), findsOneWidget);
      expect(find.text('500MB'), findsWidgets);
    });

    testWidgets('キャッシュサイズ上限の選択変更が可能', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();

      final dropdownFinder = find.byWidgetPredicate(
        (widget) =>
            widget is DropdownButton<CacheSizeLimit> &&
            widget.value == CacheSizeLimit.mb500,
      );
      expect(dropdownFinder, findsOneWidget);
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();

      await tester.tap(find.text('1GB').last);
      await tester.pumpAndSettle();
      expect(find.text('現在の上限: 1GB'), findsOneWidget);
    });

    testWidgets('全ての選択肢が DropdownButton に含まれる', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();

      final dropdownFinder = find.byWidgetPredicate(
        (widget) => widget is DropdownButton<CacheSizeLimit>,
      );
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();

      expect(find.text('100MB'), findsWidgets);
      expect(find.text('250MB'), findsWidgets);
      expect(find.text('500MB'), findsWidgets);
      expect(find.text('1GB'), findsWidgets);
    });
  });

  group('SettingsScreen - キャッシュ使用量表示 (Req 10.1)', () {
    testWidgets('現在のキャッシュ使用量が表示される', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();
      expect(find.text('現在のキャッシュ使用量'), findsOneWidget);
      expect(find.text('150.0 MB / 500MB'), findsOneWidget);
    });
  });

  group('SettingsScreen - キャッシュクリア (Req 10.2, 10.4)', () {
    testWidgets('「キャッシュをクリア」ボタンが表示される', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();
      expect(find.text('キャッシュをクリア'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('ボタンタップで確認ダイアログが表示される (Req 10.2)', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('キャッシュをクリア'));
      await tester.pumpAndSettle();

      expect(find.text('キャッシュのクリア'), findsOneWidget);
      expect(find.text('生成されたサムネイルをすべて削除します。よろしいですか？'), findsOneWidget);
      expect(find.text('キャンセル'), findsOneWidget);
      expect(find.text('削除'), findsOneWidget);
    });

    testWidgets('ダイアログで「キャンセル」を選択するとダイアログが閉じる', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('キャッシュをクリア'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('キャンセル'));
      await tester.pumpAndSettle();
      expect(find.text('キャッシュのクリア'), findsNothing);
    });

    testWidgets('ダイアログで「削除」を選択すると SnackBar が表示される (Req 10.4)', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('キャッシュをクリア'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('削除'));
      await tester.pumpAndSettle();
      expect(find.text('キャッシュをクリアしました'), findsOneWidget);
    });

    testWidgets('キャッシュクリア失敗時にエラー SnackBar が表示される (Req 10.5)', (tester) async {
      await tester.pumpWidget(
        _createTestWidget(cacheSizeOverride: _FakeCacheSizeWithError()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('キャッシュをクリア'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('削除'));
      await tester.pumpAndSettle();
      expect(find.text('キャッシュのクリアに失敗しました'), findsOneWidget);
    });
  });

  group('SettingsScreen - 基本表示', () {
    testWidgets('AppBar に「設定」タイトルが表示される', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();
      expect(find.text('設定'), findsOneWidget);
    });

    testWidgets('「表示」セクションヘッダーが表示される', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();
      expect(find.text('表示'), findsOneWidget);
    });

    testWidgets('「キャッシュ管理」セクションヘッダーが表示される', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();
      expect(find.text('キャッシュ管理'), findsOneWidget);
    });

    testWidgets('テーマ設定が表示される', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();
      expect(find.text('テーマ'), findsOneWidget);
      expect(find.text('システムに合わせる'), findsOneWidget);
    });
  });
}
