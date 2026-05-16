// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'storage_monitor_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StorageMonitorState {

/// 切断されたストレージルート（null = 全接続中）
 StorageRoot? get disconnectedRoot;/// バナー表示中かどうか
 bool get isBannerVisible;/// リトライ中かどうか
 bool get isRetrying;/// リトライ回数
 int get retryCount;/// 最大リトライ到達
 bool get maxRetryReached;
/// Create a copy of StorageMonitorState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StorageMonitorStateCopyWith<StorageMonitorState> get copyWith => _$StorageMonitorStateCopyWithImpl<StorageMonitorState>(this as StorageMonitorState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StorageMonitorState&&(identical(other.disconnectedRoot, disconnectedRoot) || other.disconnectedRoot == disconnectedRoot)&&(identical(other.isBannerVisible, isBannerVisible) || other.isBannerVisible == isBannerVisible)&&(identical(other.isRetrying, isRetrying) || other.isRetrying == isRetrying)&&(identical(other.retryCount, retryCount) || other.retryCount == retryCount)&&(identical(other.maxRetryReached, maxRetryReached) || other.maxRetryReached == maxRetryReached));
}


@override
int get hashCode => Object.hash(runtimeType,disconnectedRoot,isBannerVisible,isRetrying,retryCount,maxRetryReached);

@override
String toString() {
  return 'StorageMonitorState(disconnectedRoot: $disconnectedRoot, isBannerVisible: $isBannerVisible, isRetrying: $isRetrying, retryCount: $retryCount, maxRetryReached: $maxRetryReached)';
}


}

/// @nodoc
abstract mixin class $StorageMonitorStateCopyWith<$Res>  {
  factory $StorageMonitorStateCopyWith(StorageMonitorState value, $Res Function(StorageMonitorState) _then) = _$StorageMonitorStateCopyWithImpl;
@useResult
$Res call({
 StorageRoot? disconnectedRoot, bool isBannerVisible, bool isRetrying, int retryCount, bool maxRetryReached
});


$StorageRootCopyWith<$Res>? get disconnectedRoot;

}
/// @nodoc
class _$StorageMonitorStateCopyWithImpl<$Res>
    implements $StorageMonitorStateCopyWith<$Res> {
  _$StorageMonitorStateCopyWithImpl(this._self, this._then);

  final StorageMonitorState _self;
  final $Res Function(StorageMonitorState) _then;

/// Create a copy of StorageMonitorState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? disconnectedRoot = freezed,Object? isBannerVisible = null,Object? isRetrying = null,Object? retryCount = null,Object? maxRetryReached = null,}) {
  return _then(_self.copyWith(
disconnectedRoot: freezed == disconnectedRoot ? _self.disconnectedRoot : disconnectedRoot // ignore: cast_nullable_to_non_nullable
as StorageRoot?,isBannerVisible: null == isBannerVisible ? _self.isBannerVisible : isBannerVisible // ignore: cast_nullable_to_non_nullable
as bool,isRetrying: null == isRetrying ? _self.isRetrying : isRetrying // ignore: cast_nullable_to_non_nullable
as bool,retryCount: null == retryCount ? _self.retryCount : retryCount // ignore: cast_nullable_to_non_nullable
as int,maxRetryReached: null == maxRetryReached ? _self.maxRetryReached : maxRetryReached // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of StorageMonitorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StorageRootCopyWith<$Res>? get disconnectedRoot {
    if (_self.disconnectedRoot == null) {
    return null;
  }

  return $StorageRootCopyWith<$Res>(_self.disconnectedRoot!, (value) {
    return _then(_self.copyWith(disconnectedRoot: value));
  });
}
}


/// Adds pattern-matching-related methods to [StorageMonitorState].
extension StorageMonitorStatePatterns on StorageMonitorState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StorageMonitorState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StorageMonitorState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StorageMonitorState value)  $default,){
final _that = this;
switch (_that) {
case _StorageMonitorState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StorageMonitorState value)?  $default,){
final _that = this;
switch (_that) {
case _StorageMonitorState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( StorageRoot? disconnectedRoot,  bool isBannerVisible,  bool isRetrying,  int retryCount,  bool maxRetryReached)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StorageMonitorState() when $default != null:
return $default(_that.disconnectedRoot,_that.isBannerVisible,_that.isRetrying,_that.retryCount,_that.maxRetryReached);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( StorageRoot? disconnectedRoot,  bool isBannerVisible,  bool isRetrying,  int retryCount,  bool maxRetryReached)  $default,) {final _that = this;
switch (_that) {
case _StorageMonitorState():
return $default(_that.disconnectedRoot,_that.isBannerVisible,_that.isRetrying,_that.retryCount,_that.maxRetryReached);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( StorageRoot? disconnectedRoot,  bool isBannerVisible,  bool isRetrying,  int retryCount,  bool maxRetryReached)?  $default,) {final _that = this;
switch (_that) {
case _StorageMonitorState() when $default != null:
return $default(_that.disconnectedRoot,_that.isBannerVisible,_that.isRetrying,_that.retryCount,_that.maxRetryReached);case _:
  return null;

}
}

}

/// @nodoc


class _StorageMonitorState implements StorageMonitorState {
  const _StorageMonitorState({this.disconnectedRoot, this.isBannerVisible = false, this.isRetrying = false, this.retryCount = 0, this.maxRetryReached = false});
  

/// 切断されたストレージルート（null = 全接続中）
@override final  StorageRoot? disconnectedRoot;
/// バナー表示中かどうか
@override@JsonKey() final  bool isBannerVisible;
/// リトライ中かどうか
@override@JsonKey() final  bool isRetrying;
/// リトライ回数
@override@JsonKey() final  int retryCount;
/// 最大リトライ到達
@override@JsonKey() final  bool maxRetryReached;

/// Create a copy of StorageMonitorState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StorageMonitorStateCopyWith<_StorageMonitorState> get copyWith => __$StorageMonitorStateCopyWithImpl<_StorageMonitorState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StorageMonitorState&&(identical(other.disconnectedRoot, disconnectedRoot) || other.disconnectedRoot == disconnectedRoot)&&(identical(other.isBannerVisible, isBannerVisible) || other.isBannerVisible == isBannerVisible)&&(identical(other.isRetrying, isRetrying) || other.isRetrying == isRetrying)&&(identical(other.retryCount, retryCount) || other.retryCount == retryCount)&&(identical(other.maxRetryReached, maxRetryReached) || other.maxRetryReached == maxRetryReached));
}


@override
int get hashCode => Object.hash(runtimeType,disconnectedRoot,isBannerVisible,isRetrying,retryCount,maxRetryReached);

@override
String toString() {
  return 'StorageMonitorState(disconnectedRoot: $disconnectedRoot, isBannerVisible: $isBannerVisible, isRetrying: $isRetrying, retryCount: $retryCount, maxRetryReached: $maxRetryReached)';
}


}

/// @nodoc
abstract mixin class _$StorageMonitorStateCopyWith<$Res> implements $StorageMonitorStateCopyWith<$Res> {
  factory _$StorageMonitorStateCopyWith(_StorageMonitorState value, $Res Function(_StorageMonitorState) _then) = __$StorageMonitorStateCopyWithImpl;
@override @useResult
$Res call({
 StorageRoot? disconnectedRoot, bool isBannerVisible, bool isRetrying, int retryCount, bool maxRetryReached
});


@override $StorageRootCopyWith<$Res>? get disconnectedRoot;

}
/// @nodoc
class __$StorageMonitorStateCopyWithImpl<$Res>
    implements _$StorageMonitorStateCopyWith<$Res> {
  __$StorageMonitorStateCopyWithImpl(this._self, this._then);

  final _StorageMonitorState _self;
  final $Res Function(_StorageMonitorState) _then;

/// Create a copy of StorageMonitorState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? disconnectedRoot = freezed,Object? isBannerVisible = null,Object? isRetrying = null,Object? retryCount = null,Object? maxRetryReached = null,}) {
  return _then(_StorageMonitorState(
disconnectedRoot: freezed == disconnectedRoot ? _self.disconnectedRoot : disconnectedRoot // ignore: cast_nullable_to_non_nullable
as StorageRoot?,isBannerVisible: null == isBannerVisible ? _self.isBannerVisible : isBannerVisible // ignore: cast_nullable_to_non_nullable
as bool,isRetrying: null == isRetrying ? _self.isRetrying : isRetrying // ignore: cast_nullable_to_non_nullable
as bool,retryCount: null == retryCount ? _self.retryCount : retryCount // ignore: cast_nullable_to_non_nullable
as int,maxRetryReached: null == maxRetryReached ? _self.maxRetryReached : maxRetryReached // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of StorageMonitorState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StorageRootCopyWith<$Res>? get disconnectedRoot {
    if (_self.disconnectedRoot == null) {
    return null;
  }

  return $StorageRootCopyWith<$Res>(_self.disconnectedRoot!, (value) {
    return _then(_self.copyWith(disconnectedRoot: value));
  });
}
}

// dart format on
