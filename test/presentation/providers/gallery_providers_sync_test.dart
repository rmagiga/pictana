import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pictana/application/providers/repository_providers.dart';
import 'package:pictana/application/usecases/gallery/load_folder_images_usecase.dart';
import 'package:pictana/domain/entities/entry_id.dart';
import 'package:pictana/domain/entities/folder_entry.dart';
import 'package:pictana/domain/entities/image_entry.dart';
import 'package:pictana/domain/repositories/image_repository.dart';
import 'package:pictana/domain/value_objects/sort_option.dart';
import 'package:pictana/infrastructure/database/app_database.dart';
import 'package:pictana/presentation/providers/app_lifecycle_provider.dart';
import 'package:pictana/presentation/providers/gallery_providers.dart';

// フェイク用 ImageRepository
class FakeImageRepository implements ImageRepository {
  @override
  Stream<List<ImageEntry>> getImages({
    required FolderEntry folder,
    SortOption sort = SortOption.defaultOption,
    ImageFilter filter = ImageFilter.none,
  }) => throw UnimplementedError();

  @override
  Future<List<ImageEntry>> getImagePage({
    required FolderEntry folder,
    required int page,
    required int pageSize,
    SortOption sort = SortOption.defaultOption,
    ImageFilter filter = ImageFilter.none,
  }) => throw UnimplementedError();

  @override
  Future<int> countImages({
    required FolderEntry folder,
    ImageFilter filter = ImageFilter.none,
  }) => throw UnimplementedError();

  @override
  Future<ImageEntry> getImageMetadata(ImageEntry entry) => throw UnimplementedError();

  @override
  Future<List<int>> getImageBytes(ImageEntry entry) => throw UnimplementedError();
}

// フェイク用 LoadFolderImagesUseCase
class FakeLoadFolderImagesUseCase implements LoadFolderImagesUseCase {
  StreamController<List<ImageEntry>>? controller;
  int countCallCount = 0;
  int executeCallCount = 0;

  @override
  ImageRepository get _repo => FakeImageRepository();

  @override
  Stream<List<ImageEntry>> execute({
    required FolderEntry folder,
    SortOption sort = SortOption.defaultOption,
    ImageFilter filter = ImageFilter.none,
  }) {
    executeCallCount++;
    // 既存のコントローラーがあればクローズしておく
    controller?.close();
    controller = StreamController<List<ImageEntry>>();
    return controller!.stream;
  }

  @override
  Future<List<ImageEntry>> executePage({
    required FolderEntry folder,
    required int page,
    int pageSize = 50,
    SortOption sort = SortOption.defaultOption,
    ImageFilter filter = ImageFilter.none,
  }) async {
    return [];
  }

  @override
  Future<int> count({
    required FolderEntry folder,
    ImageFilter filter = ImageFilter.none,
  }) async {
    countCallCount++;
    return 10;
  }
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeLoadFolderImagesUseCase fakeUseCase;
  late AppDatabase db;
  late ProviderContainer container;
  late FolderEntry testFolder;

  setUp(() {
    fakeUseCase = FakeLoadFolderImagesUseCase();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        loadFolderImagesUseCaseProvider.overrideWith((ref) => fakeUseCase),
        appDatabaseProvider.overrideWithValue(db),
      ],
    );
    testFolder = FolderEntry(
      id: EntryId.windows('C:\\test\\folder'),
      name: 'folder',
      uri: 'C:\\test\\folder',
    );

    // テスト用のデバウンス間隔を 0ms にしてテストの完了を早める
    GalleryImages.debounceDuration = Duration.zero;
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('GallerySyncState & GalleryImages Sync Test', () {
    test('アプリ復帰（resumed）時に、状態を維持したままバックグラウンドで再購読（同期）が走り、同期状態が制御される', () async {
      // フォルダを設定
      container.read(currentFolderProvider.notifier).setFolder(testFolder);

      // プロバイダを購読して初期化をトリガーする
      final subscription = container.listen(
        galleryImagesProvider,
        (previous, next) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      // 非同期初期化（build）とDBロードが完了するのを待つ
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // 初回の読み込み開始を確認
      expect(fakeUseCase.executeCallCount, equals(1));
      expect(container.read(gallerySyncStateProvider), isTrue);

      final initialImages = [
        ImageEntry(
          id: EntryId.windows('C:\\test\\folder\\img1.jpg'),
          name: 'img1.jpg',
          extension: 'jpg',
          uri: 'C:\\test\\folder\\img1.jpg',
          mimeType: ImageMimeType.jpeg,
          size: 100,
          modifiedAt: DateTime(2023, 1, 1),
        ),
      ];

      // データ注入と完了
      fakeUseCase.controller!.add(initialImages);
      // デバウンスタイムアウトと完了通知を待つ
      await Future<void>.delayed(Duration.zero);
      fakeUseCase.controller!.close();
      await Future<void>.delayed(Duration.zero);

      // 同期終了の確認
      expect(container.read(gallerySyncStateProvider), isFalse);
      var state = container.read(galleryImagesProvider);
      expect(state.value, equals(initialImages));

      // アプリをバックグラウンドにする（paused）
      TestWidgetsFlutterBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // アプリをフォアグラウンドに戻す（resumed）
      TestWidgetsFlutterBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // resumed によって2回目の購読（スキャン）が走っていることを確認
      expect(fakeUseCase.executeCallCount, equals(2));
      // 同期中フラグが true になっている
      expect(container.read(gallerySyncStateProvider), isTrue);

      // 同期中も、以前 of 画像状態（initialImages）が維持されている（loading になっていない）
      state = container.read(galleryImagesProvider);
      expect(state.isLoading, isFalse);
      expect(state.value, equals(initialImages));

      final updatedImages = [
        ...initialImages,
        ImageEntry(
          id: EntryId.windows('C:\\test\\folder\\img2.jpg'),
          name: 'img2.jpg',
          extension: 'jpg',
          uri: 'C:\\test\\folder\\img2.jpg',
          mimeType: ImageMimeType.jpeg,
          size: 200,
          modifiedAt: DateTime(2023, 1, 2),
        ),
      ];

      // 新しい差分データを注入
      fakeUseCase.controller!.add(updatedImages);
      await Future<void>.delayed(Duration.zero);

      // 完了
      fakeUseCase.controller!.close();
      await Future<void>.delayed(Duration.zero);

      // 同期が完了し、同期状態フラグが false に戻る
      expect(container.read(gallerySyncStateProvider), isFalse);

      // 最終結果が反映されていることを確認
      state = container.read(galleryImagesProvider);
      expect(state.value, equals(updatedImages));
    });
  });
}
