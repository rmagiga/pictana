// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_viewer_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FolderViewerSettings _$FolderViewerSettingsFromJson(
  Map<String, dynamic> json,
) => _FolderViewerSettings(
  folderUri: json['folderUri'] as String,
  displayMode:
      $enumDecodeNullable(_$ViewerDisplayModeEnumMap, json['displayMode']) ??
      ViewerDisplayMode.single,
  isRightToLeft: json['isRightToLeft'] as bool? ?? true,
  hasCoverPage: json['hasCoverPage'] as bool? ?? true,
);

Map<String, dynamic> _$FolderViewerSettingsToJson(
  _FolderViewerSettings instance,
) => <String, dynamic>{
  'folderUri': instance.folderUri,
  'displayMode': _$ViewerDisplayModeEnumMap[instance.displayMode]!,
  'isRightToLeft': instance.isRightToLeft,
  'hasCoverPage': instance.hasCoverPage,
};

const _$ViewerDisplayModeEnumMap = {
  ViewerDisplayMode.single: 'single',
  ViewerDisplayMode.double: 'double',
  ViewerDisplayMode.scroll: 'scroll',
};
