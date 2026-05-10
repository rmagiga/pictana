# ストレージ・データ設計 (storage.md)

# 10. Platform ストレージ実装

## 10.1 Android

### 実装
- SAF (Storage Access Framework)
- DocumentFile
- ContentResolver
- Persistable URI Permission

ネイティブ実装は Kotlin 許可。

### SAFパフォーマンス最適化

大量ファイル列挙時に `DocumentFile.listFiles()` を直接使用することは禁止。

理由:
- SAF APIは大量ファイル時に極端に低速
- 10,000件規模で実用速度を満たせない

Infrastructure層にて、Kotlin側で `ContentResolver.query()` を直接実行し、カーソルベースで一括取得する。

Dart側へはDTO変換済みデータを返却する。

期待効果:
- JNI往復削減
- listFiles大量呼び出し回避
- SAF高速化

---

## 10.2 Windows

### 実装
- dart:io
- Directory
- File

---

# 13. データベース設計

## 13.1 Tables

### RecentFolders

```text
- id
- uri
- name
- lastOpenedAt
```

### ThumbnailCache

```text
- id
- imageUri
- cachePath
- width
- height
- updatedAt
```

### AppSettings

```text
- key
- value
```

---

# 5. ストレージ要件 (MVP機能より抽出)

- SAFフォルダ選択
- USB OTG対応
- Windowsローカルフォルダ対応
- Windows USBドライブ対応
- URI永続化
- ストレージ切断検知
- 再接続待機UI

## 5.5 対応画像形式

### MVP対応
- JPEG
- PNG
- WebP
- GIF
- HEIC
- AVIF

GIF仕様:

| 画面 | 動作 |
|---|---|
| 一覧 | 静止 |
| 詳細 | 自動再生 |
| 制御 | なし |

### Windows HEIC/AVIF対応

WindowsではOS標準decodeが利用できない場合がある。
そのため、Infrastructure層へ以下fallback設計を追加する。

- native decoder plugin
- Dart decoder fallback
- custom codec pipeline

Application/Domain層へOS依存decode処理を漏らさない。
