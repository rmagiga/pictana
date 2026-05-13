/// AndroidImageRepository ユニットテスト
///
/// SafPlatformChannel のモックを使用して、AndroidImageRepository の
/// 各メソッドの動作を検証する。
///
/// テストケース:
/// - 画像列挙 Stream バッチ（50 件ずつ emit）
/// - 空フォルダ（空 Stream）
/// - アクセス不可フォルダ（StorageDisconnectedException）
/// - 変換エラーのスキップ
/// - 画像バイト取得（直接 / ファイル経由）
/// - 100MB 超エラー（OutOfMemoryException）
/// - countImages
/// - getImageMetadata
/// - getImagePage
///
/// **Validates: Requirements 5.1, 5.3, 5.6, 5.7, 6.1, 6.3, 6.6**
@Tags(['android-saf', 'unit-test'])
library;

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:optrig/core/errors/app_exceptions.dart';
import 'package:optrig/domain/entities/entry_id.dart';
import 'package:optrig/domain/entities/folder_entry.dart';
import 'package:optrig/domain/entities/image_entry.dart';
import 'package:optrig/infrastructure/storage/android/android_image_repository.dart';
import 'package:optrig/infrastructure/storage/android/saf_platform_channel.dart';

// ---------------------------------------------------------------------------
// テスト用モック
// ---------------------------------------------------------------------------

/// SafPlatformChannel のモック実装
///
/// テストケースごとに getImages / getImageBytes / getImageBytesViaFile の
/// 振る舞いを差し替え可能にする。
class MockSafPlatformChannel extends SafPlatformChannel {
  /// getImages の戻り値を制御するコールバック
  Future<List<Map<String, dynamic>>> Function(
    String treeUri,
    String documentId,
    int offset,
    int limit,
  )?
  onGetImages;

  /// getImageBytes の戻り値を制御するコールバック
  Future<Uint8List> Function(String contentUri)? onGetImageBytes;

  /// getImageBytesViaFile の戻り値を制御するコールバック
  Future<String> Function(String contentUri)? onGetImageBytesViaFile;

  @override
  Future<List<Map<String, dynamic>>> getImages(
    String treeUri,
    String documentId,
    int offset,
    int limit,
  ) async {
    if (onGetImages != null) {
      return onGetImages!(treeUri, documentId, offset, limit);
    }
    return [];
  }

  @override
  Future<Uint8List> getImageBytes(String contentUri) async {
    if (onGetImageBytes != null) {
      return onGetImageBytes!(contentUri);
    }
    return Uint8List(0);
  }

  @override
  Future<String> getImageBytesViaFile(String contentUri) async {
    if (onGetImageBytesViaFile != null) {
      return onGetImageBytesViaFile!(contentUri);
    }
    return '';
  }
}

// ---------------------------------------------------------------------------
// テストヘルパー
// ---------------------------------------------------------------------------

/// テスト用の FolderEntry を生成する
FolderEntry _createTestFolder({
  String documentId = 'primary:DCIM/Camera',
  String name = 'Camera',
  String uri =
      'content://com.android.externalstorage.documents/tree/primary%3ADCIM/document/primary%3ADCIM%2FCamera',
}) {
  return FolderEntry(id: EntryId.android(documentId), name: name, uri: uri);
}

/// テスト用の画像 Map を生成する
Map<String, dynamic> _createImageMap({required int index, int size = 1000000}) {
  return {
    'documentId': 'primary:DCIM/Camera/IMG_$index.jpg',
    'name': 'IMG_$index.jpg',
    'extension': 'jpg',
    'uri': 'content://example/IMG_$index.jpg',
    'mimeType': 'image/jpeg',
    'size': size,
    'lastModified': 1704067200000 + index * 1000,
  };
}

/// 指定件数の画像 Map リストを生成する
List<Map<String, dynamic>> _createImageMaps(int count, {int startIndex = 0}) {
  return List.generate(count, (i) => _createImageMap(index: startIndex + i));
}

// ---------------------------------------------------------------------------
// テスト本体
// ---------------------------------------------------------------------------

void main() {
  late MockSafPlatformChannel mockChannel;
  late AndroidImageRepository repository;
  late FolderEntry testFolder;

  setUp(() {
    mockChannel = MockSafPlatformChannel();
    repository = AndroidImageRepository(channel: mockChannel);
    testFolder = _createTestFolder();
  });

  // =========================================================================
  // getImages テスト
  // =========================================================================

  group('getImages', () {
    test('バッチサイズ 50 で Stream を emit する', () async {
      // 120 件の画像を用意（50 + 50 + 20 の 3 バッチ）
      mockChannel.onGetImages = (treeUri, documentId, offset, limit) async {
        final totalImages = 120;
        final start = offset;
        final end = (offset + limit).clamp(0, totalImages);
        if (start >= totalImages) return [];
        return _createImageMaps(end - start, startIndex: start);
      };

      final batches = await repository.getImages(folder: testFolder).toList();

      // 3 バッチが emit されること
      expect(batches.length, 3);
      // 最初の 2 バッチは 50 件
      expect(batches[0].length, 50);
      expect(batches[1].length, 50);
      // 最後のバッチは 20 件
      expect(batches[2].length, 20);
    });

    test('ちょうど 50 件の場合は 1 バッチ + 空バッチ確認で終了', () async {
      mockChannel.onGetImages = (treeUri, documentId, offset, limit) async {
        if (offset == 0) return _createImageMaps(50);
        return []; // 2 回目は空 → 終了
      };

      final batches = await repository.getImages(folder: testFolder).toList();

      expect(batches.length, 1);
      expect(batches[0].length, 50);
    });

    test('空フォルダの場合は何も emit しない', () async {
      mockChannel.onGetImages = (treeUri, documentId, offset, limit) async {
        return [];
      };

      final batches = await repository.getImages(folder: testFolder).toList();

      expect(batches, isEmpty);
    });

    test('アクセス不可フォルダの場合は StorageDisconnectedException をスロー', () async {
      mockChannel.onGetImages = (treeUri, documentId, offset, limit) async {
        throw const StorageDisconnectedException(message: 'ストレージが切断されました');
      };

      expect(
        () => repository.getImages(folder: testFolder).toList(),
        throwsA(isA<StorageDisconnectedException>()),
      );
    });

    test('変換エラーのエントリはスキップして継続する', () async {
      mockChannel.onGetImages = (treeUri, documentId, offset, limit) async {
        if (offset > 0) return [];
        return [
          // 正常なエントリ
          _createImageMap(index: 1),
          // 変換エラーを起こすエントリ（documentId が null 相当 → cast エラー）
          <String, dynamic>{
            'documentId': null, // これは String への cast で失敗する
            'name': 'broken.jpg',
            'uri': 'content://example/broken.jpg',
            'mimeType': 'image/jpeg',
            'size': 100,
            'lastModified': 1704067200000,
          },
          // 正常なエントリ
          _createImageMap(index: 3),
        ];
      };

      final batches = await repository.getImages(folder: testFolder).toList();

      // 変換エラーのエントリはスキップされ、正常な 2 件のみ emit
      expect(batches.length, 1);
      expect(batches[0].length, 2);
      expect(batches[0][0].name, 'IMG_1.jpg');
      expect(batches[0][1].name, 'IMG_3.jpg');
    });

    test('正しい treeUri と documentId がチャネルに渡される', () async {
      String? capturedTreeUri;
      String? capturedDocumentId;

      mockChannel.onGetImages = (treeUri, documentId, offset, limit) async {
        capturedTreeUri = treeUri;
        capturedDocumentId = documentId;
        return [];
      };

      await repository.getImages(folder: testFolder).toList();

      expect(capturedTreeUri, testFolder.uri);
      expect(capturedDocumentId, testFolder.id.rawValue);
    });

    test('バッチサイズ未満のレスポンスで Stream が終了する', () async {
      // 30 件のみ返す（< 50 なので最終バッチ）
      mockChannel.onGetImages = (treeUri, documentId, offset, limit) async {
        if (offset == 0) return _createImageMaps(30);
        // offset > 0 は呼ばれないはず
        fail('バッチサイズ未満の後に追加呼び出しがあった');
      };

      final batches = await repository.getImages(folder: testFolder).toList();

      expect(batches.length, 1);
      expect(batches[0].length, 30);
    });
  });

  // =========================================================================
  // getImageBytes テスト
  // =========================================================================

  group('getImageBytes', () {
    test('10MB 以下のファイルは直接バイト配列で取得する', () async {
      final expectedBytes = Uint8List.fromList(List.generate(100, (i) => i));
      String? capturedUri;

      mockChannel.onGetImageBytes = (contentUri) async {
        capturedUri = contentUri;
        return expectedBytes;
      };

      final entry = ImageEntry(
        id: EntryId.android('primary:test.jpg'),
        name: 'test.jpg',
        extension: 'jpg',
        uri: 'content://example/test.jpg',
        mimeType: ImageMimeType.jpeg,
        size: 5 * 1024 * 1024, // 5MB（<= 10MB）
        modifiedAt: DateTime(2024, 1, 1),
      );

      final result = await repository.getImageBytes(entry);

      expect(capturedUri, 'content://example/test.jpg');
      expect(result, expectedBytes.toList());
    });

    test('10MB 超のファイルは一時ファイル経由で取得する', () async {
      String? capturedUri;
      var directCalled = false;

      mockChannel.onGetImageBytes = (contentUri) async {
        directCalled = true;
        return Uint8List(0);
      };

      mockChannel.onGetImageBytesViaFile = (contentUri) async {
        capturedUri = contentUri;
        // テスト用に実際のファイルは作成せず、例外で検証
        // 実際の実装では File(tempPath).readAsBytes() を呼ぶが、
        // ここではファイル経由メソッドが呼ばれることを確認する
        throw const StorageDisconnectedException(message: 'テスト: 一時ファイル経由で呼ばれた');
      };

      final entry = ImageEntry(
        id: EntryId.android('primary:large.jpg'),
        name: 'large.jpg',
        extension: 'jpg',
        uri: 'content://example/large.jpg',
        mimeType: ImageMimeType.jpeg,
        size: 15 * 1024 * 1024, // 15MB（> 10MB）
        modifiedAt: DateTime(2024, 1, 1),
      );

      // ファイル経由メソッドが呼ばれ、StorageDisconnectedException がスローされる
      await expectLater(
        () => repository.getImageBytes(entry),
        throwsA(isA<AppException>()),
      );

      // 直接バイト取得は呼ばれないこと
      expect(directCalled, isFalse);
      // ファイル経由メソッドが正しい URI で呼ばれたこと
      expect(capturedUri, 'content://example/large.jpg');
    });

    test('100MB 超のファイルは OutOfMemoryException をスロー', () async {
      mockChannel.onGetImageBytesViaFile = (contentUri) async {
        throw const OutOfMemoryException();
      };

      final entry = ImageEntry(
        id: EntryId.android('primary:huge.jpg'),
        name: 'huge.jpg',
        extension: 'jpg',
        uri: 'content://example/huge.jpg',
        mimeType: ImageMimeType.jpeg,
        size: 150 * 1024 * 1024, // 150MB（> 100MB）
        modifiedAt: DateTime(2024, 1, 1),
      );

      expect(
        () => repository.getImageBytes(entry),
        throwsA(isA<OutOfMemoryException>()),
      );
    });

    test('getImageBytes でチャネルエラーが発生した場合は DecodeFailedException をスロー', () async {
      mockChannel.onGetImageBytes = (contentUri) async {
        throw Exception('I/O error');
      };

      final entry = ImageEntry(
        id: EntryId.android('primary:error.jpg'),
        name: 'error.jpg',
        extension: 'jpg',
        uri: 'content://example/error.jpg',
        mimeType: ImageMimeType.jpeg,
        size: 1 * 1024 * 1024, // 1MB
        modifiedAt: DateTime(2024, 1, 1),
      );

      expect(
        () => repository.getImageBytes(entry),
        throwsA(isA<DecodeFailedException>()),
      );
    });
  });

  // =========================================================================
  // countImages テスト
  // =========================================================================

  group('countImages', () {
    test('フォルダ内の全画像数をカウントする', () async {
      // 120 件の画像
      mockChannel.onGetImages = (treeUri, documentId, offset, limit) async {
        final totalImages = 120;
        final start = offset;
        final end = (offset + limit).clamp(0, totalImages);
        if (start >= totalImages) return [];
        return _createImageMaps(end - start, startIndex: start);
      };

      final count = await repository.countImages(folder: testFolder);

      expect(count, 120);
    });

    test('空フォルダの場合は 0 を返す', () async {
      mockChannel.onGetImages = (treeUri, documentId, offset, limit) async {
        return [];
      };

      final count = await repository.countImages(folder: testFolder);

      expect(count, 0);
    });
  });

  // =========================================================================
  // getImageMetadata テスト
  // =========================================================================

  group('getImageMetadata', () {
    test('既存エントリをそのまま返す', () async {
      final entry = ImageEntry(
        id: EntryId.android('primary:test.jpg'),
        name: 'test.jpg',
        extension: 'jpg',
        uri: 'content://example/test.jpg',
        mimeType: ImageMimeType.jpeg,
        size: 1000,
        modifiedAt: DateTime(2024, 1, 1),
      );

      final result = await repository.getImageMetadata(entry);

      expect(result, entry);
    });
  });

  // =========================================================================
  // getImagePage テスト
  // =========================================================================

  group('getImagePage', () {
    test('正しいページの結果を返す', () async {
      int? capturedOffset;
      int? capturedLimit;

      mockChannel.onGetImages = (treeUri, documentId, offset, limit) async {
        capturedOffset = offset;
        capturedLimit = limit;
        return _createImageMaps(20, startIndex: offset);
      };

      final result = await repository.getImagePage(
        folder: testFolder,
        page: 2,
        pageSize: 20,
      );

      // page=2, pageSize=20 → offset=40
      expect(capturedOffset, 40);
      expect(capturedLimit, 20);
      expect(result.length, 20);
    });

    test('最初のページ (page=0) は offset=0 で取得する', () async {
      int? capturedOffset;

      mockChannel.onGetImages = (treeUri, documentId, offset, limit) async {
        capturedOffset = offset;
        return _createImageMaps(10, startIndex: offset);
      };

      await repository.getImagePage(folder: testFolder, page: 0, pageSize: 10);

      expect(capturedOffset, 0);
    });

    test('変換エラーのエントリはスキップされる', () async {
      mockChannel.onGetImages = (treeUri, documentId, offset, limit) async {
        return [
          _createImageMap(index: 1),
          // 変換エラーを起こすエントリ
          <String, dynamic>{
            'documentId': null,
            'name': 'broken.jpg',
            'uri': 'content://example/broken.jpg',
            'mimeType': 'image/jpeg',
            'size': 100,
            'lastModified': 1704067200000,
          },
          _createImageMap(index: 3),
        ];
      };

      final result = await repository.getImagePage(
        folder: testFolder,
        page: 0,
        pageSize: 50,
      );

      expect(result.length, 2);
    });
  });
}
