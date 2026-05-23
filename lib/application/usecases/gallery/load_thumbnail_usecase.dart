/// LoadThumbnailUseCase (設計書 §11)
///
/// サムネイル取得ユースケース。
/// キャッシュヒット時はキャッシュから返し、
/// キャッシュミス時は Isolate でサムネイルを生成する。
library;

import 'dart:typed_data';

import '../../../core/utils/cancel_token.dart';
import '../../../domain/entities/image_entry.dart';
import '../../../domain/repositories/thumbnail_repository.dart';
import '../../../domain/value_objects/thumbnail_size_option.dart';

/// サムネイル読み込み UseCase
class LoadThumbnailUseCase {
  const LoadThumbnailUseCase({required ThumbnailRepository thumbnailRepository})
      : _repo = thumbnailRepository;

  final ThumbnailRepository _repo;

  /// 指定画像のサムネイルを取得する。
  ///
  /// キャッシュ優先で返す。生成失敗時は null を返す。
  Future<Uint8List?> execute(
    ImageEntry entry, {
    ThumbnailSizeOption size = ThumbnailSizeOption.medium,
    CancelToken? cancelToken,
  }) {
    return _repo.getThumbnail(entry, size: size, cancelToken: cancelToken);
  }

  /// キャッシュの使用サイズ（bytes）を返す。
  Future<int> getCacheSize() => _repo.getCacheSize();

  /// 全キャッシュをクリアする。
  Future<void> clearCache() => _repo.clearCache();
}
