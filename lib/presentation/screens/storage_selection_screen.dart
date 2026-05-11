/// Storage Selection 画面 (設計書 §18.1)
library;

import 'package:flutter/material.dart';

class StorageSelectionScreen extends StatelessWidget {
  const StorageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ストレージ選択')),
      body: const Center(child: Text('Phase 2 で実装予定')),
    );
  }
}
