import 'package:flutter_test/flutter_test.dart';
import 'package:optrig/domain/entities/entry_id.dart';
import 'package:optrig/domain/entities/image_entry.dart';
import 'package:optrig/domain/entities/storage_root.dart';
import 'package:optrig/infrastructure/storage/android/saf_data_mappers.dart';

void main() {
  group('FolderEntryFromMap', () {
    test('基本的な Map から FolderEntry を正しく変換する', () {
      final map = <String, dynamic>{
        'documentId': 'primary:DCIM/Camera',
        'name': 'Camera',
        'uri':
            'content://com.android.externalstorage.documents/tree/primary%3ADCIM/document/primary%3ADCIM%2FCamera',
        'treeUri':
            'content://com.android.externalstorage.documents/tree/primary%3ADCIM',
        'parentDocumentId': 'primary:DCIM',
      };

      final entry = FolderEntryFromMap.fromChannelMap(map);

      expect(entry.id.rawValue, 'primary:DCIM/Camera');
      expect(entry.id.platformType, PlatformType.android);
      expect(entry.name, 'Camera');
      // treeUri が存在する場合は treeUri が uri として使用される
      expect(
        entry.uri,
        'content://com.android.externalstorage.documents/tree/primary%3ADCIM',
      );
      expect(entry.parentId, isNull);
    });

    test('parentId を指定した場合に正しく設定される', () {
      final map = <String, dynamic>{
        'documentId': 'primary:DCIM/Camera/2024',
        'name': '2024',
        'uri': 'content://example/2024',
        'treeUri': 'content://example/tree',
        'parentDocumentId': 'primary:DCIM/Camera',
      };
      final parentId = EntryId.android('primary:DCIM/Camera');

      final entry = FolderEntryFromMap.fromChannelMap(map, parentId: parentId);

      expect(entry.parentId, isNotNull);
      expect(entry.parentId!.rawValue, 'primary:DCIM/Camera');
      expect(entry.parentId!.platformType, PlatformType.android);
    });
  });

  group('StorageRootFromMap', () {
    test('内部ストレージの Map を正しく変換する', () {
      final map = <String, dynamic>{
        'id': 'content://com.android.externalstorage.documents/tree/primary%3A',
        'name': '内部ストレージ',
        'type': 'internal',
        'uri':
            'content://com.android.externalstorage.documents/tree/primary%3A',
        'isConnected': true,
      };

      final root = StorageRootFromMap.fromChannelMap(map);

      expect(root.id.platformType, PlatformType.android);
      expect(
        root.id.rawValue,
        'content://com.android.externalstorage.documents/tree/primary%3A',
      );
      expect(root.name, '内部ストレージ');
      expect(root.type, StorageType.internal);
      expect(root.isConnected, true);
    });

    test('USB ストレージの Map を正しく変換する', () {
      final map = <String, dynamic>{
        'id': 'content://usb-storage/tree/usb0',
        'name': 'USB メモリ',
        'type': 'usb',
        'uri': 'content://usb-storage/tree/usb0',
        'isConnected': false,
      };

      final root = StorageRootFromMap.fromChannelMap(map);

      expect(root.type, StorageType.usb);
      expect(root.isConnected, false);
    });

    test('isConnected が省略された場合は true がデフォルト', () {
      final map = <String, dynamic>{
        'id': 'content://example',
        'name': 'テスト',
        'type': 'internal',
        'uri': 'content://example',
      };

      final root = StorageRootFromMap.fromChannelMap(map);

      expect(root.isConnected, true);
    });

    test('不明な type は internal にフォールバックする', () {
      final map = <String, dynamic>{
        'id': 'content://example',
        'name': 'テスト',
        'type': 'unknown_type',
        'uri': 'content://example',
        'isConnected': true,
      };

      final root = StorageRootFromMap.fromChannelMap(map);

      expect(root.type, StorageType.internal);
    });
  });

  group('ImageEntryFromMap', () {
    test('基本的な Map から ImageEntry を正しく変換する', () {
      final map = <String, dynamic>{
        'documentId': 'primary:DCIM/Camera/IMG_20240101.jpg',
        'name': 'IMG_20240101.jpg',
        'extension': 'jpg',
        'uri': 'content://example/IMG_20240101.jpg',
        'mimeType': 'image/jpeg',
        'size': 4523000,
        'lastModified': 1704067200000,
      };

      final entry = ImageEntryFromMap.fromChannelMap(map);

      expect(entry.id.rawValue, 'primary:DCIM/Camera/IMG_20240101.jpg');
      expect(entry.id.platformType, PlatformType.android);
      expect(entry.name, 'IMG_20240101.jpg');
      expect(entry.extension, 'jpg');
      expect(entry.uri, 'content://example/IMG_20240101.jpg');
      expect(entry.mimeType, ImageMimeType.jpeg);
      expect(entry.size, 4523000);
      expect(
        entry.modifiedAt,
        DateTime.fromMillisecondsSinceEpoch(1704067200000),
      );
    });

    test('extension フィールドが無い場合はファイル名から抽出する', () {
      final map = <String, dynamic>{
        'documentId': 'primary:photo.PNG',
        'name': 'photo.PNG',
        'uri': 'content://example/photo.PNG',
        'mimeType': 'image/png',
        'size': 1000,
        'lastModified': 1704067200000,
      };

      final entry = ImageEntryFromMap.fromChannelMap(map);

      expect(entry.extension, 'png');
      expect(entry.mimeType, ImageMimeType.png);
    });

    test('size が省略された場合は 0 がデフォルト', () {
      final map = <String, dynamic>{
        'documentId': 'primary:test.webp',
        'name': 'test.webp',
        'extension': 'webp',
        'uri': 'content://example/test.webp',
        'mimeType': 'image/webp',
        'lastModified': 1704067200000,
      };

      final entry = ImageEntryFromMap.fromChannelMap(map);

      expect(entry.size, 0);
    });

    test('lastModified が省略された場合は epoch がデフォルト', () {
      final map = <String, dynamic>{
        'documentId': 'primary:test.gif',
        'name': 'test.gif',
        'extension': 'gif',
        'uri': 'content://example/test.gif',
        'mimeType': 'image/gif',
        'size': 500,
      };

      final entry = ImageEntryFromMap.fromChannelMap(map);

      expect(entry.modifiedAt, DateTime.fromMillisecondsSinceEpoch(0));
    });

    test('拡張子なしのファイル名の場合は空文字列', () {
      final map = <String, dynamic>{
        'documentId': 'primary:noext',
        'name': 'noext',
        'uri': 'content://example/noext',
        'mimeType': 'application/octet-stream',
        'size': 100,
        'lastModified': 1704067200000,
      };

      final entry = ImageEntryFromMap.fromChannelMap(map);

      expect(entry.extension, '');
      expect(entry.mimeType, ImageMimeType.unknown);
    });
  });
}
