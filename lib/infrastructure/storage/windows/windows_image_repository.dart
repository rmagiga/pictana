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
  const WindowsImageRepository();

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
      throw StorageDisconnectedException(
        message: '${folder.name} が見つかりません',
      );
    }

    final buffer = <ImageEntry>[];
    try {
      await for (final entity in dir.list(followLinks: false)) {
        if (entity is! File) continue;
        final entry = await _fileToImageEntry(entity, folder.id);
        if (entry == null) continue;
        if (!_matchesFilter(entry, filter)) continue;

        buffer.add(entry);
        // 50件ごとに emit する（インクリメンタル表示）
        if (buffer.length >= 50) {
          yield List.of(buffer);
          buffer.clear();
        }
      }
    } catch (e) {
      appLogger.e('getImages エラー: ${folder.uri}', error: e);
      throw StorageDisconnectedException(cause: e);
    }

    if (buffer.isNotEmpty) {
      yield List.of(buffer);
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
    final dir = Directory(folder.uri);
    if (!await dir.exists()) {
      throw StorageDisconnectedException(
        message: '${folder.name} が見つかりません',
      );
    }

    final allEntries = <ImageEntry>[];
    try {
      await for (final entity in dir.list(followLinks: false)) {
        if (entity is! File) continue;
        final entry = await _fileToImageEntry(entity, folder.id);
        if (entry == null) continue;
        if (!_matchesFilter(entry, filter)) continue;
        allEntries.add(entry);
      }
    } catch (e) {
      throw StorageDisconnectedException(cause: e);
    }

    _sortEntries(allEntries, sort);
    final start = page * pageSize;
    if (start >= allEntries.length) return [];
    return allEntries.sublist(
      start,
      (start + pageSize).clamp(0, allEntries.length),
    );
  }

  @override
  Future<int> countImages({
    required FolderEntry folder,
    ImageFilter filter = ImageFilter.none,
  }) async {
    final dir = Directory(folder.uri);
    if (!await dir.exists()) return 0;

    var count = 0;
    try {
      await for (final entity in dir.list(followLinks: false)) {
        if (entity is! File) continue;
        final ext =
            p.extension(entity.path).toLowerCase().replaceFirst('.', '');
        if (!_kSupportedExtensions.containsKey(ext)) continue;
        if (filter.nameQuery != null &&
            !p
                .basename(entity.path)
                .toLowerCase()
                .contains(filter.nameQuery!.toLowerCase())) {
          continue;
        }
        count++;
      }
    } catch (_) {}
    return count;
  }

  @override
  Future<ImageEntry> getImageMetadata(ImageEntry entry) async {
    final file = File(entry.uri);
    final stat = await file.stat();
    return entry.copyWith(
      size: stat.size,
      modifiedAt: stat.modified,
    );
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

  Future<ImageEntry?> _fileToImageEntry(
    File file,
    EntryId parentId,
  ) async {
    final ext = p.extension(file.path).toLowerCase().replaceFirst('.', '');
    final mime = _kSupportedExtensions[ext];
    if (mime == null) return null;

    try {
      final stat = await file.stat();
      return ImageEntry(
        id: EntryId.windows(file.path),
        name: p.basename(file.path),
        extension: ext,
        uri: file.path,
        mimeType: mime,
        size: stat.size,
        modifiedAt: stat.modified,
        createdAt: stat.changed,
      );
    } catch (e) {
      appLogger.w('_fileToImageEntry スキップ: ${file.path}', error: e);
      return null;
    }
  }

  bool _matchesFilter(ImageEntry entry, ImageFilter filter) {
    if (filter.nameQuery != null &&
        !entry.name
            .toLowerCase()
            .contains(filter.nameQuery!.toLowerCase())) {
      return false;
    }
    if (filter.mimeTypes != null &&
        !filter.mimeTypes!.contains(entry.mimeType)) {
      return false;
    }
    return true;
  }

  void _sortEntries(List<ImageEntry> entries, SortOption sort) {
    final asc = sort.isAscending;
    entries.sort((a, b) => switch (sort.field) {
          SortField.name =>
            asc ? a.name.compareTo(b.name) : b.name.compareTo(a.name),
          SortField.date => asc
              ? a.modifiedAt.compareTo(b.modifiedAt)
              : b.modifiedAt.compareTo(a.modifiedAt),
          SortField.size =>
            asc ? a.size.compareTo(b.size) : b.size.compareTo(a.size),
          SortField.type => asc
              ? a.extension.compareTo(b.extension)
              : b.extension.compareTo(a.extension),
        });
  }
}
