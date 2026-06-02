/// コレクション選択ダイアログ
///
/// フォルダ画像一覧から画像をコレクションに追加する際に表示されるモーダルダイアログ。
/// 全コレクションをチェックボックス付きリストで表示し、
/// 複数コレクションの同時選択・新規コレクション作成・インクリメンタル検索を提供する。
///
/// 確定操作で：
/// - チェック ON のコレクションに対象画像を追加
/// - チェック OFF のコレクションから対象画像を除外
/// キャンセル・ダイアログ外タップでは変更を行わない。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/repository_providers.dart';
import '../../domain/entities/collection.dart';
import '../../domain/entities/entry_id.dart';
import '../providers/collection_list_provider.dart';
import 'collection_create_dialog.dart';

/// コレクション選択ダイアログを表示する
///
/// [targetEntryIds] に追加対象の画像 EntryId リストを渡す。
/// 確定操作が成功した場合は追加件数 (int) を返し、
/// キャンセル時は null を返す。
Future<int?> showCollectionSelectDialog(
  BuildContext context,
  List<EntryId> targetEntryIds,
) {
  return showDialog<int>(
    context: context,
    builder: (context) =>
        CollectionSelectDialog(targetEntryIds: targetEntryIds),
  );
}

/// コレクション選択ダイアログ
///
/// - 全コレクションをチェックボックスリストで表示（作成日時降順）
/// - 既存所属状態の初期チェック表示
/// - 新規コレクション作成ボタン + 作成後の自動チェック
/// - インクリメンタル検索フィルター
/// - 確定操作で追加/除外を実行
class CollectionSelectDialog extends ConsumerStatefulWidget {
  const CollectionSelectDialog({required this.targetEntryIds, super.key});

  /// 追加対象の画像 EntryId リスト
  final List<EntryId> targetEntryIds;

  @override
  ConsumerState<CollectionSelectDialog> createState() =>
      _CollectionSelectDialogState();
}

class _CollectionSelectDialogState
    extends ConsumerState<CollectionSelectDialog> {
  /// 検索フィルター用コントローラ
  final _searchController = TextEditingController();

  /// 検索文字列
  String _searchQuery = '';

  /// チェック状態のマップ（collectionId -> チェック ON/OFF）
  final Map<int, bool> _checkStates = {};

  /// 初期チェック状態のマップ（確定時に差分計算用）
  final Map<int, bool> _initialCheckStates = {};

  /// コレクション一覧（作成日時降順）
  List<Collection> _collections = [];

  /// ローディング状態
  bool _isLoading = true;

  /// 確定処理中フラグ
  bool _isSubmitting = false;

  /// 新規作成で追加されたコレクション（リスト先頭に表示するため）
  final List<Collection> _newlyCreatedCollections = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// コレクション一覧と初期所属状態をロードする
  Future<void> _loadData() async {
    try {
      final repository = ref.read(collectionRepositoryProvider);

      // コレクション一覧を取得
      final collections = await repository.getCollections();

      // 作成日時降順でソート
      final sorted = List<Collection>.from(collections)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // 所属状態を取得
      final collectionIds = sorted.map((c) => c.id).toList();
      Map<int, bool> membership = {};
      if (collectionIds.isNotEmpty) {
        membership = await repository.getImageMembership(
          widget.targetEntryIds,
          collectionIds,
        );
      }

      if (mounted) {
        setState(() {
          _collections = sorted;
          // 初期チェック状態を設定
          for (final collection in sorted) {
            final isChecked = membership[collection.id] ?? false;
            _checkStates[collection.id] = isChecked;
            _initialCheckStates[collection.id] = isChecked;
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// フィルター適用後のコレクション一覧を取得する
  List<Collection> get _filteredCollections {
    // 新規作成分を先頭に追加した全体リスト
    final allCollections = [
      ..._newlyCreatedCollections,
      ..._collections.where(
        (c) => !_newlyCreatedCollections.any((nc) => nc.id == c.id),
      ),
    ];

    if (_searchQuery.isEmpty) return allCollections;

    return allCollections
        .where(
          (c) =>
              c.name.value.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  /// 新規コレクション作成を実行する
  Future<void> _onCreateNew() async {
    final created = await showCollectionCreateDialog(context);
    if (created != null && mounted) {
      setState(() {
        // 新規作成コレクションをリスト先頭に追加し、自動チェック ON
        _newlyCreatedCollections.insert(0, created);
        _checkStates[created.id] = true;
        // 初期状態は false（新規作成なので元々所属していない）
        _initialCheckStates[created.id] = false;
      });
    }
  }

  /// 確定操作を実行する
  Future<void> _onConfirm() async {
    setState(() => _isSubmitting = true);

    try {
      final addUseCase = ref.read(addImagesToCollectionUseCaseProvider);
      final removeUseCase = ref.read(removeImagesFromCollectionUseCaseProvider);

      // 差分計算: 初期状態から変化したもののみ処理
      final toAdd = <int>[]; // チェック OFF → ON になったコレクション
      final toRemove = <int>[]; // チェック ON → OFF になったコレクション

      for (final entry in _checkStates.entries) {
        final collectionId = entry.key;
        final currentCheck = entry.value;
        final initialCheck = _initialCheckStates[collectionId] ?? false;

        if (currentCheck && !initialCheck) {
          toAdd.add(collectionId);
        } else if (!currentCheck && initialCheck) {
          toRemove.add(collectionId);
        }
      }

      var totalAdded = 0;

      // 画像追加
      if (toAdd.isNotEmpty) {
        totalAdded = await addUseCase.execute(
          collectionIds: toAdd,
          entryIds: widget.targetEntryIds,
        );
      }

      // 画像除外
      for (final collectionId in toRemove) {
        await removeUseCase.execute(collectionId, widget.targetEntryIds);
      }

      if (mounted) {
        Navigator.of(context).pop(totalAdded);
      }
    } catch (_) {
      // エラー時は SnackBar 通知してダイアログを閉じる
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('コレクションの更新に失敗しました')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('コレクションに追加'),
      contentPadding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            // 検索フィルター
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'コレクション名で検索',
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
            ),
            const SizedBox(height: 8),
            // コレクションリスト
            Expanded(child: _buildContent(theme)),
          ],
        ),
      ),
      actions: [
        // 新規コレクション作成ボタン
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _isSubmitting ? null : _onCreateNew,
            icon: const Icon(Icons.add),
            label: const Text('新規作成'),
          ),
        ),
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: _isSubmitting ? null : _onConfirm,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('確定'),
        ),
      ],
    );
  }

  /// コンテンツ領域を構築する
  Widget _buildContent(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = _filteredCollections;

    if (_collections.isEmpty && _newlyCreatedCollections.isEmpty) {
      // コレクションが0件の場合
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.collections_bookmark_outlined,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'コレクションがありません',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '「新規作成」からコレクションを作成してください',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (filtered.isEmpty) {
      // 検索結果が0件の場合
      return Center(
        child: Text(
          '一致するコレクションがありません',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    // 100枚以上の画像を処理する場合のインジケータ表示
    final showLargeSetIndicator = widget.targetEntryIds.length >= 100;

    return Column(
      children: [
        if (showLargeSetIndicator && _isSubmitting)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.targetEntryIds.length}枚の画像を処理中...',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final collection = filtered[index];
              final isChecked = _checkStates[collection.id] ?? false;

              return CheckboxListTile(
                value: isChecked,
                onChanged: _isSubmitting
                    ? null
                    : (value) {
                        setState(() {
                          _checkStates[collection.id] = value ?? false;
                        });
                      },
                title: Text(
                  collection.name.value,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                subtitle: Text(
                  '${collection.imageCount}枚',
                  style: theme.textTheme.bodySmall,
                ),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              );
            },
          ),
        ),
      ],
    );
  }
}
