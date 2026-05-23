# パフォーマンス改善タスク

## Phase 0: OOM防止とメモリ解放
- [x] Android: `SafCommands.kt` に `inSampleSize` + `RGB_565` 追加
- [x] UI: `image_grid_tile.dart` の `Image.memory` → `ExtendedImage.memory` に変更
- [x] UI: `image_grid_tile.dart` のプレースホルダーを灰色Boxに変更 & アニメーション短縮

## Phase 1: SQLiteメタデータ化と検索/ソート/フィルタ委譲
- [x] DB: `images_table.dart` 新規作成（テーブル構造とインデックスの定義）
- [x] DB: `app_database.dart` 更新（スキーマバージョン3への移行とクエリ追加）
- [x] Build: `build_runner` を実行してDriftのコード自動生成を更新
- [x] Repository: `windows_image_repository.dart` を更新（同期とDBクエリへの移行。100件バッファ処理と空フォルダガード実装）
- [x] Repository: `android_image_repository.dart` を更新（同期とDBクエリへの移行。100件バッファ処理と空フォルダガード実装）
- [x] Controller: `search_controller.dart` を調整（debounce 150ms ＆ 検索中フラグ追加）
- [x] UI: `image_grid_tile.dart` に検索中のサムネイル要求ガードを追加
- [x] テストコード: `android_image_repository_test.dart` をDB同期とインデックス順を考慮したアサーション（ゼロ埋め3桁）に更新

## Phase 2: スケジューラとデコード優先度・キャンセル制御
- [x] Windows: `windows_thumbnail_repository.dart` を `Isolate.run` を使った非同期処理に更新
- [x] ユニットテスト検証の完了 (AndroidImageRepository、AndroidStorageRepositoryのテストが全件パスすることを確認)
