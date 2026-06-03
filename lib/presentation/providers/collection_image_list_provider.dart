/// コレクション画像一覧 Provider
///
/// GetCollectionImagesUseCase を利用してコレクション画像一覧を Stream で監視する。
/// sortOrder 昇順で表示され、DB の変更に応じてリアルタイムに更新される。
library;

import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/providers/repository_providers.dart';
import '../../application/usecases/collection/get_collection_images_use_case.dart';
import '../../domain/entities/collection_image.dart';
import '../../domain/entities/entry_id.dart';
import '../../domain/entities/image_entry.dart';

part 'collection_image_list_provider.g.dart';

// ---------------------------------------------------------------------------
// Stream Provider
// ---------------------------------------------------------------------------

/// コレクション画像一覧を sortOrder 昇順でリアルタイム監視する Stream Provider
///
/// [collectionId] 対象コレクションの ID
/// DB のコレクション画像データが変更されると自動的に最新の一覧を emit する。
@riverpod
Stream<List<CollectionImage>> collectionImageList(Ref ref, int collectionId) {
  final useCase = ref.watch(getCollectionImagesUseCaseProvider);
  return useCase.execute(collectionId);
}

/// コレクション画像エントリリストを非同期に取得・変換する Provider
///
/// [collectionId] 対象コレクションの ID
@riverpod
Future<List<ImageEntry>> collectionImageEntries(Ref ref, int collectionId) async {
  final collectionImagesAsync = ref.watch(collectionImageListProvider(collectionId));
  final List<CollectionImage> collectionImages;
  if (collectionImagesAsync.value == null) {
    collectionImages = await ref.watch(collectionImageListProvider(collectionId).future);
  } else {
    collectionImages = collectionImagesAsync.value!;
  }
  final db = ref.watch(appDatabaseProvider);

  final entryIds = collectionImages.map((img) => img.entryId.rawValue).toList();
  if (entryIds.isEmpty) return const [];

  final imageDatas = await db.getImagesByEntryIds(entryIds);
  final dataMap = {for (final data in imageDatas) data.entryId: data};

  final entries = <ImageEntry>[];
  for (final img in collectionImages) {
    final imageData = dataMap[img.entryId.rawValue];
    if (imageData != null) {
      entries.add(ImageEntry(
        id: Platform.isWindows
            ? EntryId.windows(imageData.uri)
            : EntryId.android(imageData.uri),
        name: imageData.name,
        extension: imageData.extension,
        uri: imageData.uri,
        mimeType: ImageMimeType.values.byName(imageData.mimeType),
        size: imageData.size,
        modifiedAt: DateTime.fromMillisecondsSinceEpoch(imageData.modified),
        width: imageData.width,
        height: imageData.height,
        exifDateTime: imageData.exifDateTime,
        exifCamera: imageData.exifCamera,
        exifGpsLatitude: imageData.exifGpsLatitude,
        exifGpsLongitude: imageData.exifGpsLongitude,
      ));
    }
  }
  return entries;
}
