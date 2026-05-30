# Pictana (ピク棚)

ローカルストレージ上の画像を閲覧・管理するための Flutter デスクトップ/モバイルアプリケーション。

## 特徴

- **外部ストレージ（USB OTG 含む）対応**: フォルダブラウジングと URI パーミッションの永続化
- **高速サムネイル表示**: 10,000 枚規模の画像に対応（遅延ロード、仮想スクロール、Viewport 最適化）
- **画像ビューア**: ズーム、スワイプ、隣接画像の先行メモリプリロード
- **見開き表示（漫画モード）**: 画像アスペクト比に応じた自動見開き、表紙（単一）判定、左右めくり（RTL/LTR）のサポート
- **閲覧位置の記憶（レジューム）**: フォルダごとの最終閲覧位置をローカル DB に自動保存し、次回起動時に復元
- **EXIF 情報の先行非同期インデックス化**: フォルダ内の撮影日時、カメラ、GPS 位置情報などを非同期で抽出し高速表示
- **整理・探索**: ソート、ファイル名検索、MIME type フィルター、お気に入り管理
- **システム構成**: ダーク/ライトテーマ切り替え、キャッシュ管理（メモリ/ディスク）

## 対応プラットフォーム

| プラットフォーム | ストレージアクセス方式 |
|---|---|
| Windows | dart:io ファイルシステム |
| Android | Storage Access Framework (SAF) |

## 対応画像形式

JPEG, PNG, WebP, GIF (一覧では静止、詳細ビューアで自動再生), HEIC, HEIF, AVIF

## 技術スタック

- **フレームワーク:** Flutter (Dart SDK ^3.11.5)
- **状態管理:** Riverpod + riverpod_generator
- **データベース:** Drift (SQLite)
- **画像表示:** Extended Image
- **ルーティング:** GoRouter
- **アーキテクチャ:** DDD 寄りクリーンアーキテクチャ

---

## 開発とビルド

本プロジェクトでは、ビルドおよびコード生成などの開発タスクを効率化するため [Melos](https://melos.invertase.dev/) をタスクランナーとして導入しています。

### 依存関係の取得

```bash
# Melos を使用する場合
melos run pub:get

# または通常の Flutter コマンド
flutter pub get
```

### コード生成（build_runner）

`freezed`, `drift`, `riverpod_generator` などの自動生成コードをビルドします。

```bash
# コード生成（ビルド）
melos run build_runner
# または: dart run build_runner build --delete-conflicting-outputs

# コード生成（変更監視ウォッチ）
melos run watch
# または: dart run build_runner watch --delete-conflicting-outputs
```

### 静的解析とテスト

```bash
# 静的解析（Linter）
melos run analyze
# または: flutter analyze

# 静的解析警告の自動修正
melos run fix
# または: dart fix --apply

# ユニットテスト実行
melos run test
# または: flutter test
```

### 開発実行

```bash
# Windows でデバッグ実行
flutter run -d windows

# Android でデバッグ実行
flutter run -d <device_id>
```

### ビルド

```bash
# Windows リリースビルド
melos run build:windows
# または: flutter build windows

# Android リリース APK ビルド
melos run build:apk
# または: flutter build apk --release
```

## ライセンス

[MIT License](LICENSE)

