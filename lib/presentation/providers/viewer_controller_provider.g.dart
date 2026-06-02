// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'viewer_controller_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ビューアの状態操作と通知を行うコントローラー

@ProviderFor(ViewerController)
final viewerControllerProvider = ViewerControllerFamily._();

/// ビューアの状態操作と通知を行うコントローラー
final class ViewerControllerProvider
    extends $NotifierProvider<ViewerController, ViewerState> {
  /// ビューアの状態操作と通知を行うコントローラー
  ViewerControllerProvider._({
    required ViewerControllerFamily super.from,
    required ({int initialIndex, int totalCount}) super.argument,
  }) : super(
         retry: null,
         name: r'viewerControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$viewerControllerHash();

  @override
  String toString() {
    return r'viewerControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  ViewerController create() => ViewerController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ViewerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ViewerState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ViewerControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$viewerControllerHash() => r'0f999ddc91d6800e72fbddc949652b7d758a3983';

/// ビューアの状態操作と通知を行うコントローラー

final class ViewerControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ViewerController,
          ViewerState,
          ViewerState,
          ViewerState,
          ({int initialIndex, int totalCount})
        > {
  ViewerControllerFamily._()
    : super(
        retry: null,
        name: r'viewerControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// ビューアの状態操作と通知を行うコントローラー

  ViewerControllerProvider call({
    required int initialIndex,
    required int totalCount,
  }) => ViewerControllerProvider._(
    argument: (initialIndex: initialIndex, totalCount: totalCount),
    from: this,
  );

  @override
  String toString() => r'viewerControllerProvider';
}

/// ビューアの状態操作と通知を行うコントローラー

abstract class _$ViewerController extends $Notifier<ViewerState> {
  late final _$args = ref.$arg as ({int initialIndex, int totalCount});
  int get initialIndex => _$args.initialIndex;
  int get totalCount => _$args.totalCount;

  ViewerState build({required int initialIndex, required int totalCount});
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ViewerState, ViewerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ViewerState, ViewerState>,
              ViewerState,
              Object?,
              Object?
            >;
    element.handleCreate(
      ref,
      () => build(
        initialIndex: _$args.initialIndex,
        totalCount: _$args.totalCount,
      ),
    );
  }
}
