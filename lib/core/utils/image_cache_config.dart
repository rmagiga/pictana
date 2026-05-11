/// ImageCache 動的制御 (設計書 §11.3)
///
/// デバイスメモリ量に応じて PaintingBinding.imageCache を動的制御する。
/// HEIC/AVIF decode対策、OOM耐性向上、低RAM端末対応。
library;

import 'dart:io';

import 'package:flutter/painting.dart';

import '../constants/app_constants.dart';
import '../logging/app_logger.dart';

/// ImageCache の最大サイズをデバイスメモリに応じて設定する。
///
/// 呼び出しタイミング: main() 内、WidgetsFlutterBinding.ensureInitialized() 後。
void configureImageCache({int? overrideSizeBytes}) {
  final cache = PaintingBinding.instance.imageCache;

  final targetBytes = overrideSizeBytes ?? _calculateCacheSize();
  cache.maximumSizeBytes = targetBytes;

  // 画像オブジェクト数の上限（デフォルト1000は多すぎる）
  cache.maximumSize = 200;

  appLogger.d(
    'ImageCache 設定: '
    'maximumSizeBytes=${(targetBytes / 1024 / 1024).toStringAsFixed(0)}MB, '
    'maximumSize=${cache.maximumSize}',
  );
}

/// デバイスの物理メモリ量に基づきキャッシュサイズを算出する。
int _calculateCacheSize() {
  // Dartから物理メモリを直接取得する標準APIはないため、
  // プラットフォーム別の合理的なデフォルト値を使用する。
  if (Platform.isAndroid) {
    // Android: 保守的に 256MB をデフォルトとする
    return 256 * 1024 * 1024;
  } else if (Platform.isWindows) {
    // Windows: 開発用途で余裕があるため 512MB
    return 512 * 1024 * 1024;
  }
  return kDefaultCacheSizeBytes;
}

/// アプリ設定のキャッシュ上限（MB）をImageCacheへ反映する。
void applyCacheSizeSetting(int limitMb) {
  final bytes = (limitMb * 1024 * 1024).clamp(
    kMinCacheSizeBytes,
    kMaxCacheSizeBytes,
  );
  PaintingBinding.instance.imageCache.maximumSizeBytes = bytes;
  appLogger.d('ImageCache 上限を ${limitMb}MB に変更');
}
