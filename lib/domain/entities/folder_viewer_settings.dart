import 'package:freezed_annotation/freezed_annotation.dart';
import '../value_objects/viewer_display_mode.dart';

part 'folder_viewer_settings.freezed.dart';
part 'folder_viewer_settings.g.dart';

@freezed
abstract class FolderViewerSettings with _$FolderViewerSettings {
  const factory FolderViewerSettings({
    /// 対象フォルダのURI
    required String folderUri,

    /// 表示モード (single, double, scroll)
    @Default(ViewerDisplayMode.single) ViewerDisplayMode displayMode,

    /// 右開き (RTL) かどうか
    @Default(true) bool isRightToLeft,

    /// 最初のページを表紙（単一）として扱うか
    @Default(true) bool hasCoverPage,
  }) = _FolderViewerSettings;

  factory FolderViewerSettings.fromJson(Map<String, dynamic> json) =>
      _$FolderViewerSettingsFromJson(json);
}
