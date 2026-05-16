/// StorageMonitorState Entity (設計書 §Data Models - ストレージ監視状態)
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import 'storage_root.dart';

part 'storage_monitor_state.freezed.dart';

/// ストレージ監視状態 (Req 14, 15)
@freezed
abstract class StorageMonitorState with _$StorageMonitorState {
  const factory StorageMonitorState({
    /// 切断されたストレージルート（null = 全接続中）
    StorageRoot? disconnectedRoot,

    /// バナー表示中かどうか
    @Default(false) bool isBannerVisible,

    /// リトライ中かどうか
    @Default(false) bool isRetrying,

    /// リトライ回数
    @Default(0) int retryCount,

    /// 最大リトライ到達
    @Default(false) bool maxRetryReached,
  }) = _StorageMonitorState;
}
