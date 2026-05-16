/// SearchController Provider (Req 11.2, 11.3, 11.4, 11.6, 12.2, 12.3, 12.4)
///
/// ギャラリーの検索・フィルター状態を管理する。
/// デバウンス 300ms でクエリ更新、MIME type フィルターは即時反映。
/// 実際のフィルタリングは `applySearchFilter` 純粋関数を使用する。
library;

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/image_entry.dart';
import '../../../domain/entities/search_filter_state.dart';
import '../../../domain/value_objects/search_filter.dart';

part 'search_controller.g.dart';

/// 検索・フィルター状態を管理する Provider
///
/// - [updateQuery]: 300ms デバウンス付きでクエリを更新
/// - [updateMimeTypeFilter]: MIME type フィルターを即時更新
/// - [clearAll]: 全フィルターをリセット
@riverpod
class SearchController extends _$SearchController {
  Timer? _debounceTimer;

  @override
  SearchFilterState build() {
    // Provider 破棄時にタイマーをキャンセル
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });
    return const SearchFilterState();
  }

  /// 検索クエリを更新する（300ms デバウンス付き）
  ///
  /// 新しい入力があるたびに前のタイマーをキャンセルし、
  /// 最後の入力から 300ms 経過後に状態を更新する。
  void updateQuery(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      state = state.copyWith(query: query);
    });
  }

  /// MIME type フィルターを即時更新する
  ///
  /// [type] が null の場合はフィルター解除（全て表示）。
  void updateMimeTypeFilter(ImageMimeType? type) {
    state = state.copyWith(selectedMimeType: type);
  }

  /// 検索バーの展開/折りたたみを切り替える
  void toggleSearchBar() {
    state = state.copyWith(isSearchBarExpanded: !state.isSearchBarExpanded);
  }

  /// 全フィルターをリセットする
  ///
  /// クエリ・MIME type フィルター・検索バー展開状態を初期値に戻す。
  void clearAll() {
    _debounceTimer?.cancel();
    state = const SearchFilterState();
  }
}

/// 検索フィルターを適用した画像リストを返す computed Provider
///
/// [SearchController] の状態と画像リストを監視し、
/// `applySearchFilter` 純粋関数でフィルタリングした結果を返す。
@riverpod
List<ImageEntry> filteredImages(Ref ref, {required List<ImageEntry> images}) {
  final filterState = ref.watch(searchControllerProvider);
  return applySearchFilter(
    images: images,
    query: filterState.query,
    mimeTypeFilter: filterState.selectedMimeType,
  );
}
