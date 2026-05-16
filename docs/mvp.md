# MVP実装計画 (mvp.md)

# 5. MVP機能一覧

## 5.1 ストレージ
- SAFフォルダ選択
- USB OTG対応
- Windowsローカルフォルダ対応
- Windows USBドライブ対応
- URI永続化
- ストレージ切断検知
- 切断時インライン通知 & 自動リトライ
- OS既定画像フォルダ自動検出
- Windows OS標準フォルダ選択ダイアログ

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
- ソート（名前/日付/サイズ/種類）
- 検索（ファイル名/種類フィルター）
- レスポンシブグリッド列数
- スクロール位置復元

## 5.4 画像ビューア
- 単体表示
- pinch zoom
- pan
- swipe（左右）
- swipe（上下、Android設定で有効化）
- 矢印ボタンによる画像移動（Windows）
- キーボードショートカット ←/→/PageUp/PageDown（Windows）
- Ctrl+MouseWheel zoom（Windows）
- GIF自動再生
- EXIF回転補正
- 画像情報表示（ファイル名/サイズ/解像度/形式/日時）

## 5.5 対応画像形式
- JPEG
- PNG
- WebP
- GIF
- HEIC
- AVIF

## 5.6 設定
- テーマ（ダーク/ライト）
- グリッド列数
- サムネイルサイズ
- キャッシュサイズ上限 / クリア
- 表示順デフォルト
- スワイプ方向（Android: 左右/上下/両方）

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
- OS既定画像フォルダ検出

## Phase 3
- Folder browser
- Gallery grid
- Thumbnail cache
- レスポンシブグリッド
- ソート機能

## Phase 4
- Image viewer
- zoom/pan
- swipe
- GIF support
- 画像情報表示

## Phase 5
- 検索機能
- Settings画面
- USB切断インライン通知 & 自動リトライ
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
- ソート/検索が動作する
- Settings項目が反映される
- USB切断時にインライン通知が表示される
