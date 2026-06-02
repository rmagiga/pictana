// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'collection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Collection {

/// コレクション ID（自動採番）
 int get id;/// コレクション名（バリデーション済み値オブジェクト）
 CollectionName get name;/// コレクション内の画像数（集計値）
 int get imageCount;/// 表示並び順（gap-based、間隔1000）
 int get sortOrder;/// 作成日時
 DateTime get createdAt;/// 更新日時
 DateTime get updatedAt;/// サムネイル用の先頭画像 EntryId（画像未登録時は null）
 String? get thumbnailEntryId;
/// Create a copy of Collection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CollectionCopyWith<Collection> get copyWith => _$CollectionCopyWithImpl<Collection>(this as Collection, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Collection&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.imageCount, imageCount) || other.imageCount == imageCount)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.thumbnailEntryId, thumbnailEntryId) || other.thumbnailEntryId == thumbnailEntryId));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,imageCount,sortOrder,createdAt,updatedAt,thumbnailEntryId);

@override
String toString() {
  return 'Collection(id: $id, name: $name, imageCount: $imageCount, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt, thumbnailEntryId: $thumbnailEntryId)';
}


}

/// @nodoc
abstract mixin class $CollectionCopyWith<$Res>  {
  factory $CollectionCopyWith(Collection value, $Res Function(Collection) _then) = _$CollectionCopyWithImpl;
@useResult
$Res call({
 int id, CollectionName name, int imageCount, int sortOrder, DateTime createdAt, DateTime updatedAt, String? thumbnailEntryId
});




}
/// @nodoc
class _$CollectionCopyWithImpl<$Res>
    implements $CollectionCopyWith<$Res> {
  _$CollectionCopyWithImpl(this._self, this._then);

  final Collection _self;
  final $Res Function(Collection) _then;

/// Create a copy of Collection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? imageCount = null,Object? sortOrder = null,Object? createdAt = null,Object? updatedAt = null,Object? thumbnailEntryId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as CollectionName,imageCount: null == imageCount ? _self.imageCount : imageCount // ignore: cast_nullable_to_non_nullable
as int,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,thumbnailEntryId: freezed == thumbnailEntryId ? _self.thumbnailEntryId : thumbnailEntryId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Collection].
extension CollectionPatterns on Collection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Collection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Collection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Collection value)  $default,){
final _that = this;
switch (_that) {
case _Collection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Collection value)?  $default,){
final _that = this;
switch (_that) {
case _Collection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  CollectionName name,  int imageCount,  int sortOrder,  DateTime createdAt,  DateTime updatedAt,  String? thumbnailEntryId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Collection() when $default != null:
return $default(_that.id,_that.name,_that.imageCount,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.thumbnailEntryId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  CollectionName name,  int imageCount,  int sortOrder,  DateTime createdAt,  DateTime updatedAt,  String? thumbnailEntryId)  $default,) {final _that = this;
switch (_that) {
case _Collection():
return $default(_that.id,_that.name,_that.imageCount,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.thumbnailEntryId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  CollectionName name,  int imageCount,  int sortOrder,  DateTime createdAt,  DateTime updatedAt,  String? thumbnailEntryId)?  $default,) {final _that = this;
switch (_that) {
case _Collection() when $default != null:
return $default(_that.id,_that.name,_that.imageCount,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.thumbnailEntryId);case _:
  return null;

}
}

}

/// @nodoc


class _Collection implements Collection {
  const _Collection({required this.id, required this.name, required this.imageCount, required this.sortOrder, required this.createdAt, required this.updatedAt, this.thumbnailEntryId});
  

/// コレクション ID（自動採番）
@override final  int id;
/// コレクション名（バリデーション済み値オブジェクト）
@override final  CollectionName name;
/// コレクション内の画像数（集計値）
@override final  int imageCount;
/// 表示並び順（gap-based、間隔1000）
@override final  int sortOrder;
/// 作成日時
@override final  DateTime createdAt;
/// 更新日時
@override final  DateTime updatedAt;
/// サムネイル用の先頭画像 EntryId（画像未登録時は null）
@override final  String? thumbnailEntryId;

/// Create a copy of Collection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CollectionCopyWith<_Collection> get copyWith => __$CollectionCopyWithImpl<_Collection>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Collection&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.imageCount, imageCount) || other.imageCount == imageCount)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.thumbnailEntryId, thumbnailEntryId) || other.thumbnailEntryId == thumbnailEntryId));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,imageCount,sortOrder,createdAt,updatedAt,thumbnailEntryId);

@override
String toString() {
  return 'Collection(id: $id, name: $name, imageCount: $imageCount, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt, thumbnailEntryId: $thumbnailEntryId)';
}


}

/// @nodoc
abstract mixin class _$CollectionCopyWith<$Res> implements $CollectionCopyWith<$Res> {
  factory _$CollectionCopyWith(_Collection value, $Res Function(_Collection) _then) = __$CollectionCopyWithImpl;
@override @useResult
$Res call({
 int id, CollectionName name, int imageCount, int sortOrder, DateTime createdAt, DateTime updatedAt, String? thumbnailEntryId
});




}
/// @nodoc
class __$CollectionCopyWithImpl<$Res>
    implements _$CollectionCopyWith<$Res> {
  __$CollectionCopyWithImpl(this._self, this._then);

  final _Collection _self;
  final $Res Function(_Collection) _then;

/// Create a copy of Collection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? imageCount = null,Object? sortOrder = null,Object? createdAt = null,Object? updatedAt = null,Object? thumbnailEntryId = freezed,}) {
  return _then(_Collection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as CollectionName,imageCount: null == imageCount ? _self.imageCount : imageCount // ignore: cast_nullable_to_non_nullable
as int,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,thumbnailEntryId: freezed == thumbnailEntryId ? _self.thumbnailEntryId : thumbnailEntryId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
