# Pictana (ピク棚)

ローカルストレージ上の画像を閲覧・管理するための Flutter デスクトップ/モバイルアプリケーション。

## 特徴

- 外部ストレージ（USB OTG 含む）のフォルダブラウジング
- 10,000 枚規模の画像に対応した高速サムネイル表示（遅延ロード・仮想スクロール）
- 画像ビューア（ズーム・スワイプ・隣接画像プリロード）
- ソート・ファイル名検索・MIME type フィルター
- お気に入り管理
- ダーク/ライトテーマ切り替え
- キャッシュ管理

## 対応プラットフォーム

| プラットフォーム | ストレージアクセス方式 |
|---|---|
| Windows | dart:io ファイルシステム |
| Android | Storage Access Framework (SAF) |

## 対応画像形式

JPEG, PNG, WebP, GIF, HEIC, HEIF, AVIF

## 技術スタック

- **フレームワーク:** Flutter (Dart SDK ^3.11.5)
- **状態管理:** Riverpod + riverpod_generator
- **データベース:** Drift (SQLite)
- **画像表示:** Extended Image
- **ルーティング:** GoRouter
- **アーキテクチャ:** DDD 寄りクリーンアーキテクチャ

## セットアップ

```bash
# 依存関係のインストール
flutter pub get

# コード生成（freezed, drift, riverpod_generator 等）
dart run build_runner build --delete-conflicting-outputs
```

## 開発

```bash
# Windows で実行
flutter run -d windows

# Android で実行
flutter run -d <device_id>

# コード生成（ウォッチモード）
dart run build_runner watch --delete-conflicting-outputs

# 静的解析
flutter analyze

# テスト実行
flutter test
```

## ビルド

```bash
# Windows リリースビルド
flutter build windows
```

## ライセンス

[MIT License](LICENSE)
