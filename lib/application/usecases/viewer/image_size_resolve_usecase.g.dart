// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_size_resolve_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ImageSizeResolveUseCase)
final imageSizeResolveUseCaseProvider = ImageSizeResolveUseCaseProvider._();

final class ImageSizeResolveUseCaseProvider
    extends
        $NotifierProvider<ImageSizeResolveUseCase, ImageSizeResolveUseCase> {
  ImageSizeResolveUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'imageSizeResolveUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$imageSizeResolveUseCaseHash();

  @$internal
  @override
  ImageSizeResolveUseCase create() => ImageSizeResolveUseCase();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImageSizeResolveUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ImageSizeResolveUseCase>(value),
    );
  }
}

String _$imageSizeResolveUseCaseHash() =>
    r'c3687f8a6526628b05d149c05d9a123d4dc28762';

abstract class _$ImageSizeResolveUseCase
    extends $Notifier<ImageSizeResolveUseCase> {
  ImageSizeResolveUseCase build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<ImageSizeResolveUseCase, ImageSizeResolveUseCase>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ImageSizeResolveUseCase, ImageSizeResolveUseCase>,
              ImageSizeResolveUseCase,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
