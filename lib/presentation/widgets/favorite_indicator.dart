/// お気に入りインジケーターウィジェット
///
/// ギャラリー画面の AppBar に配置するスターアイコン。
/// 楽観的 UI 更新により、バックエンド処理完了前にアイコン状態を即時切り替える。
/// 連続タップ防止のロック機構は FavoriteToggle Provider 側で管理する。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/favorite_helper_providers.dart';
import '../providers/favorite_toggle_provider.dart';

/// ギャラリー画面 AppBar に配置するお気に入りスターアイコン
///
/// [uri] 現在表示中のフォルダ URI
/// [name] 現在表示中のフォルダ表示名
///
/// 表示ロジック:
/// - FavoriteToggle の optimisticIsFavorite が non-null の場合はその値を使用
/// - null の場合は isFolderFavorite Provider の実際の DB 状態を使用
///
/// アクセシビリティ:
/// - 登録済み → ツールチップ/セマンティクスラベル「お気に入り解除」
/// - 未登録 → ツールチップ/セマンティクスラベル「お気に入り登録」
class FavoriteIndicator extends ConsumerWidget {
  /// 現在表示中のフォルダ URI
  final String uri;

  /// 現在表示中のフォルダ表示名
  final String name;

  const FavoriteIndicator({super.key, required this.uri, required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 楽観的 UI 状態を監視
    final toggleState = ref.watch(favoriteToggleProvider);

    // 実際の DB 状態を監視
    final actualFavoriteAsync = ref.watch(isFolderFavoriteProvider(uri));

    // 表示状態の決定: 楽観的状態は対象フォルダの場合のみ使用
    final optimistic = toggleState.targetUri == uri
        ? toggleState.optimisticIsFavorite
        : null;
    final isFavorite =
        optimistic ??
        actualFavoriteAsync.whenOrNull(data: (value) => value) ??
        false;

    // アクセシビリティラベル
    final label = isFavorite ? 'お気に入り解除' : 'お気に入り登録';

    return IconButton(
      icon: Icon(
        isFavorite ? Icons.star : Icons.star_border,
        color: isFavorite ? Colors.amber : null,
      ),
      tooltip: label,
      onPressed: () {
        ref.read(favoriteToggleProvider.notifier).toggle(uri: uri, name: name);
      },
    );
  }
}
