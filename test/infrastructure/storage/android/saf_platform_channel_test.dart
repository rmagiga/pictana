import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pictana/core/errors/app_exceptions.dart';
import 'package:pictana/infrastructure/storage/android/saf_platform_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SafPlatformChannel channel;

  const methodChannelName = 'com.pgcodetutor.pictana/saf';

  setUp(() {
    channel = SafPlatformChannel();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel(methodChannelName), null);
  });

  /// MethodChannel のモックハンドラを設定するヘルパー
  void setMockHandler(Future<Object?>? Function(MethodCall call) handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel(methodChannelName),
          handler,
        );
  }

  group('selectFolder', () {
    test('成功時 — FolderEntry Map を返す', () async {
      final expectedMap = <String, dynamic>{
        'documentId': 'primary:DCIM/Camera',
        'name': 'Camera',
        'uri': 'content://example/Camera',
        'treeUri': 'content://example/tree',
        'parentDocumentId': 'primary:DCIM',
      };

      setMockHandler((call) async {
        expect(call.method, 'selectFolder');
        return expectedMap;
      });

      final result = await channel.selectFolder();

      expect(result, isNotNull);
      expect(result!['documentId'], 'primary:DCIM/Camera');
      expect(result['name'], 'Camera');
      expect(result['uri'], 'content://example/Camera');
    });

    test('キャンセル時 — null を返す', () async {
      setMockHandler((call) async {
        expect(call.method, 'selectFolder');
        return null;
      });

      final result = await channel.selectFolder();

      expect(result, isNull);
    });

    test('エラー時 — PermissionDeniedException をスローする', () async {
      setMockHandler((call) async {
        throw PlatformException(
          code: 'PERMISSION_DENIED',
          message: 'アクセスが拒否されました',
        );
      });

      expect(
        () => channel.selectFolder(),
        throwsA(isA<PermissionDeniedException>()),
      );
    });
  });

  group('getStorageRoots', () {
    test('成功時 — StorageRoot Map のリストを返す', () async {
      final expectedList = <Map<String, dynamic>>[
        {
          'id': 'content://storage/internal',
          'name': '内部ストレージ',
          'type': 'internal',
          'uri': 'content://storage/internal',
          'isConnected': true,
        },
        {
          'id': 'content://storage/usb0',
          'name': 'USB メモリ',
          'type': 'usb',
          'uri': 'content://storage/usb0',
          'isConnected': true,
        },
      ];

      setMockHandler((call) async {
        expect(call.method, 'getStorageRoots');
        return expectedList;
      });

      final result = await channel.getStorageRoots();

      expect(result, hasLength(2));
      expect(result[0]['name'], '内部ストレージ');
      expect(result[1]['type'], 'usb');
    });
  });

  group('getChildFolders', () {
    test('成功時 — 子フォルダ Map のリストを返す', () async {
      final expectedList = <Map<String, dynamic>>[
        {
          'documentId': 'primary:DCIM/Camera',
          'name': 'Camera',
          'uri': 'content://example/Camera',
        },
        {
          'documentId': 'primary:DCIM/Screenshots',
          'name': 'Screenshots',
          'uri': 'content://example/Screenshots',
        },
      ];

      setMockHandler((call) async {
        expect(call.method, 'getChildFolders');
        expect(call.arguments['treeUri'], 'content://example/tree');
        expect(call.arguments['documentId'], 'primary:DCIM');
        return expectedList;
      });

      final result = await channel.getChildFolders(
        'content://example/tree',
        'primary:DCIM',
      );

      expect(result, hasLength(2));
      expect(result[0]['name'], 'Camera');
      expect(result[1]['name'], 'Screenshots');
    });
  });

  group('getImages', () {
    test('成功時 — ImageEntry Map のリストを返す', () async {
      final expectedList = <Map<String, dynamic>>[
        {
          'documentId': 'primary:DCIM/Camera/IMG_001.jpg',
          'name': 'IMG_001.jpg',
          'uri': 'content://example/IMG_001.jpg',
          'mimeType': 'image/jpeg',
          'size': 4523000,
          'lastModified': 1704067200000,
        },
        {
          'documentId': 'primary:DCIM/Camera/IMG_002.png',
          'name': 'IMG_002.png',
          'uri': 'content://example/IMG_002.png',
          'mimeType': 'image/png',
          'size': 2048000,
          'lastModified': 1704153600000,
        },
      ];

      setMockHandler((call) async {
        expect(call.method, 'getImages');
        expect(call.arguments['treeUri'], 'content://example/tree');
        expect(call.arguments['documentId'], 'primary:DCIM/Camera');
        expect(call.arguments['offset'], 0);
        expect(call.arguments['limit'], 50);
        return expectedList;
      });

      final result = await channel.getImages(
        'content://example/tree',
        'primary:DCIM/Camera',
        0,
        50,
      );

      expect(result, hasLength(2));
      expect(result[0]['name'], 'IMG_001.jpg');
      expect(result[0]['size'], 4523000);
      expect(result[1]['mimeType'], 'image/png');
    });
  });

  group('getImageBytes', () {
    test('成功時 — Uint8List を返す', () async {
      final expectedBytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]);

      setMockHandler((call) async {
        expect(call.method, 'getImageBytes');
        expect(call.arguments['contentUri'], 'content://example/image.jpg');
        return expectedBytes;
      });

      final result = await channel.getImageBytes('content://example/image.jpg');

      expect(result, equals(expectedBytes));
    });
  });

  group('getThumbnail', () {
    test('成功時 — Uint8List を返す', () async {
      final expectedBytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]);

      setMockHandler((call) async {
        expect(call.method, 'getThumbnail');
        expect(call.arguments['contentUri'], 'content://example/image.jpg');
        expect(call.arguments['width'], 256);
        expect(call.arguments['height'], 256);
        return expectedBytes;
      });

      final result = await channel.getThumbnail(
        'content://example/image.jpg',
        256,
        256,
      );

      expect(result, isNotNull);
      expect(result, equals(expectedBytes));
    });

    test('生成失敗時 — null を返す', () async {
      setMockHandler((call) async {
        expect(call.method, 'getThumbnail');
        return null;
      });

      final result = await channel.getThumbnail(
        'content://example/image.jpg',
        256,
        256,
      );

      expect(result, isNull);
    });
  });

  group('エラーマッピング', () {
    test('PERMISSION_DENIED → PermissionDeniedException', () async {
      setMockHandler((call) async {
        throw PlatformException(
          code: 'PERMISSION_DENIED',
          message: 'アクセスが拒否されました',
        );
      });

      expect(
        () => channel.getStorageRoots(),
        throwsA(
          isA<PermissionDeniedException>().having(
            (e) => e.cause,
            'cause',
            isA<PlatformException>(),
          ),
        ),
      );
    });

    test('STORAGE_DISCONNECTED → StorageDisconnectedException', () async {
      setMockHandler((call) async {
        throw PlatformException(
          code: 'STORAGE_DISCONNECTED',
          message: 'ストレージが切断されました',
        );
      });

      expect(
        () => channel.getStorageRoots(),
        throwsA(
          isA<StorageDisconnectedException>().having(
            (e) => e.cause,
            'cause',
            isA<PlatformException>(),
          ),
        ),
      );
    });

    test('OUT_OF_MEMORY → OutOfMemoryException', () async {
      setMockHandler((call) async {
        throw PlatformException(code: 'OUT_OF_MEMORY', message: 'メモリが不足しています');
      });

      expect(
        () => channel.getImageBytes('content://example/large.jpg'),
        throwsA(
          isA<OutOfMemoryException>().having(
            (e) => e.cause,
            'cause',
            isA<PlatformException>(),
          ),
        ),
      );
    });

    test('MissingPluginException → UnsupportedError（メソッド名を含む）', () async {
      setMockHandler((call) async {
        throw MissingPluginException(
          'No implementation found for method selectFolder',
        );
      });

      expect(
        () => channel.selectFolder(),
        throwsA(
          isA<UnsupportedError>().having(
            (e) => e.message,
            'message',
            contains('selectFolder'),
          ),
        ),
      );
    });
  });
}
