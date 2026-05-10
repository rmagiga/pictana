# プロジェクト要件 (requirements.md)

# 1. プロジェクト概要

## 1.1 目的

Androidを主軸とし、Windowsでも動作する高性能な画像参照アプリを開発する。

本アプリは以下を重視する。

- 外部ストレージ(USB OTG含む)対応
- 大量画像(10,000枚規模)への対応
- 高速なサムネイル表示
- メモリ効率
- SAF(Storage Access Framework)対応
- Windowsでの高速デバッグ
- 将来的なOS追加への拡張性
- AIエージェントによる継続開発容易性

画像編集機能は実装しない。

---

# 2. 技術要件

## 2.1 Flutter

| 項目 | 内容 |
|---|---|
| Flutter | stable 最新 |
| Dart | stable 最新 |
| Android | Android 14+ |
| Windows | Windows 11 |

---

# 3. 非機能要件

## 3.1 パフォーマンス

| 項目 | 要件 |
|---|---|
| 画像一覧 | 10,000枚規模対応 |
| スクロール | 60fps維持 |
| サムネイル | 遅延ロード |
| メモリ | OOM回避 |
| キャッシュ | ディスクキャッシュ対応 |

---

## 3.2 保守性

- SOLID原則遵守
- DDD寄りアーキテクチャ
- Platform依存コード隔離
- Repository Pattern
- UseCase分離
- DI可能構成

---

## 3.3 クロスプラットフォーム

OS差異を吸収可能な構造とする。

例:

- Android SAF
- Windows FileSystem
- 将来 Linux/macOS 対応

をDomain/Application層へ漏らさない。

---

# 4. 採用ライブラリ

## 4.1 UI/状態管理

| ライブラリ | 用途 |
|---|---|
| flutter_riverpod | 状態管理 |
| hooks_riverpod | Hook統合 |
| flutter_hooks | Hook |

---

## 4.2 画像表示

| ライブラリ | 用途 |
|---|---|
| extended_image | 画像表示/zoom/pan |
| photo_view | 必要時のみ検討 |

extended_image を主軸とする。

理由:

- memory release
- gallery向け
- cache
- gesture
- slide

対応。

---

## 4.3 データベース

| ライブラリ | 用途 |
|---|---|
| drift | SQLite ORM |
| sqlite3_flutter_libs | SQLite runtime |

---

## 4.4 Android Storage

| ライブラリ | 用途 |
|---|---|
| saf_stream | SAF stream access |

Androidネイティブ側は Kotlin 実装を許容する。

---

## 4.5 キャッシュ

| ライブラリ | 用途 |
|---|---|
| flutter_cache_manager | ディスクキャッシュ |

---

## 4.6 Utility

| ライブラリ | 用途 |
|---|---|
| freezed | immutable model |
| json_serializable | serialization |
| path | path utility |
| collection | utility |
| logger | logging |

---

## 4.7 将来拡張デコーダー

### 将来検討

- libvips
- native decoder wrapper
- custom codec pipeline

将来的な:

- RAW
- 超高解像度画像
- AVIF/HEIC高速decode

対応を見据え、ImageDecoder abstraction を導入可能な設計にする。

Domain/Application層は decoder 実装へ依存しない。

Infrastructure層で切り替え可能にする。

---

# 6. 非MVP機能

以下は後回し。

- 動画
- RAW
- AI分類
- OCR
- EXIF編集
- GIF再生制御
- クラウド同期
- NAS
- SMB
- DLNA
