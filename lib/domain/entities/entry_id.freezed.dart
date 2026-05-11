// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entry_id.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EntryId {

/// 生の識別子文字列
/// Android: "content://media/external/images/media/1234"
/// Windows: "C:\\Users\\user\\Pictures\\photo.jpg"
 String get rawValue;/// プラットフォーム種別
 PlatformType get platformType;
/// Create a copy of EntryId
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntryIdCopyWith<EntryId> get copyWith => _$EntryIdCopyWithImpl<EntryId>(this as EntryId, _$identity);

  /// Serializes this EntryId to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EntryId&&(identical(other.rawValue, rawValue) || other.rawValue == rawValue)&&(identical(other.platformType, platformType) || other.platformType == platformType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rawValue,platformType);

@override
String toString() {
  return 'EntryId(rawValue: $rawValue, platformType: $platformType)';
}


}

/// @nodoc
abstract mixin class $EntryIdCopyWith<$Res>  {
  factory $EntryIdCopyWith(EntryId value, $Res Function(EntryId) _then) = _$EntryIdCopyWithImpl;
@useResult
$Res call({
 String rawValue, PlatformType platformType
});




}
/// @nodoc
class _$EntryIdCopyWithImpl<$Res>
    implements $EntryIdCopyWith<$Res> {
  _$EntryIdCopyWithImpl(this._self, this._then);

  final EntryId _self;
  final $Res Function(EntryId) _then;

/// Create a copy of EntryId
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rawValue = null,Object? platformType = null,}) {
  return _then(_self.copyWith(
rawValue: null == rawValue ? _self.rawValue : rawValue // ignore: cast_nullable_to_non_nullable
as String,platformType: null == platformType ? _self.platformType : platformType // ignore: cast_nullable_to_non_nullable
as PlatformType,
  ));
}

}


/// Adds pattern-matching-related methods to [EntryId].
extension EntryIdPatterns on EntryId {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EntryId value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EntryId() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EntryId value)  $default,){
final _that = this;
switch (_that) {
case _EntryId():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EntryId value)?  $default,){
final _that = this;
switch (_that) {
case _EntryId() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String rawValue,  PlatformType platformType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EntryId() when $default != null:
return $default(_that.rawValue,_that.platformType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String rawValue,  PlatformType platformType)  $default,) {final _that = this;
switch (_that) {
case _EntryId():
return $default(_that.rawValue,_that.platformType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String rawValue,  PlatformType platformType)?  $default,) {final _that = this;
switch (_that) {
case _EntryId() when $default != null:
return $default(_that.rawValue,_that.platformType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EntryId extends EntryId {
  const _EntryId({required this.rawValue, required this.platformType}): super._();
  factory _EntryId.fromJson(Map<String, dynamic> json) => _$EntryIdFromJson(json);

/// 生の識別子文字列
/// Android: "content://media/external/images/media/1234"
/// Windows: "C:\\Users\\user\\Pictures\\photo.jpg"
@override final  String rawValue;
/// プラットフォーム種別
@override final  PlatformType platformType;

/// Create a copy of EntryId
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntryIdCopyWith<_EntryId> get copyWith => __$EntryIdCopyWithImpl<_EntryId>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EntryIdToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EntryId&&(identical(other.rawValue, rawValue) || other.rawValue == rawValue)&&(identical(other.platformType, platformType) || other.platformType == platformType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rawValue,platformType);

@override
String toString() {
  return 'EntryId(rawValue: $rawValue, platformType: $platformType)';
}


}

/// @nodoc
abstract mixin class _$EntryIdCopyWith<$Res> implements $EntryIdCopyWith<$Res> {
  factory _$EntryIdCopyWith(_EntryId value, $Res Function(_EntryId) _then) = __$EntryIdCopyWithImpl;
@override @useResult
$Res call({
 String rawValue, PlatformType platformType
});




}
/// @nodoc
class __$EntryIdCopyWithImpl<$Res>
    implements _$EntryIdCopyWith<$Res> {
  __$EntryIdCopyWithImpl(this._self, this._then);

  final _EntryId _self;
  final $Res Function(_EntryId) _then;

/// Create a copy of EntryId
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rawValue = null,Object? platformType = null,}) {
  return _then(_EntryId(
rawValue: null == rawValue ? _self.rawValue : rawValue // ignore: cast_nullable_to_non_nullable
as String,platformType: null == platformType ? _self.platformType : platformType // ignore: cast_nullable_to_non_nullable
as PlatformType,
  ));
}


}

// dart format on
