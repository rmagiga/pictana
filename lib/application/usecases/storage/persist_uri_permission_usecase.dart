/// PersistUriPermissionUseCase (設計書 §10.2)
///
/// Android SAF の URI 永続権限を保持するユースケース。
/// Windows では何もしない（no-op）。
library;

import '../../../domain/repositories/storage_repository.dart';

/// URI権限永続化 UseCase
class PersistUriPermissionUseCase {
  const PersistUriPermissionUseCase({
    required StorageRepository storageRepository,
  }) : _repo = storageRepository;

  final StorageRepository _repo;

  /// 指定 URI の権限を永続化する。
  ///
  /// Android: takePersistableUriPermission を呼び出す。
  /// Windows: no-op。
  Future<void> execute(String uri) => _repo.persistUriPermission(uri);
}
