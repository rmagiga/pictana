import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/image_entry.dart';
import '../../providers/gallery_providers.dart';
import '../../providers/viewer_providers.dart';

/// 単一の画像をズーム・パン可能にするウィジェット
class InteractiveImageView extends ConsumerStatefulWidget {
  const InteractiveImageView({
    super.key,
    required this.image,
    required this.onZoomChanged,
    this.transformationController,
  });

  final ImageEntry image;

  /// ズーム状態が変化したときに呼ばれるコールバック
  final ValueChanged<bool> onZoomChanged;

  /// 外部から提供される TransformationController (Ctrl+ホイールズーム用)
  final TransformationController? transformationController;

  @override
  ConsumerState<InteractiveImageView> createState() =>
      _InteractiveImageViewState();
}

class _InteractiveImageViewState extends ConsumerState<InteractiveImageView>
    with WidgetsBindingObserver {
  TransformationController? _internalController;
  TapDownDetails? _doubleTapDetails;
  Uint8List? _thumbnailBytes;

  TransformationController get _transformationController =>
      widget.transformationController ?? _internalController!;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.transformationController == null) {
      _internalController = TransformationController();
    }
    _transformationController.addListener(_onTransformChanged);
    _loadThumbnail();
  }

  @override
  void didUpdateWidget(covariant InteractiveImageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldController =
        oldWidget.transformationController ?? _internalController;
    if (widget.transformationController == null &&
        _internalController == null) {
      oldController?.removeListener(_onTransformChanged);
      _internalController = TransformationController();
      _internalController!.addListener(_onTransformChanged);
    } else if (widget.transformationController != null &&
        _internalController != null) {
      _internalController!.removeListener(_onTransformChanged);
      _internalController!.dispose();
      _internalController = null;
      widget.transformationController!.addListener(_onTransformChanged);
    } else if (widget.transformationController !=
        oldWidget.transformationController) {
      oldWidget.transformationController?.removeListener(_onTransformChanged);
      widget.transformationController?.addListener(_onTransformChanged);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _transformationController.removeListener(_onTransformChanged);
    _internalController?.dispose();
    super.dispose();
  }

  Future<void> _loadThumbnail() async {
    final useCase = ref.read(loadThumbnailUseCaseProvider);
    final bytes = await useCase.execute(widget.image);
    if (mounted && bytes != null) {
      setState(() => _thumbnailBytes = bytes);
    }
  }

  void _onTransformChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    final isZoomed = scale > 1.01;
    widget.onZoomChanged(isZoomed);
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
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
    final bytesAsync = ref.watch(imageBytesProvider(widget.image));
    final rotationAsync = ref.watch(imageExifRotationProvider(widget.image));
    final exifRotation = rotationAsync.value ?? widget.image.exifRotation;

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
              if (widget.image.isGif) {
                return _applyExifRotation(
                  _GifImageView(bytes: bytes, thumbnailBytes: _thumbnailBytes),
                  exifRotation,
                );
              }
              return _applyExifRotation(
                Image.memory(bytes, fit: BoxFit.contain, gaplessPlayback: true),
                exifRotation,
              );
            },
            loading: () {
              if (_thumbnailBytes != null) {
                return _applyExifRotation(
                  Image.memory(
                    _thumbnailBytes!,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                  ),
                  exifRotation,
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

  Widget _applyExifRotation(Widget child, int rotation) {
    if (rotation == 0) return child;
    final quarterTurns = switch (rotation) {
      90 => 1,
      180 => 2,
      270 => 3,
      _ => 0,
    };
    if (quarterTurns == 0) return child;
    return RotatedBox(quarterTurns: quarterTurns, child: child);
  }
}

/// GIF アニメーション自動再生ウィジェット
class _GifImageView extends StatefulWidget {
  const _GifImageView({required this.bytes, this.thumbnailBytes});

  final Uint8List bytes;
  final Uint8List? thumbnailBytes;

  @override
  State<_GifImageView> createState() => _GifImageViewState();
}

class _GifImageViewState extends State<_GifImageView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _animationController;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _isPaused = true;
      _animationController.stop();
    } else if (state == AppLifecycleState.resumed) {
      if (_isPaused) {
        _isPaused = false;
        _animationController.repeat();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExtendedImage.memory(
      widget.bytes,
      fit: BoxFit.contain,
      enableLoadState: true,
      clearMemoryCacheWhenDispose: true,
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            if (widget.thumbnailBytes != null) {
              return Image.memory(
                widget.thumbnailBytes!,
                fit: BoxFit.contain,
                gaplessPlayback: true,
              );
            }
            return const Center(
              child: CircularProgressIndicator(color: Colors.white54),
            );
          case LoadState.completed:
            return null;
          case LoadState.failed:
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.broken_image, color: Colors.grey, size: 64),
                const SizedBox(height: 16),
                Text(
                  'GIF の読み込みに失敗しました',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => state.reLoadImage(),
                  child: const Text('再試行'),
                ),
              ],
            );
        }
      },
    );
  }
}
