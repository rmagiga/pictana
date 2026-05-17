/// 画像ビューア画面 (設計書 §18.4)
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/usecases/settings/swipe_direction_setting.dart';
import '../../domain/entities/image_entry.dart';
import '../providers/gallery_providers.dart';
import '../providers/viewer_providers.dart';
import '../widgets/image_info_sheet.dart';
import '../widgets/viewer/ctrl_wheel_zoom_handler.dart';
import '../widgets/viewer/keyboard_navigation_handler.dart';
import '../widgets/viewer/navigation_overlay.dart';
import '../widgets/viewer/swipe_direction_controller.dart';

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

  /// ページ遷移アニメーション中かどうか (NavigationOverlay のタップ無視に使用)
  bool _isPageAnimating = false;

  /// 現在のズーム倍率 (CtrlWheelZoomHandler に使用)
  double _currentScale = 1.0;

  /// 現在表示中の画像の TransformationController (Ctrl+ホイールズーム用)
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _transformationController.addListener(_onTransformChanged);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformChanged);
    _transformationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  /// TransformationController のスケール変化を監視する
  void _onTransformChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if ((_currentScale - scale).abs() > 0.001) {
      setState(() {
        _currentScale = scale;
        _isZoomed = scale > 1.01;
      });
    }
  }

  /// 前の画像に遷移する (Req 1.3, 2.1)
  void _goToPreviousPage() {
    if (_currentIndex <= 0) return;
    _navigateToPage(_currentIndex - 1);
  }

  /// 次の画像に遷移する (Req 1.4, 2.2)
  void _goToNextPage(int totalCount) {
    if (_currentIndex >= totalCount - 1) return;
    _navigateToPage(_currentIndex + 1);
  }

  /// キーボードナビゲーションによるページ遷移 (Req 2.1, 2.2)
  void _navigateToIndex(int index, int totalCount) {
    if (index < 0 || index >= totalCount) return;
    _navigateToPage(index);
  }

  /// ページ遷移を実行する（連続操作対応）
  ///
  /// アニメーション中に次の遷移が来た場合、現在位置を即座に確定してから
  /// 新しいターゲットへ遷移する。これにより連続スワイプ時のもたつきを解消する。
  void _navigateToPage(int targetPage) {
    // アニメーション中なら現在位置を即座に確定する
    if (_isPageAnimating) {
      final snappedPage = _pageController.page?.round() ?? _currentIndex;
      _pageController.jumpToPage(snappedPage);
    }

    setState(() => _isPageAnimating = true);
    _pageController
        .animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        )
        .then((_) {
          if (mounted) setState(() => _isPageAnimating = false);
        });
  }

  /// Ctrl+ホイールズームによるスケール変更 (Req 3.1, 3.2)
  void _onCtrlWheelScaleChanged(double newScale) {
    _transformationController.value = Matrix4.diagonal3Values(
      newScale,
      newScale,
      1.0,
    );
  }

  /// Ctrl+ホイールズームの焦点位置設定 (Req 3.1)
  void _onCtrlWheelFocalPoint(Offset focalPoint) {
    // 焦点位置を考慮したズーム変換を適用する
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if (scale <= 1.0) return;
    final tx = focalPoint.dx * (1 - scale);
    final ty = focalPoint.dy * (1 - scale);
    final matrix = Matrix4.translationValues(tx, ty, 0.0)
      ..multiply(Matrix4.diagonal3Values(scale, scale, 1.0));
    _transformationController.value = matrix;
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

  /// ページビューを構築する
  ///
  /// Android: [SwipeDirectionController] を使用してスワイプ方向設定に従う (Req 4.1, 7.4)
  /// Windows: 標準の [PageView.builder] を使用する
  Widget _buildPageView(List<ImageEntry> images) {
    Widget itemBuilder(BuildContext context, int index) {
      final image = images[index];
      return _InteractiveImageView(
        image: image,
        // Windows: 現在表示中の画像にのみ外部 TransformationController を渡す
        // (Ctrl+ホイールズームで外部からスケール制御するため)
        transformationController: Platform.isWindows && index == _currentIndex
            ? _transformationController
            : null,
        onZoomChanged: (zoomed) {
          if (_isZoomed != zoomed) {
            setState(() => _isZoomed = zoomed);
          }
        },
      );
    }

    void onPageChanged(int index) {
      setState(() => _currentIndex = index);
      // 前後の画像をプリロードする
      ref.read(preloadAdjacentImagesUseCaseProvider).execute(images, index);
    }

    // 全プラットフォーム: SwipeDirectionController でスワイプ方向を制御する (Req 4.1, 7.4)
    final swipeDirection = ref.watch(swipeDirectionSettingProvider);
    return SwipeDirectionController(
      direction: swipeDirection,
      isZoomed: _isZoomed,
      pageController: _pageController,
      itemCount: images.length,
      itemBuilder: itemBuilder,
      onPageChanged: onPageChanged,
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

          // ページビュー部分を構築する
          Widget pageViewSection = GestureDetector(
            onTap: _toggleOverlay,
            child: _buildPageView(images),
          );

          // Windows: Ctrl+ホイールズームハンドラーでページビューをラップする (Req 3.1)
          if (Platform.isWindows) {
            pageViewSection = CtrlWheelZoomHandler(
              currentScale: _currentScale,
              onScaleChanged: _onCtrlWheelScaleChanged,
              onFocalPoint: _onCtrlWheelFocalPoint,
              child: pageViewSection,
            );
          }

          Widget content = Stack(
            fit: StackFit.expand,
            children: [
              // 1. ページビュー（画像表示部）
              pageViewSection,

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

              // 4. Windows: ナビゲーションオーバーレイ（矢印ボタン）(Req 1.1)
              if (Platform.isWindows)
                NavigationOverlay(
                  currentIndex: _currentIndex,
                  totalCount: images.length,
                  isAnimating: _isPageAnimating,
                  onPrevious: _goToPreviousPage,
                  onNext: () => _goToNextPage(images.length),
                ),
            ],
          );

          // Windows: キーボードナビゲーションハンドラーで全体をラップする (Req 2.1)
          if (Platform.isWindows) {
            content = KeyboardNavigationHandler(
              currentIndex: _currentIndex,
              totalCount: images.length,
              isZoomed: _isZoomed,
              onNavigate: (index) => _navigateToIndex(index, images.length),
              child: content,
            );
          }

          return content;
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Text(
            'エラーが発生しました',
            style: const TextStyle(color: Colors.white),
          ),
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
    this.transformationController,
  });

  final ImageEntry image;

  /// ズーム状態が変化したときに呼ばれるコールバック
  final ValueChanged<bool> onZoomChanged;

  /// 外部から提供される TransformationController (Ctrl+ホイールズーム用)
  ///
  /// null の場合は内部で生成する。
  final TransformationController? transformationController;

  @override
  ConsumerState<_InteractiveImageView> createState() =>
      _InteractiveImageViewState();
}

class _InteractiveImageViewState extends ConsumerState<_InteractiveImageView>
    with WidgetsBindingObserver {
  /// 内部で管理する TransformationController（外部提供がない場合に使用）
  TransformationController? _internalController;
  TapDownDetails? _doubleTapDetails;
  Uint8List? _thumbnailBytes;

  /// 使用する TransformationController を返す
  TransformationController get _transformationController =>
      widget.transformationController ?? _internalController!;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 外部コントローラーが提供されていない場合は内部で生成する
    if (widget.transformationController == null) {
      _internalController = TransformationController();
    }
    _transformationController.addListener(_onTransformChanged);
    _loadThumbnail();
  }

  @override
  void didUpdateWidget(covariant _InteractiveImageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 外部コントローラーの有無が変わった場合に対応する
    final oldController =
        oldWidget.transformationController ?? _internalController;
    if (widget.transformationController == null &&
        _internalController == null) {
      // 外部コントローラーが外された → 内部コントローラーを生成する
      oldController?.removeListener(_onTransformChanged);
      _internalController = TransformationController();
      _internalController!.addListener(_onTransformChanged);
    } else if (widget.transformationController != null &&
        _internalController != null) {
      // 外部コントローラーが提供された → 内部コントローラーを破棄する
      _internalController!.removeListener(_onTransformChanged);
      _internalController!.dispose();
      _internalController = null;
      widget.transformationController!.addListener(_onTransformChanged);
    } else if (widget.transformationController !=
        oldWidget.transformationController) {
      // 外部コントローラーが別のインスタンスに変わった
      oldWidget.transformationController?.removeListener(_onTransformChanged);
      widget.transformationController?.addListener(_onTransformChanged);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _transformationController.removeListener(_onTransformChanged);
    // 内部コントローラーのみ dispose する（外部提供の場合は呼び出し元が管理）
    _internalController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // バックグラウンド移行時は GIF アニメーションが自動停止される
    // （ExtendedImage は内部で TickerProvider を使用しており、
    //  WidgetsBindingObserver による停止は ExtendedImage 側で処理される）
    // ここでは追加のクリーンアップが必要な場合に備えて Observer を登録
    super.didChangeAppLifecycleState(state);
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
    // EXIF 回転角度を取得する Provider (Req 6.1, 6.2)
    final rotationAsync = ref.watch(imageExifRotationProvider(widget.image));

    // EXIF 回転角度（取得完了前は ImageEntry のデフォルト値を使用）
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
              // GIF 画像の場合は ExtendedImage で自動再生する (Req 5.1, 5.2)
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
            // 読み込み中はサムネイルをプレースホルダーとして表示する
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

  /// EXIF 回転角度に基づいて画像ウィジェットを回転補正する (Req 6.2)
  ///
  /// [rotation] は 0, 90, 180, 270 のいずれか。
  /// 0 の場合は回転なしでそのまま返す。
  Widget _applyExifRotation(Widget child, int rotation) {
    if (rotation == 0) return child;

    // 時計回りの回転角度を quarterTurns に変換
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

/// GIF アニメーション自動再生ウィジェット (Req 5.1, 5.2, 5.3, 5.4, 5.5, 5.6)
///
/// ExtendedImage を使用して GIF を自動再生する。
/// - 表示完了から自動的にアニメーション再生を開始する
/// - フレーム遅延に従い無限ループ再生する
/// - 非表示時（画面遷移・バックグラウンド）にリソースを解放する
/// - ピンチズーム・パン操作中もアニメーションを継続する
/// - デコード失敗時はエラー表示を行う
class _GifImageView extends StatefulWidget {
  const _GifImageView({required this.bytes, this.thumbnailBytes});

  /// GIF 画像のバイトデータ
  final Uint8List bytes;

  /// サムネイルバイトデータ（ローディング中のプレースホルダー用）
  final Uint8List? thumbnailBytes;

  @override
  State<_GifImageView> createState() => _GifImageViewState();
}

class _GifImageViewState extends State<_GifImageView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  /// GIF アニメーションコントローラー
  late AnimationController _animationController;

  /// アプリがバックグラウンドにあるかどうか
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // アニメーションコントローラーを初期化
    // duration は ExtendedImage が GIF フレーム数に基づいて自動設定する
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // 初期値、ExtendedImage が上書きする
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // リソース解放 (Req 5.3, 5.6)
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // バックグラウンド移行時にアニメーションを停止 (Req 5.6)
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _isPaused = true;
      _animationController.stop();
    } else if (state == AppLifecycleState.resumed) {
      // フォアグラウンド復帰時にアニメーションを再開
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
      // GIF アニメーション自動再生を有効化
      clearMemoryCacheWhenDispose: true,
      loadStateChanged: (ExtendedImageState state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            // ローディング中はサムネイルをプレースホルダーとして表示
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
            // 読み込み完了 - アニメーション再生は ExtendedImage が自動管理
            return null; // デフォルトの表示を使用
          case LoadState.failed:
            // デコード失敗時のエラー表示 (Req 5.5)
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
