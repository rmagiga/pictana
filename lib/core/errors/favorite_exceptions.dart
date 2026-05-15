/// お気に入り機能固有の例外クラス定義
library;

/// お気に入り登録上限超過例外
///
/// お気に入りフォルダの登録件数が上限に達した状態で
/// 新規登録を試みた場合にスローされる。
class FavoriteLimitExceededException implements Exception {
  const FavoriteLimitExceededException({
    required this.currentCount,
    required this.maxCount,
  });

  /// 現在の登録件数
  final int currentCount;

  /// 登録上限件数
  final int maxCount;

  @override
  String toString() =>
      'FavoriteLimitExceededException: お気に入り登録上限に達しました'
      ' ($currentCount / $maxCount)';
}

/// フォルダアクセス不可例外
///
/// お気に入りフォルダへのナビゲーション時に、フォルダが存在しない、
/// ストレージが切断されている、パーミッションが失効している等の理由で
/// アクセスできない場合にスローされる。
class FolderAccessException implements Exception {
  const FolderAccessException({required this.uri, required this.reason});

  /// アクセスを試みたフォルダの URI
  final String uri;

  /// アクセス不可の理由
  final String reason;

  @override
  String toString() =>
      'FolderAccessException: フォルダにアクセスできません'
      ' [uri=$uri, reason=$reason]';
}
