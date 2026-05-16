/// StorageMonitor Provider (Req 14.1, 14.6, 15.1, 15.2, 15.5, 16.1, 16.2, 16.3, 16.4, 16.5)
///
/// ストレージ接続状態を監視し、切断通知・自動リトライ・OS既定フォルダ検出を管理する。
/// - 切断検知 → バナー表示 + 3秒間隔ポーリング（最大60回）
/// - 再接続検知 → バナー非表示 + ポーリング停止
/// - detectDefaultFolder: Android は DCIM/Camera、Windows はピクチャフォルダ
library;

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/folder_entry.dart';
import '../../../domain/entities/storage_monitor_state.dart';
import '../../../domain/entities/storage_root.dart';
import '../../providers/repository_providers.dart';

part 'storage_monitor.g.dart';

/// ストレージ接続監視・自動リトライ・OS既定フォルダ検出 Provider
///
/// keepAlive: true でアプリ全体のライフサイクルにわたって状態を保持する。
@Riverpod(keepAlive: true)
class StorageMonitor extends _$StorageMonitor {
  /// ポーリング間隔（3秒）
  static const _pollingInterval = Duration(seconds: 3);

  /// 最大リトライ回数（60回 = 180秒）
  static const _maxRetries = 60;

  /// リトライ用タイマー
  Timer? _retryTimer;

  /// ストレージ監視ストリームのサブスクリプション
  StreamSubscription<List<StorageRoot>>? _watchSubscription;

  @override
  StorageMonitorState build() {
    // ストレージルートの変化を監視開始
    _startWatching();

    // Provider 破棄時にリソースをクリーンアップ
    ref.onDispose(() {
      _retryTimer?.cancel();
      _watchSubscription?.cancel();
    });

    return const StorageMonitorState();
  }

  /// ストレージルートの変化を監視する
  void _startWatching() {
    final repo = ref.read(storageRepositoryProvider);
    _watchSubscription = repo.watchStorageRoots().listen((roots) {
      _handleStorageRootsChanged(roots);
    });
  }

  /// ストレージルート変化時のハンドリング
  void _handleStorageRootsChanged(List<StorageRoot> roots) {
    final currentDisconnected = state.disconnectedRoot;

    if (currentDisconnected != null) {
      // 切断中のルートが再出現したか確認
      final reconnected = roots.any(
        (r) => r.id == currentDisconnected.id && r.isConnected,
      );
      if (reconnected) {
        _onReconnected();
      }
    }

    // 新たに切断されたルートを検出
    final disconnectedRoots = roots.where((r) => !r.isConnected);
    if (disconnectedRoots.isNotEmpty && currentDisconnected == null) {
      _onDisconnected(disconnectedRoots.first);
    }
  }

  /// 切断検知時の処理
  void _onDisconnected(StorageRoot root) {
    state = state.copyWith(
      disconnectedRoot: root,
      isBannerVisible: true,
      isRetrying: true,
      retryCount: 0,
      maxRetryReached: false,
    );
    _startRetryTimer(root);
  }

  /// 再接続検知時の処理
  void _onReconnected() {
    stopRetryPolling();
    state = state.copyWith(
      disconnectedRoot: null,
      isBannerVisible: false,
      isRetrying: false,
      retryCount: 0,
      maxRetryReached: false,
    );
  }

  /// リトライタイマーを開始する
  void _startRetryTimer(StorageRoot root) {
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(_pollingInterval, (_) async {
      await _checkConnection(root);
    });
  }

  /// 接続確認を実行する
  Future<void> _checkConnection(StorageRoot root) async {
    final currentCount = state.retryCount + 1;
    state = state.copyWith(retryCount: currentCount);

    try {
      final repo = ref.read(storageRepositoryProvider);
      final roots = await repo.getStorageRoots();
      final reconnected = roots.any((r) => r.id == root.id && r.isConnected);

      if (reconnected) {
        _onReconnected();
        return;
      }
    } catch (_) {
      // 接続確認失敗 → リトライ継続
    }

    // 最大リトライ回数到達チェック
    if (currentCount >= _maxRetries) {
      _onMaxRetryReached();
    }
  }

  /// 最大リトライ回数到達時の処理
  void _onMaxRetryReached() {
    _retryTimer?.cancel();
    _retryTimer = null;
    state = state.copyWith(isRetrying: false, maxRetryReached: true);
  }

  /// リトライポーリングを開始する（外部から呼び出し可能）
  ///
  /// 切断されたストレージルートに対して 3 秒間隔で再接続を試行する。
  /// 最大 60 回（180 秒）まで。
  void startRetryPolling(StorageRoot root) {
    state = state.copyWith(
      disconnectedRoot: root,
      isBannerVisible: true,
      isRetrying: true,
      retryCount: 0,
      maxRetryReached: false,
    );
    _startRetryTimer(root);
  }

  /// リトライポーリングを停止する
  void stopRetryPolling() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  /// バナーを非表示にする（「×」ボタン押下時）
  void dismissBanner() {
    state = state.copyWith(isBannerVisible: false);
  }

  /// OS 既定の画像フォルダを検出する
  ///
  /// - Android: DCIM/Camera フォルダ
  /// - Windows: ユーザーのピクチャフォルダ
  ///
  /// StorageRepository.getDefaultImageFolder() に委譲し、
  /// 3 秒タイムアウトを適用する。
  /// 検出失敗時・タイムアウト時は null を返す。
  Future<FolderEntry?> detectDefaultFolder() async {
    try {
      final repo = ref.read(storageRepositoryProvider);
      // 3 秒タイムアウト付きで既定フォルダを検出
      final result = await Future.any<FolderEntry?>([
        repo.getDefaultImageFolder(),
        Future<FolderEntry?>.delayed(const Duration(seconds: 3), () => null),
      ]);
      return result;
    } catch (_) {
      return null;
    }
  }
}
