/// フォルダブラウザ画面 (設計書 §18.2)
/// Windows 版 MVP では使用しないため、プレースホルダーとして実装。
library;

import 'package:flutter/material.dart';

class FolderBrowserScreen extends StatelessWidget {
  const FolderBrowserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Folder Browser')),
      body: const Center(
        child: Text('WindowsではOS標準のフォルダ選択ダイアログを使用します。'),
      ),
    );
  }
}
