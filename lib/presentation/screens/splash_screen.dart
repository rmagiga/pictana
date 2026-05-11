/// Splash画面 (設計書 §17.1)
///
/// 起動時にOS既定画像フォルダを検出し、
/// 成功 → Gallery Grid、失敗 → Storage Selection へ遷移する。
library;

import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 64),
            SizedBox(height: 24),
            Text('Optrig', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
