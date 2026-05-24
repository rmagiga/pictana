/// ギャラリー機能の Riverpod Provider 定義 (設計書 §14)
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/providers/repository_providers.dart';
import '../../application/usecases/gallery/load_folder_images_usecase.dart';
import '../../application/usecases/gallery/load_thumbnail_usecase.dart';
import '../../application/usecases/gallery/sort_images_usecase.dart';
import '../../domain/entities/folder_entry.dart';
import '../../domain/entities/image_entry.dart';
import '../../domain/value_objects/sort_option.dart';
import '../../domain/repositories/image_repository.dart';
import '../../application/usecases/gallery/search_controller.dart';
import 'app_lifecycle_provider.dart';
import 'package:flutter/widgets.dart';

part 'gallery_providers.g.dart';

// ---------------------------------------------------------------------------
// UseCase Providers
// ---------------------------------------------------------------------------

@riverpod
LoadFolderImagesUseCase loadFolderImagesUseCase(Ref ref) {
  return LoadFolderImagesUseCase(
    imageRepository: ref.watch(imageRepositoryProvider),
  );
}

@riverpod
LoadThumbnailUseCase loadThumbnailUseCase(Ref ref) {
  return LoadThumbnailUseCase(
    thumbnailRepository: ref.watch(thumbnailRepositoryProvider),
  );
}

@riverpod
SortImagesUseCase sortImagesUseCase(Ref ref) {
  return SortImagesUseCase(database: ref.watch(appDatabaseProvider));
}

// ---------------------------------------------------------------------------
// State Providers
// ---------------------------------------------------------------------------

/// ギャラリーの同期状態（差分スキャン中かどうか）を表すプロバイダ
@Riverpod(keepAlive: true)
class GallerySyncState extends _$GallerySyncState {
  @override
  bool build() => false;

  void setSyncing(bool syncing) {
    state = syncing;
  }
}

/// 現在選択されているフォルダ
@Riverpod(keepAlive: true)
class CurrentFolder extends _$CurrentFolder {
  @override
  FolderEntry? build() => null;

  void setFolder(FolderEntry folder) {
    state = folder;
  }
}

/// ギャラリーのソート設定
@Riverpod(keepAlive: true)
class GallerySortOption extends _$GallerySortOption {
  /// ユーザーが updateOption() で明示的に変更したかどうかのフラグ。
  /// _loadInitial() の非同期完了時にユーザー設定を上書きしないためのガード。
  bool _userHasUpdated = false;

  @override
  SortOption build() {
    _userHasUpdated = false;
    _loadInitial();
    return SortOption.defaultOption;
  }

  Future<void> _loadInitial() async {
    final useCase = ref.read(sortImagesUseCaseProvider);
    final loaded = await useCase.loadSortOption();
    // ユーザーが既に updateOption() で変更していた場合は DB 値で上書きしない
    if (!_userHasUpdated) {
      state = loaded;
    }
  }

  Future<void> updateOption(SortOption newOption) async {
    _userHasUpdated = true;
    state = newOption;
    final useCase = ref.read(sortImagesUseCaseProvider);
    await useCase.saveSortOption(newOption);
  }
}

/// ギャラリー画像リストを管理する AsyncNotifier
///
/// ImageRepository の Stream を内部で購読し、500ms デバウンスで
/// UI への通知を制御する。Stream 完了時は即座に通知する。
@Riverpod(keepAlive: true)
class GalleryImages extends _$GalleryImages {
  StreamSubscription<List<ImageEntry>>? _subscription;
  Timer? _debounceTimer;
  List<ImageEntry> _buffer = const [];

  /// 現在購読中のフォルダ（フォルダ変更検知用）
  FolderEntry? _currentFolder;

  /// デバウンス間隔（テストでオーバーライド可能にするため @visibleForTesting）
  @visibleForTesting
  static Duration debounceDuration = const Duration(milliseconds: 500);

  @override
  FutureOr<List<ImageEntry>> build() {
    final folder = ref.watch(currentFolderProvider);
    final sort = ref.watch(gallerySortOptionProvider);
    final filterState = ref.watch(searchControllerProvider);

    // Provider 破棄時にリソースをクリーンアップ
    ref.onDispose(_cleanup);

    final filter = ImageFilter(
      nameQuery: filterState.query.isEmpty ? null : filterState.query,
      mimeTypes: filterState.selectedMimeType == null ? null : {filterState.selectedMimeType!},
    );

    // アプリ復帰（resumed）時に差分チェック同期を走らせる
    ref.listen<AppLifecycleState>(appLifecycleProvider, (previous, next) {
      if (next == AppLifecycleState.resumed && folder != null) {
        // loading に遷移させずに、静かに再スキャン（再購読）を開始する
        _subscribe(folder, sort, filter);
      }
    });

    if (folder == null) {
      _cleanup();
      _currentFolder = null;
      return const [];
    }

    // フォルダが変わった場合: 前回の購読をキャンセルし loading へ遷移
    // ソートやフィルタのみ変わった場合: 既存データを保持しつつ再購読
    final isFolderChanged = _currentFolder != folder;
    _currentFolder = folder;

    // 購読を開始
    _subscribe(folder, sort, filter);

    if (!isFolderChanged && state.hasValue) {
      // ソートやフィルタオプション変更: 現在のデータに新しいソートを即座に適用して返す
      final sorted = _applySortToCurrentData(state.value!, sort);
      return sorted;
    }

    // フォルダ変更または初回: loading 状態で待機
    return Completer<List<ImageEntry>>().future;
  }

  /// Stream を購読し、デバウンスロジックを適用する
  void _subscribe(FolderEntry folder, SortOption sort, ImageFilter filter) {
    // 前回の購読をキャンセル
    _cleanup();
    _buffer = const [];

    // 同期状態を開始にする（build 中の副作用によるクラッシュを避けるためマイクロタスクで遅延実行）
    Future.microtask(() {
      ref.read(gallerySyncStateProvider.notifier).setSyncing(true);
    });

    final useCase = ref.read(loadFolderImagesUseCaseProvider);
    final stream = useCase.execute(folder: folder, sort: sort, filter: filter);

    _subscription = stream.listen(_onData, onError: _onError, onDone: _onDone);
  }

  /// Stream から中間 emit を受信した時の処理
  void _onData(List<ImageEntry> images) {
    _buffer = images;

    // 一度 AsyncData になった後はインクリメンタル読み込み中に
    // AsyncLoading へ遷移させない（Requirement 1.4）
    // デバウンスタイマーをリセット
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, _onDebounceTimeout);
  }

  /// デバウンスタイマー発火時: バッファの内容を state へ反映
  void _onDebounceTimeout() {
    state = AsyncData(_buffer);
  }

  /// Stream 完了時: タイマーをキャンセルし即座に最終結果を反映
  void _onDone() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    state = AsyncData(_buffer);
    Future.microtask(() {
      ref.read(gallerySyncStateProvider.notifier).setSyncing(false);
    });
  }

  /// Stream エラー時: タイマーをキャンセルし AsyncError へ遷移
  void _onError(Object error, StackTrace stackTrace) {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    // Riverpod の AsyncError は自動的に previous を保持する
    state = AsyncError<List<ImageEntry>>(error, stackTrace);
    Future.microtask(() {
      ref.read(gallerySyncStateProvider.notifier).setSyncing(false);
    });
  }

  /// リソースのクリーンアップ
  void _cleanup() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _subscription?.cancel();
    _subscription = null;
  }

  /// 現在保持している画像リストに新しいソートオプションを即座に適用する
  ///
  /// リポジトリの `_sortEntries()` と同一のソートロジックを使用する。
  /// ソートオプション変更時の即時レスポンスのために使用し、
  /// 再購読完了後はリポジトリからソート済みデータが届く。
  /// (Requirement 1.6, 3.3)
  List<ImageEntry> _applySortToCurrentData(
    List<ImageEntry> images,
    SortOption sort,
  ) {
    if (images.isEmpty) return images;
    final sorted = List<ImageEntry>.of(images);
    final asc = sort.isAscending;
    sorted.sort(
      (a, b) => switch (sort.field) {
        SortField.name =>
          asc ? a.name.compareTo(b.name) : b.name.compareTo(a.name),
        SortField.date =>
          asc
              ? a.modifiedAt.compareTo(b.modifiedAt)
              : b.modifiedAt.compareTo(a.modifiedAt),
        SortField.size =>
          asc ? a.size.compareTo(b.size) : b.size.compareTo(a.size),
        SortField.type =>
          asc
              ? a.extension.compareTo(b.extension)
              : b.extension.compareTo(a.extension),
      },
    );
    return sorted;
  }
}

/// フォルダ内の画像総数
@riverpod
Future<int> galleryImageCount(Ref ref) async {
  final folder = ref.watch(currentFolderProvider);
  if (folder == null) return 0;

  final useCase = ref.watch(loadFolderImagesUseCaseProvider);
  return useCase.count(folder: folder);
}
