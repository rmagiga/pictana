/// WatchStorageConnectionUseCase (設計書 §19.1)
///
/// USB/ストレージの接続状態を監視するユースケース。
/// ストレージが切断された際にバナー表示などの通知を行うために使用する。
library;

import '../../../domain/entities/storage_root.dart';
import '../../../domain/repositories/storage_repository.dart';

/// ストレージ接続状態監視 UseCase
class WatchStorageConnectionUseCase {
  const WatchStorageConnectionUseCase({
    required StorageRepository storageRepository,
  }) : _repo = storageRepository;

  final StorageRepository _repo;

  /// ストレージルート一覧の変化を監視するストリームを返す。
  ///
  /// ストレージの接続/切断時に新しいリストが emit される。
  Stream<List<StorageRoot>> execute() => _repo.watchStorageRoots();
}
