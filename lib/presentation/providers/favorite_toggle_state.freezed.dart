// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'favorite_toggle_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FavoriteToggleState {

/// 処理中フラグ（連続タップ防止）
 bool get isProcessing;/// 楽観的UI更新による表示状態（null の場合は実際のDB状態を使用）
 bool? get optimisticIsFavorite;/// 楽観的状態の対象フォルダ URI（どのフォルダに対する操作かを識別）
 String? get targetUri;/// エラーメッセージ
 String? get errorMessage;
/// Create a copy of FavoriteToggleState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FavoriteToggleStateCopyWith<FavoriteToggleState> get copyWith => _$FavoriteToggleStateCopyWithImpl<FavoriteToggleState>(this as FavoriteToggleState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FavoriteToggleState&&(identical(other.isProcessing, isProcessing) || other.isProcessing == isProcessing)&&(identical(other.optimisticIsFavorite, optimisticIsFavorite) || other.optimisticIsFavorite == optimisticIsFavorite)&&(identical(other.targetUri, targetUri) || other.targetUri == targetUri)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,isProcessing,optimisticIsFavorite,targetUri,errorMessage);

@override
String toString() {
  return 'FavoriteToggleState(isProcessing: $isProcessing, optimisticIsFavorite: $optimisticIsFavorite, targetUri: $targetUri, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $FavoriteToggleStateCopyWith<$Res>  {
  factory $FavoriteToggleStateCopyWith(FavoriteToggleState value, $Res Function(FavoriteToggleState) _then) = _$FavoriteToggleStateCopyWithImpl;
@useResult
$Res call({
 bool isProcessing, bool? optimisticIsFavorite, String? targetUri, String? errorMessage
});




}
/// @nodoc
class _$FavoriteToggleStateCopyWithImpl<$Res>
    implements $FavoriteToggleStateCopyWith<$Res> {
  _$FavoriteToggleStateCopyWithImpl(this._self, this._then);

  final FavoriteToggleState _self;
  final $Res Function(FavoriteToggleState) _then;

/// Create a copy of FavoriteToggleState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isProcessing = null,Object? optimisticIsFavorite = freezed,Object? targetUri = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
isProcessing: null == isProcessing ? _self.isProcessing : isProcessing // ignore: cast_nullable_to_non_nullable
as bool,optimisticIsFavorite: freezed == optimisticIsFavorite ? _self.optimisticIsFavorite : optimisticIsFavorite // ignore: cast_nullable_to_non_nullable
as bool?,targetUri: freezed == targetUri ? _self.targetUri : targetUri // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FavoriteToggleState].
extension FavoriteToggleStatePatterns on FavoriteToggleState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FavoriteToggleState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FavoriteToggleState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FavoriteToggleState value)  $default,){
final _that = this;
switch (_that) {
case _FavoriteToggleState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FavoriteToggleState value)?  $default,){
final _that = this;
switch (_that) {
case _FavoriteToggleState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isProcessing,  bool? optimisticIsFavorite,  String? targetUri,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FavoriteToggleState() when $default != null:
return $default(_that.isProcessing,_that.optimisticIsFavorite,_that.targetUri,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isProcessing,  bool? optimisticIsFavorite,  String? targetUri,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _FavoriteToggleState():
return $default(_that.isProcessing,_that.optimisticIsFavorite,_that.targetUri,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isProcessing,  bool? optimisticIsFavorite,  String? targetUri,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _FavoriteToggleState() when $default != null:
return $default(_that.isProcessing,_that.optimisticIsFavorite,_that.targetUri,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _FavoriteToggleState implements FavoriteToggleState {
  const _FavoriteToggleState({this.isProcessing = false, this.optimisticIsFavorite, this.targetUri, this.errorMessage});
  

/// 処理中フラグ（連続タップ防止）
@override@JsonKey() final  bool isProcessing;
/// 楽観的UI更新による表示状態（null の場合は実際のDB状態を使用）
@override final  bool? optimisticIsFavorite;
/// 楽観的状態の対象フォルダ URI（どのフォルダに対する操作かを識別）
@override final  String? targetUri;
/// エラーメッセージ
@override final  String? errorMessage;

/// Create a copy of FavoriteToggleState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FavoriteToggleStateCopyWith<_FavoriteToggleState> get copyWith => __$FavoriteToggleStateCopyWithImpl<_FavoriteToggleState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FavoriteToggleState&&(identical(other.isProcessing, isProcessing) || other.isProcessing == isProcessing)&&(identical(other.optimisticIsFavorite, optimisticIsFavorite) || other.optimisticIsFavorite == optimisticIsFavorite)&&(identical(other.targetUri, targetUri) || other.targetUri == targetUri)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,isProcessing,optimisticIsFavorite,targetUri,errorMessage);

@override
String toString() {
  return 'FavoriteToggleState(isProcessing: $isProcessing, optimisticIsFavorite: $optimisticIsFavorite, targetUri: $targetUri, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$FavoriteToggleStateCopyWith<$Res> implements $FavoriteToggleStateCopyWith<$Res> {
  factory _$FavoriteToggleStateCopyWith(_FavoriteToggleState value, $Res Function(_FavoriteToggleState) _then) = __$FavoriteToggleStateCopyWithImpl;
@override @useResult
$Res call({
 bool isProcessing, bool? optimisticIsFavorite, String? targetUri, String? errorMessage
});




}
/// @nodoc
class __$FavoriteToggleStateCopyWithImpl<$Res>
    implements _$FavoriteToggleStateCopyWith<$Res> {
  __$FavoriteToggleStateCopyWithImpl(this._self, this._then);

  final _FavoriteToggleState _self;
  final $Res Function(_FavoriteToggleState) _then;

/// Create a copy of FavoriteToggleState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isProcessing = null,Object? optimisticIsFavorite = freezed,Object? targetUri = freezed,Object? errorMessage = freezed,}) {
  return _then(_FavoriteToggleState(
isProcessing: null == isProcessing ? _self.isProcessing : isProcessing // ignore: cast_nullable_to_non_nullable
as bool,optimisticIsFavorite: freezed == optimisticIsFavorite ? _self.optimisticIsFavorite : optimisticIsFavorite // ignore: cast_nullable_to_non_nullable
as bool?,targetUri: freezed == targetUri ? _self.targetUri : targetUri // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
