// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(selectStorageUseCase)
final selectStorageUseCaseProvider = SelectStorageUseCaseProvider._();

final class SelectStorageUseCaseProvider
    extends
        $FunctionalProvider<
          SelectStorageUseCase,
          SelectStorageUseCase,
          SelectStorageUseCase
        >
    with $Provider<SelectStorageUseCase> {
  SelectStorageUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectStorageUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectStorageUseCaseHash();

  @$internal
  @override
  $ProviderElement<SelectStorageUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SelectStorageUseCase create(Ref ref) {
    return selectStorageUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SelectStorageUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SelectStorageUseCase>(value),
    );
  }
}

String _$selectStorageUseCaseHash() =>
    r'74f34d43f6baecd2cb8a0cda0cc9438bfc330199';

@ProviderFor(getDefaultImageFoldersUseCase)
final getDefaultImageFoldersUseCaseProvider =
    GetDefaultImageFoldersUseCaseProvider._();

final class GetDefaultImageFoldersUseCaseProvider
    extends
        $FunctionalProvider<
          GetDefaultImageFoldersUseCase,
          GetDefaultImageFoldersUseCase,
          GetDefaultImageFoldersUseCase
        >
    with $Provider<GetDefaultImageFoldersUseCase> {
  GetDefaultImageFoldersUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getDefaultImageFoldersUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getDefaultImageFoldersUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetDefaultImageFoldersUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetDefaultImageFoldersUseCase create(Ref ref) {
    return getDefaultImageFoldersUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetDefaultImageFoldersUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetDefaultImageFoldersUseCase>(
        value,
      ),
    );
  }
}

String _$getDefaultImageFoldersUseCaseHash() =>
    r'f97394acc42335dd0db23b7aec1277a7275fc18d';

@ProviderFor(watchStorageConnectionUseCase)
final watchStorageConnectionUseCaseProvider =
    WatchStorageConnectionUseCaseProvider._();

final class WatchStorageConnectionUseCaseProvider
    extends
        $FunctionalProvider<
          WatchStorageConnectionUseCase,
          WatchStorageConnectionUseCase,
          WatchStorageConnectionUseCase
        >
    with $Provider<WatchStorageConnectionUseCase> {
  WatchStorageConnectionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchStorageConnectionUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchStorageConnectionUseCaseHash();

  @$internal
  @override
  $ProviderElement<WatchStorageConnectionUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WatchStorageConnectionUseCase create(Ref ref) {
    return watchStorageConnectionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatchStorageConnectionUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatchStorageConnectionUseCase>(
        value,
      ),
    );
  }
}

String _$watchStorageConnectionUseCaseHash() =>
    r'632fc0da1808497027701e227a720e1a5ce66739';

@ProviderFor(persistUriPermissionUseCase)
final persistUriPermissionUseCaseProvider =
    PersistUriPermissionUseCaseProvider._();

final class PersistUriPermissionUseCaseProvider
    extends
        $FunctionalProvider<
          PersistUriPermissionUseCase,
          PersistUriPermissionUseCase,
          PersistUriPermissionUseCase
        >
    with $Provider<PersistUriPermissionUseCase> {
  PersistUriPermissionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'persistUriPermissionUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$persistUriPermissionUseCaseHash();

  @$internal
  @override
  $ProviderElement<PersistUriPermissionUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PersistUriPermissionUseCase create(Ref ref) {
    return persistUriPermissionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PersistUriPermissionUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PersistUriPermissionUseCase>(value),
    );
  }
}

String _$persistUriPermissionUseCaseHash() =>
    r'4a7004b0ea91fc448c677cda0de60bc3c69ef033';

/// ストレージ接続状態（切断などを検知するため）

@ProviderFor(storageRoots)
final storageRootsProvider = StorageRootsProvider._();

/// ストレージ接続状態（切断などを検知するため）

final class StorageRootsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StorageRoot>>,
          List<StorageRoot>,
          Stream<List<StorageRoot>>
        >
    with
        $FutureModifier<List<StorageRoot>>,
        $StreamProvider<List<StorageRoot>> {
  /// ストレージ接続状態（切断などを検知するため）
  StorageRootsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storageRootsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storageRootsHash();

  @$internal
  @override
  $StreamProviderElement<List<StorageRoot>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<StorageRoot>> create(Ref ref) {
    return storageRoots(ref);
  }
}

String _$storageRootsHash() => r'9c205ce68b4adde88ff0cd73f62f3e28b0607652';
