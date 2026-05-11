/// ManageCacheUseCase (設計書 §18.6)
///
/// サムネイルキャッシュのサイズ確認やクリアを行うユースケース。
library;

import '../../../domain/repositories/thumbnail_repository.dart';

class ManageCacheUseCase {
  const ManageCacheUseCase({
    required ThumbnailRepository thumbnailRepository,
  }) : _repo = thumbnailRepository;

  final ThumbnailRepository _repo;

  /// 現在のキャッシュサイズ（バイト数）を取得する
  Future<int> getCacheSize() async {
    return _repo.getCacheSize();
  }

  /// キャッシュをすべてクリアする
  Future<void> clearCache() async {
    return _repo.clearCache();
  }
}
