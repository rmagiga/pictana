/// CacheSizeLimitSetting Provider (Req 9.1, 9.2, 9.4)
///
/// キャッシュサイズ上限設定を管理する。
/// AppDatabase の getSetting/setSetting を使用して永続化。
/// 上限変更時に 30 秒以内にエビクション実行をトリガーする。
/// キー: 'cache_size_limit'
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/value_objects/cache_size_limit.dart';
import '../../providers/repository_providers.dart';

part 'cache_size_limit_setting.g.dart';

/// キャッシュサイズ上限設定を管理する Provider
///
/// デフォルト値は [CacheSizeLimit.mb500]（500MB）。
/// 設定変更時に DB へ永続化し、ThumbnailRepository に上限を通知して
/// 30 秒以内にエビクションを実行する。
@Riverpod(keepAlive: true)
class CacheSizeLimitSetting extends _$CacheSizeLimitSetting {
  static const _kKey = 'cache_size_limit';

  @override
  CacheSizeLimit build() {
    _loadInitial();
    return CacheSizeLimit.mb500;
  }

  /// DB から保存済みの設定値を読み込む
  Future<void> _loadInitial() async {
    try {
      final db = ref.read(appDatabaseProvider);
      final value = await db.getSetting(_kKey);
      if (value != null) {
        final limit = CacheSizeLimit.values.where((e) => e.name == value);
        if (limit.isNotEmpty) {
          state = limit.first;
          // 起動時にも上限を ThumbnailRepository に反映
          await _applyCacheSizeLimit(limit.first);
        }
      }
    } catch (_) {
      // DB 読み込み失敗時はデフォルト値を維持
    }
  }

  /// キャッシュサイズ上限を更新し、DB に永続化する
  ///
  /// 上限変更後、ThumbnailRepository に新しい上限を設定し
  /// エビクションをトリガーする（30 秒以内に実行）。
  Future<void> update(CacheSizeLimit limit) async {
    state = limit;
    try {
      final db = ref.read(appDatabaseProvider);
      await db.setSetting(_kKey, limit.name);
    } catch (_) {
      // DB 書き込み失敗時はメモリ上の設定は適用済み
    }

    // 上限変更時にエビクションをトリガー（30 秒以内に実行）
    await _applyCacheSizeLimit(limit);
  }

  /// ThumbnailRepository にキャッシュ上限を設定しエビクションを実行する
  Future<void> _applyCacheSizeLimit(CacheSizeLimit limit) async {
    try {
      final repo = ref.read(thumbnailRepositoryProvider);
      await repo.setCacheSizeLimit(limit.bytes);
    } catch (_) {
      // エビクション失敗時はスキップして続行 (Req 9.6)
    }
  }
}
