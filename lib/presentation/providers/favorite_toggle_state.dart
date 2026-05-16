/// FavoriteToggleState - お気に入りトグル操作の状態モデル
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorite_toggle_state.freezed.dart';

/// お気に入りトグル操作の状態
@freezed
abstract class FavoriteToggleState with _$FavoriteToggleState {
  const factory FavoriteToggleState({
    /// 処理中フラグ（連続タップ防止）
    @Default(false) bool isProcessing,

    /// 楽観的UI更新による表示状態（null の場合は実際のDB状態を使用）
    bool? optimisticIsFavorite,

    /// 楽観的状態の対象フォルダ URI（どのフォルダに対する操作かを識別）
    String? targetUri,

    /// エラーメッセージ
    String? errorMessage,
  }) = _FavoriteToggleState;
}
