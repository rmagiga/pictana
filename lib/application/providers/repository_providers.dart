/// リポジトリ層の Riverpod Provider 定義 (設計書 §14)
///
/// AppDatabase → Repository の依存注入を Riverpod で管理する。
/// UI層はリポジトリを直接参照せず、Use Case Provider 経由で利用する。
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/repositories/image_repository.dart';
import '../../domain/repositories/storage_repository.dart';
import '../../domain/repositories/thumbnail_repository.dart';
import '../../infrastructure/database/app_database.dart';
import '../../infrastructure/storage/common/platform_storage_factory.dart';

part 'repository_providers.g.dart';

// ---------------------------------------------------------------------------
// Database Provider
// ---------------------------------------------------------------------------

/// AppDatabase シングルトン
@Riverpod(keepAlive: true)
AppDatabase appDatabase(AppDatabaseRef ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

// ---------------------------------------------------------------------------
// Repository Providers
// ---------------------------------------------------------------------------

/// StorageRepository Provider
@Riverpod(keepAlive: true)
StorageRepository storageRepository(StorageRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return PlatformStorageFactory.createStorageRepository(db);
}

/// ImageRepository Provider
@Riverpod(keepAlive: true)
ImageRepository imageRepository(ImageRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return PlatformStorageFactory.createImageRepository(db);
}

/// ThumbnailRepository Provider
@Riverpod(keepAlive: true)
ThumbnailRepository thumbnailRepository(ThumbnailRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  final repo = PlatformStorageFactory.createThumbnailRepository(db);
  ref.onDispose(() async {
    // キャッシュマネージャのクリーンアップは不要（ファイルは残す）
  });
  return repo;
}
