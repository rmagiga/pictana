/// ストレージ機能の Riverpod Provider 定義 (設計書 §14)
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/providers/repository_providers.dart';
import '../../application/usecases/storage/get_default_image_folders_usecase.dart';
import '../../application/usecases/storage/persist_uri_permission_usecase.dart';
import '../../application/usecases/storage/select_storage_usecase.dart';
import '../../application/usecases/storage/watch_storage_connection_usecase.dart';
import '../../application/usecases/storage/get_recent_folders_usecase.dart';
import '../../application/usecases/storage/record_recent_folder_usecase.dart';
import '../../application/usecases/storage/navigate_to_recent_folder_usecase.dart';
import '../../domain/entities/folder_entry.dart';
import '../../domain/entities/storage_root.dart';

part 'storage_providers.g.dart';

// ---------------------------------------------------------------------------
// UseCase Providers
// ---------------------------------------------------------------------------

@riverpod
SelectStorageUseCase selectStorageUseCase(Ref ref) {
  return SelectStorageUseCase(
    storageRepository: ref.watch(storageRepositoryProvider),
  );
}

@riverpod
GetDefaultImageFoldersUseCase getDefaultImageFoldersUseCase(Ref ref) {
  return GetDefaultImageFoldersUseCase(
    storageRepository: ref.watch(storageRepositoryProvider),
  );
}

@riverpod
WatchStorageConnectionUseCase watchStorageConnectionUseCase(Ref ref) {
  return WatchStorageConnectionUseCase(
    storageRepository: ref.watch(storageRepositoryProvider),
  );
}

@riverpod
PersistUriPermissionUseCase persistUriPermissionUseCase(Ref ref) {
  return PersistUriPermissionUseCase(
    storageRepository: ref.watch(storageRepositoryProvider),
  );
}

@riverpod
GetRecentFoldersUseCase getRecentFoldersUseCase(Ref ref) {
  return GetRecentFoldersUseCase(
    storageRepository: ref.watch(storageRepositoryProvider),
  );
}

@riverpod
RecordRecentFolderUseCase recordRecentFolderUseCase(Ref ref) {
  return RecordRecentFolderUseCase(
    storageRepository: ref.watch(storageRepositoryProvider),
  );
}

@riverpod
NavigateToRecentFolderUseCase navigateToRecentFolderUseCase(Ref ref) {
  return NavigateToRecentFolderUseCase(
    storageRepository: ref.watch(storageRepositoryProvider),
  );
}

// ---------------------------------------------------------------------------
// State Providers
// ---------------------------------------------------------------------------

/// ストレージ接続状態（切断などを検知するため）
@riverpod
Stream<List<StorageRoot>> storageRoots(Ref ref) {
  final useCase = ref.watch(watchStorageConnectionUseCaseProvider);
  return useCase.execute();
}

/// 最近開いたフォルダ履歴の状態を管理する Provider
@Riverpod(keepAlive: true)
class RecentFoldersList extends _$RecentFoldersList {
  @override
  FutureOr<List<FolderEntry>> build() async {
    final useCase = ref.watch(getRecentFoldersUseCaseProvider);
    return useCase.execute();
  }

  /// 履歴に追加する
  Future<void> addRecent(FolderEntry folder) async {
    final recordUseCase = ref.read(recordRecentFolderUseCaseProvider);
    await recordUseCase.execute(folder);
    if (ref.mounted) {
      ref.invalidateSelf();
    }
  }

  /// 履歴から削除する
  Future<void> removeRecent(String uri) async {
    final database = ref.read(appDatabaseProvider);
    await database.deleteRecentFolderByUri(uri);
    if (ref.mounted) {
      ref.invalidateSelf();
    }
  }
}
