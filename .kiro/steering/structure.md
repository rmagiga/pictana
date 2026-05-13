# プロジェクト構成

## アーキテクチャ

クリーンアーキテクチャ（レイヤードアーキテクチャ）を採用。依存方向は外側から内側へ。

```
presentation → application → domain ← infrastructure
```

## ディレクトリ構造

```
lib/
├── main.dart                    # エントリーポイント
├── core/                        # 横断的関心事
│   ├── constants/               # アプリ定数
│   ├── errors/                  # 例外クラス
│   ├── extensions/              # Dart 拡張メソッド
│   ├── logging/                 # ロガー設定
│   └── utils/                   # ユーティリティ
├── domain/                      # ドメイン層（ビジネスルール）
│   ├── entities/                # エンティティ（freezed で定義）
│   ├── repositories/            # リポジトリインターフェース
│   └── value_objects/           # 値オブジェクト
├── application/                 # アプリケーション層
│   ├── providers/               # リポジトリ DI 用 Provider
│   └── usecases/                # ユースケース（機能別サブフォルダ）
│       ├── gallery/
│       ├── settings/
│       ├── storage/
│       └── viewer/
├── infrastructure/              # インフラ層（外部依存の実装）
│   ├── database/                # Drift DB 定義
│   └── storage/                 # ストレージアクセス実装
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
- 機能ドメインごとにサブフォルダで分類（gallery, settings, storage, viewer）
- コンストラクタでリポジトリを注入（DI）
- 単一責任: 1 クラス = 1 ユースケース

### プラットフォーム固有実装
- `infrastructure/storage/` 配下にプラットフォーム別フォルダ
- `PlatformStorageFactory` で実装を切り替え

### 画面遷移
- GoRouter による宣言的ルーティング
- ルートパスは `AppRoutes` 定数クラスで一元管理
