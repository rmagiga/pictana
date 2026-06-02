/// コレクション編集モード Provider
///
/// CollectionListScreen と CollectionImageListScreen の両方で使用する
/// 編集モード（選択・並び替え・削除）の UI 状態を管理する。
///
/// Validates: Requirements 7.1, 7.2, 7.4, 7.5, 7.6, 7.7, 9.1, 9.2, 9.4, 9.9, 9.10
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'collection_edit_mode_provider.g.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

/// 編集モードの状態を表すイミュータブルクラス
class CollectionEditModeState {
  const CollectionEditModeState({
    this.isActive = false,
    this.selectedIds = const {},
  });

  /// 編集モードが有効かどうか
  final bool isActive;

  /// 選択中のアイテム ID セット
  final Set<int> selectedIds;

  /// 選択件数
  int get selectedCount => selectedIds.length;

  CollectionEditModeState copyWith({bool? isActive, Set<int>? selectedIds}) {
    return CollectionEditModeState(
      isActive: isActive ?? this.isActive,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectionEditModeState &&
          isActive == other.isActive &&
          selectedIds.length == other.selectedIds.length &&
          selectedIds.containsAll(other.selectedIds);

  @override
  int get hashCode => Object.hash(isActive, Object.hashAll(selectedIds));
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// コレクション編集モードを管理する Notifier
///
/// 長押しで編集モードを開始し、選択/解除のトグル、
/// 全選択、編集モード終了を提供する。
@riverpod
class CollectionEditMode extends _$CollectionEditMode {
  @override
  CollectionEditModeState build() {
    return const CollectionEditModeState();
  }

  /// 編集モードを開始する
  ///
  /// 長押しされたアイテムを初期選択状態にして編集モードに入る。
  /// Requirements 7.1, 9.1
  void startEditMode(int initialItemId) {
    state = CollectionEditModeState(
      isActive: true,
      selectedIds: {initialItemId},
    );
  }

  /// アイテムの選択状態をトグルする
  ///
  /// 選択中のアイテムをタップすると解除、未選択のアイテムをタップすると選択。
  /// 全ての選択が解除されても編集モードは維持する。
  /// Requirements 7.2, 9.2, 9.10
  void toggleSelection(int itemId) {
    if (!state.isActive) return;

    final updatedIds = Set<int>.from(state.selectedIds);
    if (updatedIds.contains(itemId)) {
      updatedIds.remove(itemId);
    } else {
      updatedIds.add(itemId);
    }

    // 全選択解除でも編集モードは維持 (Requirement 9.10)
    state = state.copyWith(selectedIds: updatedIds);
  }

  /// 全アイテムを選択する
  ///
  /// 一覧に表示されている全アイテムの ID を選択状態にする。
  void selectAll(List<int> allIds) {
    if (!state.isActive) return;
    state = state.copyWith(selectedIds: Set<int>.from(allIds));
  }

  /// 選択をクリアする（編集モードは維持）
  void clearSelection() {
    if (!state.isActive) return;
    state = state.copyWith(selectedIds: const {});
  }

  /// 編集モードを終了する
  ///
  /// 全ての選択を解除し、通常の一覧表示に戻る。
  /// Requirements 7.7, 9.9
  void exitEditMode() {
    state = const CollectionEditModeState();
  }
}
