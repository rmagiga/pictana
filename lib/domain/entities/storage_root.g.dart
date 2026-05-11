// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_root.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StorageRoot _$StorageRootFromJson(Map<String, dynamic> json) => _StorageRoot(
  id: EntryId.fromJson(json['id'] as Map<String, dynamic>),
  name: json['name'] as String,
  type: $enumDecode(_$StorageTypeEnumMap, json['type']),
  uri: json['uri'] as String,
  isConnected: json['isConnected'] as bool? ?? true,
);

Map<String, dynamic> _$StorageRootToJson(_StorageRoot instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$StorageTypeEnumMap[instance.type]!,
      'uri': instance.uri,
      'isConnected': instance.isConnected,
    };

const _$StorageTypeEnumMap = {
  StorageType.internal: 'internal',
  StorageType.usb: 'usb',
  StorageType.sdCard: 'sdCard',
};
