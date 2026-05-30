# ストレージ・データ設計 (storage.md)

# 10. Platform ストレージ実装

## 10.1 Android

### 実装方式

SAF (Storage Access Framework) をメイン方式として採用。

- `ACTION_OPEN_DOCUMENT_TREE` によるフォルダ選択
- `ContentResolver.query()` によるカーソルベース高速列挙
- `ContentResolver.loadThumbnail()` (API 29+) によるサムネイル取得
- `takePersistableUriPermission()` によるパーミッション永続化
- ネイティブ実装は Kotlin

### SAF を採用する理由

1. フォルダ階層のブラウジングが必要（Photo Picker では不可）
2. USB OTG / 外部ストレージへのアクセスが必要
3. パーミッション永続化により再起動後もアクセス可能
4. Scoped Storage の制約を受けずにフォルダ内全ファイルにアクセス可能
5. `READ_MEDIA_*` パーミッション不要（Google Play ポリシー上有利）

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

### パーミッション永続化

- `ContentResolver.takePersistableUriPermission(uri, flags)` で再起動後もアクセス可能にする
- `ContentResolver.getPersistedUriPermissions()` で現在の永続化済み URI 一覧を取得
- `ContentResolver.releasePersistableUriPermission(uri, flags)` で不要な権限を解放

### 永続化パーミッション上限

- Android 10 以前: **128** 件/アプリ
- Android 11 (API 30) 以降: **512** 件/アプリ
- 上限に達すると `takePersistableUriPermission()` が SecurityException をスロー
- 対策: 古い権限を `releasePersistableUriPermission()` で解放してから新規取得

### SAF でアクセスできないディレクトリ (Android 11+)

以下のディレクトリは `ACTION_OPEN_DOCUMENT_TREE` で選択不可:
- ストレージルート（内部ストレージの最上位）
- `Download` ディレクトリ
- `Android/data` ディレクトリ
- `Android/obb` ディレクトリ

### プラットフォームチャネル

| 用途 | チャネル種別 |
|---|---|
| フォルダ選択、ファイル列挙、画像読み込み | MethodChannel |
| USB 接続/切断監視、ストレージ変更通知 | EventChannel |

### スレッディング

- SAF のファイル I/O は必ずバックグラウンドスレッドで実行
- `ContentResolver.openInputStream()` はメインスレッドで呼ぶと ANR の原因になる
- Kotlin コルーチン (`Dispatchers.IO`) を使用

### エラーハンドリング（例外マッピング）

| Kotlin 側例外 | Domain 例外 |
|---|---|
| `SecurityException` | PermissionDenied |
| `FileNotFoundException` | StorageDisconnected |
| `IllegalArgumentException` (無効な URI) | StorageDisconnected |

### パーミッション状態の確認ルール

- `SharedPreferences` 等にパーミッション状態を保存しない
- 常に `ContentResolver.getPersistedUriPermissions()` で実際の状態を確認する
- `onResume` でパーミッション状態が変わっている可能性がある
- 常に URI アクセス失敗を想定したエラーハンドリングが必要

---

## 10.2 Windows

### 実装
- dart:io (Directory, File)
- file_picker (OS標準フォルダ選択ダイアログ)
- desktop_drop (ドラッグ&ドロップによるフォルダ追加)

---

## 10.3 OS既定画像フォルダ検出

初回起動時に即座にギャラリーを表示するため、OS既定の画像フォルダを自動検出する。

### Android
- MediaStore経由で `DCIM/Camera`, `Pictures` 等の標準パスを自動取得
- SAF権限が不要なMediaStore読み取りで初回表示を高速化
- ユーザーがフォルダ変更時にSAF権限を取得

### Windows
- `Environment.SpecialFolder.MyPictures` を自動取得
- OS標準フォルダ選択ダイアログ (`file_picker`) でフォルダ変更

---

## 10.4 Android 14+ (API 34) 固有の考慮事項

### Selected Photos Access

- Pictana は SAF (`ACTION_OPEN_DOCUMENT_TREE`) を使用するため、Selected Photos Access の影響は受けない
- SAF はユーザーが明示的にフォルダを選択する仕組みであり、MediaStore パーミッションとは独立
- 将来的に MediaStore 連携（デフォルト画像フォルダ検出等）を行う場合は考慮が必要

### マニフェスト宣言（推奨）

```xml
<!-- Android 12L 以下 -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />

<!-- Android 13+ (MediaStore 使用時のみ) -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />

<!-- Android 14+ 部分アクセス制御 (MediaStore 使用時のみ) -->
<uses-permission android:name="android.permission.READ_MEDIA_VISUAL_USER_SELECTED" />
```

### Google Play ポリシー

- `MANAGE_EXTERNAL_STORAGE` は Google Play で厳しく審査される（ファイルマネージャ等のみ許可）
- SAF ベースのアクセスはポリシー上問題なし
- `READ_MEDIA_*` パーミッションも正当な理由が必要（2024年以降の審査強化）

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

### ExifMetadata

```text
- id
- imageEntryId
- dateTaken
- camera
- latitude
- longitude
- indexed (bool)
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
- 切断時インライン通知 & 自動リトライ
- OS既定画像フォルダ自動検出
- Windows OS標準フォルダ選択ダイアログ
- デスクトップでのドラッグ&ドロップによるフォルダ追加

## 5.5 対応画像形式

### MVP対応
- JPEG
- PNG
- WebP
- GIF
- HEIC
- HEIF
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
