/// URI パーミッション検証・管理クラス (設計書 §Permission_Manager)
///
/// アプリ起動時のパーミッション検証と、512 件上限に基づく
/// LRU 解放ロジックを提供する。
///
/// Requirements: 2.3, 2.4, 2.5, 2.6
library;

import '../../../core/logging/app_logger.dart';
import '../../database/app_database.dart';
import 'saf_platform_channel.dart';

/// URI パーミッションの永続化上限（Android 11+）
const int kMaxPersistedUriPermissions = 512;

/// URI とタイムスタンプのペア（LRU 解放判定用）
typedef UriTimestampEntry = ({String uri, DateTime lastOpenedAt});

/// LRU 解放対象の URI を特定する純粋関数
///
/// 与えられた URI + タイムスタンプのリストから、最も古い（lastOpenedAt が最小の）
/// URI を返す。リストが空の場合は null を返す。
///
/// Requirements: 2.6
String? selectUriToEvict(List<UriTimestampEntry> entries) {
  if (entries.isEmpty) return null;

  var oldest = entries.first;
  for (final entry in entries.skip(1)) {
    if (entry.lastOpenedAt.isBefore(oldest.lastOpenedAt)) {
      oldest = entry;
    }
  }
  return oldest.uri;
}

/// URI パーミッション検証・管理
///
/// 責務:
/// - アプリ起動時に DB 保存済み URI とシステム報告 URI の整合性を検証
/// - 無効な URI を DB から削除
/// - 512 件上限到達時に最古の URI を LRU 解放してから新規永続化
class UriPermissionManager {
  UriPermissionManager({
    required AppDatabase database,
    required SafPlatformChannel channel,
  }) : _db = database,
       _channel = channel;

  final AppDatabase _db;
  final SafPlatformChannel _channel;

  /// アプリ起動時のパーミッション検証
  ///
  /// システムが報告する永続化済み URI 一覧と DB に保存された URI を比較し、
  /// システム側に存在しない（＝無効化された）URI を DB から削除する。
  ///
  /// Requirements: 2.3, 2.4
  Future<void> validatePermissions() async {
    try {
      // システムから有効な永続化済み URI 一覧を取得
      final systemUris = await _channel.getPersistedUriPermissions();
      final systemUriSet = systemUris.toSet();

      // DB に保存された最近のフォルダ一覧を取得
      final dbFolders = await _db.getRecentFolders(limit: 1000);

      // Android プラットフォームの URI のみを対象にする
      final androidFolders = dbFolders.where(
        (f) => f.platformType == 'android',
      );

      // DB に保存されているがシステムに存在しない URI を特定して削除
      for (final folder in androidFolders) {
        if (!systemUriSet.contains(folder.uri)) {
          appLogger.i('無効な URI パーミッションを DB から削除: ${folder.uri}');
          await _db.deleteRecentFolderByUri(folder.uri);
        }
      }
    } catch (e) {
      appLogger.e('URI パーミッション検証に失敗', error: e);
      // 検証失敗はアプリ起動をブロックしない
    }
  }

  /// LRU 解放付き URI パーミッション永続化
  ///
  /// 永続化済み URI が 512 件上限に達している場合、
  /// 最古の URI（lastOpenedAt が最も古いもの）を解放してから
  /// 新しい URI を永続化する。
  ///
  /// Requirements: 2.5, 2.6
  Future<void> persistWithLruEviction(String uri) async {
    // 現在の永続化済み URI 数を確認
    final currentUris = await _channel.getPersistedUriPermissions();

    if (currentUris.length >= kMaxPersistedUriPermissions) {
      // 上限到達: 最古の URI を特定して解放
      await _evictOldestUri();
    }

    // 新しい URI を永続化
    await _channel.persistUriPermission(uri);
  }

  /// 最古の URI パーミッションを解放する
  ///
  /// DB の lastOpenedAt が最も古い Android URI を特定し、
  /// システムから解放した後 DB からも削除する。
  Future<void> _evictOldestUri() async {
    try {
      // DB から Android URI を lastOpenedAt 昇順（最古が先頭）で取得
      final dbFolders = await _db.getRecentFolders(limit: 1000);
      final androidFolders = dbFolders
          .where((f) => f.platformType == 'android')
          .toList();

      if (androidFolders.isEmpty) {
        appLogger.w('LRU 解放対象の URI が DB に見つかりません');
        return;
      }

      // lastOpenedAt が最も古いものを選択
      // getRecentFolders は最新順なので、末尾が最古
      final oldest = androidFolders.last;

      appLogger.i('LRU 解放: ${oldest.uri}');

      // システムからパーミッションを解放
      await _channel.releaseUriPermission(oldest.uri);

      // DB から削除
      await _db.deleteRecentFolderByUri(oldest.uri);
    } catch (e) {
      appLogger.e('LRU 解放に失敗', error: e);
      rethrow;
    }
  }
}
