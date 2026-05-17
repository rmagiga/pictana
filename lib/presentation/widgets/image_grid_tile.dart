/// グリッドアイテムウィジェット (設計書 §18.3)
library;

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/usecases/settings/thumbnail_size_setting.dart';
import '../../domain/entities/image_entry.dart';
import '../providers/gallery_providers.dart';

class ImageGridTile extends ConsumerStatefulWidget {
  const ImageGridTile({
    super.key,
    required this.image,
    required this.onTap,
  });

  final ImageEntry image;
  final VoidCallback onTap;

  @override
  ConsumerState<ImageGridTile> createState() => _ImageGridTileState();
}

class _ImageGridTileState extends ConsumerState<ImageGridTile> {
  Uint8List? _thumbnailBytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  @override
  void didUpdateWidget(covariant ImageGridTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image.uri != widget.image.uri) {
      _loadThumbnail();
    }
  }

  Future<void> _loadThumbnail() async {
    setState(() => _isLoading = true);
    final useCase = ref.read(loadThumbnailUseCaseProvider);
    final sizeOption = ref.read(thumbnailSizeSettingProvider);
    final bytes = await useCase.execute(widget.image, size: sizeOption);
    if (mounted) {
      setState(() {
        _thumbnailBytes = bytes;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            // サムネイル画像
            if (_thumbnailBytes != null)
              Image.memory(
                _thumbnailBytes!,
                fit: BoxFit.cover,
                gaplessPlayback: true,
              )
            else if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              // サムネイル生成失敗時のプレースホルダー
              Center(
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
              ),

            // GIF バッジ
            if (widget.image.isGif)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
}
