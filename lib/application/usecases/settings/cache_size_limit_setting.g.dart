// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_size_limit_setting.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// キャッシュサイズ上限設定を管理する Provider
///
/// デフォルト値は [CacheSizeLimit.mb500]（500MB）。
/// 設定変更時に DB へ永続化し、ThumbnailRepository に上限を通知して
/// 30 秒以内にエビクションを実行する。

@ProviderFor(CacheSizeLimitSetting)
final cacheSizeLimitSettingProvider = CacheSizeLimitSettingProvider._();

/// キャッシュサイズ上限設定を管理する Provider
///
/// デフォルト値は [CacheSizeLimit.mb500]（500MB）。
/// 設定変更時に DB へ永続化し、ThumbnailRepository に上限を通知して
/// 30 秒以内にエビクションを実行する。
final class CacheSizeLimitSettingProvider
    extends $NotifierProvider<CacheSizeLimitSetting, CacheSizeLimit> {
  /// キャッシュサイズ上限設定を管理する Provider
  ///
  /// デフォルト値は [CacheSizeLimit.mb500]（500MB）。
  /// 設定変更時に DB へ永続化し、ThumbnailRepository に上限を通知して
  /// 30 秒以内にエビクションを実行する。
  CacheSizeLimitSettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cacheSizeLimitSettingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cacheSizeLimitSettingHash();

  @$internal
  @override
  CacheSizeLimitSetting create() => CacheSizeLimitSetting();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CacheSizeLimit value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CacheSizeLimit>(value),
    );
  }
}

String _$cacheSizeLimitSettingHash() =>
    r'f93e4f63459e2a8a506693c1dfd10d59cc1bf874';

/// キャッシュサイズ上限設定を管理する Provider
///
/// デフォルト値は [CacheSizeLimit.mb500]（500MB）。
/// 設定変更時に DB へ永続化し、ThumbnailRepository に上限を通知して
/// 30 秒以内にエビクションを実行する。

abstract class _$CacheSizeLimitSetting extends $Notifier<CacheSizeLimit> {
  CacheSizeLimit build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CacheSizeLimit, CacheSizeLimit>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CacheSizeLimit, CacheSizeLimit>,
              CacheSizeLimit,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
