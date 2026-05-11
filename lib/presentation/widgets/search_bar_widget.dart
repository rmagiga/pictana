/// 検索バーウィジェット (設計書 §18.3)
library;

import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // MVP実装: UIのプレースホルダーとして配置
    // (実際の名前フィルタリングなどは Phase 5 拡張で実装する想定)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SearchBar(
        hintText: 'ファイル名で検索...',
        leading: const Icon(Icons.search),
        trailing: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('フィルター機能は未実装です')),
              );
            },
            tooltip: 'フィルター',
          ),
        ],
        onChanged: (value) {
          // TODO: GalleryGrid の Provider に検索クエリを渡す
        },
      ),
    );
  }
}
