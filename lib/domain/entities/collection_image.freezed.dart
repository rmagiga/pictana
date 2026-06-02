// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'collection_image.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CollectionImage {

/// コレクション画像 ID（自動採番）
 int get id;/// 所属コレクション ID
 int get collectionId;/// 画像の識別子（プラットフォーム差異を抽象化）
 EntryId get entryId;/// 表示並び順（gap-based、間隔1000）
 int get sortOrder;/// コレクションへの追加日時
 DateTime get addedAt;
/// Create a copy of CollectionImage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CollectionImageCopyWith<CollectionImage> get copyWith => _$CollectionImageCopyWithImpl<CollectionImage>(this as CollectionImage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CollectionImage&&(identical(other.id, id) || other.id == id)&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId)&&(identical(other.entryId, entryId) || other.entryId == entryId)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,collectionId,entryId,sortOrder,addedAt);

@override
String toString() {
  return 'CollectionImage(id: $id, collectionId: $collectionId, entryId: $entryId, sortOrder: $sortOrder, addedAt: $addedAt)';
}


}

/// @nodoc
abstract mixin class $CollectionImageCopyWith<$Res>  {
  factory $CollectionImageCopyWith(CollectionImage value, $Res Function(CollectionImage) _then) = _$CollectionImageCopyWithImpl;
@useResult
$Res call({
 int id, int collectionId, EntryId entryId, int sortOrder, DateTime addedAt
});


$EntryIdCopyWith<$Res> get entryId;

}
/// @nodoc
class _$CollectionImageCopyWithImpl<$Res>
    implements $CollectionImageCopyWith<$Res> {
  _$CollectionImageCopyWithImpl(this._self, this._then);

  final CollectionImage _self;
  final $Res Function(CollectionImage) _then;

/// Create a copy of CollectionImage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? collectionId = null,Object? entryId = null,Object? sortOrder = null,Object? addedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as int,entryId: null == entryId ? _self.entryId : entryId // ignore: cast_nullable_to_non_nullable
as EntryId,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of CollectionImage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EntryIdCopyWith<$Res> get entryId {
  
  return $EntryIdCopyWith<$Res>(_self.entryId, (value) {
    return _then(_self.copyWith(entryId: value));
  });
}
}


/// Adds pattern-matching-related methods to [CollectionImage].
extension CollectionImagePatterns on CollectionImage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CollectionImage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CollectionImage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CollectionImage value)  $default,){
final _that = this;
switch (_that) {
case _CollectionImage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CollectionImage value)?  $default,){
final _that = this;
switch (_that) {
case _CollectionImage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int collectionId,  EntryId entryId,  int sortOrder,  DateTime addedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CollectionImage() when $default != null:
return $default(_that.id,_that.collectionId,_that.entryId,_that.sortOrder,_that.addedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int collectionId,  EntryId entryId,  int sortOrder,  DateTime addedAt)  $default,) {final _that = this;
switch (_that) {
case _CollectionImage():
return $default(_that.id,_that.collectionId,_that.entryId,_that.sortOrder,_that.addedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int collectionId,  EntryId entryId,  int sortOrder,  DateTime addedAt)?  $default,) {final _that = this;
switch (_that) {
case _CollectionImage() when $default != null:
return $default(_that.id,_that.collectionId,_that.entryId,_that.sortOrder,_that.addedAt);case _:
  return null;

}
}

}

/// @nodoc


class _CollectionImage implements CollectionImage {
  const _CollectionImage({required this.id, required this.collectionId, required this.entryId, required this.sortOrder, required this.addedAt});
  

/// コレクション画像 ID（自動採番）
@override final  int id;
/// 所属コレクション ID
@override final  int collectionId;
/// 画像の識別子（プラットフォーム差異を抽象化）
@override final  EntryId entryId;
/// 表示並び順（gap-based、間隔1000）
@override final  int sortOrder;
/// コレクションへの追加日時
@override final  DateTime addedAt;

/// Create a copy of CollectionImage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CollectionImageCopyWith<_CollectionImage> get copyWith => __$CollectionImageCopyWithImpl<_CollectionImage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CollectionImage&&(identical(other.id, id) || other.id == id)&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId)&&(identical(other.entryId, entryId) || other.entryId == entryId)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,collectionId,entryId,sortOrder,addedAt);

@override
String toString() {
  return 'CollectionImage(id: $id, collectionId: $collectionId, entryId: $entryId, sortOrder: $sortOrder, addedAt: $addedAt)';
}


}

/// @nodoc
abstract mixin class _$CollectionImageCopyWith<$Res> implements $CollectionImageCopyWith<$Res> {
  factory _$CollectionImageCopyWith(_CollectionImage value, $Res Function(_CollectionImage) _then) = __$CollectionImageCopyWithImpl;
@override @useResult
$Res call({
 int id, int collectionId, EntryId entryId, int sortOrder, DateTime addedAt
});


@override $EntryIdCopyWith<$Res> get entryId;

}
/// @nodoc
class __$CollectionImageCopyWithImpl<$Res>
    implements _$CollectionImageCopyWith<$Res> {
  __$CollectionImageCopyWithImpl(this._self, this._then);

  final _CollectionImage _self;
  final $Res Function(_CollectionImage) _then;

/// Create a copy of CollectionImage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? collectionId = null,Object? entryId = null,Object? sortOrder = null,Object? addedAt = null,}) {
  return _then(_CollectionImage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,collectionId: null == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as int,entryId: null == entryId ? _self.entryId : entryId // ignore: cast_nullable_to_non_nullable
as EntryId,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of CollectionImage
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EntryIdCopyWith<$Res> get entryId {
  
  return $EntryIdCopyWith<$Res>(_self.entryId, (value) {
    return _then(_self.copyWith(entryId: value));
  });
}
}

// dart format on
