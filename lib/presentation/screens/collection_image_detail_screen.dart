/// コレクション画像詳細画面
///
/// コレクション内の画像をフルスクリーンで表示する。
/// ピンチズーム（1.0〜5.0倍）、左右スワイプ、前後移動ボタンを提供し、
/// 所属コレクション一覧表示と「このコレクションから解除」アクションを含む。
///
/// Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers/repository_providers.dart';
import '../../domain/entities/collection_image.dart';
import '../../domain/entities/entry_id.dart';
import '../providers/collection_image_list_provider.dart';
import '../providers/collection_list_provider.dart';

/// コレクション画像詳細画面
///
/// [collectionId] 所属コレクションの ID
/// [initialEntryId] 初期表示する画像の EntryId（rawValue）
///
/// PageView による左右スワイプと InteractiveViewer によるピンチズームを提供する。
/// collectionImageListProvider を watch してリアルタイムに画像リストを更新する。
class CollectionImageDetailScreen extends ConsumerStatefulWidget {
  const CollectionImageDetailScreen({
    required this.collectionId,
    required this.initialEntryId,
    super.key,
  });

  /// 対象コレクションの ID
  final int collectionId;

  /// 初期表示する画像の EntryId（rawValue 文字列）
  final String initialEntryId;

  @override
  ConsumerState<CollectionImageDetailScreen> createState() =>
      _CollectionImageDetailScreenState();
}

class _CollectionImageDetailScreenState
    extends ConsumerState<CollectionImageDetailScreen> {
  /// 現在表示中の画像インデックス
  int _currentIndex = 0;

  /// PageView のコントローラー
  PageController? _pageController;

  /// 初期インデックスが設定済みか
  bool _initialized = false;

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  /// 画像リストから初期表示位置を計算する
  void _initializeIndex(List<CollectionImage> images) {
    if (_initialized) return;
    _initialized = true;

    final index = images.indexWhere(
      (img) => img.entryId.rawValue == widget.initialEntryId,
    );
    _currentIndex = index >= 0 ? index : 0;
    _pageController = PageController(initialPage: _currentIndex);
  }

  /// 前の画像へ移動 (Requirement 12.1)
  void _goToPrevious() {
    if (_currentIndex > 0 && _pageController != null) {
      _pageController!.animateToPage(
        _currentIndex - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// 次の画像へ移動 (Requirement 12.1)
  void _goToNext(int totalCount) {
    if (_currentIndex < totalCount - 1 && _pageController != null) {
      _pageController!.animateToPage(
        _currentIndex + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// 所属コレクション一覧ダイアログを表示する (Requirement 12.3, 12.4)
  Future<void> _showCollectionsDialog(EntryId entryId) async {
    final repository = ref.read(collectionRepositoryProvider);
    final collections = await repository.getCollectionsForImage(entryId);

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('所属コレクション一覧'),
        content: collections.isEmpty
            ? const Text('所属するコレクションがありません')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: collections.length,
                  itemBuilder: (context, index) {
                    final collection = collections[index];
                    return ListTile(
                      leading: const Icon(Icons.collections_bookmark),
                      title: Text(collection.name.value),
                      subtitle: Text('${collection.imageCount}枚'),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  /// 「このコレクションから解除」アクション (Requirement 12.8, 12.9)
  ///
  /// 確認ダイアログを表示し、ユーザーが承認した場合のみ
  /// 現在表示中の画像をコレクションから解除する。
  /// 解除後は前後の画像へ自動遷移し、最後の1枚の場合は一覧画面へ戻る。
  Future<void> _removeFromCollection(List<CollectionImage> images) async {
    if (images.isEmpty) return;

    final currentImage = images[_currentIndex];

    // 確認ダイアログを表示
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('コレクションから解除'),
        content: const Text(
          'この画像をコレクションから解除しますか？\n'
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

    if (confirmed != true || !mounted) return;

    try {
      final useCase = ref.read(removeImagesFromCollectionUseCaseProvider);
      await useCase.execute(widget.collectionId, [currentImage.entryId]);

      if (!mounted) return;

      // 最後の1枚を解除した場合は一覧画面へ戻る (Requirement 12.9)
      if (images.length <= 1) {
        context.pop();
        return;
      }

      // 前後の画像へ自動遷移 (Requirement 12.9)
      // Stream により images リストが自動更新されるため、
      // インデックスの調整のみ行う
      setState(() {
        if (_currentIndex >= images.length - 1) {
          _currentIndex = images.length - 2;
        }
        // PageController を再構築して正しいページに移動する
        _pageController?.jumpToPage(_currentIndex);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('画像の解除に失敗しました'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  /// 所属コレクション一覧ボタンが活性かどうかを判定する
  ///
  /// 非同期で取得するため FutureBuilder で利用する。
  Future<bool> _hasCollections(EntryId entryId) async {
    final repository = ref.read(collectionRepositoryProvider);
    final collections = await repository.getCollectionsForImage(entryId);
    return collections.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final imagesAsync = ref.watch(
      collectionImageListProvider(widget.collectionId),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: imagesAsync.when(
        data: (images) {
          if (images.isEmpty) {
            // 全画像が解除された場合は戻る
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) context.pop();
            });
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          // 初期インデックスを設定
          _initializeIndex(images);

          // インデックスが範囲外になった場合の補正
          if (_currentIndex >= images.length) {
            _currentIndex = images.length - 1;
          }

          final currentImage = images[_currentIndex];

          return Stack(
            fit: StackFit.expand,
            children: [
              // 画像表示エリア: PageView + InteractiveViewer (Requirement 12.1)
              _buildPageView(images),

              // AppBar オーバーレイ
              _buildAppBarOverlay(context, currentImage, images),

              // 前後移動ボタン (Requirement 12.1)
              _buildNavigationButtons(images.length),

              // ページインジケーター
              _buildPageIndicator(images.length),
            ],
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                'エラーが発生しました: $error',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// PageView によるスワイプナビゲーション (Requirement 12.1, 12.7)
  ///
  /// 末尾/先頭でのスワイプを制限するため、physics を ClampingScrollPhysics にする。
  Widget _buildPageView(List<CollectionImage> images) {
    return PageView.builder(
      controller: _pageController,
      itemCount: images.length,
      // 末尾/先頭でのスワイプ制限 (Requirement 12.7)
      physics: const ClampingScrollPhysics(),
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      itemBuilder: (context, index) {
        return _buildImagePage(images[index]);
      },
    );
  }

  /// 個別画像ページ: InteractiveViewer によるピンチズーム (Requirement 12.1)
  ///
  /// minScale: 1.0, maxScale: 5.0 でピンチズームを提供する。
  /// 現時点ではプレースホルダーを表示する（実際の画像ロードは後続タスクで実装）。
  Widget _buildImagePage(CollectionImage image) {
    return InteractiveViewer(
      minScale: 1.0,
      maxScale: 5.0,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 120,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _formatEntryId(image.entryId),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// AppBar オーバーレイ
  ///
  /// 所属コレクション一覧ボタン (Requirement 12.3, 12.5) と
  /// 「このコレクションから解除」メニュー (Requirement 12.8) を含む。
  Widget _buildAppBarOverlay(
    BuildContext context,
    CollectionImage currentImage,
    List<CollectionImage> images,
  ) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black87, Colors.transparent],
          ),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          title: Text(
            _formatEntryId(currentImage.entryId),
            style: const TextStyle(fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            // 所属コレクション一覧ボタン (Requirement 12.3, 12.4, 12.5)
            FutureBuilder<bool>(
              future: _hasCollections(currentImage.entryId),
              builder: (context, snapshot) {
                final hasCollections = snapshot.data ?? false;
                return IconButton(
                  icon: const Icon(Icons.collections_bookmark),
                  tooltip: '所属コレクション一覧',
                  onPressed: hasCollections
                      ? () => _showCollectionsDialog(currentImage.entryId)
                      : null,
                );
              },
            ),
            // 「このコレクションから解除」メニュー (Requirement 12.8)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              tooltip: 'メニュー',
              onSelected: (value) {
                if (value == 'remove') {
                  _removeFromCollection(images);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.link_off, size: 20),
                      SizedBox(width: 12),
                      Text('このコレクションから解除'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 前後移動ボタン (Requirement 12.1)
  ///
  /// 先頭では「前」ボタンを非表示、末尾では「次」ボタンを非表示にする。
  Widget _buildNavigationButtons(int totalCount) {
    return Positioned.fill(
      child: Row(
        children: [
          // 前へボタン（先頭でない場合のみ表示）
          if (_currentIndex > 0)
            GestureDetector(
              onTap: _goToPrevious,
              behavior: HitTestBehavior.translucent,
              child: Container(
                width: 56,
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 56),

          // 中央のスペーサー（タップイベントを通す）
          const Expanded(child: SizedBox.shrink()),

          // 次へボタン（末尾でない場合のみ表示）
          if (_currentIndex < totalCount - 1)
            GestureDetector(
              onTap: () => _goToNext(totalCount),
              behavior: HitTestBehavior.translucent,
              child: Container(
                width: 56,
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 56),
        ],
      ),
    );
  }

  /// ページインジケーター（下部中央）
  Widget _buildPageIndicator(int totalCount) {
    return Positioned(
      bottom: MediaQuery.paddingOf(context).bottom + 16,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${_currentIndex + 1} / $totalCount',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
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
