/// コレクション一覧画面
///
/// 全コレクションをリスト表示し、名前・画像数・サムネイル・更新日時を表示する。
/// 新規作成ボタン、空状態メッセージ、アイテムタップで画像一覧へ遷移を提供する。
/// 長押しで編集モードに入り、選択・削除・リネーム・並び替えを可能にする。
///
/// Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 7.8, 7.9
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/collection.dart';
import '../providers/collection_edit_mode_provider.dart';
import '../providers/collection_list_provider.dart';
import '../widgets/collection_create_dialog.dart';
import '../widgets/collection_rename_dialog.dart';
import '../widgets/delete_confirm_dialog.dart';

/// コレクション一覧画面
///
/// collectionListProvider を watch してリアルタイムに一覧を更新する。
/// collectionEditModeProvider を watch して編集モード UI を制御する。
/// 空状態時は新規作成への導線を表示する。
class CollectionListScreen extends ConsumerWidget {
  const CollectionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionListProvider);
    final editModeState = ref.watch(collectionEditModeProvider);

    return Scaffold(
      appBar: editModeState.isActive
          ? _buildEditModeAppBar(context, ref, editModeState, collectionsAsync)
          : _buildNormalAppBar(context, ref, collectionsAsync),
      body: collectionsAsync.when(
        data: (collections) => collections.isEmpty
            ? _buildEmptyState(context)
            : _buildCollectionList(context, ref, collections, editModeState),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
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
        ),
      ),
      // 新規作成 FAB (Requirement 6.3) - 編集モード中は非表示
      floatingActionButton: editModeState.isActive
          ? null
          : FloatingActionButton(
              onPressed: () => _createCollection(context),
              tooltip: '新規コレクション作成',
              child: const Icon(Icons.add),
            ),
    );
  }

  /// 通常モードの AppBar
  PreferredSizeWidget _buildNormalAppBar(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Collection>> collectionsAsync,
  ) {
    return AppBar(
      title: const Text('コレクション'),
      actions: [
        // 削除ボタン: コレクションが1件以上ある場合のみ有効
        collectionsAsync.when(
          data: (collections) => collections.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: '削除',
                  onPressed: () => _showDeleteDialog(context, ref, collections),
                )
              : const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  /// 編集モードの AppBar (Requirement 7.4, 7.5, 7.6, 7.7)
  ///
  /// 選択件数（「N件選択」）、削除ボタン、キャンセルボタン、
  /// 選択件数1件の場合のみリネームボタンを表示する。
  PreferredSizeWidget _buildEditModeAppBar(
    BuildContext context,
    WidgetRef ref,
    CollectionEditModeState editModeState,
    AsyncValue<List<Collection>> collectionsAsync,
  ) {
    final selectedCount = editModeState.selectedCount;

    return AppBar(
      // キャンセルボタン (Requirement 7.7)
      leading: IconButton(
        icon: const Icon(Icons.close),
        tooltip: 'キャンセル',
        onPressed: () =>
            ref.read(collectionEditModeProvider.notifier).exitEditMode(),
      ),
      // 選択件数表示 (Requirement 7.4)
      title: Text('$selectedCount件選択'),
      actions: [
        // リネームボタン: 1件選択時のみ表示 (Requirement 7.6)
        if (selectedCount == 1)
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'リネーム',
            onPressed: () =>
                _onRenamePressed(context, ref, editModeState, collectionsAsync),
          ),
        // 削除ボタン: 選択件数0件で無効化 (Requirement 7.5)
        IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: '削除',
          onPressed: selectedCount > 0
              ? () => _onEditModeDeletePressed(
                  context,
                  ref,
                  editModeState,
                  collectionsAsync,
                )
              : null,
        ),
      ],
    );
  }

  /// 空状態表示 (Requirement 6.7)
  ///
  /// コレクションが0件のとき、メッセージと新規作成への導線を表示する。
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.collections_bookmark_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'コレクションがありません',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '画像を論理的にグループ化して管理できます',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () => _createCollection(context),
              icon: const Icon(Icons.add),
              label: const Text('新規コレクションを作成'),
            ),
          ],
        ),
      ),
    );
  }

  /// コレクション一覧リスト (Requirement 6.1, 6.2, 6.6, 7.1, 7.2, 7.3)
  Widget _buildCollectionList(
    BuildContext context,
    WidgetRef ref,
    List<Collection> collections,
    CollectionEditModeState editModeState,
  ) {
    return ReorderableListView.builder(
      itemCount: collections.length,
      onReorderItem: (oldIndex, newIndex) =>
          _onReorder(ref, collections, oldIndex, newIndex),
      buildDefaultDragHandles: false,
      itemBuilder: (context, index) {
        final collection = collections[index];
        final isSelected = editModeState.selectedIds.contains(collection.id);

        return _CollectionListTile(
          key: ValueKey(collection.id),
          collection: collection,
          index: index,
          isEditMode: editModeState.isActive,
          isSelected: isSelected,
          onTap: () => _onItemTap(context, ref, collection, editModeState),
          onLongPress: () => _onItemLongPress(ref, collection),
        );
      },
    );
  }

  /// アイテムタップ処理 (Requirement 7.2)
  ///
  /// 編集モード中はタップで選択/解除のみ。通常モードでは画像一覧へ遷移。
  void _onItemTap(
    BuildContext context,
    WidgetRef ref,
    Collection collection,
    CollectionEditModeState editModeState,
  ) {
    if (editModeState.isActive) {
      // 編集モード中: 選択トグルのみ (Requirement 7.2)
      ref
          .read(collectionEditModeProvider.notifier)
          .toggleSelection(collection.id);
    } else {
      // 通常モード: 画像一覧画面へ遷移 (Requirement 6.6)
      _navigateToImageList(context, collection);
    }
  }

  /// アイテム長押し処理 (Requirement 7.1)
  ///
  /// 500ms 以上の長押しで編集モードを開始し、長押しされたアイテムを選択状態にする。
  void _onItemLongPress(WidgetRef ref, Collection collection) {
    final editMode = ref.read(collectionEditModeProvider);
    if (!editMode.isActive) {
      // 編集モード開始: 長押しされたアイテムを初期選択 (Requirement 7.1)
      ref
          .read(collectionEditModeProvider.notifier)
          .startEditMode(collection.id);
    }
  }

  /// 並び替え処理
  void _onReorder(
    WidgetRef ref,
    List<Collection> collections,
    int oldIndex,
    int newIndex,
  ) {
    // onReorderItem は newIndex を自動調整済み
    if (oldIndex == newIndex) return;

    final orderedIds = collections.map((c) => c.id).toList();
    final movedId = orderedIds.removeAt(oldIndex);
    orderedIds.insert(newIndex, movedId);

    ref.read(reorderCollectionsUseCaseProvider).execute(orderedIds);
  }

  /// コレクション画像一覧画面へ遷移 (Requirement 6.6)
  void _navigateToImageList(BuildContext context, Collection collection) {
    context.go('/gallery?collectionId=${collection.id}');
  }

  /// 新規コレクション作成ダイアログを表示 (Requirement 6.3)
  Future<void> _createCollection(BuildContext context) async {
    await showCollectionCreateDialog(context);
  }

  /// 通常モードの削除確認ダイアログを表示 (Requirement 6.4, 6.5)
  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    List<Collection> collections,
  ) async {
    final names = collections.map((c) => c.name.value).toList();
    final confirmed = await showDeleteConfirmDialog(context, names);

    if (confirmed == true) {
      final ids = collections.map((c) => c.id).toList();
      await ref.read(deleteCollectionUseCaseProvider).execute(ids);
    }
  }

  /// 編集モードの削除ボタン押下処理 (Requirement 7.8, 7.9)
  ///
  /// 選択中のコレクションの削除確認ダイアログを表示し、
  /// 確認後に削除を実行して自動的に編集モードを終了する。
  Future<void> _onEditModeDeletePressed(
    BuildContext context,
    WidgetRef ref,
    CollectionEditModeState editModeState,
    AsyncValue<List<Collection>> collectionsAsync,
  ) async {
    final collections = collectionsAsync.value;
    if (collections == null) return;

    // 選択中のコレクションを取得
    final selectedCollections = collections
        .where((c) => editModeState.selectedIds.contains(c.id))
        .toList();

    if (selectedCollections.isEmpty) return;

    // 削除確認ダイアログ表示 (Requirement 7.8)
    final names = selectedCollections.map((c) => c.name.value).toList();
    final confirmed = await showDeleteConfirmDialog(context, names);

    if (confirmed == true) {
      // 削除実行
      final ids = selectedCollections.map((c) => c.id).toList();
      await ref.read(deleteCollectionUseCaseProvider).execute(ids);

      // 削除成功後、自動的に編集モードを終了 (Requirement 7.9)
      ref.read(collectionEditModeProvider.notifier).exitEditMode();
    }
  }

  /// リネームボタン押下処理 (Requirement 7.6)
  ///
  /// 選択中の1件のコレクションに対してリネームダイアログを表示する。
  Future<void> _onRenamePressed(
    BuildContext context,
    WidgetRef ref,
    CollectionEditModeState editModeState,
    AsyncValue<List<Collection>> collectionsAsync,
  ) async {
    final collections = collectionsAsync.value;
    if (collections == null) return;

    // 選択中のコレクションを取得（1件のみ）
    final selectedId = editModeState.selectedIds.first;
    final selectedCollection = collections.firstWhere(
      (c) => c.id == selectedId,
    );

    // リネームダイアログ表示
    await showCollectionRenameDialog(
      context,
      selectedCollection.id,
      selectedCollection.name.value,
    );
  }
}

/// コレクション一覧の各行ウィジェット
///
/// サムネイル（プレースホルダー）、名前、画像数、更新日時を表示する。
/// 編集モード中は選択状態に応じてチェックマークとドラッグハンドルを表示する。
class _CollectionListTile extends StatelessWidget {
  const _CollectionListTile({
    required this.collection,
    required this.index,
    required this.isEditMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    super.key,
  });

  final Collection collection;
  final int index;
  final bool isEditMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: ListTile(
        // 選択状態の視覚的フィードバック
        selected: isSelected,
        selectedTileColor: theme.colorScheme.primaryContainer.withValues(
          alpha: 0.3,
        ),
        // サムネイル / チェックマーク (Requirement 6.1)
        leading: isEditMode
            ? _buildEditModeLeading(theme)
            : _buildThumbnail(theme),
        // コレクション名（最大50文字、省略記号付き）(Requirement 6.1)
        title: Text(
          collection.name.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // 画像数 + 更新日時 (Requirement 6.1)
        subtitle: Text(
          '${collection.imageCount}枚 ・ ${_formatDateTime(collection.updatedAt)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        // ドラッグハンドル: 編集モード中かつ選択されたアイテムのみ (Requirement 7.3)
        trailing: isEditMode && isSelected
            ? ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.drag_handle),
              )
            : isEditMode
            ? const SizedBox(width: 24)
            : ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.drag_handle),
              ),
        onTap: onTap,
        // 長押し: 500ms で編集モード開始 (Requirement 7.1)
        onLongPress: onLongPress,
      ),
    );
  }

  /// 編集モード時のリーディングウィジェット
  ///
  /// 選択状態をチェックマークアイコンで表示する。
  Widget _buildEditModeLeading(ThemeData theme) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: isSelected
          ? Icon(Icons.check, color: theme.colorScheme.onPrimaryContainer)
          : Icon(
              Icons.photo_library_outlined,
              color: theme.colorScheme.onSurfaceVariant,
            ),
    );
  }

  /// 通常モード時のサムネイルウィジェット
  Widget _buildThumbnail(ThemeData theme) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.photo_library_outlined,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  /// 日時をフォーマットする
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'たった今';
    if (diff.inHours < 1) return '${diff.inMinutes}分前';
    if (diff.inDays < 1) return '${diff.inHours}時間前';
    if (diff.inDays < 7) return '${diff.inDays}日前';

    return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}';
  }
}
