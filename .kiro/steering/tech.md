# 技術スタック

## フレームワーク・言語

- **Flutter** (Dart SDK ^3.11.5)
- Material Design 3 ベース

## 主要ライブラリ

| カテゴリ | パッケージ | 用途 |
|---------|-----------|------|
| 状態管理 | flutter_riverpod, hooks_riverpod, riverpod_annotation | Provider ベースの状態管理 |
| Hooks | flutter_hooks | HookWidget によるステートフルロジック再利用 |
| コード生成 | freezed, json_serializable, riverpod_generator, drift_dev | イミュータブルモデル・Provider 自動生成 |
| データベース | drift, sqlite3_flutter_libs | ローカル SQLite DB |
| 画像表示 | extended_image | ズーム・ジェスチャー対応画像ウィジェット |
| キャッシュ | flutter_cache_manager | サムネイル等のファイルキャッシュ |
| ルーティング | go_router | 宣言的ルーティング |
| ファイル選択 | file_picker | ストレージルート選択 |
| UI エフェクト | shimmer | ローディングプレースホルダー |
| ユーティリティ | path, path_provider, collection, logger | パス操作・ログ |
| テスト (PBT) | glados (git) | Property-based testing |

## ビルドシステム

- **Flutter CLI** + **build_runner** によるコード生成

## よく使うコマンド

```bash
# 依存取得
flutter pub get

# コード生成（freezed, drift, riverpod_generator 等）
dart run build_runner build --delete-conflicting-outputs

# コード生成（ウォッチモード）
dart run build_runner watch --delete-conflicting-outputs

# 静的解析
flutter analyze

# テスト実行
flutter test

# Windows ビルド（デバッグ）
flutter run -d windows

# Windows ビルド（リリース）
flutter build windows
```

## Lint 設定

- `package:flutter_lints/flutter.yaml` を基本ルールとして使用
- `custom_lint` + `riverpod_lint` によるカスタムリント有効

## コード生成ファイル

以下の拡張子を持つファイルは自動生成されるため、手動編集しない:
- `*.freezed.dart`
- `*.g.dart`
