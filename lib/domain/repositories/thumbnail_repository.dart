/// ThumbnailRepository Interface (設計書 §9.2, §11)
///
/// 責務:
/// - サムネイル生成（メインIsolateではなく専用Isolateで実行）
/// - キャッシュ（メモリ + ディスク）
/// - invalidate
library;

import 'dart:typed_data';

import '../entities/image_entry.dart';

/// サムネイルのサイズオプション
enum ThumbnailSize {
  /// 一覧用サムネイル (設計書 §11.2: 256px)
  grid(256),

  /// 大きめサムネイル（設定: 大）
  large(512);

  const ThumbnailSize(this.px);
  final int px;
}

abstract interface class ThumbnailRepository {
  /// 指定画像のサムネイルを取得する。
  ///
  /// キャッシュが存在する場合はキャッシュから返す。
  /// キャッシュがない場合はIsolateでサムネイルを生成してキャッシュに保存する。
  ///
  /// - Android: ContentResolver.loadThumbnail() 優先 → Isolate fallback
  /// - Windows: Isolate decode
  ///
  /// 生成失敗時は null を返す（例外は投げない）。
  Future<Uint8List?> getThumbnail(
    ImageEntry entry, {
    ThumbnailSize size = ThumbnailSize.grid,
  });

  /// キャッシュの使用サイズを返す（bytes）。
  Future<int> getCacheSize();

  /// キャッシュを全クリアする。
  Future<void> clearCache();

  /// 指定画像のキャッシュを無効化する。
  Future<void> invalidate(ImageEntry entry);

  /// キャッシュ上限を設定する。
  Future<void> setCacheSizeLimit(int limitBytes);
}
