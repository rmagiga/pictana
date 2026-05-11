// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'storage_root.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StorageRoot {

/// プラットフォーム固有識別子
 EntryId get id;/// 表示名（例: "DCIM", "Pictures", "D:\"）
 String get name;/// ストレージ種別
 StorageType get type;/// アクセス用 URI 文字列
 String get uri;/// 接続状態
 bool get isConnected;
/// Create a copy of StorageRoot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StorageRootCopyWith<StorageRoot> get copyWith => _$StorageRootCopyWithImpl<StorageRoot>(this as StorageRoot, _$identity);

  /// Serializes this StorageRoot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StorageRoot&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.isConnected, isConnected) || other.isConnected == isConnected));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,uri,isConnected);

@override
String toString() {
  return 'StorageRoot(id: $id, name: $name, type: $type, uri: $uri, isConnected: $isConnected)';
}


}

/// @nodoc
abstract mixin class $StorageRootCopyWith<$Res>  {
  factory $StorageRootCopyWith(StorageRoot value, $Res Function(StorageRoot) _then) = _$StorageRootCopyWithImpl;
@useResult
$Res call({
 EntryId id, String name, StorageType type, String uri, bool isConnected
});


$EntryIdCopyWith<$Res> get id;

}
/// @nodoc
class _$StorageRootCopyWithImpl<$Res>
    implements $StorageRootCopyWith<$Res> {
  _$StorageRootCopyWithImpl(this._self, this._then);

  final StorageRoot _self;
  final $Res Function(StorageRoot) _then;

/// Create a copy of StorageRoot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? uri = null,Object? isConnected = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as EntryId,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as StorageType,uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,isConnected: null == isConnected ? _self.isConnected : isConnected // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of StorageRoot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EntryIdCopyWith<$Res> get id {
  
  return $EntryIdCopyWith<$Res>(_self.id, (value) {
    return _then(_self.copyWith(id: value));
  });
}
}


/// Adds pattern-matching-related methods to [StorageRoot].
extension StorageRootPatterns on StorageRoot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StorageRoot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StorageRoot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StorageRoot value)  $default,){
final _that = this;
switch (_that) {
case _StorageRoot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StorageRoot value)?  $default,){
final _that = this;
switch (_that) {
case _StorageRoot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( EntryId id,  String name,  StorageType type,  String uri,  bool isConnected)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StorageRoot() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.uri,_that.isConnected);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( EntryId id,  String name,  StorageType type,  String uri,  bool isConnected)  $default,) {final _that = this;
switch (_that) {
case _StorageRoot():
return $default(_that.id,_that.name,_that.type,_that.uri,_that.isConnected);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( EntryId id,  String name,  StorageType type,  String uri,  bool isConnected)?  $default,) {final _that = this;
switch (_that) {
case _StorageRoot() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.uri,_that.isConnected);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StorageRoot extends StorageRoot {
  const _StorageRoot({required this.id, required this.name, required this.type, required this.uri, this.isConnected = true}): super._();
  factory _StorageRoot.fromJson(Map<String, dynamic> json) => _$StorageRootFromJson(json);

/// プラットフォーム固有識別子
@override final  EntryId id;
/// 表示名（例: "DCIM", "Pictures", "D:\"）
@override final  String name;
/// ストレージ種別
@override final  StorageType type;
/// アクセス用 URI 文字列
@override final  String uri;
/// 接続状態
@override@JsonKey() final  bool isConnected;

/// Create a copy of StorageRoot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StorageRootCopyWith<_StorageRoot> get copyWith => __$StorageRootCopyWithImpl<_StorageRoot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StorageRootToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StorageRoot&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.isConnected, isConnected) || other.isConnected == isConnected));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,uri,isConnected);

@override
String toString() {
  return 'StorageRoot(id: $id, name: $name, type: $type, uri: $uri, isConnected: $isConnected)';
}


}

/// @nodoc
abstract mixin class _$StorageRootCopyWith<$Res> implements $StorageRootCopyWith<$Res> {
  factory _$StorageRootCopyWith(_StorageRoot value, $Res Function(_StorageRoot) _then) = __$StorageRootCopyWithImpl;
@override @useResult
$Res call({
 EntryId id, String name, StorageType type, String uri, bool isConnected
});


@override $EntryIdCopyWith<$Res> get id;

}
/// @nodoc
class __$StorageRootCopyWithImpl<$Res>
    implements _$StorageRootCopyWith<$Res> {
  __$StorageRootCopyWithImpl(this._self, this._then);

  final _StorageRoot _self;
  final $Res Function(_StorageRoot) _then;

/// Create a copy of StorageRoot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? uri = null,Object? isConnected = null,}) {
  return _then(_StorageRoot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as EntryId,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as StorageType,uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,isConnected: null == isConnected ? _self.isConnected : isConnected // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of StorageRoot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EntryIdCopyWith<$Res> get id {
  
  return $EntryIdCopyWith<$Res>(_self.id, (value) {
    return _then(_self.copyWith(id: value));
  });
}
}

// dart format on
