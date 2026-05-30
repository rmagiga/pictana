# 1. AI指示
- 本ドキュメントはAIエージェントの動作を規定する最上位の動作指針である
- 全てのコード生成および変更において、本ルールの遵守を最優先すること

# 2. プロジェクト概要
- アプリ名: **Pictana (ピク棚)**
- パッケージ名: `pictana`
- ローカルストレージ上の画像を閲覧・管理するためのFlutterデスクトップ/モバイルアプリ
- 外部ストレージ(USB OTG含む)対応、大量画像(10,000枚規模)への高速なサムネイル表示を目的とする
- 技術スタック: Flutter, Dart, Riverpod, Drift, SQLite, Extended Image
- 対応画像形式: JPEG, PNG, WebP, GIF (一覧では静止、詳細ビューアで自動再生), HEIC, HEIF, AVIF

# 3. アーキテクチャ
- DDD寄り Clean Architecture (Presentation -> Application -> Domain -> Infrastructure)
- SOLID原則の遵守（WidgetはUIのみ、UseCaseは業務ロジックのみ、Repositoryはデータアクセスのみ等）
- Platform差異(Android SAF, Windows FileSystem)はInfrastructure層で吸収し、Domain/Application層へ漏らさない
- StorageRepository等のインターフェースを用いて依存関係逆転の原則(DIP)を適用する

# 4. 開発コマンド
本プロジェクトではタスクランナーとして [Melos](https://melos.invertase.dev/) を導入しています。
- `melos run pub:get` または `flutter pub get`: 依存関係のインストール
- `melos run build_runner` または `dart run build_runner build --delete-conflicting-outputs`: コード自動生成（Freezed, Riverpod, Drift等）
- `melos run watch` または `dart run build_runner watch --delete-conflicting-outputs`: コード自動生成（変更監視ウォッチ）
- `melos run analyze` または `flutter analyze`: 静的解析（Linter）の実行
- `melos run fix` または `dart fix --apply`: 静的解析警告の自動修正
- `melos run test` または `flutter test`: ユニットテストの実行
- `flutter run -d windows`: Windows でのデバッグ起動
- `flutter run -d <device_id>`: Android でのデバッグ起動
- `melos run build:windows` または `flutter build windows`: Windows 向けリリースビルド
- `melos run build:apk` または `flutter build apk --release`: Android 向けリリース APK ビルド

# 5. プロジェクト構成
- `lib/core/`: 共通の定数、エラー、ユーティリティ
- `lib/domain/`: Entities (EntryId, ImageEntry等), Repository Interfaces, Value Objects
- `lib/application/`: UseCases, DTO, Providers
- `lib/infrastructure/`: プラットフォーム固有のストレージ処理 (android/, windows/), データベース (drift), キャッシュ実装
- `lib/presentation/`: Screens, Widgets, UI Providers, Themes
- `lib/router/`: GoRouter ルート定義

# 6. コーディング基準
- Provider乱立を禁止し、BuildContextへの依存を最小化する
  - Riverpod は `riverpod_generator` によるコード生成を使用する
  - シングルトン的に保持すべき Provider（Repository DI 等）には `@Riverpod(keepAlive: true)` を使用し、画面固有や一時的なデータは通常の自動破棄 `@riverpod` を使用する
- Androidの content:// URI と Windowsのファイルパスは、Domainでは `EntryId` として抽象化する
- Infrastructure層内部でのI/O待機中にUIスレッドをブロックしない（非同期/Isolate活用）

# 7. テストガイドライン
- 新規機能やUseCase実装時にはユニットテストを同梱する
- gladosを用いたProperty-based testingを活用する
- OS非依存のロジックは標準のflutter_testで検証する

# 8. 依存ライブラリポリシー
- 状態管理は `flutter_riverpod`, `riverpod_annotation` を使用する
- 画像表示は `extended_image` を主軸とし、巨大Bitmap生成 (`Image.memory`) は禁止する
- Immutableモデル生成には `freezed` を使用する

# 9. セキュリティルール
- AndroidのSAF (Storage Access Framework) 権限は適切に取得・永続化する
- ユーザーのプライベートなファイルパスをログに出力する際は個人情報をマスキングする

# 10. パフォーマンスガイドライン
- Isolateを用いた非同期デコード、Virtual Scroll、Viewport最適化を徹底する
- Android SAFにおける `DocumentFile.listFiles()` の大量呼び出しを避け、`ContentResolver.query()` を用いる
- 画像一覧表示は10,000枚規模でも60fpsを維持する遅延ロードを実装する

# 11. エラーハンドリングガイドライン
- USB切断などのOS固有の例外（FileSystemExceptionなど）はUIへ直接渡さず、必ずDomain例外へ変換する
  - `SecurityException` -> `PermissionDenied`
  - `FileSystemException` / `FileNotFoundException` / `IllegalArgumentException` (無効な URI) -> `StorageDisconnected`
- 切断時は画面遷移ではなくインライン通知を表示し、バックグラウンドでリトライを行う
- キャッシュ済みサムネイルは切断中も表示を継続させる

# 12. AIエージェント指示
- 1つのPull Request/タスクは「1画面」「1リポジトリ」「1機能」といった小さな単位で実装・提案する
- 既存のWidget責務を最小化し、ビジネスロジックは必ずUseCaseへ分離する
- 同期I/O (例: dart:ioの同期メソッド) の使用は厳禁とする

# 13. コード生成ガイドライン
- 生成するコードはFlutterのLintルール（flutter_lints）に準拠すること
- riverpod_generator、freezed、json_serializableを用いた型安全なコードを生成する
- Repositoryのメソッドは必ず `Future` または `Stream` を返却すること

# 14. ドキュメント/制限事項
- 既存のドキュメント (docs配下) のアーキテクチャ設計に反する実装を行わない
- Androidネイティブ側はKotlin、Windowsの特定処理はdart:ioで実装することを許容するが、カプセル化を維持する
- すでに実装が完了している機能（見開き表示、レジューム機能、EXIF先行インデックス化など）を修正・拡張する際は、既存のユースケース（`GetViewerPagesUseCase`, `ResumePositionUseCase`, `IndexExifUseCase`）やデータベーススキーマとの整合性を損なわないこと

# 15. 最終ルール
- 矛盾が生じた場合は、本ドキュメント（AGENTS.md）および `docs/` 配下の設計ドキュメントを最優先する
- 次に既存のコードベースの慣習に従い、常にプロジェクト全体のパフォーマンスと整合性を維持すること
- Androidネイティブコードを実装する際は、必ずAndroidの公式コード規約（Kotlin）に従い、MethodChannelの例外処理（result.error）を厳格に行うこと

