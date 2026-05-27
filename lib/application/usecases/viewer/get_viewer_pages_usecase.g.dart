// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_viewer_pages_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GetViewerPagesUseCase)
final getViewerPagesUseCaseProvider = GetViewerPagesUseCaseProvider._();

final class GetViewerPagesUseCaseProvider
    extends $NotifierProvider<GetViewerPagesUseCase, GetViewerPagesUseCase> {
  GetViewerPagesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getViewerPagesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getViewerPagesUseCaseHash();

  @$internal
  @override
  GetViewerPagesUseCase create() => GetViewerPagesUseCase();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetViewerPagesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetViewerPagesUseCase>(value),
    );
  }
}

String _$getViewerPagesUseCaseHash() =>
    r'cb8d6d7ddcff13adaeb8d49ce93e5db79d064f40';

abstract class _$GetViewerPagesUseCase
    extends $Notifier<GetViewerPagesUseCase> {
  GetViewerPagesUseCase build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<GetViewerPagesUseCase, GetViewerPagesUseCase>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GetViewerPagesUseCase, GetViewerPagesUseCase>,
              GetViewerPagesUseCase,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
