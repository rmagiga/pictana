# アーキテクチャ設計 (architecture.md)

# 7. アーキテクチャ

## 7.1 採用アーキテクチャ

DDD寄り Clean Architecture を採用する。

```text
presentation
  ↓
application
  ↓
domain
  ↓
infrastructure
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
 ├ core/
 │   ├ constants/
 │   ├ errors/
 │   ├ extensions/
 │   ├ logging/
 │   └ utils/
 │
 ├ domain/
 │   ├ entities/
 │   ├ repositories/
 │   ├ value_objects/
 │   └ services/
 │
 ├ application/
 │   ├ usecases/
 │   ├ dto/
 │   └ providers/
 │
 ├ infrastructure/
 │   ├ storage/
 │   │   ├ android/
 │   │   ├ windows/
 │   │   └ common/
 │   ├ database/
 │   ├ cache/
 │   └ repositories/
 │
 ├ presentation/
 │   ├ screens/
 │   ├ widgets/
 │   ├ providers/
 │   └ themes/
 │
 └ main.dart
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

### ImageRepository

責務:

- 画像列挙
- 画像取得
- metadata取得

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

## 14.1 Riverpod分類

| Provider | 用途 |
|---|---|
| RepositoryProvider | repository DI |
| StateNotifierProvider | state管理 |
| FutureProvider | async load |
| StreamProvider | storage監視 |

---

# 15. UseCase一覧

## 15.1 Storage

- SelectStorageUseCase
- PersistUriPermissionUseCase
- WatchStorageConnectionUseCase

## 15.2 Gallery

- LoadFolderImagesUseCase
- LoadThumbnailUseCase
- SortImagesUseCase

## 15.3 Viewer

- LoadImageUseCase
- PreloadAdjacentImagesUseCase

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
- SAF access exception
- ContentResolver exception

これらを以下Domain例外へ変換する。

```text
StorageDisconnected
```

UI層はOS例外を直接扱わない。

---

# 20. Android Native設計

## 20.1 Kotlin責務

- SAF interaction
- URI permission
- USB attach/detach
- stream access

Flutterへは抽象化済みAPIのみ提供。

---

# 21. Windows設計

Windowsは開発高速化目的で必須。

## 必須要件

- Androidと同一UI
- 同一UseCase
- 同一Repository Interface
- Local/USB drive対応

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
FileSystemException
```

を直接UIへ渡さない。

必ず:

```text
StorageDisconnected
```

へ変換する。

## 22.2 禁止

禁止事項:

- UIから直接Storage API呼び出し
- File API直アクセス
- 巨大Bitmap保持
- 同期IO
- OS条件分岐をUIへ書く

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
