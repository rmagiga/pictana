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
import '../../../domain/repositories/image_repository.dart';
import '../../../domain/value_objects/sort_option.dart';
import 'saf_data_mappers.dart';
import 'saf_platform_channel.dart';

/// 画像列挙のバッチサイズ
const _kBatchSize = 50;

/// 直接バイト転送の上限サイズ (10MB)
const _kDirectTransferLimit = 10 * 1024 * 1024;

/// Android SAF 向け ImageRepository 実装
class AndroidImageRepository implements ImageRepository {
  AndroidImageRepository({required SafPlatformChannel channel})
    : _channel = channel;

  final SafPlatformChannel _channel;

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

    while (true) {
      List<Map<String, dynamic>> batch;
      try {
        batch = await _channel.getImages(
          treeUri,
          documentId,
          offset,
          _kBatchSize,
        );
      } catch (e) {
        // アクセス不可の場合はエラーを伝播する
        appLogger.e('getImages バッチ取得エラー (offset=$offset)', error: e);
        rethrow;
      }

      // 空バッチ = 全件取得完了
      if (batch.isEmpty) break;

      // Map → ImageEntry に変換し、フィルターを適用
      final entries = <ImageEntry>[];
      for (final map in batch) {
        try {
          final entry = ImageEntryFromMap.fromChannelMap(map);
          if (_matchesFilter(entry, filter)) {
            entries.add(entry);
          }
        } catch (e) {
          // 個別エントリの変換エラーはスキップして継続（エラー耐性）
          appLogger.w('getImages エントリ変換スキップ', error: e);
        }
      }

      if (entries.isNotEmpty) {
        yield entries;
      }

      // バッチサイズ未満 = 最終バッチ
      if (batch.length < _kBatchSize) break;

      offset += _kBatchSize;
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
    final treeUri = folder.uri;
    final documentId = folder.id.rawValue;
    final offset = page * pageSize;

    final batch = await _channel.getImages(
      treeUri,
      documentId,
      offset,
      pageSize,
    );

    final entries = <ImageEntry>[];
    for (final map in batch) {
      try {
        final entry = ImageEntryFromMap.fromChannelMap(map);
        if (_matchesFilter(entry, filter)) {
          entries.add(entry);
        }
      } catch (e) {
        appLogger.w('getImagePage エントリ変換スキップ', error: e);
      }
    }

    return entries;
  }

  @override
  Future<int> countImages({
    required FolderEntry folder,
    ImageFilter filter = ImageFilter.none,
  }) async {
    final treeUri = folder.uri;
    final documentId = folder.id.rawValue;

    var count = 0;
    var offset = 0;

    while (true) {
      final batch = await _channel.getImages(
        treeUri,
        documentId,
        offset,
        _kBatchSize,
      );

      if (batch.isEmpty) break;

      if (!filter.hasFilter) {
        count += batch.length;
      } else {
        for (final map in batch) {
          try {
            final entry = ImageEntryFromMap.fromChannelMap(map);
            if (_matchesFilter(entry, filter)) {
              count++;
            }
          } catch (_) {
            // 変換エラーはカウントしない
          }
        }
      }

      if (batch.length < _kBatchSize) break;
      offset += _kBatchSize;
    }

    return count;
  }

  @override
  Future<ImageEntry> getImageMetadata(ImageEntry entry) async {
    // SAF では追加メタデータ取得が限定的なため、既存エントリをそのまま返す。
    // 将来的に ExifInterface 等を使用する場合はここを拡張する。
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
  ///
  /// ネイティブ側が一時ファイルに書き出し、そのパスを返す。
  /// Dart 側でファイルを読み込み、読み込み後に一時ファイルを削除する。
  Future<List<int>> _getImageBytesViaFile(String contentUri) async {
    try {
      final tempPath = await _channel.getImageBytesViaFile(contentUri);
      if (tempPath.isEmpty) {
        throw const DecodeFailedException(
          message: '一時ファイルパスが空です',
        );
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

  /// フィルター条件に一致するかを判定する
  bool _matchesFilter(ImageEntry entry, ImageFilter filter) {
    if (filter.nameQuery != null &&
        !entry.name.toLowerCase().contains(filter.nameQuery!.toLowerCase())) {
      return false;
    }
    if (filter.mimeTypes != null &&
        !filter.mimeTypes!.contains(entry.mimeType)) {
      return false;
    }
    return true;
  }
}
