// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$manageCacheUseCaseHash() =>
    r'415e21edce629664bc36264962107c2df36f2f55';

/// See also [manageCacheUseCase].
@ProviderFor(manageCacheUseCase)
final manageCacheUseCaseProvider =
    AutoDisposeProvider<ManageCacheUseCase>.internal(
      manageCacheUseCase,
      name: r'manageCacheUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$manageCacheUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ManageCacheUseCaseRef = AutoDisposeProviderRef<ManageCacheUseCase>;
String _$cacheSizeHash() => r'2e81fbd16591d844f099cca86c5e042fb0f23dab';

/// 現在のキャッシュサイズ（バイト）
///
/// Copied from [CacheSize].
@ProviderFor(CacheSize)
final cacheSizeProvider =
    AutoDisposeAsyncNotifierProvider<CacheSize, int>.internal(
      CacheSize.new,
      name: r'cacheSizeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cacheSizeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CacheSize = AutoDisposeAsyncNotifier<int>;
String _$appThemeModeHash() => r'5e0a0c3ae2d32cc8ce462a64c2e8ce869e868c2a';

/// テーマモード設定
///
/// Copied from [AppThemeMode].
@ProviderFor(AppThemeMode)
final appThemeModeProvider =
    AutoDisposeNotifierProvider<AppThemeMode, int>.internal(
      AppThemeMode.new,
      name: r'appThemeModeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$appThemeModeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AppThemeMode = AutoDisposeNotifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
