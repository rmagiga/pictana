// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_monitor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ストレージ接続監視・自動リトライ・OS既定フォルダ検出 Provider
///
/// keepAlive: true でアプリ全体のライフサイクルにわたって状態を保持する。

@ProviderFor(StorageMonitor)
final storageMonitorProvider = StorageMonitorProvider._();

/// ストレージ接続監視・自動リトライ・OS既定フォルダ検出 Provider
///
/// keepAlive: true でアプリ全体のライフサイクルにわたって状態を保持する。
final class StorageMonitorProvider
    extends $NotifierProvider<StorageMonitor, StorageMonitorState> {
  /// ストレージ接続監視・自動リトライ・OS既定フォルダ検出 Provider
  ///
  /// keepAlive: true でアプリ全体のライフサイクルにわたって状態を保持する。
  StorageMonitorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storageMonitorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storageMonitorHash();

  @$internal
  @override
  StorageMonitor create() => StorageMonitor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StorageMonitorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StorageMonitorState>(value),
    );
  }
}

String _$storageMonitorHash() => r'fa8e8455c41e364ec5125c91b0fe35b84fa0f83a';

/// ストレージ接続監視・自動リトライ・OS既定フォルダ検出 Provider
///
/// keepAlive: true でアプリ全体のライフサイクルにわたって状態を保持する。

abstract class _$StorageMonitor extends $Notifier<StorageMonitorState> {
  StorageMonitorState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<StorageMonitorState, StorageMonitorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StorageMonitorState, StorageMonitorState>,
              StorageMonitorState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
