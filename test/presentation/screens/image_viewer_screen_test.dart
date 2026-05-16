/// ImageViewerScreen 統合テスト
///
/// Windows/Android 各プラットフォームでのコンポーネント表示を検証する。
/// 現在のテスト実行環境は Windows のため、Windows 固有コンポーネントの存在と
/// Android 固有コンポーネントの不在を確認する。
///
/// テストシナリオ:
/// 1. Windows: NavigationOverlay が Stack 内に存在する
/// 2. Windows: KeyboardNavigationHandler が最外層に存在する
/// 3. Windows: CtrlWheelZoomHandler がページビューをラップしている
/// 4. (Windows 環境のため) SwipeDirectionController が使用されていない
/// 5. (Windows 環境のため) NavigationOverlay が存在する
/// 6. (Windows 環境のため) KeyboardNavigationHandler が存在する
///
/// Requirements: 1.1, 2.1, 3.1, 4.1
library;

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optrig/application/usecases/gallery/load_thumbnail_usecase.dart';
import 'package:optrig/application/usecases/settings/swipe_direction_setting.dart';
import 'package:optrig/application/usecases/viewer/preload_adjacent_images_usecase.dart';
import 'package:optrig/domain/entities/entry_id.dart';
import 'package:optrig/domain/entities/image_entry.dart';
import 'package:optrig/domain/repositories/exif_processor.dart';
import 'package:optrig/domain/repositories/image_repository.dart';
import 'package:optrig/domain/repositories/thumbnail_repository.dart';
import 'package:optrig/domain/value_objects/swipe_direction.dart';
import 'package:optrig/presentation/providers/gallery_providers.dart';
import 'package:optrig/presentation/providers/viewer_providers.dart';
import 'package:optrig/presentation/screens/image_viewer_screen.dart';
import 'package:optrig/presentation/widgets/viewer/ctrl_wheel_zoom_handler.dart';
import 'package:optrig/presentation/widgets/viewer/keyboard_navigation_handler.dart';
import 'package:optrig/presentation/widgets/viewer/navigation_overlay.dart';
import 'package:optrig/presentation/widgets/viewer/swipe_direction_controller.dart';

// ---------------------------------------------------------------------------
// テスト用データ
// ---------------------------------------------------------------------------

/// テスト用の画像エントリリスト
List<ImageEntry> _createTestImages() => [
  ImageEntry(
    id: EntryId.windows(r'C:\test\image1.jpg'),
    name: 'image1.jpg',
    extension: 'jpg',
    size: 1024,
    modifiedAt: DateTime(2024, 1, 1),
    uri: r'C:\test\image1.jpg',
    mimeType: ImageMimeType.jpeg,
  ),
  ImageEntry(
    id: EntryId.windows(r'C:\test\image2.png'),
    name: 'image2.png',
    extension: 'png',
    size: 2048,
    modifiedAt: DateTime(2024, 1, 2),
    uri: r'C:\test\image2.png',
    mimeType: ImageMimeType.png,
  ),
  ImageEntry(
    id: EntryId.windows(r'C:\test\image3.webp'),
    name: 'image3.webp',
    extension: 'webp',
    size: 3072,
    modifiedAt: DateTime(2024, 1, 3),
    uri: r'C:\test\image3.webp',
    mimeType: ImageMimeType.webp,
  ),
];

/// テスト用の 1x1 ピクセル PNG バイトデータ
final _testImageBytes = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, // IHDR chunk
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, // 1x1
  0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53, // 8-bit RGB
  0xDE, 0x00, 0x00, 0x00, 0x0C, 0x49, 0x44, 0x41, // IDAT chunk
  0x54, 0x08, 0xD7, 0x63, 0xF8, 0xCF, 0xC0, 0x00, // compressed data
  0x00, 0x00, 0x02, 0x00, 0x01, 0xE2, 0x21, 0xBC, // ...
  0x33, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, // IEND chunk
  0x44, 0xAE, 0x42, 0x60, 0x82,
]);

// ---------------------------------------------------------------------------
// テスト用モック
// ---------------------------------------------------------------------------

/// No-op の PreloadAdjacentImagesUseCase
class _FakePreloadAdjacentImagesUseCase extends PreloadAdjacentImagesUseCase {
  _FakePreloadAdjacentImagesUseCase()
    : super(imageRepository: _FakeImageRepository());

  @override
  Future<void> execute(List<ImageEntry> entries, int currentIndex) async {
    // テスト用: 何もしない
  }
}

/// No-op の LoadThumbnailUseCase
class _FakeLoadThumbnailUseCase extends LoadThumbnailUseCase {
  _FakeLoadThumbnailUseCase()
    : super(thumbnailRepository: _FakeThumbnailRepository());

  @override
  Future<Uint8List?> execute(
    ImageEntry entry, {
    ThumbnailSize size = ThumbnailSize.grid,
  }) async {
    return _testImageBytes;
  }
}

/// Fake ImageRepository（PreloadAdjacentImagesUseCase のコンストラクタ用）
class _FakeImageRepository implements ImageRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Fake ThumbnailRepository（LoadThumbnailUseCase のコンストラクタ用）
class _FakeThumbnailRepository implements ThumbnailRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Fake ExifProcessor
class _FakeExifProcessor implements ExifProcessor {
  @override
  int extractRotation(List<int> bytes) => 0;
}

/// Fake SwipeDirectionSetting Provider
class _FakeSwipeDirectionSetting extends SwipeDirectionSetting {
  @override
  SwipeDirection build() => SwipeDirection.horizontal;

  @override
  Future<void> update(SwipeDirection direction) async {
    state = direction;
  }
}

// ---------------------------------------------------------------------------
// テスト用ヘルパー
// ---------------------------------------------------------------------------

/// テスト用ウィジェットを作成する
///
/// [initialIndex] で初期表示する画像のインデックスを指定する。
/// [images] でテスト用画像リストを指定する（デフォルトは 3 枚）。
Widget _createTestWidget({int initialIndex = 0, List<ImageEntry>? images}) {
  final testImages = images ?? _createTestImages();

  return ProviderScope(
    overrides: [
      // galleryImagesProvider: テスト用画像リストを Stream で返す
      galleryImagesProvider.overrideWith((ref) {
        return Stream.value(testImages);
      }),
      // preloadAdjacentImagesUseCaseProvider: No-op
      preloadAdjacentImagesUseCaseProvider.overrideWith((ref) {
        return _FakePreloadAdjacentImagesUseCase();
      }),
      // loadThumbnailUseCaseProvider: テスト用バイトを返す
      loadThumbnailUseCaseProvider.overrideWith((ref) {
        return _FakeLoadThumbnailUseCase();
      }),
      // imageBytesProvider: テスト用バイトを返す
      imageBytesProvider.overrideWith((ref, entry) async {
        return _testImageBytes;
      }),
      // imageExifRotationProvider: 回転なし
      imageExifRotationProvider.overrideWith((ref, entry) async {
        return 0;
      }),
      // swipeDirectionSettingProvider: デフォルト値
      swipeDirectionSettingProvider.overrideWith(
        () => _FakeSwipeDirectionSetting(),
      ),
    ],
    child: MaterialApp(home: ImageViewerScreen(initialIndex: initialIndex)),
  );
}

// ---------------------------------------------------------------------------
// テスト本体
// ---------------------------------------------------------------------------

void main() {
  group('ImageViewerScreen - Windows コンポーネント統合 (Req 1.1, 2.1, 3.1)', () {
    testWidgets('NavigationOverlay が Stack 内に存在する', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();

      // NavigationOverlay ウィジェットが存在することを確認
      expect(find.byType(NavigationOverlay), findsOneWidget);
    });

    testWidgets('KeyboardNavigationHandler が最外層に存在する', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();

      // KeyboardNavigationHandler ウィジェットが存在することを確認
      expect(find.byType(KeyboardNavigationHandler), findsOneWidget);
    });

    testWidgets('CtrlWheelZoomHandler がページビューをラップしている', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();

      // CtrlWheelZoomHandler ウィジェットが存在することを確認
      expect(find.byType(CtrlWheelZoomHandler), findsOneWidget);
    });

    testWidgets('KeyboardNavigationHandler が NavigationOverlay の祖先である', (
      tester,
    ) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();

      // KeyboardNavigationHandler が NavigationOverlay を含む Stack の祖先であることを確認
      final keyboardHandler = find.byType(KeyboardNavigationHandler);
      final navigationOverlay = find.byType(NavigationOverlay);

      expect(keyboardHandler, findsOneWidget);
      expect(navigationOverlay, findsOneWidget);

      // KeyboardNavigationHandler が NavigationOverlay の祖先であることを確認
      expect(
        find.ancestor(of: navigationOverlay, matching: keyboardHandler),
        findsOneWidget,
      );
    });

    testWidgets('CtrlWheelZoomHandler が PageView の祖先である', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();

      // CtrlWheelZoomHandler が PageView を含むことを確認
      final zoomHandler = find.byType(CtrlWheelZoomHandler);
      final pageView = find.byType(PageView);

      expect(zoomHandler, findsOneWidget);
      expect(pageView, findsOneWidget);

      expect(
        find.ancestor(of: pageView, matching: zoomHandler),
        findsOneWidget,
      );
    });
  });

  group('ImageViewerScreen - Windows 環境で Android コンポーネントが不在 (Req 4.1)', () {
    testWidgets('SwipeDirectionController が使用されていない', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();

      // Windows 環境では SwipeDirectionController は使用されない
      expect(find.byType(SwipeDirectionController), findsNothing);
    });
  });

  group('ImageViewerScreen - 基本表示', () {
    testWidgets('画像が正常に表示される', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();

      // Scaffold が存在する
      expect(find.byType(Scaffold), findsOneWidget);
      // PageView が存在する
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('ページインジケーターが表示される', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();

      // ページインジケーター「1 / 3」が表示される
      expect(find.text('1 / 3'), findsOneWidget);
    });

    testWidgets('画像名が AppBar に表示される', (tester) async {
      await tester.pumpWidget(_createTestWidget());
      await tester.pumpAndSettle();

      // 最初の画像名が表示される
      expect(find.text('image1.jpg'), findsOneWidget);
    });

    testWidgets('画像リストが空の場合にメッセージが表示される', (tester) async {
      await tester.pumpWidget(_createTestWidget(images: []));
      await tester.pumpAndSettle();

      expect(find.text('画像がありません'), findsOneWidget);
    });

    testWidgets('単一画像の場合 NavigationOverlay のボタンが非表示', (tester) async {
      final singleImage = [_createTestImages().first];
      await tester.pumpWidget(_createTestWidget(images: singleImage));
      await tester.pumpAndSettle();

      // NavigationOverlay は存在するが、ボタンは非表示（totalCount <= 1）
      expect(find.byType(NavigationOverlay), findsOneWidget);
      // chevron アイコンが表示されていないことを確認
      expect(find.byIcon(Icons.chevron_left), findsNothing);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });
  });
}
