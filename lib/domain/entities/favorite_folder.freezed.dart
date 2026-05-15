// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'favorite_folder.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FavoriteFolder {

/// 主キー（自動インクリメント）
 int get id;/// フォルダ URI（ユニーク制約）
 String get uri;/// フォルダ表示名
 String get name;/// お気に入り登録日時
 DateTime get registeredAt;
/// Create a copy of FavoriteFolder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FavoriteFolderCopyWith<FavoriteFolder> get copyWith => _$FavoriteFolderCopyWithImpl<FavoriteFolder>(this as FavoriteFolder, _$identity);

  /// Serializes this FavoriteFolder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FavoriteFolder&&(identical(other.id, id) || other.id == id)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.name, name) || other.name == name)&&(identical(other.registeredAt, registeredAt) || other.registeredAt == registeredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,uri,name,registeredAt);

@override
String toString() {
  return 'FavoriteFolder(id: $id, uri: $uri, name: $name, registeredAt: $registeredAt)';
}


}

/// @nodoc
abstract mixin class $FavoriteFolderCopyWith<$Res>  {
  factory $FavoriteFolderCopyWith(FavoriteFolder value, $Res Function(FavoriteFolder) _then) = _$FavoriteFolderCopyWithImpl;
@useResult
$Res call({
 int id, String uri, String name, DateTime registeredAt
});




}
/// @nodoc
class _$FavoriteFolderCopyWithImpl<$Res>
    implements $FavoriteFolderCopyWith<$Res> {
  _$FavoriteFolderCopyWithImpl(this._self, this._then);

  final FavoriteFolder _self;
  final $Res Function(FavoriteFolder) _then;

/// Create a copy of FavoriteFolder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? uri = null,Object? name = null,Object? registeredAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,registeredAt: null == registeredAt ? _self.registeredAt : registeredAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [FavoriteFolder].
extension FavoriteFolderPatterns on FavoriteFolder {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FavoriteFolder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FavoriteFolder() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FavoriteFolder value)  $default,){
final _that = this;
switch (_that) {
case _FavoriteFolder():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FavoriteFolder value)?  $default,){
final _that = this;
switch (_that) {
case _FavoriteFolder() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String uri,  String name,  DateTime registeredAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FavoriteFolder() when $default != null:
return $default(_that.id,_that.uri,_that.name,_that.registeredAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String uri,  String name,  DateTime registeredAt)  $default,) {final _that = this;
switch (_that) {
case _FavoriteFolder():
return $default(_that.id,_that.uri,_that.name,_that.registeredAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String uri,  String name,  DateTime registeredAt)?  $default,) {final _that = this;
switch (_that) {
case _FavoriteFolder() when $default != null:
return $default(_that.id,_that.uri,_that.name,_that.registeredAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FavoriteFolder implements FavoriteFolder {
  const _FavoriteFolder({required this.id, required this.uri, required this.name, required this.registeredAt});
  factory _FavoriteFolder.fromJson(Map<String, dynamic> json) => _$FavoriteFolderFromJson(json);

/// 主キー（自動インクリメント）
@override final  int id;
/// フォルダ URI（ユニーク制約）
@override final  String uri;
/// フォルダ表示名
@override final  String name;
/// お気に入り登録日時
@override final  DateTime registeredAt;

/// Create a copy of FavoriteFolder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FavoriteFolderCopyWith<_FavoriteFolder> get copyWith => __$FavoriteFolderCopyWithImpl<_FavoriteFolder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FavoriteFolderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FavoriteFolder&&(identical(other.id, id) || other.id == id)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.name, name) || other.name == name)&&(identical(other.registeredAt, registeredAt) || other.registeredAt == registeredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,uri,name,registeredAt);

@override
String toString() {
  return 'FavoriteFolder(id: $id, uri: $uri, name: $name, registeredAt: $registeredAt)';
}


}

/// @nodoc
abstract mixin class _$FavoriteFolderCopyWith<$Res> implements $FavoriteFolderCopyWith<$Res> {
  factory _$FavoriteFolderCopyWith(_FavoriteFolder value, $Res Function(_FavoriteFolder) _then) = __$FavoriteFolderCopyWithImpl;
@override @useResult
$Res call({
 int id, String uri, String name, DateTime registeredAt
});




}
/// @nodoc
class __$FavoriteFolderCopyWithImpl<$Res>
    implements _$FavoriteFolderCopyWith<$Res> {
  __$FavoriteFolderCopyWithImpl(this._self, this._then);

  final _FavoriteFolder _self;
  final $Res Function(_FavoriteFolder) _then;

/// Create a copy of FavoriteFolder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? uri = null,Object? name = null,Object? registeredAt = null,}) {
  return _then(_FavoriteFolder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,registeredAt: null == registeredAt ? _self.registeredAt : registeredAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
