/// Android SAF 向け StorageRepository 実装 (設計書 §AndroidStorageRepository)
///
/// SafPlatformChannel を使用して Android ネイティブ側の SAF API を呼び出し、
/// StorageRepository インターフェースを実装する。
/// URI パーミッション永続化と DB 連携（最近開いたフォルダ）も担当する。
library;

import 'dart:async';

import '../../../core/logging/app_logger.dart';
import '../../../domain/entities/entry_id.dart';
import '../../../domain/entities/folder_entry.dart';
import '../../../domain/entities/storage_root.dart';
import '../../../domain/repositories/storage_repository.dart';
import '../../database/app_database.dart';
import 'saf_data_mappers.dart';
import 'saf_platform_channel.dart';

/// Android SAF 向け StorageRepository 実装
class AndroidStorageRepository implements StorageRepository {
  AndroidStorageRepository({
    required AppDatabase database,
    required SafPlatformChannel channel,
  }) : _db = database,
       _channel = channel;

  final AppDatabase _db;
  final SafPlatformChannel _channel;

  // ---------------------------------------------------------------------------
  // StorageRepository 実装
  // ---------------------------------------------------------------------------

  @override
  Future<List<StorageRoot>> getStorageRoots() async {
    final maps = await _channel.getStorageRoots();
    return maps.map(StorageRootFromMap.fromChannelMap).toList();
  }

  @override
  Future<FolderEntry?> getDefaultImageFolder() async {
    try {
      final map = await _channel.getDefaultImageFolder();
      if (map == null) return null;
      return FolderEntryFromMap.fromChannelMap(map);
    } catch (e) {
      appLogger.w('getDefaultImageFolder 失敗 (無視)', error: e);
      return null;
    }
  }

  @override
  Future<List<FolderEntry>> getFolders(StorageRoot root) async {
    final maps = await _channel.getChildFolders(root.uri, null);
    return maps
        .map((m) => FolderEntryFromMap.fromChannelMap(m, parentId: root.id))
        .toList();
  }

  @override
  Future<List<FolderEntry>> getSubFolders(FolderEntry folder) async {
    // SAF では treeUri と documentId を使ってサブフォルダを列挙する。
    // FolderEntry の uri にはツリー URI が含まれ、id.rawValue が documentId に対応する。
    final treeUri = folder.uri;
    final documentId = folder.id.rawValue;
    final maps = await _channel.getChildFolders(treeUri, documentId);
    return maps
        .map((m) => FolderEntryFromMap.fromChannelMap(m, parentId: folder.id))
        .toList();
  }

  @override
  Future<FolderEntry?> selectFolder() async {
    final map = await _channel.selectFolder();
    if (map == null) return null;

    final entry = FolderEntryFromMap.fromChannelMap(map);

    // ネイティブ側の SafCommands.selectFolder() で tree URI に対して
    // takePersistableUriPermission が既に実行済みのため、
    // Dart 側での再永続化は不要。
    // recordRecentFolder は UseCase 側で呼ばれる。

    return entry;
  }

  @override
  Future<void> persistUriPermission(String uri) async {
    await _channel.persistUriPermission(uri);
  }

  @override
  Stream<List<StorageRoot>> watchStorageRoots() {
    // USB EventChannel ストリームを購読し、イベント受信のたびに
    // ストレージルート一覧を再取得して emit する。
    // ネイティブ側の getStorageRoots() は現在のマウント状態を反映した
    // isConnected フィールドを返すため、イベントの volumeId/mountPath との
    // 個別マッチングは不要（ネイティブ側で解決済み）。
    //
    // エラーハンドリング: getStorageRoots() が失敗してもストリームを終了させない。
    // 失敗時は前回の結果を保持し、次のイベントで再試行する。
    return _channel.usbEvents.asyncExpand((event) async* {
      try {
        final roots = await getStorageRoots();
        yield roots;
      } catch (e) {
        // getStorageRoots() 失敗時はストリームを終了させずスキップする。
        // 次の USB イベントで再取得を試みる。
        appLogger.w(
          'watchStorageRoots: USB イベント処理中に getStorageRoots() 失敗 (スキップ)',
          error: e,
        );
      }
    });
  }

  @override
  Future<List<FolderEntry>> getRecentFolders() async {
    try {
      final rows = await _db.getRecentFolders();
      return rows
          .where((row) => row.platformType == 'android')
          .map(_rowToFolderEntry)
          .toList();
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
        platformType: 'android',
      );
    } catch (e) {
      appLogger.e('recordRecentFolder 失敗', error: e);
    }
  }

  // ---------------------------------------------------------------------------
  // private ヘルパー
  // ---------------------------------------------------------------------------

  /// DB の RecentFolder 行を FolderEntry に変換する
  ///
  /// DB には tree URI または document URI が保存されている可能性がある。
  /// どちらの場合でも正しい tree URI と document ID を抽出する。
  FolderEntry _rowToFolderEntry(RecentFolder row) {
    final uri = row.uri;
    final treeUri = _extractTreeUri(uri);
    final documentId = _extractDocumentId(uri);
    return FolderEntry(
      id: EntryId.android(documentId),
      name: row.name,
      uri: treeUri,
      parentId: null,
    );
  }

  /// URI から tree URI 部分を抽出する。
  ///
  /// document URI の場合: `.../tree/{id}/document/{id}` → `.../tree/{id}`
  /// tree URI の場合: そのまま返す
  String _extractTreeUri(String uri) {
    final docSegment = '/document/';
    final docIndex = uri.indexOf(docSegment);
    if (docIndex > 0) {
      return uri.substring(0, docIndex);
    }
    return uri;
  }

  /// URI から document ID を抽出する。
  ///
  /// document URI の場合: `.../document/{encodedId}` → デコード済み ID
  /// tree URI の場合: `.../tree/{encodedId}` → デコード済み ID
  String _extractDocumentId(String uri) {
    final docSegment = '/document/';
    final docIndex = uri.indexOf(docSegment);
    if (docIndex >= 0) {
      final encoded = uri.substring(docIndex + docSegment.length);
      return Uri.decodeComponent(encoded);
    }
    final treeSegment = '/tree/';
    final treeIndex = uri.indexOf(treeSegment);
    if (treeIndex >= 0) {
      final encoded = uri.substring(treeIndex + treeSegment.length);
      return Uri.decodeComponent(encoded);
    }
    return uri;
  }
}
