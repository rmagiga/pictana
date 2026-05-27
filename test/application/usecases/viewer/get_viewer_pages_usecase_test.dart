import 'package:flutter_test/flutter_test.dart';
import 'package:pictana/application/usecases/viewer/get_viewer_pages_usecase.dart';
import 'package:pictana/domain/entities/entry_id.dart';
import 'package:pictana/domain/entities/image_entry.dart';
import 'package:pictana/domain/value_objects/viewer_display_mode.dart';

void main() {
  late GetViewerPagesUseCase useCase;

  setUp(() {
    useCase = GetViewerPagesUseCase();
  });

  ImageEntry createDummyImage({
    required String id,
    double aspectRatio = 0.7,
  }) {
    // 幅と高さをアスペクト比に合わせて設定
    final int width = aspectRatio > 1.0 ? 1000 : 700;
    final int height = (width / aspectRatio).round();

    return ImageEntry(
      id: EntryId.windows('C:/dummy/$id.jpg'),
      name: '$id.jpg',
      extension: 'jpg',
      uri: 'C:/dummy/$id.jpg',
      mimeType: ImageMimeType.jpeg,
      size: 1024,
      modifiedAt: DateTime.now(),
      width: width,
      height: height,
    );
  }

  group('GetViewerPagesUseCase', () {
    test('displayModeがsingleのとき、すべての画像が単一ページに分割されること', () {
      final images = [
        createDummyImage(id: '1'),
        createDummyImage(id: '2'),
        createDummyImage(id: '3'),
      ];

      final pages = useCase.execute(
        images: images,
        displayMode: ViewerDisplayMode.single,
        hasCoverPage: true,
      );

      expect(pages.length, 3);
      expect(pages[0].entries.length, 1);
      expect(pages[0].entries[0].name, '1.jpg');
      expect(pages[0].isDoublePage, false);
      expect(pages[1].entries.length, 1);
      expect(pages[1].entries[0].name, '2.jpg');
      expect(pages[1].isDoublePage, false);
    });

    test('displayModeがdoubleで表紙ありの場合、1枚目が単一、2枚目以降がペアになること', () {
      final images = [
        createDummyImage(id: '1'), // 表紙
        createDummyImage(id: '2'), // 見開きL
        createDummyImage(id: '3'), // 見開きR
        createDummyImage(id: '4'), // 見開きL
        createDummyImage(id: '5'), // 見開きR
      ];

      final pages = useCase.execute(
        images: images,
        displayMode: ViewerDisplayMode.double,
        hasCoverPage: true,
      );

      // 構成: [1], [2, 3], [4, 5] => 合計 3 ページ
      expect(pages.length, 3);
      expect(pages[0].entries.length, 1);
      expect(pages[0].entries[0].name, '1.jpg');
      expect(pages[0].isDoublePage, false);

      expect(pages[1].entries.length, 2);
      expect(pages[1].entries[0].name, '2.jpg');
      expect(pages[1].entries[1].name, '3.jpg');
      expect(pages[1].isDoublePage, true);
    });

    test('displayModeがdoubleで表紙なしの場合、1枚目からペアになること', () {
      final images = [
        createDummyImage(id: '1'), // 見開きL
        createDummyImage(id: '2'), // 見開きR
        createDummyImage(id: '3'), // 見開きL
        createDummyImage(id: '4'), // 見開きR
      ];

      final pages = useCase.execute(
        images: images,
        displayMode: ViewerDisplayMode.double,
        hasCoverPage: false,
      );

      // 構成: [1, 2], [3, 4] => 合計 2 ページ
      expect(pages.length, 2);
      expect(pages[0].entries.length, 2);
      expect(pages[0].entries[0].name, '1.jpg');
      expect(pages[0].entries[1].name, '2.jpg');
      expect(pages[0].isDoublePage, true);
    });

    test('横長画像（アスペクト比 > 1.2）が混在する場合、自動で単一表示になること', () {
      final images = [
        createDummyImage(id: '1'), // 縦長
        createDummyImage(id: '2', aspectRatio: 1.5), // 横長 (単一化)
        createDummyImage(id: '3'), // 縦長
        createDummyImage(id: '4'), // 縦長
      ];

      final pages = useCase.execute(
        images: images,
        displayMode: ViewerDisplayMode.double,
        hasCoverPage: false,
      );

      // 構成:
      // 1枚目[1] (次が横長なのでペアを組めず単一に)
      // 2枚目[2] (横長なので単一に)
      // 3-4枚目[3, 4] (縦長同士なのでペアに)
      // 合計 3 ページ
      expect(pages.length, 3);
      expect(pages[0].entries.length, 1);
      expect(pages[0].entries[0].name, '1.jpg');
      expect(pages[0].isDoublePage, false);

      expect(pages[1].entries.length, 1);
      expect(pages[1].entries[0].name, '2.jpg');
      expect(pages[1].isDoublePage, false);

      expect(pages[2].entries.length, 2);
      expect(pages[2].entries[0].name, '3.jpg');
      expect(pages[2].entries[1].name, '4.jpg');
      expect(pages[2].isDoublePage, true);
    });

    test('奇数枚で終わる場合、最終ページが単一表示になること', () {
      final images = [
        createDummyImage(id: '1'),
        createDummyImage(id: '2'),
        createDummyImage(id: '3'),
      ];

      final pages = useCase.execute(
        images: images,
        displayMode: ViewerDisplayMode.double,
        hasCoverPage: false,
      );

      // 構成: [1, 2], [3] => 合計 2 ページ
      expect(pages.length, 2);
      expect(pages[0].entries.length, 2);
      expect(pages[0].isDoublePage, true);

      expect(pages[1].entries.length, 1);
      expect(pages[1].entries[0].name, '3.jpg');
      expect(pages[1].isDoublePage, false);
    });
  });
}
