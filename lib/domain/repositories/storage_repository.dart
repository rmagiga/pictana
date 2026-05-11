/// StorageRepository Interface (設計書 §9.2)
///
/// 責務:
/// - ストレージ列挙
/// - フォルダ選択
/// - URI永続化
/// - 接続状態管理
/// - OS既定画像フォルダ検出
///
/// 実装はInfrastructure層（Android/Windows）が提供する。
/// Domain/Application層はこのInterfaceのみに依存する。
library;

import '../entities/folder_entry.dart';
import '../entities/storage_root.dart';

abstract interface class StorageRepository {
  /// 利用可能なストレージルートの一覧を返す。
  ///
  /// Android: 内部ストレージ + USB OTG
  /// Windows: ローカルドライブ + USB ドライブ
  Future<List<StorageRoot>> getStorageRoots();

  /// OS既定の画像フォルダを返す。
  ///
  /// Android: DCIM/Camera, Pictures 等
  /// Windows: ピクチャフォルダ (My Pictures)
  ///
  /// 検出できない場合は null を返す。
  Future<FolderEntry?> getDefaultImageFolder();

  /// 指定ストレージルート直下のフォルダ一覧を返す。
  Future<List<FolderEntry>> getFolders(StorageRoot root);

  /// 指定フォルダ配下のサブフォルダ一覧を返す。
  Future<List<FolderEntry>> getSubFolders(FolderEntry folder);

  /// フォルダ選択ダイアログを表示し、選択されたフォルダを返す。
  ///
  /// Android: SAF ドキュメントツリーピッカー
  /// Windows: OS標準フォルダ選択ダイアログ (file_picker)
  ///
  /// ユーザーがキャンセルした場合は null を返す。
  Future<FolderEntry?> selectFolder();

  /// Android SAF の永続URI権限を保持する。
  ///
  /// Android以外のプラットフォームでは何もしない。
  Future<void> persistUriPermission(String uri);

  /// ストレージの接続状態を監視するストリーム。
  ///
  /// StorageRoot のリストが変化するたびに emit する。
  /// USB切断/接続を検知する用途で使用する。
  Stream<List<StorageRoot>> watchStorageRoots();

  /// 最近開いたフォルダの一覧を返す（DB から取得）。
  Future<List<FolderEntry>> getRecentFolders();

  /// 最近開いたフォルダを記録する。
  Future<void> recordRecentFolder(FolderEntry folder);
}
