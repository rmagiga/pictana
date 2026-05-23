/// 検索・フィルター状態 (Req 11.2, 12.2)
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import 'image_entry.dart';

part 'search_filter_state.freezed.dart';

/// 検索・フィルター状態モデル
@freezed
abstract class SearchFilterState with _$SearchFilterState {
  const factory SearchFilterState({
    /// 検索クエリ（空文字 = フィルターなし）
    @Default('') String query,

    /// 選択中の MIME type フィルター（null = 全て）
    ImageMimeType? selectedMimeType,

    /// 検索バー展開状態
    @Default(false) bool isSearchBarExpanded,

    /// 検索中フラグ（サムネイルリクエストの抑制用）
    @Default(false) bool isSearching,
  }) = _SearchFilterState;
}
