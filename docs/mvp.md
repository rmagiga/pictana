# MVP実装計画 (mvp.md)

# 5. MVP機能一覧

## 5.1 ストレージ
- SAFフォルダ選択
- USB OTG対応
- Windowsローカルフォルダ対応
- Windows USBドライブ対応
- URI永続化
- ストレージ切断検知
- 再接続待機UI

## 5.2 フォルダ一覧
- フォルダ階層表示
- パンくずリスト
- 戻る/進む
- フォルダ内画像枚数

## 5.3 画像一覧
- GridView
- 遅延ロード
- 無限スクロール
- サムネイルキャッシュ
- 高速スクロール
- 画像形式判定

## 5.4 画像ビューア
- 単体表示
- pinch zoom
- pan
- swipe
- GIF自動再生
- EXIF回転補正

## 5.5 対応画像形式
- JPEG
- PNG
- WebP
- GIF
- HEIC
- AVIF

---

# 23. MVP開発順序

## Phase 1
- Project setup
- Architecture setup
- Riverpod setup
- Drift setup

## Phase 2
- Android SAF
- Windows filesystem
- Repository abstraction

## Phase 3
- Folder browser
- Gallery grid
- Thumbnail cache

## Phase 4
- Image viewer
- zoom/pan
- swipe
- GIF support

## Phase 5
- reconnect waiting
- cache optimization
- memory tuning

---

# 25. 成功条件

以下を満たした場合、MVP成功とする。

- Android 14 USBストレージ閲覧可能
- Windows同機能動作
- 10,000枚画像で実用速度
- OOMしない
- GIF表示可能
- zoom/pan安定
- SAF権限永続化可能
