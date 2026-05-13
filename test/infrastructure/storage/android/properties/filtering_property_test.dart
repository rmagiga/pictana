/// Property 7: ディレクトリ MIME type フィルタリング
///
/// DocumentsContract クエリから返されるドキュメントエントリのリストに対して、
/// ディレクトリフィルタリングを適用した結果、MIME type が
/// "vnd.android.document/directory" のエントリのみが含まれ、
/// それ以外の MIME type のエントリは含まれないことを検証するプロパティテスト。
///
/// **Validates: Requirements 4.1, 4.2**
///
/// Property 9: 画像 MIME type フィルタリング
///
/// DocumentsContract クエリから返されるドキュメントエントリのリストに対して、
/// 画像フィルタリングを適用した結果、サポートされた画像 MIME type
/// (image/jpeg, image/png, image/webp, image/gif, image/heic, image/heif, image/avif)
/// のエントリのみが含まれ、それ以外の MIME type のエントリは含まれないことを検証する。
///
/// **Validates: Requirements 5.1**
@Tags(['android-saf', 'property-test'])
library;

import 'package:glados/glados.dart';

/// ディレクトリを示す MIME type（Android SAF 仕様）
const directoryMimeType = 'vnd.android.document/directory';

/// テストで使用する全 MIME type のリスト（ディレクトリ含む）
const allMimeTypes = [
  directoryMimeType,
  'image/jpeg',
  'image/png',
  'image/webp',
  'image/gif',
  'image/heic',
  'image/heif',
  'image/avif',
  'application/pdf',
  'text/plain',
  'video/mp4',
  'audio/mpeg',
  'application/octet-stream',
];

/// 非ディレクトリ MIME type のリスト
const nonDirectoryMimeTypes = [
  'image/jpeg',
  'image/png',
  'image/webp',
  'image/gif',
  'image/heic',
  'image/heif',
  'image/avif',
  'application/pdf',
  'text/plain',
  'video/mp4',
  'audio/mpeg',
  'application/octet-stream',
];

/// サポートされた画像 MIME type のセット
const supportedImageMimeTypes = {
  'image/jpeg',
  'image/png',
  'image/webp',
  'image/gif',
  'image/heic',
  'image/heif',
  'image/avif',
};

/// 非画像 MIME type のリスト（ディレクトリ含む）
const nonImageMimeTypes = [
  directoryMimeType,
  'application/pdf',
  'text/plain',
  'video/mp4',
  'audio/mpeg',
  'application/octet-stream',
];

/// ドキュメントエントリのリストからディレクトリのみをフィルタリングする。
///
/// SafCommands.getChildFolders の Kotlin 側フィルタリングロジックと同等の
/// Dart 実装。MIME type が "vnd.android.document/directory" のエントリのみを返す。
List<Map<String, dynamic>> filterDirectories(
  List<Map<String, dynamic>> documents,
) {
  return documents
      .where((doc) => doc['mimeType'] == directoryMimeType)
      .toList();
}

/// ドキュメントエントリのリストからサポートされた画像のみをフィルタリングする。
///
/// SafCommands.getImages の Kotlin 側フィルタリングロジックと同等の
/// Dart 実装。MIME type が supportedImageMimeTypes に含まれるエントリのみを返す。
List<Map<String, dynamic>> filterImages(List<Map<String, dynamic>> documents) {
  return documents
      .where((doc) => supportedImageMimeTypes.contains(doc['mimeType']))
      .toList();
}

/// テスト用ドキュメントエントリを生成するヘルパー
Map<String, dynamic> createDocumentEntry({
  required String documentId,
  required String name,
  required String mimeType,
}) {
  return {
    'documentId': documentId,
    'name': name,
    'mimeType': mimeType,
    'uri':
        'content://com.android.externalstorage.documents/tree/primary%3A/document/$documentId',
  };
}

/// MIME type 混在ドキュメントリストのジェネレータ
extension MixedDocumentListGenerator on Any {
  /// ランダムな MIME type を選択するジェネレータ
  Generator<String> get _mimeType => choose(allMimeTypes);

  /// ランダムなドキュメントエントリを生成するジェネレータ
  Generator<Map<String, dynamic>> get _documentEntry => combine2(
    any.nonEmptyLetters,
    any._mimeType,
    (String name, String mimeType) => createDocumentEntry(
      documentId: 'primary:$name',
      name: name,
      mimeType: mimeType,
    ),
  );

  /// ディレクトリと非ディレクトリが混在するドキュメントリストを生成する
  Generator<List<Map<String, dynamic>>> get mixedDocumentList =>
      any.list(any._documentEntry);

  /// 非ディレクトリ MIME type のみのジェネレータ
  Generator<String> get _nonDirectoryMimeType => choose(nonDirectoryMimeTypes);

  /// 非画像 MIME type のみのジェネレータ
  Generator<String> get _nonImageMimeType => choose(nonImageMimeTypes);

  /// 非ディレクトリエントリのみのリストを生成するジェネレータ
  Generator<List<Map<String, dynamic>>> get nonDirectoryDocumentList =>
      any.list(
        combine2(
          any.nonEmptyLetters,
          any._nonDirectoryMimeType,
          (String name, String mimeType) => createDocumentEntry(
            documentId: 'primary:$name',
            name: name,
            mimeType: mimeType,
          ),
        ),
      );

  /// 非画像エントリのみのリストを生成するジェネレータ
  Generator<List<Map<String, dynamic>>> get nonImageDocumentList => any.list(
    combine2(
      any.nonEmptyLetters,
      any._nonImageMimeType,
      (String name, String mimeType) => createDocumentEntry(
        documentId: 'primary:$name',
        name: name,
        mimeType: mimeType,
      ),
    ),
  );
}

void main() {
  group('Feature: android-saf, Property 7: ディレクトリ MIME type フィルタリング', () {
    Glados(any.mixedDocumentList).test(
      'フィルタ結果にはディレクトリ MIME type のエントリのみが含まれる',
      (documents) {
        final result = filterDirectories(documents);

        // フィルタ結果のすべてのエントリが directoryMimeType を持つ
        for (final entry in result) {
          expect(
            entry['mimeType'],
            equals(directoryMimeType),
            reason: 'フィルタ結果に非ディレクトリエントリが含まれている: ${entry['mimeType']}',
          );
        }
      },
    );

    Glados(any.mixedDocumentList).test('フィルタ結果に非ディレクトリ MIME type のエントリは含まれない', (
      documents,
    ) {
      final result = filterDirectories(documents);

      // フィルタ結果に directoryMimeType 以外のエントリが含まれないことを確認
      final nonDirectoryEntries = result.where(
        (doc) => doc['mimeType'] != directoryMimeType,
      );
      expect(nonDirectoryEntries, isEmpty, reason: '非ディレクトリエントリがフィルタ結果に含まれている');
    });

    Glados(any.mixedDocumentList).test('フィルタ結果の件数は元リスト内のディレクトリエントリ数と一致する', (
      documents,
    ) {
      final result = filterDirectories(documents);

      // 元リスト内のディレクトリエントリ数をカウント
      final expectedCount = documents
          .where((doc) => doc['mimeType'] == directoryMimeType)
          .length;

      expect(
        result.length,
        equals(expectedCount),
        reason: 'フィルタ結果の件数 (${result.length}) が期待値 ($expectedCount) と一致しない',
      );
    });

    Glados(any.mixedDocumentList).test('フィルタ結果は元リストのディレクトリエントリと完全に一致する', (
      documents,
    ) {
      final result = filterDirectories(documents);

      // 元リストからディレクトリエントリのみを抽出
      final expected = documents
          .where((doc) => doc['mimeType'] == directoryMimeType)
          .toList();

      expect(result, equals(expected));
    });

    Glados(any.list(any.nonEmptyLetters)).test('すべてディレクトリのリストはフィルタ後も全件残る', (
      names,
    ) {
      final documents = names
          .map(
            (name) => createDocumentEntry(
              documentId: 'primary:$name',
              name: name,
              mimeType: directoryMimeType,
            ),
          )
          .toList();

      final result = filterDirectories(documents);

      expect(result.length, equals(documents.length));
    });

    Glados(any.nonDirectoryDocumentList).test('ディレクトリが含まれないリストはフィルタ後に空になる', (
      documents,
    ) {
      final result = filterDirectories(documents);

      expect(result, isEmpty);
    });
  });

  group('Feature: android-saf, Property 9: 画像 MIME type フィルタリング', () {
    Glados(any.mixedDocumentList).test(
      'フィルタ結果にはサポートされた画像 MIME type のエントリのみが含まれる',
      (documents) {
        final result = filterImages(documents);

        // フィルタ結果のすべてのエントリが supportedImageMimeTypes に含まれる
        for (final entry in result) {
          expect(
            supportedImageMimeTypes.contains(entry['mimeType']),
            isTrue,
            reason: 'フィルタ結果に非画像エントリが含まれている: ${entry['mimeType']}',
          );
        }
      },
    );

    Glados(any.mixedDocumentList).test(
      'フィルタ結果にサポートされていない MIME type のエントリは含まれない',
      (documents) {
        final result = filterImages(documents);

        // フィルタ結果に supportedImageMimeTypes 以外のエントリが含まれないことを確認
        final unsupportedEntries = result.where(
          (doc) => !supportedImageMimeTypes.contains(doc['mimeType']),
        );
        expect(
          unsupportedEntries,
          isEmpty,
          reason: 'サポートされていない MIME type のエントリがフィルタ結果に含まれている',
        );
      },
    );

    Glados(any.mixedDocumentList).test('フィルタ結果の件数は元リスト内のサポート画像エントリ数と一致する', (
      documents,
    ) {
      final result = filterImages(documents);

      // 元リスト内のサポート画像エントリ数をカウント
      final expectedCount = documents
          .where((doc) => supportedImageMimeTypes.contains(doc['mimeType']))
          .length;

      expect(
        result.length,
        equals(expectedCount),
        reason: 'フィルタ結果の件数 (${result.length}) が期待値 ($expectedCount) と一致しない',
      );
    });

    Glados(any.mixedDocumentList).test('フィルタ結果は元リストのサポート画像エントリと完全に一致する', (
      documents,
    ) {
      final result = filterImages(documents);

      // 元リストからサポート画像エントリのみを抽出
      final expected = documents
          .where((doc) => supportedImageMimeTypes.contains(doc['mimeType']))
          .toList();

      expect(result, equals(expected));
    });

    Glados(any.list(any.nonEmptyLetters)).test('すべてサポート画像のリストはフィルタ後も全件残る', (
      names,
    ) {
      final supportedTypes = supportedImageMimeTypes.toList();
      final documents = names
          .asMap()
          .entries
          .map(
            (entry) => createDocumentEntry(
              documentId: 'primary:${entry.value}',
              name: entry.value,
              mimeType: supportedTypes[entry.key % supportedTypes.length],
            ),
          )
          .toList();

      final result = filterImages(documents);

      expect(result.length, equals(documents.length));
    });

    Glados(any.nonImageDocumentList).test('サポート画像が含まれないリストはフィルタ後に空になる', (
      documents,
    ) {
      final result = filterImages(documents);

      expect(result, isEmpty);
    });
  });
}
