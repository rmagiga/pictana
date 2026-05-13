/// MethodChannel Map → ドメインエンティティ変換ユーティリティ
///
/// Kotlin ネイティブ側から MethodChannel 経由で受け取る Map データを
/// ドメインエンティティに変換する拡張メソッドを提供する。
library;

import 'package:optrig/domain/entities/entry_id.dart';
import 'package:optrig/domain/entities/folder_entry.dart';
import 'package:optrig/domain/entities/image_entry.dart';
import 'package:optrig/domain/entities/storage_root.dart';

/// MethodChannel Map → FolderEntry 変換
extension FolderEntryFromMap on FolderEntry {
  /// チャネルから受け取った Map を FolderEntry に変換する。
  ///
  /// Map フォーマット:
  /// ```json
  /// {
  ///   "documentId": "primary:DCIM/Camera",
  ///   "name": "Camera",
  ///   "uri": "content://...",
  ///   "treeUri": "content://...",
  ///   "parentDocumentId": "primary:DCIM"
  /// }
  /// ```
  static FolderEntry fromChannelMap(
    Map<String, dynamic> map, {
    EntryId? parentId,
  }) {
    final documentId = map['documentId'] as String;
    return FolderEntry(
      id: EntryId.android(documentId),
      name: map['name'] as String,
      uri: map['uri'] as String,
      parentId: parentId,
    );
  }
}

/// MethodChannel Map → StorageRoot 変換
extension StorageRootFromMap on StorageRoot {
  /// チャネルから受け取った Map を StorageRoot に変換する。
  ///
  /// Map フォーマット:
  /// ```json
  /// {
  ///   "id": "content://...",
  ///   "name": "内部ストレージ",
  ///   "type": "internal" | "usb",
  ///   "uri": "content://...",
  ///   "isConnected": true
  /// }
  /// ```
  static StorageRoot fromChannelMap(Map<String, dynamic> map) {
    return StorageRoot(
      id: EntryId.android(map['id'] as String),
      name: map['name'] as String,
      type: _parseStorageType(map['type'] as String),
      uri: map['uri'] as String,
      isConnected: map['isConnected'] as bool? ?? true,
    );
  }
}

/// MethodChannel Map → ImageEntry 変換
extension ImageEntryFromMap on ImageEntry {
  /// チャネルから受け取った Map を ImageEntry に変換する。
  ///
  /// Map フォーマット:
  /// ```json
  /// {
  ///   "documentId": "primary:DCIM/Camera/IMG_20240101.jpg",
  ///   "name": "IMG_20240101.jpg",
  ///   "extension": "jpg",
  ///   "uri": "content://...",
  ///   "mimeType": "image/jpeg",
  ///   "size": 4523000,
  ///   "lastModified": 1704067200000
  /// }
  /// ```
  static ImageEntry fromChannelMap(Map<String, dynamic> map) {
    final name = map['name'] as String;
    final ext = map['extension'] as String? ?? _extractExtension(name);
    return ImageEntry(
      id: EntryId.android(map['documentId'] as String),
      name: name,
      extension: ext,
      uri: map['uri'] as String,
      mimeType: ImageMimeType.fromExtension(ext),
      size: map['size'] as int? ?? 0,
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(
        map['lastModified'] as int? ?? 0,
      ),
    );
  }
}

/// ストレージ種別文字列を StorageType enum に変換する。
StorageType _parseStorageType(String type) => switch (type) {
  'internal' => StorageType.internal,
  'usb' => StorageType.usb,
  'sdCard' => StorageType.sdCard,
  _ => StorageType.internal,
};

/// ファイル名から拡張子を抽出する（小文字、ドットなし）。
///
/// 例: "IMG_20240101.JPG" → "jpg"
/// 例: "photo.tar.gz" → "gz"
/// 例: "noext" → ""
String _extractExtension(String fileName) {
  final dotIndex = fileName.lastIndexOf('.');
  if (dotIndex < 0 || dotIndex == fileName.length - 1) {
    return '';
  }
  return fileName.substring(dotIndex + 1).toLowerCase();
}
