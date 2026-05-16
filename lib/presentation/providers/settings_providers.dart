/// 設定機能の Riverpod Provider 定義 (設計書 §14)
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/providers/repository_providers.dart';
import '../../application/usecases/settings/manage_cache_usecase.dart';

part 'settings_providers.g.dart';

// ---------------------------------------------------------------------------
// UseCase Providers
// ---------------------------------------------------------------------------

@riverpod
ManageCacheUseCase manageCacheUseCase(Ref ref) {
  return ManageCacheUseCase(
    thumbnailRepository: ref.watch(thumbnailRepositoryProvider),
  );
}

// ---------------------------------------------------------------------------
// State Providers
// ---------------------------------------------------------------------------

/// 現在のキャッシュサイズ（バイト）
@riverpod
class CacheSize extends _$CacheSize {
  @override
  FutureOr<int> build() {
    return ref.watch(manageCacheUseCaseProvider).getCacheSize();
  }

  Future<void> clearCache() async {
    state = const AsyncValue.loading();
    await ref.read(manageCacheUseCaseProvider).clearCache();
    // クリア後に再度サイズを再計算
    state = await AsyncValue.guard(
      () => ref.read(manageCacheUseCaseProvider).getCacheSize(),
    );
  }
}

/// テーマモード設定
@riverpod
class AppThemeMode extends _$AppThemeMode {
  static const _kThemeKey = 'theme_mode';

  @override
  int build() {
    _loadInitial();
    // デフォルトは 0 (System)
    return 0;
  }

  Future<void> _loadInitial() async {
    final db = ref.read(appDatabaseProvider);
    final value = await db.getSetting(_kThemeKey);
    if (value != null) {
      state = int.tryParse(value) ?? 0;
    }
  }

  Future<void> setTheme(int mode) async {
    state = mode;
    final db = ref.read(appDatabaseProvider);
    await db.setSetting(_kThemeKey, mode.toString());
  }
}
