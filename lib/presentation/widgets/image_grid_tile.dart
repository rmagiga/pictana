/// グリッドアイテムウィジェット (設計書 §18.3)
///
/// サムネイル読み込み中は Skeletonizer でスケルトン表示。
/// 読み込み完了時は 150ms フェードトランジションで切替。
/// 10 秒タイムアウトでエラープレースホルダーへ遷移。
library;

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:extended_image/extended_image.dart';

import '../../core/utils/cancel_token.dart';
import '../../application/usecases/settings/thumbnail_size_setting.dart';
import '../../application/usecases/gallery/search_controller.dart';
import '../../domain/entities/image_entry.dart';
import '../providers/gallery_providers.dart';

/// サムネイル読み込みタイムアウト時間
const _kThumbnailTimeout = Duration(seconds: 10);

/// フェードトランジション時間（100ms以下）
const _kFadeDuration = Duration(milliseconds: 100);

class ImageGridTile extends ConsumerStatefulWidget {
  const ImageGridTile({super.key, required this.image, required this.onTap});

  final ImageEntry image;
  final VoidCallback onTap;

  @override
  ConsumerState<ImageGridTile> createState() => _ImageGridTileState();
}

class _ImageGridTileState extends ConsumerState<ImageGridTile> {
  Uint8List? _thumbnailBytes;
  bool _isLoading = true;
  Timer? _timeoutTimer;
  CancelToken? _cancelToken;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  @override
  void didUpdateWidget(covariant ImageGridTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image.uri != widget.image.uri) {
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

  Future<void> _loadThumbnail() async {
    final isSearching = ref.read(searchControllerProvider.select((s) => s.isSearching));
    if (isSearching) {
      // 検索中の場合はリクエストを行わない（プレースホルダー状態を維持）
      return;
    }

    _cancelToken?.cancel();
    final token = CancelToken();
    _cancelToken = token;

    setState(() {
      _isLoading = true;
      _thumbnailBytes = null;
    });
    _startTimeout();

    final useCase = ref.read(loadThumbnailUseCaseProvider);
    final sizeOption = ref.read(thumbnailSizeSettingProvider);
    final bytes = await useCase.execute(widget.image, size: sizeOption, cancelToken: token);

    if (!mounted) return;
    if (token.isCancelled) return;
    _cancelTimeout();

    if (bytes != null) {
      setState(() {
        _thumbnailBytes = bytes;
        _isLoading = false;
      });
    } else {
      // サムネイル生成失敗
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 検索中フラグが解除されたら、未ロードのサムネイルのロードを開始する
    ref.listen<bool>(
      searchControllerProvider.select((s) => s.isSearching),
      (previous, isSearching) {
        if (!isSearching && _thumbnailBytes == null && _isLoading) {
          _loadThumbnail();
        }
      },
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: widget.onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // メインコンテンツ: AnimatedSwitcher でフェードトランジション
            AnimatedSwitcher(
              duration: _kFadeDuration,
              child: _buildContent(context),
            ),

            // GIF バッジ
            if (widget.image.isGif)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'GIF',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 状態に応じたコンテンツウィジェットを返す
  Widget _buildContent(BuildContext context) {
    if (_thumbnailBytes != null) {
      // サムネイル読み込み完了
      return ExtendedImage.memory(
        _thumbnailBytes!,
        key: const ValueKey('thumbnail'),
        fit: BoxFit.cover,
        gaplessPlayback: true,
        clearMemoryCacheWhenDispose: true,
      );
    } else if (_isLoading) {
      // 単純な灰色 Box（Skeletonizer を排除して GPU 負荷を軽減）
      return Container(
        key: const ValueKey('skeleton'),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
      );
    } else {
      // エラープレースホルダー（サムネイル生成失敗 or タイムアウト）
      return Center(
        key: const ValueKey('error'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_outlined,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 4),
            Text(
              widget.image.extension.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      );
    }
  }
}
