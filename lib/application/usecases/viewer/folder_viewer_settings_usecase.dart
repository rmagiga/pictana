import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/folder_viewer_settings.dart';
import '../../providers/repository_providers.dart';

part 'folder_viewer_settings_usecase.g.dart';

@riverpod
class GetFolderViewerSettingsUseCase extends _$GetFolderViewerSettingsUseCase {
  @override
  GetFolderViewerSettingsUseCase build() {
    return this;
  }

  Future<FolderViewerSettings> execute(String folderUri) async {
    final repository = ref.read(folderViewerSettingsRepositoryProvider);
    final settings = await repository.getSettings(folderUri);
    if (settings != null) return settings;

    // デフォルトの設定を返す
    return FolderViewerSettings(folderUri: folderUri);
  }
}

@riverpod
class SaveFolderViewerSettingsUseCase
    extends _$SaveFolderViewerSettingsUseCase {
  @override
  SaveFolderViewerSettingsUseCase build() {
    return this;
  }

  Future<void> execute(FolderViewerSettings settings) async {
    final repository = ref.read(folderViewerSettingsRepositoryProvider);
    await repository.saveSettings(settings);
  }
}
