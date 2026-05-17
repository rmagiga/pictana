/// Windows 向け StorageRepository 実装 (設計書 §10.1)
///
/// Windows ローカルファイルシステムに対して
/// StorageRepository インターフェースを実装する。
library;

import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/errors/app_exceptions.dart';
import '../../../core/logging/app_logger.dart';
import '../../../domain/entities/entry_id.dart';
import '../../../domain/entities/folder_entry.dart';
import '../../../domain/entities/storage_root.dart';
import '../../../domain/repositories/storage_repository.dart';
import '../../database/app_database.dart';

/// 最近開いたフォルダの DB 行型エイリアス
typedef RecentFolderRow = RecentFolder;

/// Windows 向け StorageRepository 実装
class WindowsStorageRepository implements StorageRepository {
  WindowsStorageRepository({required AppDatabase database}) : _db = database;

  final AppDatabase _db;

  /// ストレージ変更ストリーム用コントローラ
  final _storageStreamController =
      StreamController<List<StorageRoot>>.broadcast();

  // ---------------------------------------------------------------------------
  // StorageRepository 実装
  // ---------------------------------------------------------------------------

  @override
  Future<List<StorageRoot>> getStorageRoots() async {
    try {
      final roots = await _enumerateDrives();
      return roots;
    } catch (e) {
      appLogger.e('getStorageRoots 失敗', error: e);
      throw StorageDisconnectedException(cause: e);
    }
  }

  @override
  Future<FolderEntry?> getDefaultImageFolder() async {
    try {
      // Windows: ユーザーのピクチャフォルダ (~/Pictures)
      final pictures = await getApplicationDocumentsDirectory();
      // path_provider の Documents を基点に Pictures を特定
      final home = pictures.parent;
      final picturesDir = Directory(p.join(home.path, 'Pictures'));
      if (await picturesDir.exists()) {
        return _dirToFolderEntry(picturesDir, parentId: null);
      }
      return null;
    } catch (e) {
      appLogger.w('getDefaultImageFolder 失敗 (無視)', error: e);
      return null;
    }
  }

  @override
  Future<List<FolderEntry>> getFolders(StorageRoot root) async {
    try {
      final dir = Directory(root.uri);
      return await _listSubDirs(dir, parentId: root.id);
    } catch (e) {
      appLogger.e('getFolders 失敗: ${root.uri}', error: e);
      throw StorageDisconnectedException(
        message: 'ドライブ ${root.name} へのアクセスに失敗しました',
        cause: e,
      );
    }
  }

  @override
  Future<List<FolderEntry>> getSubFolders(FolderEntry folder) async {
    try {
      final dir = Directory(folder.uri);
      return await _listSubDirs(dir, parentId: folder.id);
    } catch (e) {
      appLogger.e('getSubFolders 失敗: ${folder.uri}', error: e);
      throw StorageDisconnectedException(cause: e);
    }
  }

  @override
  Future<FolderEntry?> selectFolder() async {
    try {
      final result = await FilePicker.getDirectoryPath(
        dialogTitle: '画像フォルダを選択',
      );
      if (result == null) return null; // キャンセル

      final dir = Directory(result);
      if (!await dir.exists()) return null;

      final entry = _dirToFolderEntry(dir, parentId: null);
      return entry;
    } catch (e) {
      appLogger.e('selectFolder 失敗', error: e);
      throw StorageDisconnectedException(cause: e);
    }
  }

  @override
  Future<void> persistUriPermission(String uri) async {
    // Windows ではパーミッションの永続化は不要
  }

  @override
  Stream<List<StorageRoot>> watchStorageRoots() {
    // 初期値を流す
    getStorageRoots()
        .then((roots) => _storageStreamController.add(roots))
        .catchError((_) {});
    return _storageStreamController.stream;
  }

  @override
  Future<List<FolderEntry>> getRecentFolders() async {
    try {
      final rows = await _db.getRecentFolders();
      return rows.map((row) => _rowToFolderEntry(row)).toList();
    } catch (e) {
      appLogger.e('getRecentFolders 失敗', error: e);
      return [];
    }
  }

  @override
  Future<void> recordRecentFolder(FolderEntry folder) async {
    try {
      await _db.upsertRecentFolder(
        uri: folder.uri,
        name: folder.name,
        platformType: 'windows',
      );
    } catch (e) {
      appLogger.e('recordRecentFolder 失敗', error: e);
    }
  }

  @override
  FolderEntry restoreFolderFromUri({
    required String uri,
    required String name,
  }) {
    return FolderEntry(
      id: EntryId.windows(uri),
      name: name,
      uri: uri,
      parentId: null,
    );
  }

  // ---------------------------------------------------------------------------
  // private ヘルパー
  // ---------------------------------------------------------------------------

  /// 利用可能なドライブ (C:\, D:\, ...) を列挙する
  Future<List<StorageRoot>> _enumerateDrives() async {
    final roots = <StorageRoot>[];
    for (final letter in _driveLetters()) {
      final path = '$letter:\\';
      final dir = Directory(path);
      if (await dir.exists()) {
        roots.add(
          StorageRoot(
            id: EntryId.windows(path),
            name: '$letter:',
            type: StorageType.internal,
            uri: path,
          ),
        );
      }
    }
    return roots;
  }

  /// A〜Z のドライブ文字リスト
  Iterable<String> _driveLetters() sync* {
    for (var i = 0; i < 26; i++) {
      yield String.fromCharCode('A'.codeUnitAt(0) + i);
    }
  }

  /// ディレクトリ内のサブディレクトリを FolderEntry リストとして返す
  Future<List<FolderEntry>> _listSubDirs(
    Directory dir, {
    required EntryId? parentId,
  }) async {
    final entries = <FolderEntry>[];
    try {
      await for (final entity in dir.list(followLinks: false)) {
        if (entity is Directory) {
          final name = p.basename(entity.path);
          // 隠しフォルダ ($RECYCLE.BIN, System Volume Information 等) を除外
          if (name.startsWith(r'$') || name.startsWith('.')) continue;
          entries.add(_dirToFolderEntry(entity, parentId: parentId));
        }
      }
    } catch (e) {
      appLogger.w('_listSubDirs 部分エラー: ${dir.path}', error: e);
    }
    entries.sort((a, b) => a.name.compareTo(b.name));
    return entries;
  }

  FolderEntry _dirToFolderEntry(Directory dir, {required EntryId? parentId}) {
    return FolderEntry(
      id: EntryId.windows(dir.path),
      name: p.basename(dir.path).isEmpty ? dir.path : p.basename(dir.path),
      uri: dir.path,
      parentId: parentId,
    );
  }

  FolderEntry _rowToFolderEntry(RecentFolderRow row) {
    return restoreFolderFromUri(uri: row.uri, name: row.name);
  }

  /// リソース解放
  Future<void> dispose() async {
    await _storageStreamController.close();
  }
}
