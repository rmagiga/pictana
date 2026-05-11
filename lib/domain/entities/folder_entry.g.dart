// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FolderEntry _$FolderEntryFromJson(Map<String, dynamic> json) => _FolderEntry(
  id: EntryId.fromJson(json['id'] as Map<String, dynamic>),
  name: json['name'] as String,
  uri: json['uri'] as String,
  imageCount: (json['imageCount'] as num?)?.toInt(),
  parentId: json['parentId'] == null
      ? null
      : EntryId.fromJson(json['parentId'] as Map<String, dynamic>),
);

Map<String, dynamic> _$FolderEntryToJson(_FolderEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'uri': instance.uri,
      'imageCount': instance.imageCount,
      'parentId': instance.parentId,
    };
