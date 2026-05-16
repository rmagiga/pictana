/// FolderCard ウィジェットテスト
///
/// お気に入りフォルダカードの UI 動作を検証する。
/// - タップコールバック呼び出し
/// - ホバー時 elevation 変化（1dp → 3dp）
/// - フォルダ名テキスト表示
/// - フォルダアイコン表示
///
/// Requirements: 2.6, 2.7, 4.2
library;

import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:optrig/domain/entities/favorite_folder.dart';
import 'package:optrig/presentation/providers/folder_thumbnail_provider.dart';
import 'package:optrig/presentation/widgets/folder_card.dart';

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
/// [ProviderScope] で [getFolderThumbnailProvider] をオーバーライドし、
/// サムネイル取得の非同期処理を回避する。
Widget _createTestWidget({
  required FavoriteFolder folder,
  VoidCallback? onTap,
  VoidCallback? onDelete,
}) {
  return ProviderScope(
    overrides: [
      // サムネイル取得を空リスト（画像なし）で即座に返すようオーバーライド
      getFolderThumbnailsProvider(
        folder,
      ).overrideWith((ref) => Future<List<Uint8List?>>.value([])),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 200,
          height: 200,
          child: FolderCard(
            folder: folder,
            onTap: onTap ?? () {},
            onDelete: onDelete ?? () {},
          ),
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// テスト本体
// ---------------------------------------------------------------------------

void main() {
  group('FolderCard - タップコールバック', () {
    testWidgets('タップ時に onTap コールバックが呼ばれる', (tester) async {
      var tapCount = 0;
      final folder = _createTestFolder();

      await tester.pumpWidget(
        _createTestWidget(folder: folder, onTap: () => tapCount++),
      );
      await tester.pumpAndSettle();

      // FolderCard をタップ
      await tester.tap(find.byType(FolderCard));
      await tester.pump();

      // onTap コールバックが1回呼ばれる
      expect(tapCount, 1);
    });
  });

  group('FolderCard - ホバー時 elevation 変化', () {
    testWidgets('マウスホバー時に Card の elevation が 1dp → 3dp に変化する', (tester) async {
      final folder = _createTestFolder();

      await tester.pumpWidget(_createTestWidget(folder: folder));
      await tester.pumpAndSettle();

      // ウィジェット外の座標（画面右下の遠い位置）
      const outsideOffset = Offset(600, 600);

      // マウスポインタをウィジェット外に配置
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: outsideOffset);
      addTearDown(gesture.removePointer);
      await tester.pump();

      // ホバー前: elevation が 1.0
      final cardBefore = tester.widget<Card>(find.byType(Card));
      expect(cardBefore.elevation, 1.0);

      // FolderCard の中心にマウスを移動（ホバー開始）
      await gesture.moveTo(tester.getCenter(find.byType(FolderCard)));
      await tester.pump();

      // ホバー中: elevation が 3.0
      final cardAfter = tester.widget<Card>(find.byType(Card));
      expect(cardAfter.elevation, 3.0);

      // マウスをウィジェット外に移動（ホバー解除）
      await gesture.moveTo(outsideOffset);
      await tester.pump();

      // ホバー解除後: elevation が 1.0 に戻る
      final cardAfterExit = tester.widget<Card>(find.byType(Card));
      expect(cardAfterExit.elevation, 1.0);
    });
  });

  group('FolderCard - フォルダ名表示', () {
    testWidgets('folder.name がテキストとして表示される', (tester) async {
      final folder = _createTestFolder(name: 'マイフォルダ');

      await tester.pumpWidget(_createTestWidget(folder: folder));
      await tester.pumpAndSettle();

      // フォルダ名が表示される
      expect(find.text('マイフォルダ'), findsOneWidget);
    });
  });

  group('FolderCard - フォルダアイコン表示', () {
    testWidgets('Icons.folder アイコンが表示される', (tester) async {
      final folder = _createTestFolder();

      await tester.pumpWidget(_createTestWidget(folder: folder));
      await tester.pumpAndSettle();

      // フォルダアイコンが表示される（カード下部 + ThumbnailOverlay の画像なし時）
      expect(find.byIcon(Icons.folder), findsAtLeastNWidgets(1));
    });
  });
}
