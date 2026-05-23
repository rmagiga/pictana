// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_filter_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchFilterState {

/// 検索クエリ（空文字 = フィルターなし）
 String get query;/// 選択中の MIME type フィルター（null = 全て）
 ImageMimeType? get selectedMimeType;/// 検索バー展開状態
 bool get isSearchBarExpanded;/// 検索中フラグ（サムネイルリクエストの抑制用）
 bool get isSearching;
/// Create a copy of SearchFilterState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchFilterStateCopyWith<SearchFilterState> get copyWith => _$SearchFilterStateCopyWithImpl<SearchFilterState>(this as SearchFilterState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchFilterState&&(identical(other.query, query) || other.query == query)&&(identical(other.selectedMimeType, selectedMimeType) || other.selectedMimeType == selectedMimeType)&&(identical(other.isSearchBarExpanded, isSearchBarExpanded) || other.isSearchBarExpanded == isSearchBarExpanded)&&(identical(other.isSearching, isSearching) || other.isSearching == isSearching));
}


@override
int get hashCode => Object.hash(runtimeType,query,selectedMimeType,isSearchBarExpanded,isSearching);

@override
String toString() {
  return 'SearchFilterState(query: $query, selectedMimeType: $selectedMimeType, isSearchBarExpanded: $isSearchBarExpanded, isSearching: $isSearching)';
}


}

/// @nodoc
abstract mixin class $SearchFilterStateCopyWith<$Res>  {
  factory $SearchFilterStateCopyWith(SearchFilterState value, $Res Function(SearchFilterState) _then) = _$SearchFilterStateCopyWithImpl;
@useResult
$Res call({
 String query, ImageMimeType? selectedMimeType, bool isSearchBarExpanded, bool isSearching
});




}
/// @nodoc
class _$SearchFilterStateCopyWithImpl<$Res>
    implements $SearchFilterStateCopyWith<$Res> {
  _$SearchFilterStateCopyWithImpl(this._self, this._then);

  final SearchFilterState _self;
  final $Res Function(SearchFilterState) _then;

/// Create a copy of SearchFilterState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,Object? selectedMimeType = freezed,Object? isSearchBarExpanded = null,Object? isSearching = null,}) {
  return _then(_self.copyWith(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,selectedMimeType: freezed == selectedMimeType ? _self.selectedMimeType : selectedMimeType // ignore: cast_nullable_to_non_nullable
as ImageMimeType?,isSearchBarExpanded: null == isSearchBarExpanded ? _self.isSearchBarExpanded : isSearchBarExpanded // ignore: cast_nullable_to_non_nullable
as bool,isSearching: null == isSearching ? _self.isSearching : isSearching // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchFilterState].
extension SearchFilterStatePatterns on SearchFilterState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchFilterState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchFilterState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchFilterState value)  $default,){
final _that = this;
switch (_that) {
case _SearchFilterState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchFilterState value)?  $default,){
final _that = this;
switch (_that) {
case _SearchFilterState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String query,  ImageMimeType? selectedMimeType,  bool isSearchBarExpanded,  bool isSearching)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchFilterState() when $default != null:
return $default(_that.query,_that.selectedMimeType,_that.isSearchBarExpanded,_that.isSearching);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String query,  ImageMimeType? selectedMimeType,  bool isSearchBarExpanded,  bool isSearching)  $default,) {final _that = this;
switch (_that) {
case _SearchFilterState():
return $default(_that.query,_that.selectedMimeType,_that.isSearchBarExpanded,_that.isSearching);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String query,  ImageMimeType? selectedMimeType,  bool isSearchBarExpanded,  bool isSearching)?  $default,) {final _that = this;
switch (_that) {
case _SearchFilterState() when $default != null:
return $default(_that.query,_that.selectedMimeType,_that.isSearchBarExpanded,_that.isSearching);case _:
  return null;

}
}

}

/// @nodoc


class _SearchFilterState implements SearchFilterState {
  const _SearchFilterState({this.query = '', this.selectedMimeType, this.isSearchBarExpanded = false, this.isSearching = false});
  

/// 検索クエリ（空文字 = フィルターなし）
@override@JsonKey() final  String query;
/// 選択中の MIME type フィルター（null = 全て）
@override final  ImageMimeType? selectedMimeType;
/// 検索バー展開状態
@override@JsonKey() final  bool isSearchBarExpanded;
/// 検索中フラグ（サムネイルリクエストの抑制用）
@override@JsonKey() final  bool isSearching;

/// Create a copy of SearchFilterState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchFilterStateCopyWith<_SearchFilterState> get copyWith => __$SearchFilterStateCopyWithImpl<_SearchFilterState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchFilterState&&(identical(other.query, query) || other.query == query)&&(identical(other.selectedMimeType, selectedMimeType) || other.selectedMimeType == selectedMimeType)&&(identical(other.isSearchBarExpanded, isSearchBarExpanded) || other.isSearchBarExpanded == isSearchBarExpanded)&&(identical(other.isSearching, isSearching) || other.isSearching == isSearching));
}


@override
int get hashCode => Object.hash(runtimeType,query,selectedMimeType,isSearchBarExpanded,isSearching);

@override
String toString() {
  return 'SearchFilterState(query: $query, selectedMimeType: $selectedMimeType, isSearchBarExpanded: $isSearchBarExpanded, isSearching: $isSearching)';
}


}

/// @nodoc
abstract mixin class _$SearchFilterStateCopyWith<$Res> implements $SearchFilterStateCopyWith<$Res> {
  factory _$SearchFilterStateCopyWith(_SearchFilterState value, $Res Function(_SearchFilterState) _then) = __$SearchFilterStateCopyWithImpl;
@override @useResult
$Res call({
 String query, ImageMimeType? selectedMimeType, bool isSearchBarExpanded, bool isSearching
});




}
/// @nodoc
class __$SearchFilterStateCopyWithImpl<$Res>
    implements _$SearchFilterStateCopyWith<$Res> {
  __$SearchFilterStateCopyWithImpl(this._self, this._then);

  final _SearchFilterState _self;
  final $Res Function(_SearchFilterState) _then;

/// Create a copy of SearchFilterState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,Object? selectedMimeType = freezed,Object? isSearchBarExpanded = null,Object? isSearching = null,}) {
  return _then(_SearchFilterState(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,selectedMimeType: freezed == selectedMimeType ? _self.selectedMimeType : selectedMimeType // ignore: cast_nullable_to_non_nullable
as ImageMimeType?,isSearchBarExpanded: null == isSearchBarExpanded ? _self.isSearchBarExpanded : isSearchBarExpanded // ignore: cast_nullable_to_non_nullable
as bool,isSearching: null == isSearching ? _self.isSearching : isSearching // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
