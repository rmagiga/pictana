/// キャンセルシグナルを伝播するためのクラス
library;

/// キャンセルシグナルを管理するクラス
class CancelToken {
  bool _isCancelled = false;

  /// キャンセルされたかどうか
  bool get isCancelled => _isCancelled;

  /// キャンセルを実行する
  void cancel() {
    _isCancelled = true;
  }
}
