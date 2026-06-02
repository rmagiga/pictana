// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_collection_images_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// コレクション画像一覧を Stream で監視するユースケース

@ProviderFor(GetCollectionImagesUseCase)
final getCollectionImagesUseCaseProvider =
    GetCollectionImagesUseCaseProvider._();

/// コレクション画像一覧を Stream で監視するユースケース
final class GetCollectionImagesUseCaseProvider
    extends
        $NotifierProvider<
          GetCollectionImagesUseCase,
          GetCollectionImagesUseCase
        > {
  /// コレクション画像一覧を Stream で監視するユースケース
  GetCollectionImagesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getCollectionImagesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getCollectionImagesUseCaseHash();

  @$internal
  @override
  GetCollectionImagesUseCase create() => GetCollectionImagesUseCase();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetCollectionImagesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetCollectionImagesUseCase>(value),
    );
  }
}

String _$getCollectionImagesUseCaseHash() =>
    r'adfd033076ec14263dc0670354e4aaccbcd23f1c';

/// コレクション画像一覧を Stream で監視するユースケース

abstract class _$GetCollectionImagesUseCase
    extends $Notifier<GetCollectionImagesUseCase> {
  GetCollectionImagesUseCase build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<GetCollectionImagesUseCase, GetCollectionImagesUseCase>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                GetCollectionImagesUseCase,
                GetCollectionImagesUseCase
              >,
              GetCollectionImagesUseCase,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
