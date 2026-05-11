/// ビューア機能の Riverpod Provider 定義 (設計書 §14)
library;

import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/providers/repository_providers.dart';
import '../../application/usecases/viewer/load_image_usecase.dart';
import '../../application/usecases/viewer/preload_adjacent_images_usecase.dart';
import '../../domain/entities/image_entry.dart';

part 'viewer_providers.g.dart';

// ---------------------------------------------------------------------------
// UseCase Providers
// ---------------------------------------------------------------------------

@riverpod
LoadImageUseCase loadImageUseCase(LoadImageUseCaseRef ref) {
  return LoadImageUseCase(
    imageRepository: ref.watch(imageRepositoryProvider),
  );
}

@riverpod
PreloadAdjacentImagesUseCase preloadAdjacentImagesUseCase(
  PreloadAdjacentImagesUseCaseRef ref,
) {
  return PreloadAdjacentImagesUseCase(
    imageRepository: ref.watch(imageRepositoryProvider),
  );
}

// ---------------------------------------------------------------------------
// State Providers
// ---------------------------------------------------------------------------

/// 指定された画像のメタデータを取得する Provider
@riverpod
Future<ImageEntry> imageMetadata(
  ImageMetadataRef ref,
  ImageEntry entry,
) async {
  final useCase = ref.watch(loadImageUseCaseProvider);
  return useCase.getMetadata(entry);
}

/// 指定された画像のバイト列を取得する Provider
/// 取得中はローディングになり、成功すると Uint8List を返す。
/// 同時に同じ画像が要求された場合はキャッシュを共有する。
@riverpod
Future<Uint8List> imageBytes(
  ImageBytesRef ref,
  ImageEntry entry,
) async {
  final useCase = ref.watch(loadImageUseCaseProvider);
  final bytes = await useCase.execute(entry);
  return Uint8List.fromList(bytes);
}
