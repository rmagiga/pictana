/// SwipeDirectionSetting Provider (Req 7.1, 7.3)
///
/// Android でのスワイプ方向設定を管理する。
/// AppDatabase の getSetting/setSetting を使用して永続化。
/// キー: 'swipe_direction'
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/value_objects/swipe_direction.dart';
import '../../providers/repository_providers.dart';

part 'swipe_direction_setting.g.dart';

/// スワイプ方向設定を管理する Provider
///
/// デフォルト値は [SwipeDirection.horizontal]（左右スワイプ）。
/// 設定変更時に DB へ永続化し、次回起動時に復元する。
@Riverpod(keepAlive: true)
class SwipeDirectionSetting extends _$SwipeDirectionSetting {
  static const _kKey = 'swipe_direction';

  @override
  SwipeDirection build() {
    _loadInitial();
    return SwipeDirection.horizontal;
  }

  /// DB から保存済みの設定値を読み込む
  Future<void> _loadInitial() async {
    try {
      final db = ref.read(appDatabaseProvider);
      final value = await db.getSetting(_kKey);
      if (value != null) {
        final direction = SwipeDirection.values.where(
          (e) => e.name == value,
        );
        if (direction.isNotEmpty) {
          state = direction.first;
        }
      }
    } catch (_) {
      // DB 読み込み失敗時はデフォルト値を維持
    }
  }

  /// スワイプ方向を更新し、DB に永続化する
  Future<void> update(SwipeDirection direction) async {
    state = direction;
    try {
      final db = ref.read(appDatabaseProvider);
      await db.setSetting(_kKey, direction.name);
    } catch (_) {
      // DB 書き込み失敗時はメモリ上の設定は適用済み
    }
  }
}
