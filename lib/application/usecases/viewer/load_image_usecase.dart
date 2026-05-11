/// LoadImageUseCase (設計書 §18.4)
///
/// 画像ビューアで表示するための実データ（バイト列）を取得するユースケース。
/// 巨大な画像をメインスレッドで同期的に読み込むのを防ぎ、非同期で取得する。
library;

import '../../../domain/entities/image_entry.dart';
import '../../../domain/repositories/image_repository.dart';

class LoadImageUseCase {
  const LoadImageUseCase({required ImageRepository imageRepository})
      : _repo = imageRepository;

  final ImageRepository _repo;

  /// 指定された画像のバイト列を非同期で取得する
  Future<List<int>> execute(ImageEntry entry) async {
    return _repo.getImageBytes(entry);
  }

  /// 指定された画像のメタデータ（詳細なファイルサイズや日時）を取得する
  Future<ImageEntry> getMetadata(ImageEntry entry) async {
    return _repo.getImageMetadata(entry);
  }
}
