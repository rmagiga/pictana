// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ImageEntry _$ImageEntryFromJson(Map<String, dynamic> json) => _ImageEntry(
  id: EntryId.fromJson(json['id'] as Map<String, dynamic>),
  name: json['name'] as String,
  extension: json['extension'] as String,
  width: (json['width'] as num?)?.toInt(),
  height: (json['height'] as num?)?.toInt(),
  size: (json['size'] as num).toInt(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  modifiedAt: DateTime.parse(json['modifiedAt'] as String),
  uri: json['uri'] as String,
  mimeType: $enumDecode(_$ImageMimeTypeEnumMap, json['mimeType']),
  exifRotation: (json['exifRotation'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ImageEntryToJson(_ImageEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'extension': instance.extension,
      'width': instance.width,
      'height': instance.height,
      'size': instance.size,
      'createdAt': instance.createdAt?.toIso8601String(),
      'modifiedAt': instance.modifiedAt.toIso8601String(),
      'uri': instance.uri,
      'mimeType': _$ImageMimeTypeEnumMap[instance.mimeType]!,
      'exifRotation': instance.exifRotation,
    };

const _$ImageMimeTypeEnumMap = {
  ImageMimeType.jpeg: 'jpeg',
  ImageMimeType.png: 'png',
  ImageMimeType.webp: 'webp',
  ImageMimeType.gif: 'gif',
  ImageMimeType.heic: 'heic',
  ImageMimeType.heif: 'heif',
  ImageMimeType.avif: 'avif',
  ImageMimeType.unknown: 'unknown',
};
