# 改善優先順位ロードマップ（高効果順・低リスク順）

> **凡例**
> - 効果: 🔴超大 / 🟠大 / 🟡中 / ⚪低
> - リスク: 🟢低（1ファイル以内・既存設計変更なし） / 🟡中（複数ファイル・設計の一部変更） / 🔴高（アーキテクチャ変更・大規模）

---

## Tier S — 最優先（絶対にやる）

| # | 改善項目 | 効果 | リスク | 変更箇所 |
|---|---|---|---|---|
| **1** | **フォールバックサムネイルに `inSampleSize` + `RGB_565` 追加** | 🔴超大 (OOM防止) | 🟢低 | [SafCommands.kt](file:///d:/work/optrig/android/app/src/main/kotlin/com/pgcodetutor/pictana/SafCommands.kt) のみ1箇所 |
| **2** | **`Image.memory` → `ExtendedImage.memory` へ変更** | 🔴超大 (メモリ解放) | 🟢低 | [image_grid_tile.dart](file:///d:/work/optrig/lib/presentation/widgets/image_grid_tile.dart) のみ1箇所 |
| **3** | **SQLite 画像メタデータテーブル新設 + 検索/ソート/フィルタ委譲** | 🔴超大 (根本改善) | 🔴高 | DB定義・Repository・UseCase・Provider 全層 |
| **4** | **Viewport Scheduler + Cancelable Decode Queue** | 🔴超大 (60fps保証) | 🔴高 | Kotlin新規クラス + Dart Provider刷新 |

---

## Tier A — 高優先（Tier S と並行または直後）

| # | 改善項目 | 効果 | リスク | 変更箇所 |
|---|---|---|---|---|
| **5** | **検索中のサムネイルリクエスト停止** | 🟠大 (競合排除) | 🟢低 | [search_controller.dart](file:///d:/work/optrig/lib/application/usecases/gallery/search_controller.dart) + [image_grid_tile.dart](file:///d:/work/optrig/lib/presentation/widgets/image_grid_tile.dart) |
| **6** | **`clearMemoryCacheWhenDispose: true` を ExtendedImage に設定** | 🟠大 (メモリ解放) | 🟢低 | #2 の変更と同時に対応（追加コスト0） |
| **7** | **Disk thumbnail cache の活用強化** | 🟠大 (2回目以降高速) | 🟡中 | [android_thumbnail_repository.dart](file:///d:/work/optrig/lib/infrastructure/storage/android/android_thumbnail_repository.dart) + `ThumbnailCache` テーブル |
| **8** | **visible-only IO（USB OTG）** | 🟠大 (USB遅延対策) | 🟡中 | #4 の Viewport Scheduler 実装と同時対応 |
| **9** | **スクロール速度に応じたデコード優先度切り替え（VISIBLE/NEAR/FAR）** | 🟠大 (高速スクロール) | 🟡中 | #4 の Viewport Scheduler 内で実装 |

---

## Tier B — 中優先（Tier A 完了後）

| # | 改善項目 | 効果 | リスク | 変更箇所 |
|---|---|---|---|---|
| **10** | **検索 debounce を 300ms → 150ms に調整** | 🟡中 (UX改善) | 🟢低 | [search_controller.dart](file:///d:/work/optrig/lib/application/usecases/gallery/search_controller.dart) 1行 |
| **11** | **Skeleton UI を Skeletonizer → 単純灰色 Box に変更** | 🟡中 (GPU軽減) | 🟢低 | [image_grid_tile.dart](file:///d:/work/optrig/lib/presentation/widgets/image_grid_tile.dart) の骨格部分のみ |
| **12** | **Splash での folder metadata 先読み最適化** | 🟡中 (起動高速化) | 🟢低 | [splash_screen.dart](file:///d:/work/optrig/lib/presentation/screens/splash_screen.dart) のみ |
| **13** | **スクロール位置復元（offset + anchor + sort + filter 保持）** | 🟡中 (UX改善) | 🟡中 | GalleryState 新規 + ScrollController 連携 |
| **14** | **Folder Browser: expand 時のみクエリ発行** | 🟡中 (SAF無駄削減) | 🟡中 | [folder_browser_screen.dart](file:///d:/work/optrig/lib/presentation/screens/folder_browser_screen.dart)（まだ最小実装）|

---

## Tier C — 低優先（将来検討）

| # | 改善項目 | 効果 | リスク | 変更箇所 |
|---|---|---|---|---|
| **15** | **URI/Path転送 → integer ID ベース化** | 🟡中 (転送最適化) | 🔴高 | #3（SQLite委譲）完了後に設計 |
| **16** | **MethodChannel → Pigeon 移行** | 🟡中 (型安全性) | 🔴高 | 全チャネル11メソッド書き換え |
| **17** | **Grid 列数の離散段階化** | ⚪低 | 🟢低 | [gallery_grid_screen.dart](file:///d:/work/optrig/lib/presentation/screens/gallery_grid_screen.dart) 1箇所 |
| **18** | **Windows native plugin（C++/Rust）** | 🟡中 | 🔴高 | 新規プラグイン作成（計測で必要性確認後） |
| **19** | **FlatBuffers / DirectByteBuffer** | ⚪低 (小サイズでは無効) | 🔴高 | #16（Pigeon移行）後に検討 |

---

## 実装フェーズ別ロードマップ

```text
Phase 0 ── 今すぐ・数時間
│
├─ #1  inSampleSize + RGB_565 追加
│      [SafCommands.kt] loadThumbnailFallback のみ
│
└─ #2 + #6  Image.memory → ExtendedImage.memory
           [image_grid_tile.dart] _buildContent のみ


Phase 1 ── 数日・中規模
│
├─ #3  SQLite 画像メタデータ + 検索/ソート委譲
│      [新規] app_database.dart にテーブル追加
│      [修正] android_image_repository.dart 検索ロジック移動
│      [修正] windows_image_repository.dart 検索ロジック移動
│      [修正] gallery_providers.dart filteredImages → DB委譲
│      [削除] search_filter.dart の Flutter側フィルタ
│
├─ #5  検索中サムネイル停止
│      [修正] search_controller.dart に isSearching フラグ
│      [修正] image_grid_tile.dart にガード追加
│
├─ #7  Disk thumbnail cache 強化
│      [修正] android_thumbnail_repository.dart キャッシュヒット率改善
│
└─ #10 debounce 150ms 調整
       [修正] search_controller.dart L43 の Duration 変更


Phase 2 ── 1〜2週間・大規模
│
├─ #4  Viewport Scheduler + Cancelable Decode Queue
│      [新規] ThumbnailDecodeQueue.kt (Kotlin)
│      [追加] cancelThumbnail メソッド → SafMethodHandler.kt
│      [新規] viewport_scheduler_provider.dart (Dart)
│      [修正] image_grid_tile.dart → スケジューラ経由に変更
│
├─ #8  visible-only IO（#4 と同時）
│      Viewport Scheduler 内で実装
│
└─ #9  VISIBLE/NEAR/FAR 優先度制御（#4 と同時）
       ThumbnailDecodeQueue.kt に PriorityQueue 追加


Phase 3 ── 余裕があれば
│
├─ #11 Skeleton → 灰色 Box
├─ #12 Splash 先読み最適化
├─ #13 スクロール位置復元
└─ #14 Folder Browser 遅延クエリ


Phase 4 ── 将来
│
├─ #15 ID ベース転送（#3完了後）
├─ #16 Pigeon 移行（チャネル増加時）
└─ #18 Windows native plugin（計測で必要性確認後）
```

---

## 判断根拠

### #1 を最上位にした理由
- [SafCommands.kt L409](file:///d:/work/optrig/android/app/src/main/kotlin/com/pgcodetutor/pictana/SafCommands.kt#L409) での **原寸デコードは OOM 直撃リスク**（10,000枚中に1枚 `loadThumbnail` 失敗があれば即発動）
- `SafCommands.kt` 1ファイルのみ変更で完了、リグレッションリスクほぼ0

### #2/#6 を Phase 0 にした理由
- `extended_image` は `pubspec.yaml` に既存依存済み
- [image_grid_tile.dart L161](file:///d:/work/optrig/lib/presentation/widgets/image_grid_tile.dart#L161) の `Image.memory` は設計書・高速化案双方で「NG」明記済み
- 変更箇所は `_buildContent()` の1メソッドのみ

### #3 を Phase 1 にした理由（Phase 0 でない理由）
- 高効果だが **DB スキーマ変更 → マイグレーション → Repository → UseCase → Provider** と全層に影響
- Phase 0 で簡単な修正の効果を先に確認してから着手するのが安全

### #4 を Phase 2 にした理由
- Kotlin 側に新規キューイングシステムが必要
- Dart 側の Provider 設計も大幅刷新が必要
- #3（SQLite 委譲）完了後に画像ID管理が整理されてから実装する方が設計がシンプル

### #16（Pigeon）を Tier C にした理由
- 現行11メソッドは [SafMethodHandler.kt](file:///d:/work/optrig/android/app/src/main/kotlin/com/pgcodetutor/pictana/SafMethodHandler.kt) 198行で十分管理可能
- エラーハンドリング・型変換は既に適切に構造化されている
- 移行コスト ＞ 得られる利益（現規模では）
