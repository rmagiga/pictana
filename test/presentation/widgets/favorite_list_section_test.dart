import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pictana/application/providers/repository_providers.dart';
import 'package:pictana/domain/entities/favorite_folder.dart';
import 'package:pictana/domain/repositories/favorite_repository.dart';
import 'package:pictana/presentation/widgets/favorite_list_section.dart';

class FakeFavoriteRepository implements FavoriteRepository {
  final List<FavoriteFolder> _favorites = [];

  @override
  Future<List<FavoriteFolder>> getFavorites() async => _favorites;

  @override
  Future<int> getFavoriteCount() async => _favorites.length;

  @override
  Future<bool> isFavorite(String uri) async => _favorites.any((f) => f.uri == uri);

  @override
  Future<FavoriteFolder> addFavorite({required String uri, required String name}) async {
    final folder = FavoriteFolder(
      id: _favorites.length + 1,
      uri: uri,
      name: name,
      registeredAt: DateTime.now(),
    );
    _favorites.add(folder);
    return folder;
  }

  @override
  Future<void> removeFavorite(String uri) async {
    _favorites.removeWhere((f) => f.uri == uri);
  }

  @override
  Future<FavoriteFolder?> getFavoriteByUri(String uri) async {
    try {
      return _favorites.firstWhere((f) => f.uri == uri);
    } catch (_) {
      return null;
    }
  }
}

void main() {
  late FakeFavoriteRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeFavoriteRepository();
  });

  Widget createTestWidget({required Widget child}) {
    return ProviderScope(
      overrides: [
        favoriteRepositoryProvider.overrideWithValue(fakeRepository),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: child,
        ),
      ),
    );
  }

  group('FavoriteListSection', () {
    testWidgets('お気に入りが空の場合、プレースホルダーが表示されること', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: FavoriteListSection(onFolderTap: (_) {}),
        ),
      );

      // 非同期のデータロードを待つ
      await tester.pump();

      expect(find.text('お気に入りフォルダはありません'), findsOneWidget);
      expect(find.byIcon(Icons.folder_open_rounded), findsOneWidget);
    });

    testWidgets('お気に入りがある場合、リスト項目が表示されること', (tester) async {
      await fakeRepository.addFavorite(uri: 'file:///test/folder1', name: 'フォルダ1');
      await fakeRepository.addFavorite(uri: 'file:///test/folder2', name: 'フォルダ2');

      await tester.pumpWidget(
        createTestWidget(
          child: FavoriteListSection(onFolderTap: (_) {}),
        ),
      );

      await tester.pump();

      expect(find.text('フォルダ1'), findsOneWidget);
      expect(find.text('フォルダ2'), findsOneWidget);
      expect(find.text('file:///test/folder1'), findsOneWidget);
      expect(find.text('file:///test/folder2'), findsOneWidget);
      expect(find.byIcon(Icons.folder_rounded), findsNWidgets(2));
    });

    testWidgets('リスト項目をタップした時、onFolderTap が呼ばれること', (tester) async {
      FavoriteFolder? tappedFolder;
      await fakeRepository.addFavorite(uri: 'file:///test/folder1', name: 'フォルダ1');

      await tester.pumpWidget(
        createTestWidget(
          child: FavoriteListSection(
            onFolderTap: (folder) {
              tappedFolder = folder;
            },
          ),
        ),
      );

      await tester.pump();

      await tester.tap(find.text('フォルダ1'));
      await tester.pump();

      expect(tappedFolder, isNotNull);
      expect(tappedFolder!.name, 'フォルダ1');
    });

    testWidgets('お気に入り解除ボタンをタップした時、お気に入りから削除され、Undoスナックバーが表示されること', (tester) async {
      await fakeRepository.addFavorite(uri: 'file:///test/folder1', name: 'フォルダ1');

      await tester.pumpWidget(
        createTestWidget(
          child: FavoriteListSection(onFolderTap: (_) {}),
        ),
      );

      await tester.pump();

      expect(find.text('フォルダ1'), findsOneWidget);

      // お気に入り解除ボタン（星アイコンのボタン）をタップ
      await tester.tap(find.byTooltip('お気に入り解除'));
      await tester.pump(); // 削除の反映を待つ

      // リストから消えること
      expect(find.text('フォルダ1'), findsNothing);
      expect(find.text('お気に入りフォルダはありません'), findsOneWidget);

      // スナックバーが表示されること
      expect(find.text('「フォルダ1」をお気に入りから削除しました'), findsOneWidget);
      expect(find.text('元に戻す'), findsOneWidget);
    });
  });
}
