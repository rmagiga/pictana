/// フォルダサムネイル取得 Provider
///
/// 個別フォルダのサムネイル取得を管理する Family Provider。
/// キャッシュチェック → キャッシュミス時に UseCase 実行 →
/// 結果をキャッシュに保存 → 結果を返す。
library;

import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/providers/repository_providers.dart';
import '../../application/usecases/favorites/get_folder_thumbnail_usecase.dart';
import '../../domain/entities/favorite_folder.dart';
import 'folder_thumbnail_cache_provider.dart';

part 'folder_thumbnail_provider.g.dart';

/// 個別フォルダのサムネイルを取得する Family Provider
///
/// [FavoriteFolder] を引数に取り、以下のフローでサムネイルを返す:
/// 1. メモリキャッシュをチェック（ヒット時は即座に返す）
/// 2. キャッシュミス時は [GetFolderThumbnailUseCase] を実行
/// 3. 取得結果をキャッシュに保存
/// 4. 結果を返す（null の場合もそのまま返す）
@riverpod
Future<Uint8List?> getFolderThumbnail(
  GetFolderThumbnailRef ref,
  FavoriteFolder folder,
) async {
  // 1. キャッシュチェック
  final cache = ref.read(folderThumbnailCacheProvider.notifier);
  final cached = cache.get(folder.uri);
  if (cached != null) {
    return cached;
  }

  // 2. キャッシュミス時は UseCase を実行
  final useCase = GetFolderThumbnailUseCase(
    imageRepository: ref.read(imageRepositoryProvider),
    thumbnailRepository: ref.read(thumbnailRepositoryProvider),
  );

  final result = await useCase.execute(folder: folder);

  // 3. 結果をキャッシュに保存（null でない場合のみ）
  if (result != null) {
    cache.put(folder.uri, result);
  }

  // 4. 結果を返す
  return result;
}
