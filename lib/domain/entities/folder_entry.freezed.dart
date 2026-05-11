// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'folder_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FolderEntry {

/// プラットフォーム固有識別子
 EntryId get id;/// フォルダ名
 String get name;/// アクセス用 URI 文字列
 String get uri;/// フォルダ内画像枚数。未スキャン時は null。
 int? get imageCount;/// 親フォルダの EntryId。ルートの場合は null。
 EntryId? get parentId;
/// Create a copy of FolderEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FolderEntryCopyWith<FolderEntry> get copyWith => _$FolderEntryCopyWithImpl<FolderEntry>(this as FolderEntry, _$identity);

  /// Serializes this FolderEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FolderEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.imageCount, imageCount) || other.imageCount == imageCount)&&(identical(other.parentId, parentId) || other.parentId == parentId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,uri,imageCount,parentId);

@override
String toString() {
  return 'FolderEntry(id: $id, name: $name, uri: $uri, imageCount: $imageCount, parentId: $parentId)';
}


}

/// @nodoc
abstract mixin class $FolderEntryCopyWith<$Res>  {
  factory $FolderEntryCopyWith(FolderEntry value, $Res Function(FolderEntry) _then) = _$FolderEntryCopyWithImpl;
@useResult
$Res call({
 EntryId id, String name, String uri, int? imageCount, EntryId? parentId
});


$EntryIdCopyWith<$Res> get id;$EntryIdCopyWith<$Res>? get parentId;

}
/// @nodoc
class _$FolderEntryCopyWithImpl<$Res>
    implements $FolderEntryCopyWith<$Res> {
  _$FolderEntryCopyWithImpl(this._self, this._then);

  final FolderEntry _self;
  final $Res Function(FolderEntry) _then;

/// Create a copy of FolderEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? uri = null,Object? imageCount = freezed,Object? parentId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as EntryId,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,imageCount: freezed == imageCount ? _self.imageCount : imageCount // ignore: cast_nullable_to_non_nullable
as int?,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as EntryId?,
  ));
}
/// Create a copy of FolderEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EntryIdCopyWith<$Res> get id {
  
  return $EntryIdCopyWith<$Res>(_self.id, (value) {
    return _then(_self.copyWith(id: value));
  });
}/// Create a copy of FolderEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EntryIdCopyWith<$Res>? get parentId {
    if (_self.parentId == null) {
    return null;
  }

  return $EntryIdCopyWith<$Res>(_self.parentId!, (value) {
    return _then(_self.copyWith(parentId: value));
  });
}
}


/// Adds pattern-matching-related methods to [FolderEntry].
extension FolderEntryPatterns on FolderEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FolderEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FolderEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FolderEntry value)  $default,){
final _that = this;
switch (_that) {
case _FolderEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FolderEntry value)?  $default,){
final _that = this;
switch (_that) {
case _FolderEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( EntryId id,  String name,  String uri,  int? imageCount,  EntryId? parentId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FolderEntry() when $default != null:
return $default(_that.id,_that.name,_that.uri,_that.imageCount,_that.parentId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( EntryId id,  String name,  String uri,  int? imageCount,  EntryId? parentId)  $default,) {final _that = this;
switch (_that) {
case _FolderEntry():
return $default(_that.id,_that.name,_that.uri,_that.imageCount,_that.parentId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( EntryId id,  String name,  String uri,  int? imageCount,  EntryId? parentId)?  $default,) {final _that = this;
switch (_that) {
case _FolderEntry() when $default != null:
return $default(_that.id,_that.name,_that.uri,_that.imageCount,_that.parentId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FolderEntry extends FolderEntry {
  const _FolderEntry({required this.id, required this.name, required this.uri, this.imageCount, this.parentId}): super._();
  factory _FolderEntry.fromJson(Map<String, dynamic> json) => _$FolderEntryFromJson(json);

/// プラットフォーム固有識別子
@override final  EntryId id;
/// フォルダ名
@override final  String name;
/// アクセス用 URI 文字列
@override final  String uri;
/// フォルダ内画像枚数。未スキャン時は null。
@override final  int? imageCount;
/// 親フォルダの EntryId。ルートの場合は null。
@override final  EntryId? parentId;

/// Create a copy of FolderEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FolderEntryCopyWith<_FolderEntry> get copyWith => __$FolderEntryCopyWithImpl<_FolderEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FolderEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FolderEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.imageCount, imageCount) || other.imageCount == imageCount)&&(identical(other.parentId, parentId) || other.parentId == parentId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,uri,imageCount,parentId);

@override
String toString() {
  return 'FolderEntry(id: $id, name: $name, uri: $uri, imageCount: $imageCount, parentId: $parentId)';
}


}

/// @nodoc
abstract mixin class _$FolderEntryCopyWith<$Res> implements $FolderEntryCopyWith<$Res> {
  factory _$FolderEntryCopyWith(_FolderEntry value, $Res Function(_FolderEntry) _then) = __$FolderEntryCopyWithImpl;
@override @useResult
$Res call({
 EntryId id, String name, String uri, int? imageCount, EntryId? parentId
});


@override $EntryIdCopyWith<$Res> get id;@override $EntryIdCopyWith<$Res>? get parentId;

}
/// @nodoc
class __$FolderEntryCopyWithImpl<$Res>
    implements _$FolderEntryCopyWith<$Res> {
  __$FolderEntryCopyWithImpl(this._self, this._then);

  final _FolderEntry _self;
  final $Res Function(_FolderEntry) _then;

/// Create a copy of FolderEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? uri = null,Object? imageCount = freezed,Object? parentId = freezed,}) {
  return _then(_FolderEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as EntryId,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,imageCount: freezed == imageCount ? _self.imageCount : imageCount // ignore: cast_nullable_to_non_nullable
as int?,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as EntryId?,
  ));
}

/// Create a copy of FolderEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EntryIdCopyWith<$Res> get id {
  
  return $EntryIdCopyWith<$Res>(_self.id, (value) {
    return _then(_self.copyWith(id: value));
  });
}/// Create a copy of FolderEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EntryIdCopyWith<$Res>? get parentId {
    if (_self.parentId == null) {
    return null;
  }

  return $EntryIdCopyWith<$Res>(_self.parentId!, (value) {
    return _then(_self.copyWith(parentId: value));
  });
}
}

// dart format on
