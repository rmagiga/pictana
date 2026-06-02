/// コレクション機能固有の例外クラス定義
library;

/// コレクション名バリデーションエラーの基底クラス
///
/// [CollectionName] 値オブジェクトのバリデーション失敗時にスローされる。
/// sealed class により網羅的パターンマッチが可能。
sealed class CollectionNameException implements Exception {
  const CollectionNameException();
}

/// コレクション名が空文字（trim後）の場合にスローされる例外
class CollectionNameEmptyException extends CollectionNameException {
  const CollectionNameEmptyException();

  @override
  String toString() => 'CollectionNameEmptyException: コレクション名が空です';
}

/// コレクション名が最大文字数（50文字）を超過した場合にスローされる例外
class CollectionNameTooLongException extends CollectionNameException {
  const CollectionNameTooLongException();

  @override
  String toString() => 'CollectionNameTooLongException: コレクション名が50文字を超えています';
}

/// コレクション名に改行文字が含まれている場合にスローされる例外
class CollectionNameContainsNewlineException extends CollectionNameException {
  const CollectionNameContainsNewlineException();

  @override
  String toString() =>
      'CollectionNameContainsNewlineException: コレクション名に改行を含めることはできません';
}

/// コレクション名が既存のコレクション名と重複している場合にスローされる例外
class CollectionNameDuplicateException extends CollectionNameException {
  const CollectionNameDuplicateException({required this.existingName});

  /// 重複している既存のコレクション名
  final String existingName;

  @override
  String toString() =>
      'CollectionNameDuplicateException: コレクション名「$existingName」は既に使用されています';
}
