// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_folder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FavoriteFolder _$FavoriteFolderFromJson(Map<String, dynamic> json) =>
    _FavoriteFolder(
      id: (json['id'] as num).toInt(),
      uri: json['uri'] as String,
      name: json['name'] as String,
      registeredAt: DateTime.parse(json['registeredAt'] as String),
    );

Map<String, dynamic> _$FavoriteFolderToJson(_FavoriteFolder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uri': instance.uri,
      'name': instance.name,
      'registeredAt': instance.registeredAt.toIso8601String(),
    };
