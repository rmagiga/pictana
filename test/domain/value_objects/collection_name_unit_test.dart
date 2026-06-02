/// CollectionName 値オブジェクト ユニットテスト
///
/// バリデーション、trim正規化、等値性を検証する。
///
/// **Validates: Requirements 1.2, 1.3, 1.4, 1.5, 1.6**
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:pictana/core/errors/collection_exceptions.dart';
import 'package:pictana/domain/value_objects/collection_name.dart';

void main() {
  group('CollectionName - 有効な入力', () {
    test('通常の文字列で作成できる', () {
      final name = CollectionName.create('お気に入り');
      expect(name.value, equals('お気に入り'));
    });

    test('1文字で作成できる', () {
      final name = CollectionName.create('A');
      expect(name.value, equals('A'));
    });

    test('50文字ちょうどで作成できる', () {
      final input = 'あ' * 50;
      final name = CollectionName.create(input);
      expect(name.value, equals(input));
      expect(name.value.length, equals(50));
    });

    test('絵文字を含む名前で作成できる', () {
      final name = CollectionName.create('🎨 アート作品');
      expect(name.value, equals('🎨 アート作品'));
    });

    test('絵文字のみの名前で作成できる', () {
      final name = CollectionName.create('🎨🖼️🎭');
      expect(name.value, equals('🎨🖼️🎭'));
    });
  });

  group('CollectionName - trim正規化', () {
    test('前後の空白がtrimされる', () {
      final name = CollectionName.create('  テスト  ');
      expect(name.value, equals('テスト'));
    });

    test('先頭の空白がtrimされる', () {
      final name = CollectionName.create('   先頭空白');
      expect(name.value, equals('先頭空白'));
    });

    test('末尾の空白がtrimされる', () {
      final name = CollectionName.create('末尾空白   ');
      expect(name.value, equals('末尾空白'));
    });

    test('タブ文字がtrimされる', () {
      final name = CollectionName.create('\tタブ\t');
      expect(name.value, equals('タブ'));
    });
  });

  group('CollectionName - 空文字拒否', () {
    test('空文字列は拒否される', () {
      expect(
        () => CollectionName.create(''),
        throwsA(isA<CollectionNameEmptyException>()),
      );
    });

    test('空白のみの文字列は拒否される', () {
      expect(
        () => CollectionName.create('   '),
        throwsA(isA<CollectionNameEmptyException>()),
      );
    });

    test('タブのみの文字列は拒否される', () {
      expect(
        () => CollectionName.create('\t\t'),
        throwsA(isA<CollectionNameEmptyException>()),
      );
    });
  });

  group('CollectionName - 文字数制限', () {
    test('51文字は拒否される', () {
      final input = 'あ' * 51;
      expect(
        () => CollectionName.create(input),
        throwsA(isA<CollectionNameTooLongException>()),
      );
    });

    test('100文字は拒否される', () {
      final input = 'a' * 100;
      expect(
        () => CollectionName.create(input),
        throwsA(isA<CollectionNameTooLongException>()),
      );
    });
  });

  group('CollectionName - 改行禁止', () {
    test('LF（\\n）を含む文字列は拒否される', () {
      expect(
        () => CollectionName.create('行1\n行2'),
        throwsA(isA<CollectionNameContainsNewlineException>()),
      );
    });

    test('CR（\\r）を含む文字列は拒否される', () {
      expect(
        () => CollectionName.create('行1\r行2'),
        throwsA(isA<CollectionNameContainsNewlineException>()),
      );
    });

    test('CRLF（\\r\\n）を含む文字列は拒否される', () {
      expect(
        () => CollectionName.create('行1\r\n行2'),
        throwsA(isA<CollectionNameContainsNewlineException>()),
      );
    });
  });

  group('CollectionName - 等値性', () {
    test('同じ値を持つインスタンスは等しい', () {
      final a = CollectionName.create('テスト');
      final b = CollectionName.create('テスト');
      expect(a, equals(b));
    });

    test('trim後に同じ値になるインスタンスは等しい', () {
      final a = CollectionName.create('  テスト  ');
      final b = CollectionName.create('テスト');
      expect(a, equals(b));
    });

    test('異なる値を持つインスタンスは等しくない', () {
      final a = CollectionName.create('テストA');
      final b = CollectionName.create('テストB');
      expect(a, isNot(equals(b)));
    });

    test('hashCode が等しいインスタンスで一致する', () {
      final a = CollectionName.create('テスト');
      final b = CollectionName.create('テスト');
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('CollectionName - toString', () {
    test('toString は value を返す', () {
      final name = CollectionName.create('マイコレクション');
      expect(name.toString(), equals('マイコレクション'));
    });
  });

  group('CollectionName - maxLength定数', () {
    test('maxLength は 50', () {
      expect(CollectionName.maxLength, equals(50));
    });
  });
}
