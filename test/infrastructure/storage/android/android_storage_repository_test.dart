/// AndroidStorageRepository ユニットテスト
///
/// SafPlatformChannel と AppDatabase のモックを使用して
/// AndroidStorageRepository の各メソッドを検証する。
///
/// Requirements: 1.1, 1.2, 1.3, 2.1, 2.2, 2.3, 2.4, 2.5, 3.1
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:pictana/core/errors/app_exceptions.dart';
import 'package:pictana/domain/entities/entry_id.dart';
import 'package:pictana/domain/entities/folder_entry.dart';
import 'package:pictana/domain/entities/storage_root.dart';
import 'package:pictana/infrastructure/database/app_database.dart';
import 'package:pictana/infrastructure/storage/android/android_storage_repository.dart';
import 'package:pictana/infrastructure/storage/android/saf_platform_channel.dart';

// =============================================================================
// モッククラス
// =============================================================================

/// SafPlatformChannel のモック
class MockSafPlatformChannel extends SafPlatformChannel {
  // --- selectFolder ---
  Map<String, dynamic>? selectFolderResult;
  Object? selectFolderError;
  int selectFolderCallCount = 0;

  @override
  Future<Map<String, dynamic>?> selectFolder() async {
    selectFolderCallCount++;
    if (selectFolderError != null) throw selectFolderError!;
    return selectFolderResult;
  }

  // --- getStorageRoots ---
  List<Map<String, dynamic>> getStorageRootsResult = [];
  Object? getStorageRootsError;
  int getStorageRootsCallCount = 0;

  @override
  Future<List<Map<String, dynamic>>> getStorageRoots() async {
    getStorageRootsCallCount++;
    if (getStorageRootsError != null) throw getStorageRootsError!;
    return getStorageRootsResult;
  }

  // --- getChildFolders ---
  List<Map<String, dynamic>> getChildFoldersResult = [];
  Object? getChildFoldersError;
  int getChildFoldersCallCount = 0;
  String? lastGetChildFoldersTreeUri;
  String? lastGetChildFoldersDocumentId;

  @override
  Future<List<Map<String, dynamic>>> getChildFolders(
    String treeUri,
    String? documentId,
  ) async {
    getChildFoldersCallCount++;
    lastGetChildFoldersTreeUri = treeUri;
    lastGetChildFoldersDocumentId = documentId;
    if (getChildFoldersError != null) throw getChildFoldersError!;
    return getChildFoldersResult;
  }

  // --- persistUriPermission ---
  Object? persistUriPermissionError;
  int persistUriPermissionCallCount = 0;
  String? lastPersistedUri;

  @override
  Future<void> persistUriPermission(String uri) async {
    persistUriPermissionCallCount++;
    lastPersistedUri = uri;
    if (persistUriPermissionError != null) throw persistUriPermissionError!;
  }

  // --- getDefaultImageFolder ---
  Map<String, dynamic>? getDefaultImageFolderResult;
  Object? getDefaultImageFolderError;
  int getDefaultImageFolderCallCount = 0;

  @override
  Future<Map<String, dynamic>?> getDefaultImageFolder() async {
    getDefaultImageFolderCallCount++;
    if (getDefaultImageFolderError != null) throw getDefaultImageFolderError!;
    return getDefaultImageFolderResult;
  }

  // --- usbEvents ---
  Stream<Map<String, dynamic>> usbEventsStream = const Stream.empty();

  @override
  Stream<Map<String, dynamic>> get usbEvents => usbEventsStream;
}

/// AppDatabase のモック
///
/// テストに必要な getRecentFolders / upsertRecentFolder のみ実装する。
class MockAppDatabase extends Fake implements AppDatabase {
  // --- getRecentFolders ---
  List<RecentFolder> getRecentFoldersResult = [];
  Object? getRecentFoldersError;
  int getRecentFoldersCallCount = 0;

  @override
  Future<List<RecentFolder>> getRecentFolders({int limit = 20}) async {
    getRecentFoldersCallCount++;
    if (getRecentFoldersError != null) throw getRecentFoldersError!;
    return getRecentFoldersResult;
  }

  // --- upsertRecentFolder ---
  int upsertRecentFolderCallCount = 0;
  String? lastUpsertUri;
  String? lastUpsertName;
  String? lastUpsertPlatformType;
  Object? upsertRecentFolderError;

  @override
  Future<void> upsertRecentFolder({
    required String uri,
    required String name,
    required String platformType,
  }) async {
    upsertRecentFolderCallCount++;
    lastUpsertUri = uri;
    lastUpsertName = name;
    lastUpsertPlatformType = platformType;
    if (upsertRecentFolderError != null) throw upsertRecentFolderError!;
  }
}

/// テスト用 RecentFolder データを生成するヘルパー
RecentFolder createRecentFolder({
  required int id,
  required String uri,
  required String name,
  String platformType = 'android',
  DateTime? lastOpenedAt,
}) {
  return RecentFolder(
    id: id,
    uri: uri,
    name: name,
    platformType: platformType,
    lastOpenedAt: lastOpenedAt ?? DateTime.now(),
  );
}

// =============================================================================
// テスト本体
// =============================================================================

void main() {
  late AndroidStorageRepository repository;
  late MockSafPlatformChannel mockChannel;
  late MockAppDatabase mockDb;

  setUp(() {
    mockChannel = MockSafPlatformChannel();
    mockDb = MockAppDatabase();
    repository = AndroidStorageRepository(
      database: mockDb,
      channel: mockChannel,
    );
  });

  group('getStorageRoots', () {
    test('成功時 — StorageRoot リストを返す', () async {
      mockChannel.getStorageRootsResult = [
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

      final result = await repository.getStorageRoots();

      expect(result, hasLength(2));
      expect(result[0].name, '内部ストレージ');
      expect(result[0].type, StorageType.internal);
      expect(result[0].isConnected, true);
      expect(result[0].id.platformType, PlatformType.android);
      expect(result[1].name, 'USB メモリ');
      expect(result[1].type, StorageType.usb);
      expect(mockChannel.getStorageRootsCallCount, 1);
    });

    test('エラー時 — 例外がそのまま伝播する', () async {
      mockChannel.getStorageRootsError = const StorageDisconnectedException(
        message: 'ストレージ列挙失敗',
      );

      expect(
        () => repository.getStorageRoots(),
        throwsA(isA<StorageDisconnectedException>()),
      );
    });
  });

  group('selectFolder', () {
    test(
      '成功時 — FolderEntry を返す（persistUriPermission はネイティブ側で実行済み、recordRecentFolder は UseCase 側で呼ばれる）',
      () async {
        mockChannel.selectFolderResult = {
          'documentId': 'primary:DCIM/Camera',
          'name': 'Camera',
          'uri': 'content://example/Camera',
          'treeUri': 'content://example/tree',
          'parentDocumentId': 'primary:DCIM',
        };

        final result = await repository.selectFolder();

        expect(result, isNotNull);
        expect(result!.name, 'Camera');
        // treeUri が存在する場合は treeUri が uri として使用される
        expect(result.uri, 'content://example/tree');
        expect(result.id.rawValue, 'primary:DCIM/Camera');
        expect(result.id.platformType, PlatformType.android);
        expect(result.parentId, isNull);

        // persistUriPermission はネイティブ側で既に実行済みのため Dart 側では呼ばれない
        expect(mockChannel.persistUriPermissionCallCount, 0);

        // recordRecentFolder は UseCase 側で呼ばれるため Repository では呼ばれない
        expect(mockDb.upsertRecentFolderCallCount, 0);
      },
    );

    test('キャンセル時 — null を返し、副作用なし', () async {
      mockChannel.selectFolderResult = null;

      final result = await repository.selectFolder();

      expect(result, isNull);
      // persistUriPermission は呼ばれない
      expect(mockChannel.persistUriPermissionCallCount, 0);
      // recordRecentFolder は呼ばれない
      expect(mockDb.upsertRecentFolderCallCount, 0);
    });

    test('チャネルエラー時 — 例外が伝播する', () async {
      mockChannel.selectFolderError = const PermissionDeniedException();

      expect(
        () => repository.selectFolder(),
        throwsA(isA<PermissionDeniedException>()),
      );
      // 副作用なし
      expect(mockChannel.persistUriPermissionCallCount, 0);
      expect(mockDb.upsertRecentFolderCallCount, 0);
    });
  });

  group('persistUriPermission', () {
    test('成功時 — チャネルの persistUriPermission を呼ぶ', () async {
      await repository.persistUriPermission('content://example/folder');

      expect(mockChannel.persistUriPermissionCallCount, 1);
      expect(mockChannel.lastPersistedUri, 'content://example/folder');
    });

    test('失敗時 — 例外が伝播する', () async {
      mockChannel.persistUriPermissionError = const PermissionDeniedException(
        message: 'パーミッション永続化失敗',
      );

      expect(
        () => repository.persistUriPermission('content://example/folder'),
        throwsA(isA<PermissionDeniedException>()),
      );
    });
  });

  group('getFolders', () {
    test('成功時 — FolderEntry リストを返す（parentId にルートの id が設定される）', () async {
      final root = StorageRoot(
        id: EntryId.android('content://storage/internal'),
        name: '内部ストレージ',
        type: StorageType.internal,
        uri: 'content://storage/internal',
      );

      mockChannel.getChildFoldersResult = [
        {
          'documentId': 'primary:DCIM',
          'name': 'DCIM',
          'uri': 'content://example/DCIM',
        },
        {
          'documentId': 'primary:Pictures',
          'name': 'Pictures',
          'uri': 'content://example/Pictures',
        },
      ];

      final result = await repository.getFolders(root);

      expect(result, hasLength(2));
      expect(result[0].name, 'DCIM');
      expect(result[0].parentId, root.id);
      expect(result[1].name, 'Pictures');
      expect(result[1].parentId, root.id);
      // treeUri = root.uri, documentId = null
      expect(
        mockChannel.lastGetChildFoldersTreeUri,
        'content://storage/internal',
      );
      expect(mockChannel.lastGetChildFoldersDocumentId, isNull);
    });
  });

  group('getSubFolders', () {
    test('成功時 — FolderEntry リストを返す（parentId に親フォルダの id が設定される）', () async {
      final parentFolder = FolderEntry(
        id: EntryId.android('primary:DCIM'),
        name: 'DCIM',
        uri: 'content://example/tree/DCIM',
        parentId: null,
      );

      mockChannel.getChildFoldersResult = [
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

      final result = await repository.getSubFolders(parentFolder);

      expect(result, hasLength(2));
      expect(result[0].name, 'Camera');
      expect(result[0].parentId, parentFolder.id);
      expect(result[1].name, 'Screenshots');
      expect(result[1].parentId, parentFolder.id);
      // treeUri = folder.uri, documentId = folder.id.rawValue
      expect(
        mockChannel.lastGetChildFoldersTreeUri,
        'content://example/tree/DCIM',
      );
      expect(mockChannel.lastGetChildFoldersDocumentId, 'primary:DCIM');
    });
  });

  group('getDefaultImageFolder', () {
    test('成功時 — FolderEntry を返す', () async {
      mockChannel.getDefaultImageFolderResult = {
        'documentId': 'primary:DCIM',
        'name': 'DCIM',
        'uri': 'content://example/DCIM',
      };

      final result = await repository.getDefaultImageFolder();

      expect(result, isNotNull);
      expect(result!.name, 'DCIM');
      expect(result.uri, 'content://example/DCIM');
      expect(result.id.rawValue, 'primary:DCIM');
    });

    test('null 時 — null を返す', () async {
      mockChannel.getDefaultImageFolderResult = null;

      final result = await repository.getDefaultImageFolder();

      expect(result, isNull);
    });

    test('エラー時 — null を返す（例外を投げない）', () async {
      mockChannel.getDefaultImageFolderError =
          const StorageDisconnectedException(message: 'デフォルトフォルダ検出失敗');

      final result = await repository.getDefaultImageFolder();

      // エラーが発生しても null を返す（グレースフルデグラデーション）
      expect(result, isNull);
    });
  });

  group('getRecentFolders', () {
    test('成功時 — android プラットフォームのフォルダのみ返す', () async {
      mockDb.getRecentFoldersResult = [
        createRecentFolder(
          id: 1,
          uri: 'content://example/Camera',
          name: 'Camera',
          platformType: 'android',
        ),
        createRecentFolder(
          id: 2,
          uri: 'C:\\Users\\Pictures',
          name: 'Pictures',
          platformType: 'windows',
        ),
        createRecentFolder(
          id: 3,
          uri: 'content://example/DCIM',
          name: 'DCIM',
          platformType: 'android',
        ),
      ];

      final result = await repository.getRecentFolders();

      // windows のエントリはフィルタされる
      expect(result, hasLength(2));
      expect(result[0].name, 'Camera');
      expect(result[0].uri, 'content://example/Camera');
      expect(result[0].id.platformType, PlatformType.android);
      expect(result[1].name, 'DCIM');
    });

    test('DB エラー時 — 空リストを返す（例外を投げない）', () async {
      mockDb.getRecentFoldersError = Exception('DB エラー');

      final result = await repository.getRecentFolders();

      expect(result, isEmpty);
    });
  });

  group('recordRecentFolder', () {
    test('成功時 — DB の upsertRecentFolder を呼ぶ', () async {
      final folder = FolderEntry(
        id: EntryId.android('primary:DCIM/Camera'),
        name: 'Camera',
        uri: 'content://example/Camera',
      );

      await repository.recordRecentFolder(folder);

      expect(mockDb.upsertRecentFolderCallCount, 1);
      expect(mockDb.lastUpsertUri, 'content://example/Camera');
      expect(mockDb.lastUpsertName, 'Camera');
      expect(mockDb.lastUpsertPlatformType, 'android');
    });

    test('DB エラー時 — 例外を投げない（ログのみ）', () async {
      mockDb.upsertRecentFolderError = Exception('DB 書き込みエラー');

      final folder = FolderEntry(
        id: EntryId.android('primary:DCIM/Camera'),
        name: 'Camera',
        uri: 'content://example/Camera',
      );

      // 例外が伝播しないことを確認
      await expectLater(repository.recordRecentFolder(folder), completes);
    });
  });

  group('watchStorageRoots', () {
    test('USB イベント受信時 — getStorageRoots を再取得して emit する', () async {
      mockChannel.usbEventsStream = Stream.fromIterable([
        {
          'event': 'connected',
          'volumeId': 'usb:001',
          'mountPath': '/storage/usb0',
        },
      ]);

      mockChannel.getStorageRootsResult = [
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

      final result = await repository.watchStorageRoots().first;

      expect(result, hasLength(2));
      expect(result[0].name, '内部ストレージ');
      expect(result[1].name, 'USB メモリ');
      expect(result[1].isConnected, true);
    });

    test('getStorageRoots 失敗時 — ストリームを終了させずスキップする', () async {
      // 2 つのイベントを送信し、1 つ目で getStorageRoots が失敗するケース
      mockChannel.usbEventsStream = Stream.fromIterable([
        {
          'event': 'disconnected',
          'volumeId': 'usb:001',
          'mountPath': '/storage/usb0',
        },
        {
          'event': 'connected',
          'volumeId': 'usb:001',
          'mountPath': '/storage/usb0',
        },
      ]);

      // getStorageRoots をオーバーライドして 1 回目は失敗、2 回目は成功にする
      final customChannel = _FailOnceChannel();
      final customRepo = AndroidStorageRepository(
        database: mockDb,
        channel: customChannel,
      );

      final results = await customRepo.watchStorageRoots().toList();

      // 1 回目は失敗してスキップ、2 回目のみ emit される
      expect(results, hasLength(1));
      expect(results[0], hasLength(1));
      expect(results[0][0].name, '内部ストレージ');
    });
  });
}

/// getStorageRoots が 1 回目に失敗し、2 回目に成功するモックチャネル
class _FailOnceChannel extends SafPlatformChannel {
  int _callCount = 0;

  @override
  Future<List<Map<String, dynamic>>> getStorageRoots() async {
    _callCount++;
    if (_callCount == 1) {
      throw const StorageDisconnectedException(message: '一時的なエラー');
    }
    return [
      {
        'id': 'content://storage/internal',
        'name': '内部ストレージ',
        'type': 'internal',
        'uri': 'content://storage/internal',
        'isConnected': true,
      },
    ];
  }

  @override
  Stream<Map<String, dynamic>> get usbEvents => Stream.fromIterable([
    {
      'event': 'disconnected',
      'volumeId': 'usb:001',
      'mountPath': '/storage/usb0',
    },
    {'event': 'connected', 'volumeId': 'usb:001', 'mountPath': '/storage/usb0'},
  ]);
}
