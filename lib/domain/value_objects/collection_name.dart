/// コレクション名の値オブジェクト
///
/// バリデーションと正規化（trim）を担う。
/// 無効な入力に対しては [CollectionNameException] をスローする。
library;

import 'package:pictana/core/errors/collection_exceptions.dart';

/// コレクション名のバリデーションと正規化を担う値オブジェクト
///
/// バリデーションルール:
/// - 1〜50文字（trim後）
/// - 改行文字（`\n`, `\r`）禁止
/// - 前後空白は自動 trim
/// - trim後に空文字の場合は拒否
/// - 絵文字は許可
class CollectionName {
  CollectionName._(this.value);

  /// コレクション名の文字列値（trim済み）
  final String value;

  /// 最大文字数
  static const int maxLength = 50;

  /// バリデーション付きファクトリ
  ///
  /// 無効な入力に対して [CollectionNameException] をスローする。
  /// 有効な場合は trim 済みの [CollectionName] を返す。
  factory CollectionName.create(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) throw const CollectionNameEmptyException();
    if (trimmed.length > maxLength) {
      throw const CollectionNameTooLongException();
    }
    if (trimmed.contains('\n') || trimmed.contains('\r')) {
      throw const CollectionNameContainsNewlineException();
    }
    return CollectionName._(trimmed);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CollectionName && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
