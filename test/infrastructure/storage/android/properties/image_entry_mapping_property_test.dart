/// ImageEntry Map 変換の完全性 Property Test
///
/// **Validates: Requirements 5.2**
///
/// Property 2: For any valid channel map containing documentId, name, uri,
/// mimeType, size, and lastModified fields, converting it to an ImageEntry
/// SHALL produce an entity where id.platformType == PlatformType.android,
/// name matches, extension is extracted correctly (lowercase, no dot),
/// mimeType matches ImageMimeType.fromExtension(extension), size matches,
/// and modifiedAt equals DateTime.fromMillisecondsSinceEpoch(lastModified).
@Tags(['android-saf', 'property-test'])
library;

import 'package:glados/glados.dart';
import 'package:pictana/domain/entities/entry_id.dart';
import 'package:pictana/domain/entities/image_entry.dart';
import 'package:pictana/infrastructure/storage/android/saf_data_mappers.dart';

/// サポートする画像拡張子リスト
const _supportedExtensions = [
  'jpg',
  'jpeg',
  'png',
  'webp',
  'gif',
  'heic',
  'heif',
  'avif',
];

/// ランダムな画像メタデータ Map を生成するジェネレーター
extension ImageChannelMapGenerators on Any {
  /// ファイル名に使える文字列（英数字 + アンダースコア）を生成
  Generator<String> get _baseName => nonEmptyLetterOrDigits;

  /// サポートされる拡張子をランダムに選択
  Generator<String> get _imageExtension => choose(_supportedExtensions);

  /// 正の整数（ファイルサイズ用）
  Generator<int> get _positiveSize => intInRange(1, null);

  /// 正の整数（タイムスタンプ用、ミリ秒）
  Generator<int> get _positiveTimestamp => intInRange(1, null);

  /// documentId を生成（例: "primary:DCIM/Camera/IMG_xxx.jpg"）
  Generator<String> get _documentId =>
      nonEmptyLetterOrDigits.map((s) => 'primary:DCIM/$s');

  /// content:// URI を生成
  Generator<String> get _contentUri =>
      nonEmptyLetterOrDigits.map((s) => 'content://example/$s');

  /// 有効な ImageEntry チャネル Map を生成するジェネレーター
  Generator<Map<String, dynamic>> get imageChannelMap {
    return combine5(
      _documentId,
      _baseName,
      _imageExtension,
      _positiveSize,
      _positiveTimestamp,
      (documentId, baseName, ext, size, lastModified) {
        final name = '$baseName.$ext';
        return <String, dynamic>{
          'documentId': documentId,
          'name': name,
          'extension': ext,
          'uri': 'content://example/$baseName.$ext',
          'mimeType': 'image/$ext',
          'size': size,
          'lastModified': lastModified,
        };
      },
    );
  }

  /// extension フィールドなしの Map を生成（ファイル名から拡張子を抽出するケース）
  Generator<Map<String, dynamic>> get imageChannelMapWithoutExtField {
    return combine5(
      _documentId,
      _baseName,
      _imageExtension,
      _positiveSize,
      _positiveTimestamp,
      (documentId, baseName, ext, size, lastModified) {
        final name = '$baseName.$ext';
        return <String, dynamic>{
          'documentId': documentId,
          'name': name,
          'uri': 'content://example/$baseName.$ext',
          'mimeType': 'image/$ext',
          'size': size,
          'lastModified': lastModified,
        };
      },
    );
  }

  /// 大文字拡張子を含む Map を生成（大文字→小文字変換の検証用）
  Generator<Map<String, dynamic>> get imageChannelMapWithUppercaseExt {
    return combine6(
      _documentId,
      _baseName,
      _imageExtension,
      _contentUri,
      _positiveSize,
      _positiveTimestamp,
      (documentId, baseName, ext, uri, size, lastModified) {
        final upperExt = ext.toUpperCase();
        final name = '$baseName.$upperExt';
        return <String, dynamic>{
          'documentId': documentId,
          'name': name,
          // extension フィールドなし → ファイル名から抽出
          'uri': uri,
          'mimeType': 'image/$ext',
          'size': size,
          'lastModified': lastModified,
        };
      },
    );
  }
}

void main() {
  group('Property 2: ImageEntry Map 変換の完全性', () {
    Glados(any.imageChannelMap, ExploreConfig(numRuns: 100)).test(
      'id.platformType は常に PlatformType.android である',
      (map) {
        final entry = ImageEntryFromMap.fromChannelMap(map);
        expect(entry.id.platformType, PlatformType.android);
      },
    );

    Glados(any.imageChannelMap, ExploreConfig(numRuns: 100)).test(
      'id.rawValue は documentId と一致する',
      (map) {
        final entry = ImageEntryFromMap.fromChannelMap(map);
        expect(entry.id.rawValue, map['documentId']);
      },
    );

    Glados(any.imageChannelMap, ExploreConfig(numRuns: 100)).test(
      'name は Map の name フィールドと一致する',
      (map) {
        final entry = ImageEntryFromMap.fromChannelMap(map);
        expect(entry.name, map['name']);
      },
    );

    Glados(any.imageChannelMap, ExploreConfig(numRuns: 100)).test(
      'extension は小文字・ドットなしで正しく抽出される',
      (map) {
        final entry = ImageEntryFromMap.fromChannelMap(map);
        // extension フィールドがある場合はそのまま使用される
        final expectedExt = map['extension'] as String;
        expect(entry.extension, expectedExt.toLowerCase());
        expect(entry.extension.contains('.'), isFalse);
      },
    );

    Glados(any.imageChannelMap, ExploreConfig(numRuns: 100)).test(
      'mimeType は ImageMimeType.fromExtension(extension) と一致する',
      (map) {
        final entry = ImageEntryFromMap.fromChannelMap(map);
        expect(entry.mimeType, ImageMimeType.fromExtension(entry.extension));
      },
    );

    Glados(any.imageChannelMap, ExploreConfig(numRuns: 100)).test(
      'size は Map の size フィールドと一致する',
      (map) {
        final entry = ImageEntryFromMap.fromChannelMap(map);
        expect(entry.size, map['size']);
      },
    );

    Glados(any.imageChannelMap, ExploreConfig(numRuns: 100)).test(
      'modifiedAt は DateTime.fromMillisecondsSinceEpoch(lastModified) と一致する',
      (map) {
        final entry = ImageEntryFromMap.fromChannelMap(map);
        final expectedDateTime = DateTime.fromMillisecondsSinceEpoch(
          map['lastModified'] as int,
        );
        expect(entry.modifiedAt, expectedDateTime);
      },
    );

    Glados(
      any.imageChannelMapWithoutExtField,
      ExploreConfig(numRuns: 100),
    ).test('extension フィールドがない場合もファイル名から正しく抽出される', (map) {
      final entry = ImageEntryFromMap.fromChannelMap(map);
      final name = map['name'] as String;
      final dotIndex = name.lastIndexOf('.');
      final expectedExt = dotIndex >= 0
          ? name.substring(dotIndex + 1).toLowerCase()
          : '';
      expect(entry.extension, expectedExt);
    });

    Glados(
      any.imageChannelMapWithUppercaseExt,
      ExploreConfig(numRuns: 100),
    ).test('大文字拡張子のファイル名から小文字で拡張子が抽出される', (map) {
      final entry = ImageEntryFromMap.fromChannelMap(map);
      // 拡張子は常に小文字であること
      expect(entry.extension, entry.extension.toLowerCase());
      expect(entry.extension.contains('.'), isFalse);
    });
  });
}
