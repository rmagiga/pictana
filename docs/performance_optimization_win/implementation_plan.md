# 画像一覧の高速化およびパフォーマンス改善の実装計画 (Windows/Android両対応)

本計画は、`docs/priority_roadmap.md` に提示された改善ロードマップに基づき、WindowsおよびAndroid環境下での大量画像（10,000枚規模）のサムネイル表示、検索、ソート、フィルタリングなどの動作を劇的に高速化・最適化するための実装手順を示します。

特に、Windows環境におけるUIスレッドのブロッキング回避（Isolateデコードの導入）や、Windows/Android共通でのSQLiteへのメタデータ検索/ソート委譲について考慮しています。

## ユーザーレビューが必要な項目

> [!IMPORTANT]
> **1. SQLiteへのメタデータ同期タイミング**
> フォルダを開いた際、初回のみファイルシステム（Windows: `Directory.list()`, Android: `ContentResolver.query()`）からメタデータを取得してSQLiteに格納（インデックス化）し、以降はDBをクエリするようにします。
> この同期処理により、初回のみ走査コストがかかりますが、2回目以降は瞬時にソート・フィルタ・検索が完了します。この挙動で問題ないかご確認ください。

> [!WARNING]
> **2. Driftのスキーママイグレーション**
> データベースに `images` テーブルを追加するため、スキーマバージョンを `2` から `3` に上げ、`MigrationStrategy` を実装します。既存ユーザーのお気に入りフォルダなどのデータは維持されます。

---

## 提案する変更

### 1. 共通データベース層 (Drift SQLite)
画像をSQLiteで管理し、ソート、フィルタ、検索をDBに委譲します。

#### [NEW] [images_table.dart](file:///d:/work/optrig/lib/infrastructure/database/tables/images_table.dart)
- `images` テーブルを追加。
  - カラム: `entry_id` (Text, Primary Key), `folder_uri` (Text), `name` (Text), `extension` (Text), `modified` (Integer), `size` (Integer), `mime_type` (Text), `width` (Integer), `height` (Integer), `indexed_at` (Integer)
  - フォルダごとの検索・ソートを高速化するため、複合インデックスを設定：
    - `idx_folder_name` (folder_uri, name)
    - `idx_folder_modified` (folder_uri, modified)
    - `idx_folder_size` (folder_uri, size)

#### [MODIFY] [app_database.dart](file:///d:/work/optrig/lib/infrastructure/database/app_database.dart)
- `images` テーブルのインポートおよび `@DriftDatabase` への追加。
- `schemaVersion` を `3` に更新。
- `onUpgrade` で `from < 3` の際に `images` テーブルを作成するマイグレーションロジックを追加。
- 検索/ソート/フィルタに対応した画像クエリメソッドの実装。
  - `Stream<List<ImageEntry>> watchImagesInFolder(...)`
  - `Future<void> upsertImages(List<ImageEntryCompanion> entries)`
  - `Future<void> deleteImagesNotIn(String folderUri, List<String> activeUris)`

---

### 2. Windows 向け実装 (Infrastructure層)
Windowsでの走査の高速化、およびサムネイルデコード時のUIスレッドフリーズを解消します。

#### [MODIFY] [windows_image_repository.dart](file:///d:/work/optrig/lib/infrastructure/storage/windows/windows_image_repository.dart)
- `getImages` で毎回 `Directory.list()` し、`stat` を取ってメモリ上ソートする処理を廃止。
- バックグラウンド（または同期処理）でフォルダ内のファイルを走査し、SQLiteデータベースを更新。
- `getImages` や検索結果 of SQLite データベースからのクエリ（`watch` ストリーム）に切り替え。

#### [MODIFY] [windows_thumbnail_repository.dart](file:///d:/work/optrig/lib/infrastructure/storage/windows/windows_thumbnail_repository.dart)
- メイン Isolate で動作していた `_generateInIsolate` を、バックグラウンド `Isolate.run` を使用した非同期処理に変更。
- Flutter 3.7+ の `Isolate.run` を利用し、`ui.instantiateImageCodec` によるリサイズデコード処理をバックグラウンド Isolate で実行可能かテストし、動作しない場合は `image` パッケージによる非同期デコードや Dart の標準デコーダーを利用。

---

### 3. Android 向け実装 (Infrastructure / Native層)
OOMの防止とデコードキューのキャンセル・優先度制御を適用します。

#### [MODIFY] [SafCommands.kt](file:///d:/work/optrig/android/app/src/main/kotlin/com/pgcodetutor/pictana/SafCommands.kt)
- `loadThumbnailFallback` 処理において、`BitmapFactory.Options` に `inSampleSize` 計算ロジックを導入。
- メモリ空間を節約するため、`inPreferredConfig = Bitmap.Config.RGB_565` を適用してデコード時のメモリを半分にする。

---

### 4. UI / Presentation層
画像の表示部品を最適化し、スクロール時の不要なデコードとGPU負荷を軽減します。

#### [MODIFY] [image_grid_tile.dart](file:///d:/work/optrig/lib/presentation/widgets/image_grid_tile.dart)
- `Image.memory` を `ExtendedImage.memory` に変更。
- メモリ解放を確実にするため `clearMemoryCacheWhenDispose: true` を指定。
- Skeletonizer プレースホルダーのGPU負荷が高いため、シンプルな灰色Box（Container）プレースホルダーに変更し、フェードインアニメーションを100ms以下に短縮。

#### [MODIFY] [search_controller.dart](file:///d:/work/optrig/lib/application/usecases/gallery/search_controller.dart)
- 検索 debounce を `300ms` から `150ms` へ調整してUXを向上。
- 検索入力中（検索の文字入力が行われている最中）はサムネイルのデコードリクエストを一時停止するガードを実装。

---

## 検証計画

### 自動テスト
- Drift データベースのマイグレーションが正常に行われることを検証するユニットテスト。
- WindowsImageRepository の SQLite 経由でのソート/フィルタ/検索のテスト。

### 手動検証 (Windows/Android)
1. **メモリプロファイリング**:
   - `ExtendedImage.memory` 導入後、スクロールし続けた際のヒープメモリ（特に画像メモリ）の推移を監視し、メモリが正しく解放されるか検証。
2. **スクロール性能**:
   - 10,000枚のダミー画像フォルダを用意し、Windows環境およびAndroid環境でスクロールした際のフレームレート（60fps維持）とUIのカクつき（ジャンク）がないか確認。
3. **検索/ソートのレスポンス性**:
   - 検索ワード入力から結果表示までの遅延、ソート順切り替えの速度。
