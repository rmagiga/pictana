/// お気に入り状態確認・件数取得の補助 Provider 定義
///
/// UI 層から現在のフォルダのお気に入り状態や登録件数を
/// 簡潔に参照するための Provider を提供する。
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/providers/repository_providers.dart';

part 'favorite_helper_providers.g.dart';

/// 指定フォルダ URI がお気に入り登録済みか判定する Provider
///
/// [uri] に対してリポジトリの isFavorite を呼び出し、
/// 登録済みであれば true を返す。
@riverpod
Future<bool> isFolderFavorite(Ref ref, String uri) async {
  final repository = ref.watch(favoriteRepositoryProvider);
  return repository.isFavorite(uri);
}

/// 現在のお気に入り登録件数を返す Provider
///
/// お気に入りリストの件数表示（例: 「3 / 50」）に使用する。
@riverpod
Future<int> favoriteCount(Ref ref) async {
  final repository = ref.watch(favoriteRepositoryProvider);
  return repository.getFavoriteCount();
}
