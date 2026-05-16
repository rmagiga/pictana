// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'grid_column_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GridColumnSettings {

/// 最小列数（デフォルト: 3）
 int get minColumns;/// 最大列数（デフォルト: 12）
 int get maxColumns;
/// Create a copy of GridColumnSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GridColumnSettingsCopyWith<GridColumnSettings> get copyWith => _$GridColumnSettingsCopyWithImpl<GridColumnSettings>(this as GridColumnSettings, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GridColumnSettings&&(identical(other.minColumns, minColumns) || other.minColumns == minColumns)&&(identical(other.maxColumns, maxColumns) || other.maxColumns == maxColumns));
}


@override
int get hashCode => Object.hash(runtimeType,minColumns,maxColumns);

@override
String toString() {
  return 'GridColumnSettings(minColumns: $minColumns, maxColumns: $maxColumns)';
}


}

/// @nodoc
abstract mixin class $GridColumnSettingsCopyWith<$Res>  {
  factory $GridColumnSettingsCopyWith(GridColumnSettings value, $Res Function(GridColumnSettings) _then) = _$GridColumnSettingsCopyWithImpl;
@useResult
$Res call({
 int minColumns, int maxColumns
});




}
/// @nodoc
class _$GridColumnSettingsCopyWithImpl<$Res>
    implements $GridColumnSettingsCopyWith<$Res> {
  _$GridColumnSettingsCopyWithImpl(this._self, this._then);

  final GridColumnSettings _self;
  final $Res Function(GridColumnSettings) _then;

/// Create a copy of GridColumnSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? minColumns = null,Object? maxColumns = null,}) {
  return _then(_self.copyWith(
minColumns: null == minColumns ? _self.minColumns : minColumns // ignore: cast_nullable_to_non_nullable
as int,maxColumns: null == maxColumns ? _self.maxColumns : maxColumns // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GridColumnSettings].
extension GridColumnSettingsPatterns on GridColumnSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GridColumnSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GridColumnSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GridColumnSettings value)  $default,){
final _that = this;
switch (_that) {
case _GridColumnSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GridColumnSettings value)?  $default,){
final _that = this;
switch (_that) {
case _GridColumnSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int minColumns,  int maxColumns)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GridColumnSettings() when $default != null:
return $default(_that.minColumns,_that.maxColumns);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int minColumns,  int maxColumns)  $default,) {final _that = this;
switch (_that) {
case _GridColumnSettings():
return $default(_that.minColumns,_that.maxColumns);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int minColumns,  int maxColumns)?  $default,) {final _that = this;
switch (_that) {
case _GridColumnSettings() when $default != null:
return $default(_that.minColumns,_that.maxColumns);case _:
  return null;

}
}

}

/// @nodoc


class _GridColumnSettings implements GridColumnSettings {
  const _GridColumnSettings({this.minColumns = 3, this.maxColumns = 12});
  

/// 最小列数（デフォルト: 3）
@override@JsonKey() final  int minColumns;
/// 最大列数（デフォルト: 12）
@override@JsonKey() final  int maxColumns;

/// Create a copy of GridColumnSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GridColumnSettingsCopyWith<_GridColumnSettings> get copyWith => __$GridColumnSettingsCopyWithImpl<_GridColumnSettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GridColumnSettings&&(identical(other.minColumns, minColumns) || other.minColumns == minColumns)&&(identical(other.maxColumns, maxColumns) || other.maxColumns == maxColumns));
}


@override
int get hashCode => Object.hash(runtimeType,minColumns,maxColumns);

@override
String toString() {
  return 'GridColumnSettings(minColumns: $minColumns, maxColumns: $maxColumns)';
}


}

/// @nodoc
abstract mixin class _$GridColumnSettingsCopyWith<$Res> implements $GridColumnSettingsCopyWith<$Res> {
  factory _$GridColumnSettingsCopyWith(_GridColumnSettings value, $Res Function(_GridColumnSettings) _then) = __$GridColumnSettingsCopyWithImpl;
@override @useResult
$Res call({
 int minColumns, int maxColumns
});




}
/// @nodoc
class __$GridColumnSettingsCopyWithImpl<$Res>
    implements _$GridColumnSettingsCopyWith<$Res> {
  __$GridColumnSettingsCopyWithImpl(this._self, this._then);

  final _GridColumnSettings _self;
  final $Res Function(_GridColumnSettings) _then;

/// Create a copy of GridColumnSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? minColumns = null,Object? maxColumns = null,}) {
  return _then(_GridColumnSettings(
minColumns: null == minColumns ? _self.minColumns : minColumns // ignore: cast_nullable_to_non_nullable
as int,maxColumns: null == maxColumns ? _self.maxColumns : maxColumns // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
