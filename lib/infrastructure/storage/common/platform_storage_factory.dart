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
import '../android/android_image_repository.dart';
import '../android/android_storage_repository.dart';
import '../android/android_thumbnail_repository.dart';
import '../android/saf_platform_channel.dart';
import '../windows/windows_image_repository.dart';
import '../windows/windows_storage_repository.dart';
import '../windows/windows_thumbnail_repository.dart';

/// プラットフォーム別リポジトリファクトリ
abstract final class PlatformStorageFactory {
  /// Android SAF 用プラットフォームチャネル（共有インスタンス）
  static final SafPlatformChannel _safChannel = SafPlatformChannel();

  /// StorageRepository を生成する
  static StorageRepository createStorageRepository(AppDatabase db) {
    if (Platform.isWindows) {
      return WindowsStorageRepository(database: db);
    }
    if (Platform.isAndroid) {
      return AndroidStorageRepository(database: db, channel: _safChannel);
    }
    throw UnsupportedError('未対応のプラットフォーム: ${Platform.operatingSystem}');
  }

  /// ImageRepository を生成する
  static ImageRepository createImageRepository(AppDatabase db) {
    if (Platform.isWindows) {
      return const WindowsImageRepository();
    }
    if (Platform.isAndroid) {
      return AndroidImageRepository(channel: _safChannel);
    }
    throw UnsupportedError('未対応のプラットフォーム: ${Platform.operatingSystem}');
  }

  /// ThumbnailRepository を生成する
  static ThumbnailRepository createThumbnailRepository(AppDatabase db) {
    if (Platform.isWindows) {
      return WindowsThumbnailRepository(database: db);
    }
    if (Platform.isAndroid) {
      return AndroidThumbnailRepository(database: db, channel: _safChannel);
    }
    throw UnsupportedError('未対応のプラットフォーム: ${Platform.operatingSystem}');
  }
}
