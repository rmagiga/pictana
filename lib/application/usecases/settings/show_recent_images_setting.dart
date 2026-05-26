/// 最近見た画像の表示設定 Provider
///
/// AppDatabase の getSetting/setSetting を使用して永続化。
/// キー: 'show_recent_images'
/// デフォルト値: Windows では true、Android では false
library;

import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../providers/repository_providers.dart';

part 'show_recent_images_setting.g.dart';

/// 最近見た画像の表示設定を管理する Provider
@Riverpod(keepAlive: true)
class ShowRecentImagesSetting extends _$ShowRecentImagesSetting {
  static const _kSettingKey = 'show_recent_images';

  @override
  bool build() {
    _loadInitial();
    // デフォルト値：Windowsはtrue、それ以外（Androidなど）はfalse
    return Platform.isWindows;
  }

  /// DB から保存済みの設定を読み込む
  Future<void> _loadInitial() async {
    try {
      final db = ref.read(appDatabaseProvider);
      final value = await db.getSetting(_kSettingKey);
      if (value != null) {
        state = value == 'true';
      }
    } catch (_) {
      // 読み込み失敗時はデフォルト値を維持
    }
  }

  /// 設定を更新し、DB に永続化する
  Future<void> update(bool show) async {
    state = show;
    try {
      final db = ref.read(appDatabaseProvider);
      await db.setSetting(_kSettingKey, show ? 'true' : 'false');
    } catch (_) {
      // 書き込み失敗時はメモリ上の設定は適用済み
    }
  }
}
