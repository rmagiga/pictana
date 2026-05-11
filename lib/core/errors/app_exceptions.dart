/// アプリ固有の Domain 例外定義 (設計書 §19.1)
///
/// OS固有例外はInfrastructure層でこれらへ変換し、
/// UIへはDomain例外のみを伝播させる。
library;

/// 基底例外クラス
sealed class AppException implements Exception {
  const AppException({
    required this.message,
    this.cause,
  });

  final String message;
  final Object? cause;

  @override
  String toString() =>
      '$runtimeType: $message${cause != null ? ' (cause: $cause)' : ''}';
}

/// USB/ストレージ切断例外 (設計書 §19.1)
///
/// FileSystemException / SAF access exception / ContentResolver exception
/// をInfrastructure層でこの例外へ変換する。
class StorageDisconnectedException extends AppException {
  const StorageDisconnectedException({
    super.message = 'ストレージが切断されました',
    super.cause,
  });
}

/// SAF権限喪失例外 (設計書 §19.1)
class PermissionDeniedException extends AppException {
  const PermissionDeniedException({
    super.message = 'ストレージへのアクセス権限がありません',
    super.cause,
  });
}

/// 画像デコード失敗例外 (設計書 §19.1)
class DecodeFailedException extends AppException {
  const DecodeFailedException({
    super.message = '画像の読み込みに失敗しました',
    super.cause,
    this.filePath,
  });

  final String? filePath;

  @override
  String toString() =>
      '$runtimeType: $message'
      '${filePath != null ? ' [$filePath]' : ''}'
      '${cause != null ? ' (cause: $cause)' : ''}';
}

/// キャッシュ破損例外 (設計書 §19.1)
class CacheFailedException extends AppException {
  const CacheFailedException({
    super.message = 'キャッシュの読み書きに失敗しました',
    super.cause,
  });
}

/// メモリ不足例外 (設計書 §19.1)
class OutOfMemoryException extends AppException {
  const OutOfMemoryException({
    super.message = 'メモリが不足しています',
    super.cause,
  });
}

/// フォルダが見つからない例外
class FolderNotFoundException extends AppException {
  const FolderNotFoundException({
    super.message = 'フォルダが見つかりません',
    super.cause,
    this.folderPath,
  });

  final String? folderPath;
}
