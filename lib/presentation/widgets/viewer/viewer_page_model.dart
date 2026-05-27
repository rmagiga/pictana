import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/image_entry.dart';

part 'viewer_page_model.freezed.dart';

/// ビューアの1ページに表示する画像データを表すモデル
@freezed
abstract class ViewerPageModel with _$ViewerPageModel {
  const factory ViewerPageModel({
    /// このページに含まれる画像エントリ（1枚または2枚）
    required List<ImageEntry> entries,

    /// このページが見開き表示（2枚並び）されるかどうか
    required bool isDoublePage,
  }) = _ViewerPageModel;
}
