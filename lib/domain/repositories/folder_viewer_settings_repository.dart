import '../entities/folder_viewer_settings.dart';

/// フォルダごとの表示設定リポジトリインターフェース
abstract class FolderViewerSettingsRepository {
  /// 指定したフォルダの表示設定を取得する。設定が存在しない場合はnullを返す。
  Future<FolderViewerSettings?> getSettings(String folderUri);

  /// フォルダの表示設定を保存する。
  Future<void> saveSettings(FolderViewerSettings settings);
}
