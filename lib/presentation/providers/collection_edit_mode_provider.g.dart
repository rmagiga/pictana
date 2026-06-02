// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_edit_mode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// コレクション編集モードを管理する Notifier
///
/// 長押しで編集モードを開始し、選択/解除のトグル、
/// 全選択、編集モード終了を提供する。

@ProviderFor(CollectionEditMode)
final collectionEditModeProvider = CollectionEditModeProvider._();

/// コレクション編集モードを管理する Notifier
///
/// 長押しで編集モードを開始し、選択/解除のトグル、
/// 全選択、編集モード終了を提供する。
final class CollectionEditModeProvider
    extends $NotifierProvider<CollectionEditMode, CollectionEditModeState> {
  /// コレクション編集モードを管理する Notifier
  ///
  /// 長押しで編集モードを開始し、選択/解除のトグル、
  /// 全選択、編集モード終了を提供する。
  CollectionEditModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collectionEditModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collectionEditModeHash();

  @$internal
  @override
  CollectionEditMode create() => CollectionEditMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CollectionEditModeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CollectionEditModeState>(value),
    );
  }
}

String _$collectionEditModeHash() =>
    r'1655835d55bb2ea4447f7576c1a166bcf3bb252c';

/// コレクション編集モードを管理する Notifier
///
/// 長押しで編集モードを開始し、選択/解除のトグル、
/// 全選択、編集モード終了を提供する。

abstract class _$CollectionEditMode extends $Notifier<CollectionEditModeState> {
  CollectionEditModeState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<CollectionEditModeState, CollectionEditModeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CollectionEditModeState, CollectionEditModeState>,
              CollectionEditModeState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
