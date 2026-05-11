// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'image_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ImageEntry {

/// プラットフォーム固有識別子
 EntryId get id;/// ファイル名（拡張子あり）
 String get name;/// 拡張子（小文字、ドットなし）
 String get extension;/// 画像幅 (px)。未取得時は null。
 int? get width;/// 画像高さ (px)。未取得時は null。
 int? get height;/// ファイルサイズ (bytes)
 int get size;/// ファイル作成日時
 DateTime? get createdAt;/// ファイル更新日時
 DateTime get modifiedAt;/// アクセス用 URI 文字列
 String get uri;/// MIME type
 ImageMimeType get mimeType;/// EXIF 回転角度 (0, 90, 180, 270)
 int get exifRotation;
/// Create a copy of ImageEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageEntryCopyWith<ImageEntry> get copyWith => _$ImageEntryCopyWithImpl<ImageEntry>(this as ImageEntry, _$identity);

  /// Serializes this ImageEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.extension, extension) || other.extension == extension)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.size, size) || other.size == size)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.modifiedAt, modifiedAt) || other.modifiedAt == modifiedAt)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.exifRotation, exifRotation) || other.exifRotation == exifRotation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,extension,width,height,size,createdAt,modifiedAt,uri,mimeType,exifRotation);

@override
String toString() {
  return 'ImageEntry(id: $id, name: $name, extension: $extension, width: $width, height: $height, size: $size, createdAt: $createdAt, modifiedAt: $modifiedAt, uri: $uri, mimeType: $mimeType, exifRotation: $exifRotation)';
}


}

/// @nodoc
abstract mixin class $ImageEntryCopyWith<$Res>  {
  factory $ImageEntryCopyWith(ImageEntry value, $Res Function(ImageEntry) _then) = _$ImageEntryCopyWithImpl;
@useResult
$Res call({
 EntryId id, String name, String extension, int? width, int? height, int size, DateTime? createdAt, DateTime modifiedAt, String uri, ImageMimeType mimeType, int exifRotation
});


$EntryIdCopyWith<$Res> get id;

}
/// @nodoc
class _$ImageEntryCopyWithImpl<$Res>
    implements $ImageEntryCopyWith<$Res> {
  _$ImageEntryCopyWithImpl(this._self, this._then);

  final ImageEntry _self;
  final $Res Function(ImageEntry) _then;

/// Create a copy of ImageEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? extension = null,Object? width = freezed,Object? height = freezed,Object? size = null,Object? createdAt = freezed,Object? modifiedAt = null,Object? uri = null,Object? mimeType = null,Object? exifRotation = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as EntryId,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,extension: null == extension ? _self.extension : extension // ignore: cast_nullable_to_non_nullable
as String,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,modifiedAt: null == modifiedAt ? _self.modifiedAt : modifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime,uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as ImageMimeType,exifRotation: null == exifRotation ? _self.exifRotation : exifRotation // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of ImageEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EntryIdCopyWith<$Res> get id {
  
  return $EntryIdCopyWith<$Res>(_self.id, (value) {
    return _then(_self.copyWith(id: value));
  });
}
}


/// Adds pattern-matching-related methods to [ImageEntry].
extension ImageEntryPatterns on ImageEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImageEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImageEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImageEntry value)  $default,){
final _that = this;
switch (_that) {
case _ImageEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImageEntry value)?  $default,){
final _that = this;
switch (_that) {
case _ImageEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( EntryId id,  String name,  String extension,  int? width,  int? height,  int size,  DateTime? createdAt,  DateTime modifiedAt,  String uri,  ImageMimeType mimeType,  int exifRotation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImageEntry() when $default != null:
return $default(_that.id,_that.name,_that.extension,_that.width,_that.height,_that.size,_that.createdAt,_that.modifiedAt,_that.uri,_that.mimeType,_that.exifRotation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( EntryId id,  String name,  String extension,  int? width,  int? height,  int size,  DateTime? createdAt,  DateTime modifiedAt,  String uri,  ImageMimeType mimeType,  int exifRotation)  $default,) {final _that = this;
switch (_that) {
case _ImageEntry():
return $default(_that.id,_that.name,_that.extension,_that.width,_that.height,_that.size,_that.createdAt,_that.modifiedAt,_that.uri,_that.mimeType,_that.exifRotation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( EntryId id,  String name,  String extension,  int? width,  int? height,  int size,  DateTime? createdAt,  DateTime modifiedAt,  String uri,  ImageMimeType mimeType,  int exifRotation)?  $default,) {final _that = this;
switch (_that) {
case _ImageEntry() when $default != null:
return $default(_that.id,_that.name,_that.extension,_that.width,_that.height,_that.size,_that.createdAt,_that.modifiedAt,_that.uri,_that.mimeType,_that.exifRotation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImageEntry extends ImageEntry {
  const _ImageEntry({required this.id, required this.name, required this.extension, this.width, this.height, required this.size, this.createdAt, required this.modifiedAt, required this.uri, required this.mimeType, this.exifRotation = 0}): super._();
  factory _ImageEntry.fromJson(Map<String, dynamic> json) => _$ImageEntryFromJson(json);

/// プラットフォーム固有識別子
@override final  EntryId id;
/// ファイル名（拡張子あり）
@override final  String name;
/// 拡張子（小文字、ドットなし）
@override final  String extension;
/// 画像幅 (px)。未取得時は null。
@override final  int? width;
/// 画像高さ (px)。未取得時は null。
@override final  int? height;
/// ファイルサイズ (bytes)
@override final  int size;
/// ファイル作成日時
@override final  DateTime? createdAt;
/// ファイル更新日時
@override final  DateTime modifiedAt;
/// アクセス用 URI 文字列
@override final  String uri;
/// MIME type
@override final  ImageMimeType mimeType;
/// EXIF 回転角度 (0, 90, 180, 270)
@override@JsonKey() final  int exifRotation;

/// Create a copy of ImageEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImageEntryCopyWith<_ImageEntry> get copyWith => __$ImageEntryCopyWithImpl<_ImageEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImageEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImageEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.extension, extension) || other.extension == extension)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.size, size) || other.size == size)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.modifiedAt, modifiedAt) || other.modifiedAt == modifiedAt)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.exifRotation, exifRotation) || other.exifRotation == exifRotation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,extension,width,height,size,createdAt,modifiedAt,uri,mimeType,exifRotation);

@override
String toString() {
  return 'ImageEntry(id: $id, name: $name, extension: $extension, width: $width, height: $height, size: $size, createdAt: $createdAt, modifiedAt: $modifiedAt, uri: $uri, mimeType: $mimeType, exifRotation: $exifRotation)';
}


}

/// @nodoc
abstract mixin class _$ImageEntryCopyWith<$Res> implements $ImageEntryCopyWith<$Res> {
  factory _$ImageEntryCopyWith(_ImageEntry value, $Res Function(_ImageEntry) _then) = __$ImageEntryCopyWithImpl;
@override @useResult
$Res call({
 EntryId id, String name, String extension, int? width, int? height, int size, DateTime? createdAt, DateTime modifiedAt, String uri, ImageMimeType mimeType, int exifRotation
});


@override $EntryIdCopyWith<$Res> get id;

}
/// @nodoc
class __$ImageEntryCopyWithImpl<$Res>
    implements _$ImageEntryCopyWith<$Res> {
  __$ImageEntryCopyWithImpl(this._self, this._then);

  final _ImageEntry _self;
  final $Res Function(_ImageEntry) _then;

/// Create a copy of ImageEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? extension = null,Object? width = freezed,Object? height = freezed,Object? size = null,Object? createdAt = freezed,Object? modifiedAt = null,Object? uri = null,Object? mimeType = null,Object? exifRotation = null,}) {
  return _then(_ImageEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as EntryId,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,extension: null == extension ? _self.extension : extension // ignore: cast_nullable_to_non_nullable
as String,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,modifiedAt: null == modifiedAt ? _self.modifiedAt : modifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime,uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as ImageMimeType,exifRotation: null == exifRotation ? _self.exifRotation : exifRotation // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of ImageEntry
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
