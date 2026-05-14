/// 画像ビューア画面 (設計書 §18.4)
library;

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/image_entry.dart';
import '../providers/gallery_providers.dart';
import '../providers/viewer_providers.dart';
import '../widgets/image_info_sheet.dart';

class ImageViewerScreen extends ConsumerStatefulWidget {
  const ImageViewerScreen({super.key, required this.initialIndex});

  final int initialIndex;

  @override
  ConsumerState<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends ConsumerState<ImageViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isOverlayVisible = true;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleOverlay() {
    setState(() {
      _isOverlayVisible = !_isOverlayVisible;
    });
  }

  void _showImageInfo(ImageEntry image) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ImageInfoSheet(image: image),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagesAsync = ref.watch(galleryImagesProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: imagesAsync.when(
        data: (images) {
          if (images.isEmpty) {
            return const Center(
              child: Text('画像がありません', style: TextStyle(color: Colors.white)),
            );
          }

          final currentImage = images[_currentIndex];

          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. ページビュー（画像表示部）
              GestureDetector(
                onTap: _toggleOverlay,
                child: PageView.builder(
                  controller: _pageController,
                  // ズーム中はページスワイプを無効にする
                  physics: _isZoomed
                      ? const NeverScrollableScrollPhysics()
                      : null,
                  itemCount: images.length,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                    // 前後の画像をプリロードする
                    ref
                        .read(preloadAdjacentImagesUseCaseProvider)
                        .execute(images, index);
                  },
                  itemBuilder: (context, index) {
                    final image = images[index];
                    return _InteractiveImageView(
                      image: image,
                      onZoomChanged: (zoomed) {
                        if (_isZoomed != zoomed) {
                          setState(() => _isZoomed = zoomed);
                        }
                      },
                    );
                  },
                ),
              ),

              // 2. AppBar（オーバーレイ）
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                top: _isOverlayVisible
                    ? 0
                    : -kToolbarHeight - MediaQuery.paddingOf(context).top,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.paddingOf(context).top,
                  ),
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
                      currentImage.name,
                      style: const TextStyle(fontSize: 16),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () => _showImageInfo(currentImage),
                        tooltip: '画像情報',
                      ),
                    ],
                  ),
                ),
              ),

              // 3. ページインジケーター（オーバーレイ下部）
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                bottom: _isOverlayVisible
                    ? MediaQuery.paddingOf(context).bottom + 16
                    : -50,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${_currentIndex + 1} / ${images.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Text('エラー: $e', style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

/// 単一の画像をズーム・パン可能にするウィジェット
class _InteractiveImageView extends ConsumerStatefulWidget {
  const _InteractiveImageView({
    required this.image,
    required this.onZoomChanged,
  });

  final ImageEntry image;

  /// ズーム状態が変化したときに呼ばれるコールバック
  final ValueChanged<bool> onZoomChanged;

  @override
  ConsumerState<_InteractiveImageView> createState() =>
      _InteractiveImageViewState();
}

class _InteractiveImageViewState extends ConsumerState<_InteractiveImageView> {
  final TransformationController _transformationController =
      TransformationController();
  TapDownDetails? _doubleTapDetails;
  Uint8List? _thumbnailBytes;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformChanged);
    _loadThumbnail();
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformChanged);
    _transformationController.dispose();
    super.dispose();
  }

  /// サムネイルを事前に読み込んでプレースホルダーとして使用する
  Future<void> _loadThumbnail() async {
    final useCase = ref.read(loadThumbnailUseCaseProvider);
    final bytes = await useCase.execute(widget.image);
    if (mounted && bytes != null) {
      setState(() => _thumbnailBytes = bytes);
    }
  }

  /// スケール変化を監視し、ズーム状態を親に通知する
  void _onTransformChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    final isZoomed = scale > 1.01; // 浮動小数点誤差を考慮
    widget.onZoomChanged(isZoomed);
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      // ズームリセット
      _transformationController.value = Matrix4.identity();
    } else {
      // ダブルタップした位置を中心にズーム
      final position = _doubleTapDetails!.localPosition;
      final translation = Matrix4.translationValues(
        -position.dx * 1.5,
        -position.dy * 1.5,
        0.0,
      );
      final scale = Matrix4.diagonal3Values(2.5, 2.5, 1.0);
      _transformationController.value = translation * scale;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 高解像度の画像バイト列を非同期で取得するProvider
    final bytesAsync = ref.watch(imageBytesProvider(widget.image));

    return GestureDetector(
      onDoubleTapDown: _handleDoubleTapDown,
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 1.0,
        maxScale: 5.0,
        child: Center(
          child: bytesAsync.when(
            data: (bytes) {
              return Image.memory(
                bytes,
                fit: BoxFit.contain,
                gaplessPlayback: true,
              );
            },
            // 読み込み中はサムネイルをプレースホルダーとして表示する
            loading: () {
              if (_thumbnailBytes != null) {
                return Image.memory(
                  _thumbnailBytes!,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                );
              }
              return const SizedBox.shrink();
            },
            error: (e, st) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.broken_image, color: Colors.grey, size: 64),
                const SizedBox(height: 16),
                Text('読み込み失敗', style: TextStyle(color: Colors.grey[400])),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
