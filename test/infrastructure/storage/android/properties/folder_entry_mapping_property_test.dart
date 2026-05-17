/// Property 1: FolderEntry Map 変換の完全性
///
/// 任意の有効なチャネル Map（非空の documentId, name, uri フィールドを含む）を
/// FolderEntry に変換した場合、エンティティの各フィールドが正しく設定されることを
/// 検証するプロパティテスト。
///
/// **Validates: Requirements 1.2, 4.3**
@Tags(['android-saf'])
library;

import 'package:glados/glados.dart';
import 'package:pictana/domain/entities/entry_id.dart';
import 'package:pictana/infrastructure/storage/android/saf_data_mappers.dart';

void main() {
  group('Property 1: FolderEntry Map 変換の完全性', () {
    Glados3(any.nonEmptyLetters, any.nonEmptyLetters, any.nonEmptyLetters).test(
      'id.platformType が PlatformType.android である',
      (documentId, name, uri) {
        final map = <String, dynamic>{
          'documentId': documentId,
          'name': name,
          'uri': uri,
        };

        final entry = FolderEntryFromMap.fromChannelMap(map);

        expect(entry.id.platformType, PlatformType.android);
      },
    );

    Glados3(any.nonEmptyLetters, any.nonEmptyLetters, any.nonEmptyLetters).test(
      'id.rawValue が documentId と一致する',
      (documentId, name, uri) {
        final map = <String, dynamic>{
          'documentId': documentId,
          'name': name,
          'uri': uri,
        };

        final entry = FolderEntryFromMap.fromChannelMap(map);

        expect(entry.id.rawValue, documentId);
      },
    );

    Glados3(any.nonEmptyLetters, any.nonEmptyLetters, any.nonEmptyLetters).test(
      'name が map["name"] と一致する',
      (documentId, name, uri) {
        final map = <String, dynamic>{
          'documentId': documentId,
          'name': name,
          'uri': uri,
        };

        final entry = FolderEntryFromMap.fromChannelMap(map);

        expect(entry.name, name);
      },
    );

    Glados3(any.nonEmptyLetters, any.nonEmptyLetters, any.nonEmptyLetters).test(
      'uri が map["uri"] と一致する',
      (documentId, name, uri) {
        final map = <String, dynamic>{
          'documentId': documentId,
          'name': name,
          'uri': uri,
        };

        final entry = FolderEntryFromMap.fromChannelMap(map);

        expect(entry.uri, uri);
      },
    );

    Glados3(any.nonEmptyLetters, any.nonEmptyLetters, any.nonEmptyLetters).test(
      'parentId 未指定時は null になる（ルートレベルエントリ）',
      (documentId, name, uri) {
        final map = <String, dynamic>{
          'documentId': documentId,
          'name': name,
          'uri': uri,
        };

        final entry = FolderEntryFromMap.fromChannelMap(map);

        expect(entry.parentId, isNull);
      },
    );

    Glados(any.nonEmptyLetters).test('parentId 指定時は提供された parentId が設定される', (
      documentId,
    ) {
      final map = <String, dynamic>{
        'documentId': documentId,
        'name': 'TestFolder',
        'uri': 'content://test/folder',
      };
      final parentId = EntryId.android('parent:document:id');

      final entry = FolderEntryFromMap.fromChannelMap(map, parentId: parentId);

      expect(entry.parentId, isNotNull);
      expect(entry.parentId!.rawValue, 'parent:document:id');
      expect(entry.parentId!.platformType, PlatformType.android);
    });
  });
}
