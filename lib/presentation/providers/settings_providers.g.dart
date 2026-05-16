// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(manageCacheUseCase)
final manageCacheUseCaseProvider = ManageCacheUseCaseProvider._();

final class ManageCacheUseCaseProvider
    extends
        $FunctionalProvider<
          ManageCacheUseCase,
          ManageCacheUseCase,
          ManageCacheUseCase
        >
    with $Provider<ManageCacheUseCase> {
  ManageCacheUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'manageCacheUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$manageCacheUseCaseHash();

  @$internal
  @override
  $ProviderElement<ManageCacheUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ManageCacheUseCase create(Ref ref) {
    return manageCacheUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ManageCacheUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ManageCacheUseCase>(value),
    );
  }
}

String _$manageCacheUseCaseHash() =>
    r'415e21edce629664bc36264962107c2df36f2f55';

/// 現在のキャッシュサイズ（バイト）

@ProviderFor(CacheSize)
final cacheSizeProvider = CacheSizeProvider._();

/// 現在のキャッシュサイズ（バイト）
final class CacheSizeProvider extends $AsyncNotifierProvider<CacheSize, int> {
  /// 現在のキャッシュサイズ（バイト）
  CacheSizeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cacheSizeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cacheSizeHash();

  @$internal
  @override
  CacheSize create() => CacheSize();
}

String _$cacheSizeHash() => r'2e81fbd16591d844f099cca86c5e042fb0f23dab';

/// 現在のキャッシュサイズ（バイト）

abstract class _$CacheSize extends $AsyncNotifier<int> {
  FutureOr<int> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<int>, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<int>, int>,
              AsyncValue<int>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// テーマモード設定

@ProviderFor(AppThemeMode)
final appThemeModeProvider = AppThemeModeProvider._();

/// テーマモード設定
final class AppThemeModeProvider extends $NotifierProvider<AppThemeMode, int> {
  /// テーマモード設定
  AppThemeModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appThemeModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appThemeModeHash();

  @$internal
  @override
  AppThemeMode create() => AppThemeMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$appThemeModeHash() => r'5e0a0c3ae2d32cc8ce462a64c2e8ce869e868c2a';

/// テーマモード設定

abstract class _$AppThemeMode extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
