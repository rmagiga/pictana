/// FavoriteGridSection ウィジェットテスト
///
/// お気に入りフォルダグリッドセクションの UI 動作を検証する。
/// - 空状態表示（プレースホルダー）
/// - ローディング表示（CircularProgressIndicator）
/// - グリッド表示（GridView + FolderCard）
/// - ヘッダー件数表示（「N / 50」形式）
/// - ヘッダータイトル表示（「お気に入り」）
///
/// Requirements: 1.1, 1.2, 6.1, 6.2, 7.1, 7.2
library;

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pictana/domain/entities/favorite_folder.dart';
import 'package:pictana/presentation/providers/favorite_helper_providers.dart';
import 'package:pictana/presentation/providers/favorite_list_provider.dart';
import 'package:pictana/presentation/providers/folder_thumbnail_provider.dart';
import 'package:pictana/presentation/widgets/favorite_grid_section.dart';
import 'package:pictana/presentation/widgets/folder_card.dart';

// ---------------------------------------------------------------------------
// テスト用ヘルパー
// ---------------------------------------------------------------------------

/// テスト用のお気に入りフォルダを作成する
FavoriteFolder _createTestFolder({
  int id = 1,
  String uri = 'file:///test/folder',
  String name = 'テストフォルダ',
  DateTime? registeredAt,
}) {
  return FavoriteFolder(
    id: id,
    uri: uri,
    name: name,
    registeredAt: registeredAt ?? DateTime(2024, 1, 1),
  );
}

/// テスト用ウィジェットツリーを構築する
///
/// [ProviderScope] で各 Provider をオーバーライドし、
/// 非同期処理を回避してテストを安定させる。
/// [screenWidth] で MediaQuery のサイズを制御する。
Widget _createTestWidget({
  required List<dynamic> overrides,
  double screenWidth = 400,
}) {
  return ProviderScope(
    overrides: overrides.cast(),
    child: MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: Size(screenWidth, 800)),
        child: Scaffold(
          body: SingleChildScrollView(
            child: FavoriteGridSection(onFolderTap: (_) {}),
          ),
        ),
      ),
    ),
  );
}

/// favoriteListProvider を空リストでオーバーライドする
///
/// FavoriteList は AsyncNotifierProvider なので、
/// notifier ごとオーバーライドする。
class _EmptyFavoriteList extends FavoriteList {
  @override
  Future<List<FavoriteFolder>> build() async => [];
}

/// favoriteListProvider をフォルダリストでオーバーライドする
class _DataFavoriteList extends FavoriteList {
  _DataFavoriteList(this._folders);
  final List<FavoriteFolder> _folders;

  @override
  Future<List<FavoriteFolder>> build() async => _folders;
}

/// favoriteListProvider をローディング状態に保つ
///
/// Completer を使って永遠に完了しない Future を返すことで
/// ローディング状態を維持する。
class _LoadingFavoriteList extends FavoriteList {
  @override
  Future<List<FavoriteFolder>> build() {
    // Completer を使って永遠に完了しない Future を返す
    // AsyncNotifierProvider は build が完了するまで AsyncLoading 状態
    return Completer<List<FavoriteFolder>>().future;
  }
}

// ---------------------------------------------------------------------------
// テスト本体
// ---------------------------------------------------------------------------

void main() {
  group('FavoriteGridSection - 空状態表示', () {
    testWidgets('お気に入りが0件の場合、プレースホルダーが表示される', (tester) async {
      await tester.pumpWidget(
        _createTestWidget(
          overrides: [
            favoriteListProvider.overrideWith(() => _EmptyFavoriteList()),
            favoriteCountProvider.overrideWith((ref) => Future.value(0)),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // 「お気に入りフォルダはありません」テキストが表示される
      expect(find.text('お気に入りフォルダはありません'), findsOneWidget);

      // フォルダアイコン（folder_open）が表示される
      expect(find.byIcon(Icons.folder_open), findsOneWidget);

      // GridView は表示されない
      expect(find.byType(GridView), findsNothing);
    });
  });

  group('FavoriteGridSection - ローディング表示', () {
    testWidgets('ローディング中は CircularProgressIndicator が表示される', (tester) async {
      await tester.pumpWidget(
        _createTestWidget(
          overrides: [
            favoriteListProvider.overrideWith(() => _LoadingFavoriteList()),
            favoriteCountProvider.overrideWith((ref) => Future.value(0)),
          ],
        ),
      );
      // pumpWidget 後に1フレーム進めてウィジェットツリーを構築
      // _LoadingFavoriteList の build は完了しないためローディング状態が維持される
      await tester.pump(const Duration(milliseconds: 100));

      // CircularProgressIndicator が表示される
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // プレースホルダーは表示されない
      expect(find.text('お気に入りフォルダはありません'), findsNothing);

      // GridView は表示されない
      expect(find.byType(GridView), findsNothing);
    });
  });

  group('FavoriteGridSection - グリッド表示', () {
    testWidgets('フォルダリストがある場合、GridView と FolderCard が表示される', (tester) async {
      final folders = [
        _createTestFolder(id: 1, uri: 'file:///a', name: 'フォルダA'),
        _createTestFolder(id: 2, uri: 'file:///b', name: 'フォルダB'),
      ];

      await tester.pumpWidget(
        _createTestWidget(
          overrides: [
            favoriteListProvider.overrideWith(() => _DataFavoriteList(folders)),
            favoriteCountProvider.overrideWith((ref) => Future.value(2)),
            // サムネイル取得を空リストで即座に返す
            getFolderThumbnailsProvider(
              folders[0],
            ).overrideWith((ref) => Future<List<Uint8List?>>.value([])),
            getFolderThumbnailsProvider(
              folders[1],
            ).overrideWith((ref) => Future<List<Uint8List?>>.value([])),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // GridView が表示される
      expect(find.byType(GridView), findsOneWidget);

      // FolderCard が2つ表示される
      expect(find.byType(FolderCard), findsNWidgets(2));

      // フォルダ名が表示される
      expect(find.text('フォルダA'), findsOneWidget);
      expect(find.text('フォルダB'), findsOneWidget);
    });
  });

  group('FavoriteGridSection - ヘッダー件数表示', () {
    testWidgets('件数が「N / 50」形式で表示される', (tester) async {
      await tester.pumpWidget(
        _createTestWidget(
          overrides: [
            favoriteListProvider.overrideWith(() => _EmptyFavoriteList()),
            favoriteCountProvider.overrideWith((ref) => Future.value(3)),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // 「3 / 50」形式で件数が表示される
      expect(find.text('3 / 50'), findsOneWidget);
    });
  });

  group('FavoriteGridSection - ヘッダータイトル表示', () {
    testWidgets('「お気に入り」タイトルが表示される', (tester) async {
      await tester.pumpWidget(
        _createTestWidget(
          overrides: [
            favoriteListProvider.overrideWith(() => _EmptyFavoriteList()),
            favoriteCountProvider.overrideWith((ref) => Future.value(0)),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // 「お気に入り」タイトルが表示される
      expect(find.text('お気に入り'), findsOneWidget);
    });
  });
}
