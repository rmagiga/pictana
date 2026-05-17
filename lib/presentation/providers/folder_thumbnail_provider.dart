/// フォルダサムネイル取得 Provider（複数サムネイル対応版）
///
/// 個別フォルダの最大4枚のサムネイル取得を管理する Family Provider。
/// キャッシュチェック → キャッシュミス時に UseCase 実行 →
/// 結果をキャッシュに保存 → 結果を返す。
library;

import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/providers/repository_providers.dart';
import '../../application/usecases/storage/get_folder_thumbnails_usecase.dart';
import '../../domain/entities/favorite_folder.dart';
import 'folder_thumbnail_cache_provider.dart';

part 'folder_thumbnail_provider.g.dart';

/// 個別フォルダのサムネイルを最大4枚取得する Family Provider
///
/// [FavoriteFolder] を引数に取り、以下のフローでサムネイルリストを返す:
/// 1. メモリキャッシュをチェック（ヒット時は即座に返す）
/// 2. キャッシュミス時は [GetFolderThumbnailsUseCase] を実行
/// 3. 取得結果をキャッシュに保存
/// 4. 結果を返す（空リストの場合もそのまま返す）
@riverpod
Future<List<Uint8List?>> getFolderThumbnails(
  Ref ref,
  FavoriteFolder folder,
) async {
  // 1. キャッシュチェック
  final cache = ref.read(folderThumbnailCacheProvider.notifier);
  final cached = cache.getList(folder.uri);
  if (cached != null) {
    return cached;
  }

  // 2. キャッシュミス時は UseCase を実行
  final useCase = GetFolderThumbnailsUseCase(
    imageRepository: ref.read(imageRepositoryProvider),
    thumbnailRepository: ref.read(thumbnailRepositoryProvider),
    storageRepository: ref.read(storageRepositoryProvider),
  );

  final result = await useCase.execute(folder: folder);

  // 3. 結果をキャッシュに保存（空でない場合のみ）
  if (result.isNotEmpty) {
    cache.putList(folder.uri, result);
  }

  // 4. 結果を返す
  return result;
}
