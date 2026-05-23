/// Windows 向け ImageRepository 実装 (設計書 §10.1)
library;

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../core/errors/app_exceptions.dart';
import '../../../core/logging/app_logger.dart';
import '../../../domain/entities/entry_id.dart';
import '../../../domain/entities/folder_entry.dart';
import '../../../domain/entities/image_entry.dart';
import '../../../domain/repositories/image_repository.dart';
import '../../../domain/value_objects/sort_option.dart';
import '../../database/app_database.dart';

/// Windows で対応する画像拡張子 → MimeType マップ
/// (bmp は ImageMimeType に存在しないため unknown へ)
const _kSupportedExtensions = <String, ImageMimeType>{
  'jpg': ImageMimeType.jpeg,
  'jpeg': ImageMimeType.jpeg,
  'png': ImageMimeType.png,
  'webp': ImageMimeType.webp,
  'gif': ImageMimeType.gif,
  'heic': ImageMimeType.heic,
  'heif': ImageMimeType.heif,
  'avif': ImageMimeType.avif,
};

/// Windows 向け ImageRepository 実装
class WindowsImageRepository implements ImageRepository {
  WindowsImageRepository({required AppDatabase database}) : _db = database;

  final AppDatabase _db;

  // ---------------------------------------------------------------------------
  // ImageRepository 実装
  // ---------------------------------------------------------------------------

  @override
  Stream<List<ImageEntry>> getImages({
    required FolderEntry folder,
    SortOption sort = SortOption.defaultOption,
    ImageFilter filter = ImageFilter.none,
  }) async* {
    final dir = Directory(folder.uri);
    if (!await dir.exists()) {
      throw StorageDisconnectedException(message: '${folder.name} が見つかりません');
    }

    final activeEntryIds = <String>[];
    final batchToUpsert = <ImageTableData>[];

    try {
      await for (final entity in dir.list(followLinks: false)) {
        if (entity is! File) continue;

        final ext = p.extension(entity.path).toLowerCase().replaceFirst('.', '');
        final mime = _kSupportedExtensions[ext];
        if (mime == null) continue;

        final entryId = EntryId.windows(entity.path).rawValue;
        activeEntryIds.add(entryId);

        final stat = await entity.stat();
        batchToUpsert.add(ImageTableData(
          entryId: entryId,
          uri: entity.path,
          folderUri: folder.uri,
          name: p.basename(entity.path),
          extension: ext,
          modified: stat.modified.millisecondsSinceEpoch,
          size: stat.size,
          mimeType: mime.name,
          indexedAt: DateTime.now(),
        ));

        // 100件ごとにDBへ一括 upsert & yield (有限Streamとして完了を保証するため)
        if (batchToUpsert.length >= 100) {
          await _db.upsertImages(List.of(batchToUpsert));
          batchToUpsert.clear();

          final currentImages = await _db.getImagePage(
            folderUri: folder.uri,
            page: 0,
            pageSize: 1000000,
            sort: sort,
            filter: filter,
          );
          yield currentImages.map((item) => _toImageEntry(item)).toList();
        }
      }

      if (batchToUpsert.isNotEmpty) {
        await _db.upsertImages(batchToUpsert);
      }

      // 存在しない画像をクリーンアップ
      await _db.deleteImagesNotIn(folder.uri, activeEntryIds);

      // アクティブな画像がある場合のみ最終結果を emit
      if (activeEntryIds.isNotEmpty) {
        final finalImages = await _db.getImagePage(
          folderUri: folder.uri,
          page: 0,
          pageSize: 1000000,
          sort: sort,
          filter: filter,
        );
        yield finalImages.map((item) => _toImageEntry(item)).toList();
      }

    } catch (e) {
      appLogger.e('getImages 同期・取得エラー: ${folder.uri}', error: e);
      throw StorageDisconnectedException(cause: e);
    }
  }

  @override
  Future<List<ImageEntry>> getImagePage({
    required FolderEntry folder,
    required int page,
    required int pageSize,
    SortOption sort = SortOption.defaultOption,
    ImageFilter filter = ImageFilter.none,
  }) async {
    final list = await _db.getImagePage(
      folderUri: folder.uri,
      page: page,
      pageSize: pageSize,
      sort: sort,
      filter: filter,
    );
    return list.map((item) => _toImageEntry(item)).toList();
  }

  @override
  Future<int> countImages({
    required FolderEntry folder,
    ImageFilter filter = ImageFilter.none,
  }) async {
    return _db.countImages(folderUri: folder.uri, filter: filter);
  }

  @override
  Future<ImageEntry> getImageMetadata(ImageEntry entry) async {
    final file = File(entry.uri);
    final stat = await file.stat();
    return entry.copyWith(size: stat.size, modifiedAt: stat.modified);
  }

  @override
  Future<List<int>> getImageBytes(ImageEntry entry) async {
    try {
      return await File(entry.uri).readAsBytes();
    } catch (e) {
      throw DecodeFailedException(filePath: entry.uri, cause: e);
    }
  }

  // ---------------------------------------------------------------------------
  // private ヘルパー
  // ---------------------------------------------------------------------------



  ImageEntry _toImageEntry(ImageTableData data) {
    return ImageEntry(
      id: EntryId.windows(data.uri),
      name: data.name,
      extension: data.extension,
      uri: data.uri,
      mimeType: ImageMimeType.values.byName(data.mimeType),
      size: data.size,
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(data.modified),
      width: data.width,
      height: data.height,
    );
  }
}
