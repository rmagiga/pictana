import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../widgets/viewer/viewer_display_mode.dart';

part 'viewer_controller_provider.g.dart';

/// ビューアの状態を管理するイミュータブルクラス
class ViewerState {
  const ViewerState({
    required this.currentIndex,
    required this.totalCount,
    required this.isOverlayVisible,
    required this.isZoomed,
    required this.displayMode,
  });

  /// 現在表示中の画像インデックス
  final int currentIndex;

  /// フォルダ内の画像総数
  final int totalCount;

  /// メニュー等のオーバーレイが表示されているか
  final bool isOverlayVisible;

  /// 画像がズームされているか
  final bool isZoomed;

  /// 現在の表示モード
  final ViewerDisplayMode displayMode;

  ViewerState copyWith({
    int? currentIndex,
    int? totalCount,
    bool? isOverlayVisible,
    bool? isZoomed,
    ViewerDisplayMode? displayMode,
  }) {
    return ViewerState(
      currentIndex: currentIndex ?? this.currentIndex,
      totalCount: totalCount ?? this.totalCount,
      isOverlayVisible: isOverlayVisible ?? this.isOverlayVisible,
      isZoomed: isZoomed ?? this.isZoomed,
      displayMode: displayMode ?? this.displayMode,
    );
  }
}

/// ビューアの状態操作と通知を行うコントローラー
@riverpod
class ViewerController extends _$ViewerController {
  @override
  ViewerState build({
    required int initialIndex,
    required int totalCount,
  }) {
    return ViewerState(
      currentIndex: initialIndex,
      totalCount: totalCount,
      isOverlayVisible: true,
      isZoomed: false,
      displayMode: ViewerDisplayMode.single,
    );
  }

  /// インデックスを更新する
  void setCurrentIndex(int index) {
    if (index < 0 || index >= state.totalCount) return;
    state = state.copyWith(currentIndex: index);
  }

  /// オーバーレイ表示をトグルする
  void toggleOverlay() {
    state = state.copyWith(isOverlayVisible: !state.isOverlayVisible);
  }

  /// オーバーレイ表示を設定する
  void setOverlayVisible(bool visible) {
    state = state.copyWith(isOverlayVisible: visible);
  }

  /// ズーム状態を設定する
  void setZoomed(bool zoomed) {
    state = state.copyWith(isZoomed: zoomed);
  }

  /// 表示モードを設定する
  void setDisplayMode(ViewerDisplayMode mode) {
    state = state.copyWith(displayMode: mode);
  }

  /// 次のページに遷移する
  void goToNext() {
    if (state.currentIndex < state.totalCount - 1) {
      setCurrentIndex(state.currentIndex + 1);
    }
  }

  /// 前のページに遷移する
  void goToPrevious() {
    if (state.currentIndex > 0) {
      setCurrentIndex(state.currentIndex - 1);
    }
  }
}
