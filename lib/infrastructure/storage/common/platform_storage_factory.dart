/// プラットフォーム固有リポジトリのファクトリ (設計書 §10.1)
///
/// 実行プラットフォームを判定し、
/// 対応する具体的なリポジトリ実装を返す。
library;

import 'dart:io';

import '../../../domain/repositories/image_repository.dart';
import '../../../domain/repositories/storage_repository.dart';
import '../../../domain/repositories/thumbnail_repository.dart';
import '../../database/app_database.dart';
import '../windows/windows_image_repository.dart';
import '../windows/windows_storage_repository.dart';
import '../windows/windows_thumbnail_repository.dart';

/// プラットフォーム別リポジトリファクトリ
abstract final class PlatformStorageFactory {
  /// StorageRepository を生成する
  static StorageRepository createStorageRepository(AppDatabase db) {
    if (Platform.isWindows) {
      return WindowsStorageRepository(database: db);
    }
    // TODO: Android 実装は Phase後半で追加
    throw UnsupportedError(
      '未対応のプラットフォーム: ${Platform.operatingSystem}',
    );
  }

  /// ImageRepository を生成する
  static ImageRepository createImageRepository(AppDatabase db) {
    if (Platform.isWindows) {
      return const WindowsImageRepository();
    }
    throw UnsupportedError(
      '未対応のプラットフォーム: ${Platform.operatingSystem}',
    );
  }

  /// ThumbnailRepository を生成する
  static ThumbnailRepository createThumbnailRepository(AppDatabase db) {
    if (Platform.isWindows) {
      return WindowsThumbnailRepository(database: db);
    }
    throw UnsupportedError(
      '未対応のプラットフォーム: ${Platform.operatingSystem}',
    );
  }
}
