# 画面設計 (screens.md)

# 16. 画面一覧

| ID | 画面 |
|---|---|
| S01 | Splash |
| S02 | Storage Selection |
| S03 | Folder Browser |
| S04 | Gallery Grid |
| S05 | Image Viewer |
| S06 | Settings |
| S07 | Reconnect Waiting |

---

# 17. 画面フロー

```text
[Splash]
   ↓
[Recent Folder Check]
   ├ YES → [Gallery Grid]
   └ NO
          ↓
[Storage Selection]
          ↓
[Folder Browser]
          ↓
[Gallery Grid]
          ↓
[Image Viewer]

USB Disconnect
   ↓
[Reconnect Waiting]
```

---

# 18. ワイヤーフレーム

## 18.1 Storage Selection

```text
+--------------------------------+
| Gallery Viewer                 |
+--------------------------------+

Recent Folders

----------------------------------

USB Storage
Internal Storage
Windows Drive

----------------------------------

[ Select Storage ]
```

---

## 18.2 Folder Browser

```text
+--------------------------------+
| ← DCIM/Pictures                |
+--------------------------------+

📁 Camera
📁 Screenshots
📁 Downloads

```

---

## 18.3 Gallery Grid

```text
+--------------------------------+
| ← Camera         [Search][⚙]   |
+--------------------------------+

+-----+ +-----+ +-----+
|img1 | |img2 | |img3 |
+-----+ +-----+ +-----+

+-----+ +-----+ +-----+
|img4 | |img5 | |img6 |
+-----+ +-----+ +-----+
```

---

## 18.4 Image Viewer

```text
+--------------------------------+
| ← IMG_0001.jpg          [⋮]    |
+--------------------------------+

         IMAGE VIEW

      pinch zoom
      pan
      swipe

----------------------------------

1 / 152
```

---

## 18.5 Reconnect Waiting

```text
+--------------------------------+
| Storage Disconnected           |
+--------------------------------+

Waiting for reconnection...

[ Retry ]
[ Close Folder ]
```

---

# UI動作要件 (MVP機能より抽出)

## フォルダ一覧 (S03)

- フォルダ階層表示
- パンくずリスト
- 戻る/進む
- フォルダ内画像枚数

## 画像一覧 (S04)

- GridView
- 遅延ロード
- 無限スクロール
- サムネイルキャッシュ
- 高速スクロール
- 画像形式判定

## 画像ビューア (S05)

- 単体表示
- pinch zoom
- pan
- swipe
- GIF自動再生
- EXIF回転補正

---

# Windows最適化要件

Windowsデバッグ高速化のため、以下へ対応する。

- マウスホイール高速スクロール
- キーボードショートカット
- ←/→画像切り替え
- PageUp/PageDown対応
- Ctrl+MouseWheel zoom
