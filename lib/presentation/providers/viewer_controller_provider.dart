import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../application/usecases/viewer/folder_viewer_settings_usecase.dart';
import '../../application/usecases/viewer/get_viewer_pages_usecase.dart';
import '../../domain/entities/folder_viewer_settings.dart';
import '../widgets/viewer/viewer_display_mode.dart';
import '../widgets/viewer/viewer_page_model.dart';
import 'gallery_providers.dart';

part 'viewer_controller_provider.g.dart';

/// ビューアの状態を管理するイミュータブルクラス
class ViewerState {
  const ViewerState({
    required this.currentIndex,
    required this.totalCount,
    required this.isOverlayVisible,
    required this.isZoomed,
    required this.displayMode,
    this.pages = const [],
    this.folderSettings,
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

  /// 表示されるページのリスト (見開き対応)
  final List<ViewerPageModel> pages;

  /// フォルダ固有の設定
  final FolderViewerSettings? folderSettings;

  ViewerState copyWith({
    int? currentIndex,
    int? totalCount,
    bool? isOverlayVisible,
    bool? isZoomed,
    ViewerDisplayMode? displayMode,
    List<ViewerPageModel>? pages,
    FolderViewerSettings? folderSettings,
  }) {
    return ViewerState(
      currentIndex: currentIndex ?? this.currentIndex,
      totalCount: totalCount ?? this.totalCount,
      isOverlayVisible: isOverlayVisible ?? this.isOverlayVisible,
      isZoomed: isZoomed ?? this.isZoomed,
      displayMode: displayMode ?? this.displayMode,
      pages: pages ?? this.pages,
      folderSettings: folderSettings ?? this.folderSettings,
    );
  }
}

/// ビューアの状態操作と通知を行うコントローラー
@riverpod
class ViewerController extends _$ViewerController {
  @override
  ViewerState build({required int initialIndex, required int totalCount}) {
    final stateVal = ViewerState(
      currentIndex: initialIndex,
      totalCount: totalCount,
      isOverlayVisible: true,
      isZoomed: false,
      displayMode: ViewerDisplayMode.single,
    );

    // 設定ロード処理をバックグラウンド実行
    Future.microtask(() => _loadSettings());

    return stateVal;
  }

  /// 現在のフォルダ設定と画像一覧を取得して、初期状態の pages を構築する
  Future<void> _loadSettings() async {
    final folder = ref.read(currentFolderProvider);
    if (folder == null) return;

    final settings = await ref
        .read(getFolderViewerSettingsUseCaseProvider.notifier)
        .execute(folder.uri);
    final images = ref.read(galleryImagesProvider).value ?? [];

    final pages = ref
        .read(getViewerPagesUseCaseProvider.notifier)
        .execute(
          images: images,
          displayMode: settings.displayMode,
          hasCoverPage: settings.hasCoverPage,
        );

    state = state.copyWith(
      folderSettings: settings,
      displayMode: settings.displayMode,
      pages: pages,
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

  /// フォルダ設定を更新してDBに保存し、pagesを再計算する
  Future<void> updateFolderSettings({
    ViewerDisplayMode? displayMode,
    bool? isRightToLeft,
    bool? hasCoverPage,
  }) async {
    final folder = ref.read(currentFolderProvider);
    if (folder == null) return;

    final currentSettings =
        state.folderSettings ?? FolderViewerSettings(folderUri: folder.uri);
    final newSettings = currentSettings.copyWith(
      displayMode: displayMode ?? currentSettings.displayMode,
      isRightToLeft: isRightToLeft ?? currentSettings.isRightToLeft,
      hasCoverPage: hasCoverPage ?? currentSettings.hasCoverPage,
    );

    // DBに保存
    await ref
        .read(saveFolderViewerSettingsUseCaseProvider.notifier)
        .execute(newSettings);

    // pagesを再計算
    final images = ref.read(galleryImagesProvider).value ?? [];
    final pages = ref
        .read(getViewerPagesUseCaseProvider.notifier)
        .execute(
          images: images,
          displayMode: newSettings.displayMode,
          hasCoverPage: newSettings.hasCoverPage,
        );

    state = state.copyWith(
      folderSettings: newSettings,
      displayMode: newSettings.displayMode,
      pages: pages,
    );
  }

  /// 現在表示している画像が含まれるページのインデックスを取得する
  int get currentPageIndex {
    if (state.pages.isEmpty) return 0;
    final images = ref.read(galleryImagesProvider).value ?? [];
    if (images.isEmpty || state.currentIndex >= images.length) return 0;

    final currentImage = images[state.currentIndex];
    final idx = state.pages.indexWhere(
      (page) => page.entries.any(
        (entry) => entry.id.rawValue == currentImage.id.rawValue,
      ),
    );
    return idx >= 0 ? idx : 0;
  }

  /// 指定されたページインデックスの画像に遷移する
  void setCurrentPageIndex(int pageIndex) {
    if (pageIndex < 0 || pageIndex >= state.pages.length) return;

    final targetPage = state.pages[pageIndex];
    if (targetPage.entries.isEmpty) return;

    // 代表画像として、ページ内の最初の画像のインデックスを特定して遷移する
    final images = ref.read(galleryImagesProvider).value ?? [];
    final targetImage = targetPage.entries.first;
    final index = images.indexWhere(
      (img) => img.id.rawValue == targetImage.id.rawValue,
    );

    if (index >= 0) {
      setCurrentIndex(index);
    }
  }

  /// 次のページに遷移する (見開き対応)
  void goToNext() {
    if (state.displayMode == ViewerDisplayMode.double) {
      final currentIdx = currentPageIndex;
      if (currentIdx < state.pages.length - 1) {
        setCurrentPageIndex(currentIdx + 1);
      }
    } else {
      if (state.currentIndex < state.totalCount - 1) {
        setCurrentIndex(state.currentIndex + 1);
      }
    }
  }

  /// 前のページに遷移する (見開き対応)
  void goToPrevious() {
    if (state.displayMode == ViewerDisplayMode.double) {
      final currentIdx = currentPageIndex;
      if (currentIdx > 0) {
        setCurrentPageIndex(currentIdx - 1);
      }
    } else {
      if (state.currentIndex > 0) {
        setCurrentIndex(state.currentIndex - 1);
      }
    }
  }
}
