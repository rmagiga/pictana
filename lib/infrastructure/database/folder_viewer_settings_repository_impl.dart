import '../../domain/entities/folder_viewer_settings.dart';
import '../../domain/repositories/folder_viewer_settings_repository.dart';
import '../../domain/value_objects/viewer_display_mode.dart';
import 'app_database.dart';

/// FolderViewerSettingsRepository の Drift データベースによる実装
class FolderViewerSettingsRepositoryImpl implements FolderViewerSettingsRepository {
  FolderViewerSettingsRepositoryImpl({required AppDatabase database}) : _db = database;

  final AppDatabase _db;

  @override
  Future<FolderViewerSettings?> getSettings(String folderUri) async {
    final row = await _db.getFolderViewerSetting(folderUri);
    if (row == null) return null;

    return FolderViewerSettings(
      folderUri: row.folderUri,
      displayMode: _parseDisplayMode(row.displayMode),
      isRightToLeft: row.isRightToLeft,
      hasCoverPage: row.hasCoverPage,
    );
  }

  @override
  Future<void> saveSettings(FolderViewerSettings settings) async {
    await _db.upsertFolderViewerSetting(
      folderUri: settings.folderUri,
      displayMode: settings.displayMode.name,
      isRightToLeft: settings.isRightToLeft,
      hasCoverPage: settings.hasCoverPage,
    );
  }

  ViewerDisplayMode _parseDisplayMode(String value) {
    try {
      return ViewerDisplayMode.values.byName(value);
    } catch (_) {
      return ViewerDisplayMode.single;
    }
  }
}
