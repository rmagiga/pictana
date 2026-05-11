// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry_id.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EntryId _$EntryIdFromJson(Map<String, dynamic> json) => _EntryId(
  rawValue: json['rawValue'] as String,
  platformType: $enumDecode(_$PlatformTypeEnumMap, json['platformType']),
);

Map<String, dynamic> _$EntryIdToJson(_EntryId instance) => <String, dynamic>{
  'rawValue': instance.rawValue,
  'platformType': _$PlatformTypeEnumMap[instance.platformType]!,
};

const _$PlatformTypeEnumMap = {
  PlatformType.android: 'android',
  PlatformType.windows: 'windows',
  PlatformType.unknown: 'unknown',
};
