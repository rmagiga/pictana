// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'folder_viewer_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FolderViewerSettings {

/// 対象フォルダのURI
 String get folderUri;/// 表示モード (single, double, scroll)
 ViewerDisplayMode get displayMode;/// 右開き (RTL) かどうか
 bool get isRightToLeft;/// 最初のページを表紙（単一）として扱うか
 bool get hasCoverPage;
/// Create a copy of FolderViewerSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FolderViewerSettingsCopyWith<FolderViewerSettings> get copyWith => _$FolderViewerSettingsCopyWithImpl<FolderViewerSettings>(this as FolderViewerSettings, _$identity);

  /// Serializes this FolderViewerSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FolderViewerSettings&&(identical(other.folderUri, folderUri) || other.folderUri == folderUri)&&(identical(other.displayMode, displayMode) || other.displayMode == displayMode)&&(identical(other.isRightToLeft, isRightToLeft) || other.isRightToLeft == isRightToLeft)&&(identical(other.hasCoverPage, hasCoverPage) || other.hasCoverPage == hasCoverPage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,folderUri,displayMode,isRightToLeft,hasCoverPage);

@override
String toString() {
  return 'FolderViewerSettings(folderUri: $folderUri, displayMode: $displayMode, isRightToLeft: $isRightToLeft, hasCoverPage: $hasCoverPage)';
}


}

/// @nodoc
abstract mixin class $FolderViewerSettingsCopyWith<$Res>  {
  factory $FolderViewerSettingsCopyWith(FolderViewerSettings value, $Res Function(FolderViewerSettings) _then) = _$FolderViewerSettingsCopyWithImpl;
@useResult
$Res call({
 String folderUri, ViewerDisplayMode displayMode, bool isRightToLeft, bool hasCoverPage
});




}
/// @nodoc
class _$FolderViewerSettingsCopyWithImpl<$Res>
    implements $FolderViewerSettingsCopyWith<$Res> {
  _$FolderViewerSettingsCopyWithImpl(this._self, this._then);

  final FolderViewerSettings _self;
  final $Res Function(FolderViewerSettings) _then;

/// Create a copy of FolderViewerSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? folderUri = null,Object? displayMode = null,Object? isRightToLeft = null,Object? hasCoverPage = null,}) {
  return _then(_self.copyWith(
folderUri: null == folderUri ? _self.folderUri : folderUri // ignore: cast_nullable_to_non_nullable
as String,displayMode: null == displayMode ? _self.displayMode : displayMode // ignore: cast_nullable_to_non_nullable
as ViewerDisplayMode,isRightToLeft: null == isRightToLeft ? _self.isRightToLeft : isRightToLeft // ignore: cast_nullable_to_non_nullable
as bool,hasCoverPage: null == hasCoverPage ? _self.hasCoverPage : hasCoverPage // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FolderViewerSettings].
extension FolderViewerSettingsPatterns on FolderViewerSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FolderViewerSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FolderViewerSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FolderViewerSettings value)  $default,){
final _that = this;
switch (_that) {
case _FolderViewerSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FolderViewerSettings value)?  $default,){
final _that = this;
switch (_that) {
case _FolderViewerSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String folderUri,  ViewerDisplayMode displayMode,  bool isRightToLeft,  bool hasCoverPage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FolderViewerSettings() when $default != null:
return $default(_that.folderUri,_that.displayMode,_that.isRightToLeft,_that.hasCoverPage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String folderUri,  ViewerDisplayMode displayMode,  bool isRightToLeft,  bool hasCoverPage)  $default,) {final _that = this;
switch (_that) {
case _FolderViewerSettings():
return $default(_that.folderUri,_that.displayMode,_that.isRightToLeft,_that.hasCoverPage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String folderUri,  ViewerDisplayMode displayMode,  bool isRightToLeft,  bool hasCoverPage)?  $default,) {final _that = this;
switch (_that) {
case _FolderViewerSettings() when $default != null:
return $default(_that.folderUri,_that.displayMode,_that.isRightToLeft,_that.hasCoverPage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FolderViewerSettings implements FolderViewerSettings {
  const _FolderViewerSettings({required this.folderUri, this.displayMode = ViewerDisplayMode.single, this.isRightToLeft = true, this.hasCoverPage = true});
  factory _FolderViewerSettings.fromJson(Map<String, dynamic> json) => _$FolderViewerSettingsFromJson(json);

/// 対象フォルダのURI
@override final  String folderUri;
/// 表示モード (single, double, scroll)
@override@JsonKey() final  ViewerDisplayMode displayMode;
/// 右開き (RTL) かどうか
@override@JsonKey() final  bool isRightToLeft;
/// 最初のページを表紙（単一）として扱うか
@override@JsonKey() final  bool hasCoverPage;

/// Create a copy of FolderViewerSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FolderViewerSettingsCopyWith<_FolderViewerSettings> get copyWith => __$FolderViewerSettingsCopyWithImpl<_FolderViewerSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FolderViewerSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FolderViewerSettings&&(identical(other.folderUri, folderUri) || other.folderUri == folderUri)&&(identical(other.displayMode, displayMode) || other.displayMode == displayMode)&&(identical(other.isRightToLeft, isRightToLeft) || other.isRightToLeft == isRightToLeft)&&(identical(other.hasCoverPage, hasCoverPage) || other.hasCoverPage == hasCoverPage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,folderUri,displayMode,isRightToLeft,hasCoverPage);

@override
String toString() {
  return 'FolderViewerSettings(folderUri: $folderUri, displayMode: $displayMode, isRightToLeft: $isRightToLeft, hasCoverPage: $hasCoverPage)';
}


}

/// @nodoc
abstract mixin class _$FolderViewerSettingsCopyWith<$Res> implements $FolderViewerSettingsCopyWith<$Res> {
  factory _$FolderViewerSettingsCopyWith(_FolderViewerSettings value, $Res Function(_FolderViewerSettings) _then) = __$FolderViewerSettingsCopyWithImpl;
@override @useResult
$Res call({
 String folderUri, ViewerDisplayMode displayMode, bool isRightToLeft, bool hasCoverPage
});




}
/// @nodoc
class __$FolderViewerSettingsCopyWithImpl<$Res>
    implements _$FolderViewerSettingsCopyWith<$Res> {
  __$FolderViewerSettingsCopyWithImpl(this._self, this._then);

  final _FolderViewerSettings _self;
  final $Res Function(_FolderViewerSettings) _then;

/// Create a copy of FolderViewerSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? folderUri = null,Object? displayMode = null,Object? isRightToLeft = null,Object? hasCoverPage = null,}) {
  return _then(_FolderViewerSettings(
folderUri: null == folderUri ? _self.folderUri : folderUri // ignore: cast_nullable_to_non_nullable
as String,displayMode: null == displayMode ? _self.displayMode : displayMode // ignore: cast_nullable_to_non_nullable
as ViewerDisplayMode,isRightToLeft: null == isRightToLeft ? _self.isRightToLeft : isRightToLeft // ignore: cast_nullable_to_non_nullable
as bool,hasCoverPage: null == hasCoverPage ? _self.hasCoverPage : hasCoverPage // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
