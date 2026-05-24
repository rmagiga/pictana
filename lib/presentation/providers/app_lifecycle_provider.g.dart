// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_lifecycle_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// アプリケーションのライフサイクル状態を監視するProvider

@ProviderFor(AppLifecycle)
final appLifecycleProvider = AppLifecycleProvider._();

/// アプリケーションのライフサイクル状態を監視するProvider
final class AppLifecycleProvider
    extends $NotifierProvider<AppLifecycle, AppLifecycleState> {
  /// アプリケーションのライフサイクル状態を監視するProvider
  AppLifecycleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLifecycleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLifecycleHash();

  @$internal
  @override
  AppLifecycle create() => AppLifecycle();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLifecycleState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLifecycleState>(value),
    );
  }
}

String _$appLifecycleHash() => r'197a53dd95006b35db6d33b15351567336d25b8b';

/// アプリケーションのライフサイクル状態を監視するProvider

abstract class _$AppLifecycle extends $Notifier<AppLifecycleState> {
  AppLifecycleState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AppLifecycleState, AppLifecycleState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppLifecycleState, AppLifecycleState>,
              AppLifecycleState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
