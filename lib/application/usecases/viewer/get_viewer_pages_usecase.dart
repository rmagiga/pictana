import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/image_entry.dart';
import '../../../domain/value_objects/viewer_display_mode.dart';
import '../../../presentation/widgets/viewer/viewer_page_model.dart';

part 'get_viewer_pages_usecase.g.dart';

@riverpod
class GetViewerPagesUseCase extends _$GetViewerPagesUseCase {
  @override
  GetViewerPagesUseCase build() {
    return this;
  }

  /// アスペクト比がこの値より大きい画像を「横長画像（単一表示）」と判定する
  static const double landscapeAspectRatioThreshold = 1.2;

  List<ViewerPageModel> execute({
    required List<ImageEntry> images,
    required ViewerDisplayMode displayMode,
    required bool hasCoverPage,
  }) {
    if (images.isEmpty) return const [];

    // 見開き表示でない場合は、すべて単一ページとして変換
    if (displayMode != ViewerDisplayMode.double) {
      return images
          .map((img) => ViewerPageModel(entries: [img], isDoublePage: false))
          .toList();
    }

    final pages = <ViewerPageModel>[];
    var i = 0;

    // 表紙（最初の1枚目を単一表示にする）の処理
    if (hasCoverPage && images.isNotEmpty) {
      pages.add(ViewerPageModel(entries: [images[0]], isDoublePage: false));
      i = 1;
    }

    while (i < images.length) {
      final current = images[i];

      // 1. 現在の画像が横長の場合、単一表示にする
      if (current.aspectRatio > landscapeAspectRatioThreshold) {
        pages.add(ViewerPageModel(entries: [current], isDoublePage: false));
        i++;
        continue;
      }

      // 2. 次の画像がある場合
      if (i + 1 < images.length) {
        final next = images[i + 1];

        // 次の画像が横長の場合、現在の画像だけを単一表示して次へ進む
        if (next.aspectRatio > landscapeAspectRatioThreshold) {
          pages.add(ViewerPageModel(entries: [current], isDoublePage: false));
          i++;
        } else {
          // 両方とも縦長なら、見開きペアにする
          pages.add(ViewerPageModel(entries: [current, next], isDoublePage: true));
          i += 2;
        }
      } else {
        // 3. 最後の1枚が余った場合
        pages.add(ViewerPageModel(entries: [current], isDoublePage: false));
        i++;
      }
    }

    return pages;
  }
}
