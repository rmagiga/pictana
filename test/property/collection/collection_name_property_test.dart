/// CollectionName 値オブジェクト プロパティベーステスト
///
/// glados を使用して、CollectionName のバリデーションと正規化の正当性プロパティを検証する。
/// 各プロパティテストは最低100回のイテレーションで実行される。
///
/// テスト対象:
/// - Property 1: CollectionName バリデーションは無効な入力を拒否する
/// - Property 2: CollectionName の trim 正規化
// Feature: collection-management, Property 1: CollectionName バリデーションは無効な入力を拒否する
// Feature: collection-management, Property 2: CollectionName の trim 正規化
@Tags(['property-test', 'collection-management'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, tearDown, test;
import 'package:pictana/core/errors/collection_exceptions.dart';
import 'package:pictana/domain/value_objects/collection_name.dart';

// ---------------------------------------------------------------------------
// カスタムジェネレータ
// ---------------------------------------------------------------------------

/// 有効なコレクション名用の文字セット（英数字 + スペース + 絵文字）
const _validChars =
    'abcdefghijklmnopqrstuvwxyz'
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    '0123456789'
    ' 🎨🌟💡📷';

/// 英数字のみの文字セット
const _alphanumericChars =
    'abcdefghijklmnopqrstuvwxyz'
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    '0123456789';

extension CollectionNameGenerators on Any {
  /// 有効なコレクション名を生成する（1〜50文字、改行なし、空白のみでない）
  ///
  /// 戦略: 英数字文字列を生成し、長さを1〜50に制限する
  Generator<String> get validCollectionName =>
      any.nonEmptyStringOf(_validChars).map((s) {
        // trim 後に空でなく50文字以下になるよう調整
        final trimmed = s.trim();
        if (trimmed.isEmpty) return 'a'; // フォールバック
        if (trimmed.length > 50) return trimmed.substring(0, 50);
        return trimmed;
      });

  /// 51文字以上の文字列を生成する（長すぎる入力）
  ///
  /// 戦略: 英数字で60〜100文字の文字列を生成する
  Generator<String> get tooLongString => any.intInRange(51, 100).map((length) {
    // 指定長の英数字文字列を生成
    final chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      buffer.write(chars[i % chars.length]);
    }
    return buffer.toString();
  });

  /// 改行文字を含む文字列を生成する
  ///
  /// 戦略: 有効なプレフィックスの中間に改行文字を挿入する
  /// （trim で改行が除去されないよう、前後に英数字を配置する）
  Generator<String> get stringWithNewline => any.combine3(
    any.nonEmptyStringOf(_alphanumericChars),
    any.choose(['\n', '\r', '\r\n']),
    any.nonEmptyStringOf(_alphanumericChars),
    (String prefix, String newline, String suffix) {
      // trim 後も50文字以下になるよう調整
      final p = prefix.length > 20 ? prefix.substring(0, 20) : prefix;
      final s = suffix.length > 20 ? suffix.substring(0, 20) : suffix;
      return '$p$newline$s';
    },
  );

  /// trim 後に空文字になる文字列を生成する（空白のみ）
  Generator<String> get whitespaceOnlyString =>
      any.intInRange(1, 10).map((count) => ' ' * count);

  /// 前後に付加する空白文字列を生成する（1〜5文字のスペース）
  Generator<String> get paddingWhitespace =>
      any.intInRange(1, 5).map((count) => ' ' * count);
}

// ---------------------------------------------------------------------------
// テスト本体
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // Property 1: CollectionName バリデーションは無効な入力を拒否する
  // =========================================================================
  group(
    'Feature: collection-management, Property 1: CollectionName バリデーションは無効な入力を拒否する',
    () {
      /// **Validates: Requirements 1.2, 1.4, 1.6**
      ///
      /// 51文字以上の文字列に対して、CollectionName.create() は
      /// CollectionNameTooLongException をスローする。
      Glados(any.tooLongString).test(
        '51文字以上の文字列は CollectionNameTooLongException をスローする',
        (input) {
          expect(
            () => CollectionName.create(input),
            throwsA(isA<CollectionNameTooLongException>()),
            reason: '入力 "${input.length}文字" は50文字を超えているため拒否されるべき',
          );
        },
      );

      /// 改行文字を含む文字列に対して、CollectionName.create() は
      /// CollectionNameContainsNewlineException をスローする。
      Glados(any.stringWithNewline).test(
        '改行文字を含む文字列は CollectionNameContainsNewlineException をスローする',
        (input) {
          expect(
            () => CollectionName.create(input),
            throwsA(isA<CollectionNameContainsNewlineException>()),
            reason: '入力に改行文字が含まれているため拒否されるべき',
          );
        },
      );

      /// trim 後に空文字になる文字列に対して、CollectionName.create() は
      /// CollectionNameEmptyException をスローする。
      Glados(any.whitespaceOnlyString).test(
        'trim 後に空文字になる文字列は CollectionNameEmptyException をスローする',
        (input) {
          expect(
            () => CollectionName.create(input),
            throwsA(isA<CollectionNameEmptyException>()),
            reason: '空白のみの入力は trim 後に空文字となるため拒否されるべき',
          );
        },
      );

      /// 空文字列に対して、CollectionName.create() は
      /// CollectionNameEmptyException をスローする。
      Glados(any.always('')).test('空文字列は CollectionNameEmptyException をスローする', (
        input,
      ) {
        expect(
          () => CollectionName.create(input),
          throwsA(isA<CollectionNameEmptyException>()),
          reason: '空文字列は拒否されるべき',
        );
      });
    },
  );

  // =========================================================================
  // Property 2: CollectionName の trim 正規化
  // =========================================================================
  group(
    'Feature: collection-management, Property 2: CollectionName の trim 正規化',
    () {
      /// **Validates: Requirements 1.2, 1.3**
      ///
      /// 有効な文字列 s に対して、前後に空白を付加した文字列を
      /// CollectionName.create() に渡した場合、結果の value は s.trim() と等しい。
      Glados2(any.validCollectionName, any.paddingWhitespace).test(
        '前後に空白を付加した有効な文字列の value は trim 後の値と等しい',
        (validName, padding) {
          final paddedInput = '$padding$validName$padding';

          // パディング付きでも trim 後が50文字以下であることを確認
          final expectedValue = paddedInput.trim();
          if (expectedValue.length > 50) return; // 長すぎる場合はスキップ

          final result = CollectionName.create(paddedInput);

          expect(
            result.value,
            expectedValue,
            reason: '入力 "$paddedInput" の value は "$expectedValue" であるべき',
          );
        },
      );

      /// 有効な文字列に対して、CollectionName.create() は常に成功し、
      /// value が trim 済みであることを検証する。
      Glados(any.validCollectionName).test(
        '有効な文字列に対して create は成功し value は trim 済みである',
        (input) {
          final result = CollectionName.create(input);

          // value が trim 済みであることを検証
          expect(
            result.value,
            result.value.trim(),
            reason: 'value "${result.value}" は前後に空白を含まないべき',
          );

          // value が1〜50文字であることを検証
          expect(result.value.length, greaterThanOrEqualTo(1));
          expect(result.value.length, lessThanOrEqualTo(50));
        },
      );
    },
  );
}
