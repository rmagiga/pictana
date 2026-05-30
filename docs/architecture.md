# アーキテクチャ設計 (architecture.md)

# 7. アーキテクチャ

## 7.1 採用アーキテクチャ

DDD寄り Clean Architecture（レイヤードアーキテクチャ）を採用する。依存方向は外側から内側へ。

```text
presentation → application → domain ← infrastructure
```

---

## 7.2 SOLID原則

### S: Single Responsibility Principle

- WidgetはUIのみ
- UseCaseは業務ロジックのみ
- Repositoryはデータアクセスのみ

### O: Open Closed Principle

新OS追加時:

- Domain変更不要
- Repository差し替えのみ

### L: Liskov Substitution Principle

StorageRepository Interface を全OSで置換可能にする。

### I: Interface Segregation Principle

Repository Interface を小さく分割。

例:

- ImageRepository
- ThumbnailRepository
- StorageRepository

### D: Dependency Inversion Principle

Application層は抽象Interfaceへ依存する。

---

# 8. ディレクトリ構成

```text
lib/
├── main.dart                    # エントリーポイント
├── core/                        # 横断的関心事
│   ├── constants/               # アプリ定数
│   ├── errors/                  # 例外クラス（StorageDisconnected 等）
│   ├── extensions/              # Dart 拡張メソッド
│   ├── logging/                 # ロガー設定
│   └── utils/                   # ユーティリティ
├── domain/                      # ドメイン層（ビジネスルール）
│   ├── entities/                # エンティティ（freezed で定義）
│   ├── repositories/            # リポジトリインターフェース
│   └── value_objects/           # 値オブジェクト（EntryId 等）
├── application/                 # アプリケーション層
│   ├── providers/               # リポジトリ DI 用 Provider
│   └── usecases/                # ユースケース（機能別サブフォルダ）
│       ├── favorites/
│       ├── gallery/
│       ├── settings/
│       ├── storage/
│       └── viewer/
├── infrastructure/              # インフラ層（外部依存の実装）
│   ├── database/                # Drift DB 定義
│   └── storage/                 # ストレージアクセス実装
│       ├── android/             # Android SAF 固有実装
│       ├── common/              # プラットフォーム共通ファクトリ
│       └── windows/             # Windows 固有実装
├── presentation/                # プレゼンテーション層
│   ├── providers/               # UI 状態管理 Provider
│   ├── screens/                 # 画面ウィジェット
│   ├── themes/                  # テーマ定義
│   └── widgets/                 # 再利用可能ウィジェット
└── router/                      # GoRouter ルート定義
```

---

# 9. Domain設計

## 9.1 Entity

### EntryId

Platform固有識別子を抽象化する Value Object。

目的:

- Android content:// URI
- Windows file path

混同防止。

Infrastructure層のみで変換を行う。

```text
- rawValue
- platformType
```

### ImageEntry

```text
- id: EntryId
- name
- extension
- width
- height
- size
- createdAt
- modifiedAt
- uri
- thumbnailUri
- mimeType
```

### FolderEntry

```text
- id
- name
- uri
- imageCount
```

### StorageRoot

```text
- id
- name
- type
- uri
- isConnected
```

## 9.2 Repository Interface

### StorageRepository

責務:

- ストレージ列挙
- フォルダ選択
- URI永続化
- 接続状態管理
- OS既定画像フォルダ検出

### ImageRepository

責務:

- 画像列挙
- 画像取得
- metadata取得
- ファイル名検索
- 形式フィルター

### ThumbnailRepository

責務:

- サムネイル生成
- キャッシュ
- invalidate

---

# 10. Platform差異吸収

## 10.3 抽象化方針

Domain/Application層へ以下を漏らさない。

- Uri権限
- SAF API
- File API
- OS固有例外

Repository内部で吸収する。

---

# 12. パフォーマンス設計

## 12.1 必須事項

- Isolate decode
- 非同期ロード
- Lazy Load
- Virtual Scroll
- Viewport最適化

## 12.2 禁止事項

禁止:

```dart
Image.memory(fullImage)
```

理由:

- 巨大Bitmap生成
- OOM原因

---

# 14. Provider設計

## 14.1 Riverpod + riverpod_generator

`@riverpod` アノテーションによるコード生成 Provider を使用する。

| Provider パターン | 用途 |
|---|---|
| `@riverpod` (自動破棄) | 画面固有の状態、一時的なデータ |
| `@Riverpod(keepAlive: true)` | シングルトン的に保持すべき Provider（Repository DI 等） |
| FutureProvider (生成) | 非同期データロード |
| StreamProvider (生成) | ストレージ監視等のリアクティブデータ |

### Provider 命名規約

- riverpod_generator が自動生成するため、関数名がそのまま Provider 名になる
- `*.g.dart` ファイルは手動編集しない

---

# 15. UseCase一覧

## 15.1 Storage

- SelectStorageUseCase
- PersistUriPermissionUseCase
- WatchStorageConnectionUseCase
- GetDefaultImageFoldersUseCase

## 15.2 Gallery

- LoadFolderImagesUseCase
- LoadThumbnailUseCase
- SortImagesUseCase
- SearchImagesUseCase
- IndexExifUseCase

## 15.3 Viewer

- LoadImageUseCase
- PreloadAdjacentImagesUseCase
- ResumePositionUseCase
- GetViewerPagesUseCase

## 15.4 Favorites

- ToggleFavoriteUseCase
- GetFavoritesUseCase

---

# 19. エラーハンドリング

## 19.1 Error分類

| Error | 内容 |
|---|---|
| StorageDisconnected | USB切断 |
| PermissionDenied | SAF権限喪失 |
| DecodeFailed | 画像破損 |
| CacheFailed | cache破損 |
| OutOfMemory | memory不足 |

## 19.2 方針

- OS固有例外をDomainへ漏らさない
- User向けメッセージへ変換
- retry可能設計

### USB切断対応

Infrastructure層では以下例外を必ず捕捉する。

- FileSystemException
- SAF access exception (SecurityException)
- ContentResolver exception (FileNotFoundException, IllegalArgumentException)

これらを以下Domain例外へ変換する。

```text
StorageDisconnected
```

UI層はOS例外を直接扱わない。

StorageDisconnected例外を受けた場合、画面遷移ではなくインラインバナーで通知し、バックグラウンドで自動リトライする。キャッシュ済みサムネイルは切断中も表示を継続する。

---

# 20. Android Native設計

## 20.1 Kotlin責務

- SAF interaction (ACTION_OPEN_DOCUMENT_TREE)
- URI permission (takePersistableUriPermission)
- ContentResolver.query() による高速ファイル列挙
- ContentResolver.loadThumbnail() によるサムネイル取得
- USB attach/detach 監視
- stream access (ContentResolver.openInputStream)

Flutterへは抽象化済みAPIのみ提供。

## 20.2 プラットフォームチャネル

| 用途 | チャネル種別 |
|---|---|
| フォルダ選択、ファイル列挙、画像読み込み | MethodChannel |
| USB 接続/切断監視、ストレージ変更通知 | EventChannel |

## 20.3 スレッディング

- SAF のファイル I/O は必ずバックグラウンドスレッドで実行
- Kotlin コルーチン (`Dispatchers.IO`) を使用
- メインスレッドでの ContentResolver 操作は ANR の原因になるため禁止

---

# 21. Windows設計

Windowsは開発高速化目的で主要ターゲット。

## 必須要件

- Androidと同一UI
- 同一UseCase
- 同一Repository Interface
- Local/USB drive対応
- dart:io による FileSystem アクセス
- file_picker による OS標準フォルダ選択ダイアログ
- desktop_drop によるドラッグ&ドロップ対応

OS差異はInfrastructure層で吸収。

---

# 22. AIエージェント実装ルール

## 22.1 必須

- SOLID遵守
- Platform依存分離
- Widget責務最小化
- Repository経由アクセス
- Provider乱立禁止
- BuildContext依存最小化

### 非同期境界

Repositoryのメソッドはすべて:

- Future
- Stream

のいずれかを返す。

同期I/Oは禁止。

Infrastructure内部でI/O待機中にUIスレッドをブロックしない。

### 型安全

Android:

```text
content:// URI
```

Windows:

```text
file path
```

を直接混在させない。

Domainでは EntryId Value Object を使用する。

Infrastructure層のみで変換する。

### エラーハンドリング

USB切断時:

```text
FileSystemException → StorageDisconnected
SecurityException → PermissionDenied
FileNotFoundException → StorageDisconnected
IllegalArgumentException → StorageDisconnected
```

を直接UIへ渡さない。必ずDomain例外へ変換する。

## 22.2 禁止

禁止事項:

- UIから直接Storage API呼び出し
- File API直アクセス
- 巨大Bitmap保持
- 同期IO
- OS条件分岐をUIへ書く
- `*.freezed.dart` / `*.g.dart` の手動編集

## 22.3 Pull Request単位

1PRは以下単位を推奨。

- 1 screen
- 1 repository
- 1 usecase
- 1 feature

---

# 24. 将来拡張性

以下追加時にDomain変更不要を目標とする。

- Linux
- macOS
- NAS
- SMB
- Cloud Storage
- Video Viewer
- AI Search
