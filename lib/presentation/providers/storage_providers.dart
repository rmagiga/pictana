/// ストレージ機能の Riverpod Provider 定義 (設計書 §14)
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/providers/repository_providers.dart';
import '../../application/usecases/storage/get_default_image_folders_usecase.dart';
import '../../application/usecases/storage/persist_uri_permission_usecase.dart';
import '../../application/usecases/storage/select_storage_usecase.dart';
import '../../application/usecases/storage/watch_storage_connection_usecase.dart';
import '../../domain/entities/storage_root.dart';

part 'storage_providers.g.dart';

// ---------------------------------------------------------------------------
// UseCase Providers
// ---------------------------------------------------------------------------

@riverpod
SelectStorageUseCase selectStorageUseCase(SelectStorageUseCaseRef ref) {
  return SelectStorageUseCase(
    storageRepository: ref.watch(storageRepositoryProvider),
  );
}

@riverpod
GetDefaultImageFoldersUseCase getDefaultImageFoldersUseCase(
  GetDefaultImageFoldersUseCaseRef ref,
) {
  return GetDefaultImageFoldersUseCase(
    storageRepository: ref.watch(storageRepositoryProvider),
  );
}

@riverpod
WatchStorageConnectionUseCase watchStorageConnectionUseCase(
  WatchStorageConnectionUseCaseRef ref,
) {
  return WatchStorageConnectionUseCase(
    storageRepository: ref.watch(storageRepositoryProvider),
  );
}

@riverpod
PersistUriPermissionUseCase persistUriPermissionUseCase(
  PersistUriPermissionUseCaseRef ref,
) {
  return PersistUriPermissionUseCase(
    storageRepository: ref.watch(storageRepositoryProvider),
  );
}

// ---------------------------------------------------------------------------
// State Providers
// ---------------------------------------------------------------------------

/// ストレージ接続状態（切断などを検知するため）
@riverpod
Stream<List<StorageRoot>> storageRoots(StorageRootsRef ref) {
  final useCase = ref.watch(watchStorageConnectionUseCaseProvider);
  return useCase.execute();
}
