# プロジェクト構成

## アーキテクチャ

DDD 寄りクリーンアーキテクチャ（レイヤードアーキテクチャ）を採用。依存方向は外側から内側へ。

```
presentation → application → domain ← infrastructure
```

## ディレクトリ構造

```
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

## 設計パターン・規約

### レイヤー間の依存ルール
- `domain` 層は他のどの層にも依存しない（純粋 Dart）
- `application` 層は `domain` のみに依存
- `infrastructure` 層は `domain` のインターフェースを実装
- `presentation` 層は `application` の Provider/UseCase 経由でデータにアクセス

### 状態管理
- Riverpod + riverpod_generator によるコード生成 Provider
- `@riverpod` アノテーションで Provider を定義
- `keepAlive: true` はシングルトン的に保持すべき Provider に使用

### エンティティ
- `freezed` でイミュータブルに定義
- `fromJson` / `toJson` は `json_serializable` で生成

### ユースケース
- 機能ドメインごとにサブフォルダで分類
- コンストラクタでリポジトリを注入（DI）
- 単一責任: 1 クラス = 1 ユースケース
- 必ず `Future` または `Stream` を返却

### プラットフォーム固有実装
- `infrastructure/storage/` 配下にプラットフォーム別フォルダ
- Android の `content://` URI と Windows のファイルパスは Domain では `EntryId` として抽象化
- Platform 差異は Infrastructure 層で吸収し Domain/Application 層へ漏らさない

### 画面遷移
- GoRouter による宣言的ルーティング
- ルートパスは定数クラスで一元管理

### エラーハンドリング
- OS 固有例外は Domain 例外（`StorageDisconnected` 等）へ変換
- 切断時はインライン通知を表示しバックグラウンドでリトライ
- キャッシュ済みサムネイルは切断中も表示を継続

### 禁止事項
- 同期 I/O（dart:io の同期メソッド）の使用
- `Image.memory` による巨大 Bitmap 生成
- Provider 乱立と BuildContext への過度な依存
