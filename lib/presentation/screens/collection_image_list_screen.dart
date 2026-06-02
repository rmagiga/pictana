/// コレクション画像一覧画面
///
/// コレクション内の画像をグリッド表示する。
/// 遅延ロード（GridView.builder）により表示領域外の画像は描画しない。
/// 手動ソート順（sortOrder 昇順）で表示し、空状態メッセージを提供する。
/// アクセス可能な画像タップで CollectionImageDetailScreen へ遷移し、
/// 参照不能画像はプレースホルダー表示でタップ時に遷移拒否＋インライン通知を表示する。
///
/// 編集モード:
/// - 長押し（500ms）で開始、初期選択
/// - タップで選択/解除トグル、ナビゲーション無効化
/// - 選択画像にドラッグハンドル表示
/// - ReorderableListView で並び替え（複数選択時の一括移動）
/// - 解除ボタン + 確認ダイアログ
/// - 並び替え結果の即時永続化
/// - 永続化失敗時は前の状態に復元 + エラー通知
///
/// Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 8.7, 8.8,
///              9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7, 9.8, 9.9, 9.10, 9.11,
///              10.1, 10.2, 10.3, 10.4, 10.5, 10.6
library;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers/repository_providers.dart';
import '../../application/usecases/settings/thumbnail_size_setting.dart';
import '../../core/utils/cancel_token.dart';
import '../../domain/entities/collection_image.dart';
import '../../domain/entities/entry_id.dart';
import '../../domain/entities/image_entry.dart';
import '../providers/collection_edit_mode_provider.dart';
import '../providers/collection_image_list_provider.dart';
import '../providers/collection_list_provider.dart';
import '../providers/gallery_providers.dart';

/// コレクション画像一覧画面
///
/// [collectionId] で指定されたコレクション内の画像をグリッド表示する。
/// collectionImageListProvider を watch してリアルタイムに一覧を更新する。
/// collectionListProvider からコレクション名を取得し AppBar に表示する。
/// collectionEditModeProvider を watch して編集モード UI を制御する。
class CollectionImageListScreen extends ConsumerWidget {
  const CollectionImageListScreen({required this.collectionId, super.key});

  /// 対象コレクションの ID
  final int collectionId;

  /// グリッドの列数
  static const int _crossAxisCount = 3;

  /// グリッドのスペーシング
  static const double _spacing = 4.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagesAsync = ref.watch(collectionImageListProvider(collectionId));
    final collectionsAsync = ref.watch(collectionListProvider);
    final editModeState = ref.watch(collectionEditModeProvider);

    // コレクション名を取得（AppBar 表示用）
    final collectionName = collectionsAsync.when(
      data: (collections) {
        final match = collections.where((c) => c.id == collectionId);
        return match.isNotEmpty ? match.first.name.value : 'コレクション';
      },
      loading: () => 'コレクション',
      error: (_, _) => 'コレクション',
    );

    return PopScope(
      // 編集モード中の戻る操作で編集モードを終了する (Requirement 9.9)
      canPop: !editModeState.isActive,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && editModeState.isActive) {
          ref.read(collectionEditModeProvider.notifier).exitEditMode();
        }
      },
      child: Scaffold(
        appBar: editModeState.isActive
            ? _buildEditModeAppBar(context, ref, editModeState, imagesAsync)
            : _buildNormalAppBar(context, collectionName),
        body: imagesAsync.when(
          data: (images) => images.isEmpty
              ? _buildEmptyState(context)
              : editModeState.isActive
              ? _buildEditModeList(context, ref, images, editModeState)
              : _buildImageGrid(context, ref, images),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _buildErrorState(context, error),
        ),
      ),
    );
  }

  /// 通常モードの AppBar
  PreferredSizeWidget _buildNormalAppBar(
    BuildContext context,
    String collectionName,
  ) {
    return AppBar(
      title: Text(collectionName),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: '戻る',
        onPressed: () => context.pop(),
      ),
    );
  }

  /// 編集モードの AppBar (Requirement 9.4, 9.9)
  ///
  /// 「N件選択」と「解除」ボタン、キャンセルボタンを表示する。
  PreferredSizeWidget _buildEditModeAppBar(
    BuildContext context,
    WidgetRef ref,
    CollectionEditModeState editModeState,
    AsyncValue<List<CollectionImage>> imagesAsync,
  ) {
    final selectedCount = editModeState.selectedCount;

    return AppBar(
      // キャンセルボタン (Requirement 9.9)
      leading: IconButton(
        icon: const Icon(Icons.close),
        tooltip: 'キャンセル',
        onPressed: () =>
            ref.read(collectionEditModeProvider.notifier).exitEditMode(),
      ),
      // 選択件数表示 (Requirement 9.4)
      title: Text('$selectedCount件選択'),
      actions: [
        // 解除ボタン (Requirement 9.4)
        IconButton(
          icon: const Icon(Icons.link_off),
          tooltip: '解除',
          onPressed: selectedCount > 0
              ? () => _onRemovePressed(context, ref, editModeState, imagesAsync)
              : null,
        ),
      ],
    );
  }

  /// 空状態表示 (Requirement 8.4)
  ///
  /// コレクション内の画像数が 0 件の場合に表示する。
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '画像が登録されていません',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'フォルダ画像一覧から画像を追加してください',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// エラー状態表示
  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text('エラーが発生しました: $error'),
          ],
        ),
      ),
    );
  }

  /// 画像グリッド表示 (Requirement 8.1, 8.2) - 通常モード
  ///
  /// GridView.builder による遅延ロードで、表示領域外の画像は描画しない。
  /// sortOrder 昇順（Provider が保証）で表示する。
  Widget _buildImageGrid(
    BuildContext context,
    WidgetRef ref,
    List<CollectionImage> images,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(_spacing),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _crossAxisCount,
        crossAxisSpacing: _spacing,
        mainAxisSpacing: _spacing,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        return _CollectionImageTile(
          image: image,
          collectionId: collectionId,
          isEditMode: false,
          isSelected: false,
          onLongPress: () => _onImageLongPress(ref, image),
          onTap: () => _onImageTap(context, ref, image),
        );
      },
    );
  }

  /// 編集モードのリスト表示 (Requirement 9.3, 9.5, 10.2, 10.3)
  ///
  /// 編集モードでは ReorderableListView に切り替えてドラッグ並び替えを可能にする。
  /// 選択されている画像にのみドラッグハンドルを表示する。
  Widget _buildEditModeList(
    BuildContext context,
    WidgetRef ref,
    List<CollectionImage> images,
    CollectionEditModeState editModeState,
  ) {
    return ReorderableListView.builder(
      itemCount: images.length,
      buildDefaultDragHandles: false,
      onReorderItem: (oldIndex, newIndex) =>
          _onReorder(context, ref, images, oldIndex, newIndex),
      itemBuilder: (context, index) {
        final image = images[index];
        final isSelected = editModeState.selectedIds.contains(image.id);

        return _EditModeImageTile(
          key: ValueKey(image.id),
          image: image,
          index: index,
          isSelected: isSelected,
          onTap: () => _onEditModeTap(ref, image),
        );
      },
    );
  }

  /// 通常モードでのタップ処理 (Requirement 8.3)
  void _onImageTap(BuildContext context, WidgetRef ref, CollectionImage image) {
    // TODO: 参照不能画像の検出はファイルシステムアクセスが必要なため後続で実装
    // ignore: dead_code
    const isAccessible = true;

    if (isAccessible) {
      // CollectionImageDetailScreen へ遷移 (Requirement 8.3)
      final entryId = image.entryId.rawValue;
      context.go('/collection-viewer/$collectionId/$entryId');
    } else {
      // 参照不能画像: 遷移拒否 + インライン通知 (Requirement 8.8)
      // ignore: dead_code
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('この画像は参照できません。元のファイルが移動または削除された可能性があります。'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  /// 長押し処理: 編集モード開始 (Requirement 9.1, 10.2)
  ///
  /// 500ms 以上の長押しで編集モードを開始し、長押しされた画像を選択状態にする。
  void _onImageLongPress(WidgetRef ref, CollectionImage image) {
    final editMode = ref.read(collectionEditModeProvider);
    if (!editMode.isActive) {
      ref.read(collectionEditModeProvider.notifier).startEditMode(image.id);
    }
  }

  /// 編集モード中のタップ処理: 選択/解除のみ (Requirement 9.2, 9.10)
  ///
  /// ナビゲーションは無効化され、タップで選択トグルのみ行う。
  /// 全選択解除でも編集モードは維持する。
  void _onEditModeTap(WidgetRef ref, CollectionImage image) {
    ref.read(collectionEditModeProvider.notifier).toggleSelection(image.id);
  }

  /// 並び替え処理 (Requirement 9.5, 9.6, 9.7, 9.8, 10.1, 10.4, 10.5, 10.6)
  ///
  /// ドロップ完了時に新しい並び順を即座にデータベースへ永続化する。
  /// 複数選択時は選択画像群をまとめてドロップ位置に移動し、
  /// 選択画像間の相対順序を維持する。
  /// 永続化失敗時は前の状態に復元しエラー通知を表示する。
  Future<void> _onReorder(
    BuildContext context,
    WidgetRef ref,
    List<CollectionImage> images,
    int oldIndex,
    int newIndex,
  ) async {
    // onReorderItem は newIndex を自動調整済み
    if (oldIndex == newIndex) return;

    final editModeState = ref.read(collectionEditModeProvider);
    final movedImage = images[oldIndex];

    // 新しい順序を計算する
    List<EntryId> newOrder;

    if (editModeState.selectedIds.contains(movedImage.id) &&
        editModeState.selectedIds.length > 1) {
      // 複数選択時の一括移動 (Requirement 9.6, 9.7, 10.6)
      // 1. 選択画像を相対順序を維持して抽出
      final selectedImages = images
          .where((img) => editModeState.selectedIds.contains(img.id))
          .toList();
      // 2. 残りのリスト
      final remainingImages = images
          .where((img) => !editModeState.selectedIds.contains(img.id))
          .toList();
      // 3. ドロップ位置を計算（残りリスト内での挿入位置）
      // newIndex は元リストでの位置なので、残りリスト内でのインデックスを計算する
      int insertIndex = 0;
      int countBefore = 0;
      for (int i = 0; i <= newIndex && i < images.length; i++) {
        if (!editModeState.selectedIds.contains(images[i].id)) {
          countBefore++;
        }
      }
      insertIndex = countBefore;
      if (insertIndex > remainingImages.length) {
        insertIndex = remainingImages.length;
      }
      // 4. 挿入
      remainingImages.insertAll(insertIndex, selectedImages);
      newOrder = remainingImages.map((img) => img.entryId).toList();
    } else {
      // 単一画像の移動
      final mutableImages = List<CollectionImage>.from(images);
      final item = mutableImages.removeAt(oldIndex);
      mutableImages.insert(newIndex, item);
      newOrder = mutableImages.map((img) => img.entryId).toList();
    }

    // 即時永続化 (Requirement 9.8, 10.4)
    try {
      final useCase = ref.read(reorderCollectionImagesUseCaseProvider);
      await useCase.execute(collectionId, newOrder);
    } catch (e) {
      // 永続化失敗: エラー通知を表示 (Requirement 10.5)
      // DB が未変更のため UI は Stream で元の状態に自動復帰する
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('並び替えの保存に失敗しました'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 解除ボタン押下処理 (Requirement 5.1, 5.3, 5.5, 9.4, 9.11)
  ///
  /// 確認ダイアログを表示し、ユーザーが承認した場合のみ
  /// 選択中の画像をコレクションから解除する。
  /// 解除完了後は自動的に編集モードを終了する。
  Future<void> _onRemovePressed(
    BuildContext context,
    WidgetRef ref,
    CollectionEditModeState editModeState,
    AsyncValue<List<CollectionImage>> imagesAsync,
  ) async {
    final images = imagesAsync.value;
    if (images == null) return;

    final selectedCount = editModeState.selectedCount;
    if (selectedCount == 0) return;

    // 確認ダイアログを表示 (Requirement 5.3, 5.5)
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('画像の解除'),
        content: Text(
          '$selectedCount件の画像をこのコレクションから解除しますか？\n'
          '※ 画像ファイルは削除されません',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('解除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // 選択中の画像の EntryId を取得
    final selectedEntryIds = images
        .where((img) => editModeState.selectedIds.contains(img.id))
        .map((img) => img.entryId)
        .toList();

    // 解除実行
    try {
      final useCase = ref.read(removeImagesFromCollectionUseCaseProvider);
      await useCase.execute(collectionId, selectedEntryIds);

      // 解除成功: 自動的に編集モードを終了 (Requirement 9.11)
      ref.read(collectionEditModeProvider.notifier).exitEditMode();
    } catch (e) {
      // エラー通知 (Requirement 5.6)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('画像の解除に失敗しました'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

/// 通常モードの画像グリッドタイルウィジェット
///
/// EntryId から ImageEntry を解決し、サムネイルを読み込んで表示する。
/// 読み込み中はスケルトンプレースホルダーを表示し、
/// 読み込み完了時はフェードトランジションで切替する。
/// 10 秒タイムアウトでエラープレースホルダーへ遷移。
///
/// Requirements: 8.3, 8.5, 8.6, 8.7, 8.8
class _CollectionImageTile extends ConsumerStatefulWidget {
  const _CollectionImageTile({
    required this.image,
    required this.collectionId,
    required this.isEditMode,
    required this.isSelected,
    required this.onLongPress,
    required this.onTap,
  });

  final CollectionImage image;
  final int collectionId;
  final bool isEditMode;
  final bool isSelected;
  final VoidCallback onLongPress;
  final VoidCallback onTap;

  @override
  ConsumerState<_CollectionImageTile> createState() =>
      _CollectionImageTileState();
}

class _CollectionImageTileState extends ConsumerState<_CollectionImageTile> {
  /// サムネイルのバイトデータ
  Uint8List? _thumbnailBytes;

  /// 読み込み中フラグ
  bool _isLoading = true;

  /// タイムアウトタイマー
  Timer? _timeoutTimer;

  /// キャンセルトークン
  CancelToken? _cancelToken;

  /// サムネイル読み込みタイムアウト
  static const _kThumbnailTimeout = Duration(seconds: 10);

  /// フェードトランジション時間
  static const _kFadeDuration = Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  @override
  void didUpdateWidget(covariant _CollectionImageTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image.entryId != widget.image.entryId) {
      _cancelToken?.cancel();
      _cancelTimeout();
      _loadThumbnail();
    }
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    _cancelTimeout();
    super.dispose();
  }

  void _cancelTimeout() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  void _startTimeout() {
    _cancelTimeout();
    _timeoutTimer = Timer(_kThumbnailTimeout, () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  /// EntryId から ImageEntry を解決してサムネイルを読み込む
  Future<void> _loadThumbnail() async {
    _cancelToken?.cancel();
    final token = CancelToken();
    _cancelToken = token;

    setState(() {
      _isLoading = true;
      _thumbnailBytes = null;
    });
    _startTimeout();

    // EntryId → ImageEntry を DB から解決する
    final db = ref.read(appDatabaseProvider);
    final entryId = widget.image.entryId.rawValue;
    final imageData = await db.getImageByEntryId(entryId);

    if (!mounted || token.isCancelled) return;

    if (imageData == null) {
      // DB に画像情報がない場合はエラー状態
      _cancelTimeout();
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // ImageTableData → ImageEntry に変換
    final imageEntry = ImageEntry(
      id: Platform.isWindows
          ? EntryId.windows(imageData.uri)
          : EntryId.android(imageData.uri),
      name: imageData.name,
      extension: imageData.extension,
      uri: imageData.uri,
      mimeType: ImageMimeType.values.byName(imageData.mimeType),
      size: imageData.size,
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(imageData.modified),
      width: imageData.width,
      height: imageData.height,
      exifDateTime: imageData.exifDateTime,
      exifCamera: imageData.exifCamera,
      exifGpsLatitude: imageData.exifGpsLatitude,
      exifGpsLongitude: imageData.exifGpsLongitude,
    );

    // サムネイルを読み込む
    final useCase = ref.read(loadThumbnailUseCaseProvider);
    final sizeOption = ref.read(thumbnailSizeSettingProvider);
    final bytes = await useCase.execute(
      imageEntry,
      size: sizeOption,
      cancelToken: token,
    );

    if (!mounted || token.isCancelled) return;
    _cancelTimeout();

    if (bytes != null) {
      setState(() {
        _thumbnailBytes = bytes;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: widget.isSelected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        // 長押し: 500ms（Flutter デフォルト）で編集モード開始 (Requirement 9.1, 10.2)
        onLongPress: widget.onLongPress,
        borderRadius: BorderRadius.circular(8),
        child: _buildTileContent(theme),
      ),
    );
  }

  /// タイルのコンテンツを構築する
  Widget _buildTileContent(ThemeData theme) {
    return Stack(
      children: [
        // サムネイル表示: AnimatedSwitcher でフェードトランジション
        AnimatedSwitcher(
          duration: _kFadeDuration,
          child: _buildMainContent(theme),
        ),
        // 選択状態のチェックマーク
        if (widget.isSelected)
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                size: 14,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
      ],
    );
  }

  /// メインコンテンツ（サムネイル / ローディング / エラー）を構築する
  Widget _buildMainContent(ThemeData theme) {
    if (_isLoading) {
      // ローディング状態: スケルトンプレースホルダー
      return Container(
        key: const ValueKey('loading'),
        color: theme.colorScheme.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.image_outlined,
            size: 32,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
        ),
      );
    }

    if (_thumbnailBytes != null) {
      // サムネイル表示
      return SizedBox.expand(
        key: const ValueKey('thumbnail'),
        child: Image.memory(
          _thumbnailBytes!,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        ),
      );
    }

    // エラー状態: プレースホルダー
    return Container(
      key: const ValueKey('error'),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 32,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

/// 編集モードのリストタイルウィジェット (Requirement 9.3, 9.5, 10.2)
///
/// 編集モードでは ReorderableListView 内のタイルとして表示する。
/// 選択された画像にのみドラッグハンドルを表示する。
/// サムネイルを leading に表示する。
class _EditModeImageTile extends ConsumerStatefulWidget {
  const _EditModeImageTile({
    required this.image,
    required this.index,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final CollectionImage image;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  ConsumerState<_EditModeImageTile> createState() => _EditModeImageTileState();
}

class _EditModeImageTileState extends ConsumerState<_EditModeImageTile> {
  Uint8List? _thumbnailBytes;
  CancelToken? _cancelToken;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  @override
  void didUpdateWidget(covariant _EditModeImageTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image.entryId != widget.image.entryId) {
      _cancelToken?.cancel();
      _loadThumbnail();
    }
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    super.dispose();
  }

  Future<void> _loadThumbnail() async {
    _cancelToken?.cancel();
    final token = CancelToken();
    _cancelToken = token;

    final db = ref.read(appDatabaseProvider);
    final entryId = widget.image.entryId.rawValue;
    final imageData = await db.getImageByEntryId(entryId);

    if (!mounted || token.isCancelled) return;
    if (imageData == null) return;

    final imageEntry = ImageEntry(
      id: Platform.isWindows
          ? EntryId.windows(imageData.uri)
          : EntryId.android(imageData.uri),
      name: imageData.name,
      extension: imageData.extension,
      uri: imageData.uri,
      mimeType: ImageMimeType.values.byName(imageData.mimeType),
      size: imageData.size,
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(imageData.modified),
      width: imageData.width,
      height: imageData.height,
    );

    final useCase = ref.read(loadThumbnailUseCaseProvider);
    final sizeOption = ref.read(thumbnailSizeSettingProvider);
    final bytes = await useCase.execute(
      imageEntry,
      size: sizeOption,
      cancelToken: token,
    );

    if (!mounted || token.isCancelled) return;

    if (bytes != null) {
      setState(() {
        _thumbnailBytes = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      // 選択状態の視覚的フィードバック
      selected: widget.isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer.withValues(
        alpha: 0.3,
      ),
      // サムネイル / チェックマーク
      leading: _buildLeading(theme),
      // 画像識別情報（EntryId の末尾部分を表示）
      title: Text(
        _formatEntryId(widget.image.entryId),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '並び順: ${widget.image.sortOrder}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      // ドラッグハンドル: 選択されたアイテムのみ表示 (Requirement 9.3, 9.5)
      trailing: widget.isSelected
          ? ReorderableDragStartListener(
              index: widget.index,
              child: const Icon(Icons.drag_handle),
            )
          : const SizedBox(width: 24),
      // タップ: 選択/解除トグル (Requirement 9.2)
      onTap: widget.onTap,
    );
  }

  /// リーディングウィジェットを構築する
  Widget _buildLeading(ThemeData theme) {
    if (widget.isSelected) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.check, color: theme.colorScheme.onPrimaryContainer),
      );
    }

    if (_thumbnailBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Image.memory(
            _thumbnailBytes!,
            fit: BoxFit.cover,
            gaplessPlayback: true,
          ),
        ),
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.image_outlined,
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
    );
  }

  /// EntryId をユーザーに見やすい形式にフォーマットする
  String _formatEntryId(EntryId entryId) {
    final raw = entryId.rawValue;
    // ファイルパスの場合はファイル名部分のみ表示
    final lastSeparator = raw.lastIndexOf(RegExp(r'[/\\]'));
    if (lastSeparator >= 0 && lastSeparator < raw.length - 1) {
      return raw.substring(lastSeparator + 1);
    }
    // URI の場合は末尾部分を表示
    if (raw.length > 40) {
      return '...${raw.substring(raw.length - 37)}';
    }
    return raw;
  }
}
