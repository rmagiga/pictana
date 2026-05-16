// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// アプリのテーマモード状態
///
/// DB からの読み込みは AppSettingsProvider 経由で行い、
/// このProviderは純粋なテーマモード切替のみを担う。

@ProviderFor(ThemeModeNotifier)
final themeModeProvider = ThemeModeNotifierProvider._();

/// アプリのテーマモード状態
///
/// DB からの読み込みは AppSettingsProvider 経由で行い、
/// このProviderは純粋なテーマモード切替のみを担う。
final class ThemeModeNotifierProvider
    extends $NotifierProvider<ThemeModeNotifier, ThemeMode> {
  /// アプリのテーマモード状態
  ///
  /// DB からの読み込みは AppSettingsProvider 経由で行い、
  /// このProviderは純粋なテーマモード切替のみを担う。
  ThemeModeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeNotifierHash();

  @$internal
  @override
  ThemeModeNotifier create() => ThemeModeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$themeModeNotifierHash() => r'965c1f1f7e4b67d1a5043eec925b4c17e5c4ec0b';

/// アプリのテーマモード状態
///
/// DB からの読み込みは AppSettingsProvider 経由で行い、
/// このProviderは純粋なテーマモード切替のみを担う。

abstract class _$ThemeModeNotifier extends $Notifier<ThemeMode> {
  ThemeMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ThemeMode, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeMode, ThemeMode>,
              ThemeMode,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
