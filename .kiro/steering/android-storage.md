# Android 14+ ストレージアクセス仕様まとめ

Optrig の Android 対応に関連する、Android 14 (API 34) 以降のストレージ関連仕様をまとめる。
情報源: [Android Developers 公式ドキュメント](https://developer.android.com/about/versions/14)

## 1. Storage Access Framework (SAF) — 基本仕様

SAF は Android 4.4 (API 19) から導入されたフレームワークで、Android 14+ でも引き続き有効。

### ACTION_OPEN_DOCUMENT_TREE

- ユーザーにフォルダ選択 UI を表示し、選択されたフォルダツリーへのアクセス権を取得する
- 返される URI は `content://` スキーム（ファイルパスではない）
- `DocumentsContract.buildChildDocumentsUriUsingTree()` で子要素を列挙可能
- `DocumentsContract.buildDocumentUriUsingTree()` で個別ドキュメントにアクセス可能

### パーミッション永続化 (takePersistableUriPermission)

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

## 2. Android 14 (API 34) の変更点

### 2.1 Selected Photos Access（写真・動画の部分アクセス）

Android 14 の最大の変更。ユーザーがアプリに対して「選択した写真と動画のみ」アクセスを許可できる。

#### 新しいパーミッション

- `READ_MEDIA_VISUAL_USER_SELECTED` — 部分アクセス制御用の新パーミッション
- `READ_MEDIA_IMAGES` / `READ_MEDIA_VIDEO` を宣言すると自動的にマニフェストに追加される

#### パーミッションモデル（API 34 ターゲット時）

| ユーザーの選択 | 結果 |
|---|---|
| すべて許可 | `READ_MEDIA_IMAGES` / `READ_MEDIA_VIDEO` が GRANTED |
| 写真と動画を選択 | `READ_MEDIA_VISUAL_USER_SELECTED` のみ GRANTED |
| 許可しない | すべて DENIED |

#### 互換モード

- `READ_MEDIA_VISUAL_USER_SELECTED` を宣言していないアプリは互換モードで動作
- 互換モードでは「写真と動画を選択」時に一時的に `READ_MEDIA_IMAGES`/`READ_MEDIA_VIDEO` が付与される
- アプリがバックグラウンドに移行するかプロセスが終了すると権限が失効（ワンタイムパーミッション相当）

#### Optrig への影響

- **Optrig は SAF (`ACTION_OPEN_DOCUMENT_TREE`) を使用するため、Selected Photos Access の影響は受けない**
- SAF はユーザーが明示的にフォルダを選択する仕組みであり、MediaStore パーミッションとは独立
- ただし、将来的に MediaStore 連携（デフォルト画像フォルダ検出等）を行う場合は考慮が必要

### 2.2 マニフェスト宣言（推奨）

```xml
<!-- Android 12L 以下 -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />

<!-- Android 13+ (MediaStore 使用時のみ) -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />

<!-- Android 14+ 部分アクセス制御 (MediaStore 使用時のみ) -->
<uses-permission android:name="android.permission.READ_MEDIA_VISUAL_USER_SELECTED" />
```

### 2.3 フォアグラウンドサービスタイプ必須化

- Android 14 ターゲットのアプリは、すべてのフォアグラウンドサービスに `foregroundServiceType` を指定する必要がある
- Optrig でバックグラウンドスキャン等を行う場合は `dataSync` または `shortService` を検討

### 2.4 その他の関連変更

- 暗黙的インテントの制限強化（exported=false のコンポーネントへの配信制限）
- `SCHEDULE_EXACT_ALARM` がデフォルトで拒否（新規インストールアプリ）

## 3. Android 15 (API 35) の変更点

### 3.1 QUERY_ARG_LATEST_SELECTION_ONLY

- 部分アクセス時に「最後にユーザーが選択したメディア」のみをクエリ可能
- `MediaStore` クエリの `Bundle` に `QUERY_ARG_LATEST_SELECTION_ONLY = true` を設定
- Android 15 以降、および Google Play システムアップデート対応の Android 14 デバイスで利用可能

### 3.2 SAF への直接的な変更

- Android 15 では SAF の基本動作に大きな変更はない
- `ACTION_OPEN_DOCUMENT_TREE` と `takePersistableUriPermission` は引き続き同様に動作

## 4. Photo Picker vs SAF vs MediaStore — 使い分け

| 方式 | ユースケース | パーミッション | Optrig での用途 |
|---|---|---|---|
| **Photo Picker** | 写真/動画の選択（プロフィール画像、添付等） | 不要 | 使用しない |
| **MediaStore** | デバイス全体のメディアクエリ | READ_MEDIA_* | デフォルト画像フォルダ検出（補助的） |
| **SAF (OPEN_DOCUMENT_TREE)** | フォルダ単位のアクセス、ファイル管理アプリ | 不要（ユーザー選択で付与） | **メイン方式** |

### Optrig が SAF を採用する理由

1. フォルダ階層のブラウジングが必要（Photo Picker では不可）
2. USB OTG / 外部ストレージへのアクセスが必要
3. パーミッション永続化により再起動後もアクセス可能
4. Scoped Storage の制約を受けずにフォルダ内全ファイルにアクセス可能
5. `READ_MEDIA_*` パーミッション不要（Google Play ポリシー上有利）

## 5. ContentResolver.loadThumbnail() (API 29+)

```kotlin
// Android 10 (API 29) 以降で利用可能
val thumbnail: Bitmap = contentResolver.loadThumbnail(
    uri,           // content:// URI
    Size(256, 256), // 要求サイズ
    null           // CancellationSignal
)
```

- SAF の `content://` URI に対しても使用可能
- システムがキャッシュ済みサムネイルを返すため高速
- サポートされていない場合やエラー時は例外をスロー → フォールバックでフル画像をデコード

## 6. 実装上の注意点

### URI アクセスの一時性

- SAF URI へのアクセスは永続化しない限り一時的
- `takePersistableUriPermission()` を呼ばないと、プロセス終了後にアクセス不可
- 永続化済みでも、ユーザーが設定からアクセスを取り消す可能性がある
- **常に URI アクセス失敗を想定したエラーハンドリングが必要**

### パーミッション状態の確認

- `SharedPreferences` 等にパーミッション状態を保存しない
- 常に `ContentResolver.getPersistedUriPermissions()` で実際の状態を確認する
- `onResume` でパーミッション状態が変わっている可能性がある

### デバイスアップグレード時の互換性

- Android 13 → 14 へのアップグレード時、既存の `READ_MEDIA_*` 権限は維持される
- Android 12 以前 → 14 へのアップグレード時、`READ_EXTERNAL_STORAGE` は `READ_MEDIA_*` に自動マッピング
- SAF の永続化パーミッションはアップグレードの影響を受けない

### Google Play ポリシー

- `MANAGE_EXTERNAL_STORAGE` は Google Play で厳しく審査される（ファイルマネージャ等のみ許可）
- SAF ベースのアクセスはポリシー上問題なし
- `READ_MEDIA_*` パーミッションも正当な理由が必要（2024年以降の審査強化）

## 7. Flutter プラットフォームチャネル実装時の考慮事項

### MethodChannel vs EventChannel

| 用途 | チャネル種別 |
|---|---|
| フォルダ選択、ファイル列挙、画像読み込み | MethodChannel |
| USB 接続/切断監視、ストレージ変更通知 | EventChannel |

### スレッディング

- SAF のファイル I/O は必ずバックグラウンドスレッドで実行
- `ContentResolver.openInputStream()` はメインスレッドで呼ぶと ANR の原因になる
- Kotlin コルーチン (`Dispatchers.IO`) または `ExecutorService` を使用

### エラーハンドリング

- `SecurityException` → PermissionDeniedException にマッピング
- `FileNotFoundException` → StorageDisconnectedException にマッピング
- `IllegalArgumentException` (無効な URI) → StorageDisconnectedException にマッピング
