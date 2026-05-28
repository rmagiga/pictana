/// 画像情報表示シート (設計書 §18.4)
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/image_entry.dart';
import '../providers/viewer_providers.dart';

class ImageInfoSheet extends ConsumerWidget {
  const ImageInfoSheet({
    super.key,
    required this.images,
  });

  final List<ImageEntry> images;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    if (images.length == 1) {
      return _buildSingleInfo(context, ref, images.first);
    }

    return _buildDoubleInfo(context, ref);
  }

  Widget _buildSingleInfo(BuildContext context, WidgetRef ref, ImageEntry image) {
    final theme = Theme.of(context);
    final metadataAsync = ref.watch(imageMetadataProvider(image));

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '画像情報',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(height: 32),
          metadataAsync.when(
            data: (metadata) => _InfoList(image: metadata),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (_, st) => _InfoList(image: image), // 取得失敗時は既存情報を使用
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDoubleInfo(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: images.length,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '画像情報',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TabBar(
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: images.map((img) {
                  return Tab(
                    child: Text(
                      img.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: TabBarView(
                  children: images.map((img) {
                    return Consumer(
                      builder: (context, ref, _) {
                        final metadataAsync = ref.watch(imageMetadataProvider(img));
                        return SingleChildScrollView(
                          child: metadataAsync.when(
                            data: (metadata) => _InfoList(image: metadata),
                            loading: () => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            error: (_, st) => _InfoList(image: img),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoList extends StatelessWidget {
  const _InfoList({required this.image});

  final ImageEntry image;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildRow(context, 'ファイル名', image.name),
        _buildRow(context, 'サイズ', _formatBytes(image.size)),
        _buildRow(context, '形式', image.extension.toUpperCase()),
        _buildRow(context, '解像度', image.resolutionString),
        if (image.createdAt != null)
          _buildRow(context, '作成日時', _formatDate(image.createdAt!)),
        _buildRow(context, '更新日時', _formatDate(image.modifiedAt)),
        const SizedBox(height: 8),
        _buildRow(context, 'パス', image.uri),
      ],
    );
  }

  Widget _buildRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.copy, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: value));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$labelをコピーしました'),
                    duration: const Duration(milliseconds: 800),
                  ),
                );
              }
            },
            tooltip: '$labelをコピー',
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    // 簡易フォーマット
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
