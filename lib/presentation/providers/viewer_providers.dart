/// ビューア機能の Riverpod Provider 定義 (設計書 §14)
library;

import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/providers/repository_providers.dart';
import '../../application/usecases/viewer/load_image_usecase.dart';
import '../../application/usecases/viewer/preload_adjacent_images_usecase.dart';
import '../../application/usecases/viewer/record_recent_image_usecase.dart';
import '../../application/usecases/viewer/get_recent_images_usecase.dart';
import '../../application/usecases/viewer/resume_position_usecase.dart';
import '../../domain/entities/image_entry.dart';

part 'viewer_providers.g.dart';

// ---------------------------------------------------------------------------
// UseCase Providers
// ---------------------------------------------------------------------------

@riverpod
LoadImageUseCase loadImageUseCase(Ref ref) {
  return LoadImageUseCase(imageRepository: ref.watch(imageRepositoryProvider));
}

@riverpod
PreloadAdjacentImagesUseCase preloadAdjacentImagesUseCase(Ref ref) {
  return PreloadAdjacentImagesUseCase(
    imageRepository: ref.watch(imageRepositoryProvider),
  );
}

@riverpod
RecordRecentImageUseCase recordRecentImageUseCase(Ref ref) {
  return RecordRecentImageUseCase(
    imageRepository: ref.watch(imageRepositoryProvider),
  );
}

@riverpod
GetRecentImagesUseCase getRecentImagesUseCase(Ref ref) {
  return GetRecentImagesUseCase(
    imageRepository: ref.watch(imageRepositoryProvider),
  );
}

@riverpod
ResumePositionUseCase resumePositionUseCase(Ref ref) {
  return ResumePositionUseCase(
    imageRepository: ref.watch(imageRepositoryProvider),
  );
}


// ---------------------------------------------------------------------------
// State Providers
// ---------------------------------------------------------------------------

/// 指定された画像のメタデータを取得する Provider
@riverpod
Future<ImageEntry> imageMetadata(Ref ref, ImageEntry entry) async {
  final useCase = ref.watch(loadImageUseCaseProvider);
  return useCase.getMetadata(entry);
}

/// 指定された画像のバイト列を取得する Provider
/// 取得中はローディングになり、成功すると Uint8List を返す。
/// 同時に同じ画像が要求された場合はキャッシュを共有する。
@riverpod
Future<Uint8List> imageBytes(Ref ref, ImageEntry entry) async {
  final useCase = ref.watch(loadImageUseCaseProvider);
  final bytes = await useCase.execute(entry);
  return Uint8List.fromList(bytes);
}

/// 指定された画像のバイト列から EXIF 回転角度を抽出する Provider。
///
/// 画像バイト列を取得し、ExifProcessorImpl で Orientation タグを解析して
/// 回転角度 (0, 90, 180, 270) を返す。
/// ImageEntry に既に exifRotation が設定されている場合はそれを優先する。
@riverpod
Future<int> imageExifRotation(Ref ref, ImageEntry entry) async {
  // ImageEntry に既に回転角度が設定されている場合はそれを使用
  if (entry.exifRotation != 0) {
    return entry.exifRotation;
  }

  // バイト列を取得して EXIF 解析を実行
  final bytes = await ref.watch(imageBytesProvider(entry).future);
  final exifProcessor = ref.watch(exifProcessorProvider);
  return exifProcessor.extractRotation(bytes);
}

/// 最近見た画像リストの状態管理プロバイダ
@Riverpod(keepAlive: true)
class RecentImagesList extends _$RecentImagesList {
  @override
  FutureOr<List<ImageEntry>> build() async {
    final useCase = ref.watch(getRecentImagesUseCaseProvider);
    return useCase.execute();
  }

  /// 最近見た画像履歴に記録し、一覧状態を更新する
  Future<void> addRecent(ImageEntry image) async {
    final recordUseCase = ref.read(recordRecentImageUseCaseProvider);
    await recordUseCase.execute(image);
    // 状態をリフレッシュする
    if (ref.mounted) {
      ref.invalidateSelf();
    }
  }

  /// 最近見た画像履歴から削除し、一覧状態を更新する
  Future<void> removeRecent(String entryId) async {
    final database = ref.read(appDatabaseProvider);
    await database.deleteRecentImageByEntryId(entryId);
    if (ref.mounted) {
      ref.invalidateSelf();
    }
  }
}

/// フォルダごとの続き位置（最後に見た画像EntryId）を取得する Provider
@riverpod
Future<String?> folderResumePosition(Ref ref, String folderUri) async {
  final useCase = ref.watch(resumePositionUseCaseProvider);
  return useCase.getPosition(folderUri);
}

