# サムネイル設計 (thumbnail.md)

# 11. サムネイル・キャッシュ戦略

## 11.1 キャッシュ種類

| 種類 | 用途 |
|---|---|
| Memory Cache | 短期表示 |
| Disk Cache | サムネイル保存 |

## 11.2 サムネイル戦略

### 一覧
```text
256px thumbnail
```

### 詳細表示
必要時のみ原寸decode。

### サムネイル生成
サムネイル生成はメインIsolateで実行しない。
専用Isolateへ分離する。

理由:
- UI jank回避
- CPU負荷分離
- scroll性能維持

Androidでは以下を優先:
```text
ContentResolver.loadThumbnail()
```

Fallback:
- isolate decode
- custom thumbnail generation

---

## 11.3 キャッシュルール

- LRU管理
- 上限サイズ制御
- viewport外解放
- dispose徹底

### ImageCache動的制御
以下を `core` 層へ実装する。

```dart
PaintingBinding.instance.imageCache.maximumSizeBytes
```

デバイスメモリ量に応じて動的制御する。

理由:
- HEIC/AVIF decode対策
- OOM耐性向上
- 低RAM端末対応

extended_image の以下設定を活用する。
```text
clearMemoryCacheWhenDispose
```

---

# 10. Android Thumbnail最適化

Android 10+ では `ContentResolver.loadThumbnail()` を優先利用する。

理由:
- OSキャッシュ活用
- 高速decode
- メモリ削減
- thumbnail生成高速化

---

# 12.4 プレフェッチ戦略

## Gallery Grid
スクロール方向に応じて、数画面先のサムネイルを先行読み込みする。

目的:
- scroll jank削減
- thumbnail表示高速化

## Image Viewer
前後画像をメモリへプリロードする。

対象:
- previous image
- next image

目的:
- swipe高速化
- decode待機削減
