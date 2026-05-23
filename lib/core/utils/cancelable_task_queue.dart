import 'dart:async';
import 'cancel_token.dart';

/// 同時実行数を制限し、キャンセル可能なタスクキュー
class CancelableTaskQueue {
  CancelableTaskQueue(this.maxConcurrency);

  /// 最大同時実行数
  final int maxConcurrency;

  int _running = 0;
  final _queue = <_QueueEntry>[];

  /// タスクを実行キューに登録し、実行完了を待つ。
  /// [token] が実行前にキャンセルされている場合は null を返す。
  Future<T?> run<T>(Future<T?> Function() task, {CancelToken? token}) async {
    if (token?.isCancelled == true) return null;

    if (_running >= maxConcurrency) {
      final completer = Completer<T?>();
      _queue.add(_QueueEntry(
        task: task,
        completer: completer,
        token: token,
      ));
      return completer.future;
    }

    _running++;
    try {
      if (token?.isCancelled == true) return null;
      return await task();
    } finally {
      _running--;
      _processNext();
    }
  }

  void _processNext() {
    while (_queue.isNotEmpty && _running < maxConcurrency) {
      final entry = _queue.removeAt(0);
      if (entry.token?.isCancelled == true) {
        entry.completer.complete(null);
        continue;
      }

      _running++;
      entry.runTask().then((result) {
        entry.completer.complete(result);
      }).catchError((e) {
        entry.completer.completeError(e);
      }).whenComplete(() {
        _running--;
        _processNext();
      });
    }
  }
}

class _QueueEntry {
  _QueueEntry({required this.task, required this.completer, this.token});

  final Future<dynamic> Function() task;
  final Completer<dynamic> completer;
  final CancelToken? token;

  Future<dynamic> runTask() => task();
}
