/// SAF プラットフォームチャネル (設計書 §SafPlatformChannel)
///
/// Android ネイティブ側との MethodChannel / EventChannel 通信を一元管理する。
/// すべてのメソッド呼び出しで PlatformException をドメイン例外に変換し、
/// MissingPluginException を UnsupportedError に変換する。
library;

import 'package:flutter/services.dart';

import '../../../core/errors/app_exceptions.dart';

/// SAF プラットフォームチャネル
///
/// MethodChannel(`com.pgcodetutor.pictana/saf`) と
/// EventChannel(`com.pgcodetutor.pictana/saf/usb`) を使用して
/// Android ネイティブ側の SAF API を呼び出す。
class SafPlatformChannel {
  static const _methodChannel = MethodChannel('com.pgcodetutor.pictana/saf');
  static const _usbEventChannel = EventChannel(
    'com.pgcodetutor.pictana/saf/usb',
  );

  // ---------------------------------------------------------------------------
  // フォルダ選択
  // ---------------------------------------------------------------------------

  /// フォルダ選択ダイアログを表示
  ///
  /// ユーザーがフォルダを選択した場合は FolderEntry Map を返す。
  /// キャンセルした場合は null を返す。
  Future<Map<String, dynamic>?> selectFolder() async {
    return await _invokeMethod<Map<dynamic, dynamic>?>(
      'selectFolder',
    ).then((result) => result?.cast<String, dynamic>());
  }

  // ---------------------------------------------------------------------------
  // ストレージルート
  // ---------------------------------------------------------------------------

  /// ストレージルート一覧を取得
  Future<List<Map<String, dynamic>>> getStorageRoots() async {
    final result = await _invokeMethod<List<dynamic>>('getStorageRoots');
    return _castListOfMaps(result);
  }

  // ---------------------------------------------------------------------------
  // フォルダ列挙
  // ---------------------------------------------------------------------------

  /// 指定フォルダの子フォルダ一覧を取得
  Future<List<Map<String, dynamic>>> getChildFolders(
    String treeUri,
    String? documentId,
  ) async {
    final result = await _invokeMethod<List<dynamic>>('getChildFolders', {
      'treeUri': treeUri,
      'documentId': documentId,
    });
    return _castListOfMaps(result);
  }

  // ---------------------------------------------------------------------------
  // 画像列挙
  // ---------------------------------------------------------------------------

  /// 指定フォルダの画像一覧を取得（バッチ）
  Future<List<Map<String, dynamic>>> getImages(
    String treeUri,
    String documentId,
    int offset,
    int limit,
  ) async {
    final result = await _invokeMethod<List<dynamic>>('getImages', {
      'treeUri': treeUri,
      'documentId': documentId,
      'offset': offset,
      'limit': limit,
    });
    return _castListOfMaps(result);
  }

  // ---------------------------------------------------------------------------
  // 画像データ取得
  // ---------------------------------------------------------------------------

  /// 画像バイトデータを取得（<= 10MB）
  Future<Uint8List> getImageBytes(String contentUri) async {
    final result = await _invokeMethod<Uint8List>('getImageBytes', {
      'contentUri': contentUri,
    });
    return result ?? Uint8List(0);
  }

  /// 画像バイトデータを一時ファイル経由で取得（> 10MB）
  ///
  /// ネイティブ側で一時ファイルに書き出し、そのパスを返す。
  Future<String> getImageBytesViaFile(String contentUri) async {
    final result = await _invokeMethod<String>('getImageBytesViaFile', {
      'contentUri': contentUri,
    });
    return result ?? '';
  }

  // ---------------------------------------------------------------------------
  // サムネイル
  // ---------------------------------------------------------------------------

  /// サムネイルを取得
  ///
  /// 生成に失敗した場合は null を返す。
  Future<Uint8List?> getThumbnail(
    String contentUri,
    int width,
    int height,
  ) async {
    return await _invokeMethod<Uint8List?>('getThumbnail', {
      'contentUri': contentUri,
      'width': width,
      'height': height,
    });
  }

  // ---------------------------------------------------------------------------
  // URI パーミッション管理
  // ---------------------------------------------------------------------------

  /// URI パーミッションを永続化
  Future<void> persistUriPermission(String uri) async {
    await _invokeMethod<void>('persistUriPermission', {'uri': uri});
  }

  /// 永続化済み URI パーミッション一覧を取得
  Future<List<String>> getPersistedUriPermissions() async {
    final result = await _invokeMethod<List<dynamic>>(
      'getPersistedUriPermissions',
    );
    return result?.cast<String>() ?? [];
  }

  /// 永続化済み URI パーミッションを解放
  Future<void> releaseUriPermission(String uri) async {
    await _invokeMethod<void>('releaseUriPermission', {'uri': uri});
  }

  // ---------------------------------------------------------------------------
  // デフォルト画像フォルダ
  // ---------------------------------------------------------------------------

  /// デフォルト画像フォルダを検出
  ///
  /// DCIM > Pictures の優先順位で検出し、見つからない場合は null を返す。
  Future<Map<String, dynamic>?> getDefaultImageFolder() async {
    return await _invokeMethod<Map<dynamic, dynamic>?>(
      'getDefaultImageFolder',
    ).then((result) => result?.cast<String, dynamic>());
  }

  // ---------------------------------------------------------------------------
  // USB イベントストリーム
  // ---------------------------------------------------------------------------

  /// USB 接続/切断イベントストリーム
  ///
  /// EventChannel から USB デバイスの接続・切断イベントを受信する。
  Stream<Map<String, dynamic>> get usbEvents {
    return _usbEventChannel.receiveBroadcastStream().map((event) {
      if (event is Map) {
        return event.cast<String, dynamic>();
      }
      return <String, dynamic>{};
    });
  }

  // ---------------------------------------------------------------------------
  // private ヘルパー
  // ---------------------------------------------------------------------------

  /// MethodChannel 呼び出しのラッパー
  ///
  /// PlatformException をドメイン例外に変換し、
  /// MissingPluginException を UnsupportedError に変換する。
  Future<T?> _invokeMethod<T>(
    String method, [
    Map<String, dynamic>? args,
  ]) async {
    try {
      final result = await _methodChannel.invokeMethod<T>(method, args);
      return result;
    } on PlatformException catch (e) {
      throw _mapPlatformException(e);
    } on MissingPluginException catch (e) {
      throw UnsupportedError('ネイティブハンドラが見つかりません: $method (${e.message})');
    }
  }

  /// PlatformException のエラーコードをドメイン例外に変換する
  AppException _mapPlatformException(PlatformException e) {
    switch (e.code) {
      case 'PERMISSION_DENIED':
        return PermissionDeniedException(cause: e);
      case 'STORAGE_DISCONNECTED':
        return StorageDisconnectedException(
          message: e.message ?? 'ストレージが切断されました',
          cause: e,
        );
      case 'OUT_OF_MEMORY':
        return OutOfMemoryException(cause: e);
      default:
        return StorageDisconnectedException(
          message: e.message ?? '不明なエラーが発生しました',
          cause: e,
        );
    }
  }

  /// `List<dynamic>` を `List<Map<String, dynamic>>` にキャストする
  List<Map<String, dynamic>> _castListOfMaps(List<dynamic>? list) {
    if (list == null) return [];
    return list.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
  }
}
