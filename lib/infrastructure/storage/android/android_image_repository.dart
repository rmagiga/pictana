/// Android SAF 向け ImageRepository 実装 (設計書 §AndroidImageRepository)
///
/// SafPlatformChannel を使用して Android ネイティブ側の SAF API を呼び出し、
/// ImageRepository インターフェースを実装する。
/// 画像列挙はバッチサイズ 50 で Stream emit し、
/// 画像バイト取得はファイルサイズに応じて転送方式を切り替える。
library;

import 'dart:async';
import 'dart:io';

import '../../../core/errors/app_exceptions.dart';
import '../../../core/logging/app_logger.dart';
import '../../../domain/entities/folder_entry.dart';
import '../../../domain/entities/image_entry.dart';
import '../../../domain/entities/entry_id.dart';
import '../../../domain/repositories/image_repository.dart';
import '../../../domain/value_objects/sort_option.dart';
import 'saf_data_mappers.dart';
import 'saf_platform_channel.dart';
import '../../database/app_database.dart';

/// 画像列挙のバッチサイズ
const _kBatchSize = 50;

/// 直接バイト転送の上限サイズ (10MB)
const _kDirectTransferLimit = 10 * 1024 * 1024;

/// Android SAF 向け ImageRepository 実装
class AndroidImageRepository implements ImageRepository {
  AndroidImageRepository({
    required SafPlatformChannel channel,
    required AppDatabase database,
  })  : _channel = channel,
        _db = database;

  final SafPlatformChannel _channel;
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
    final treeUri = folder.uri;
    final documentId = folder.id.rawValue;

    var offset = 0;
    final activeEntryIds = <String>[];
    final batchToUpsert = <ImageTableData>[];

    try {
      while (true) {
        final batch = await _channel.getImages(
          treeUri,
          documentId,
          offset,
          _kBatchSize,
        );

        if (batch.isEmpty) break;

        for (final map in batch) {
          try {
            final entry = ImageEntryFromMap.fromChannelMap(map);
            activeEntryIds.add(entry.id.rawValue);

            batchToUpsert.add(ImageTableData(
              entryId: entry.id.rawValue,
              uri: entry.uri,
              folderUri: folder.uri,
              name: entry.name,
              extension: entry.extension,
              modified: entry.modifiedAt.millisecondsSinceEpoch,
              size: entry.size,
              mimeType: entry.mimeType.name,
              indexedAt: DateTime.now(),
            ));
          } catch (e) {
            appLogger.w('AndroidImageRepository 同期バッチ変換エラー', error: e);
          }
        }

        // 100件ごとにDBへ一括 upsert & yield
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

        if (batch.length < _kBatchSize) break;
        offset += _kBatchSize;
      }

      if (batchToUpsert.isNotEmpty) {
        await _db.upsertImages(batchToUpsert);
      }

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
      appLogger.e('AndroidImageRepository getImages エラー: ${folder.uri}', error: e);
      rethrow;
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
    // SAF では追加メタデータ取得が限定的なため、既存エントリをそのまま返す。
    return entry;
  }

  @override
  Future<List<int>> getImageBytes(ImageEntry entry) async {
    final contentUri = entry.uri;

    // ファイルサイズに応じて転送方式を切り替える
    if (entry.size > _kDirectTransferLimit) {
      // > 10MB: 一時ファイル経由で取得
      return _getImageBytesViaFile(contentUri);
    }

    // <= 10MB: 直接バイト配列で取得
    try {
      final bytes = await _channel.getImageBytes(contentUri);
      return bytes.toList();
    } catch (e) {
      if (e is OutOfMemoryException) rethrow;
      if (e is AppException) rethrow;
      throw DecodeFailedException(filePath: contentUri, cause: e);
    }
  }

  // ---------------------------------------------------------------------------
  // private ヘルパー
  // ---------------------------------------------------------------------------

  /// 一時ファイル経由で画像バイトを取得する
  Future<List<int>> _getImageBytesViaFile(String contentUri) async {
    try {
      final tempPath = await _channel.getImageBytesViaFile(contentUri);
      if (tempPath.isEmpty) {
        throw const DecodeFailedException(message: '一時ファイルパスが空です');
      }

      final file = File(tempPath);
      try {
        final bytes = await file.readAsBytes();
        return bytes.toList();
      } finally {
        // 一時ファイルを削除（失敗しても無視）
        try {
          await file.delete();
        } catch (_) {}
      }
    } catch (e) {
      if (e is OutOfMemoryException) rethrow;
      if (e is AppException) rethrow;
      throw DecodeFailedException(filePath: contentUri, cause: e);
    }
  }



  ImageEntry _toImageEntry(ImageTableData data) {
    return ImageEntry(
      id: EntryId.android(data.entryId),
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
