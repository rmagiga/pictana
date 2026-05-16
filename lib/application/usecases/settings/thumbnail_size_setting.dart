/// サムネイルサイズ設定 Provider (Req 8)
///
/// AppDatabase の getSetting/setSetting を使用して永続化。
/// キー: 'thumbnail_size'
/// デフォルト値: ThumbnailSizeOption.medium (256px)
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../providers/repository_providers.dart';
import '../../../domain/value_objects/thumbnail_size_option.dart';

part 'thumbnail_size_setting.g.dart';

/// サムネイルサイズ設定を管理する Provider
///
/// 起動時に DB から設定を読み込み、変更時に永続化する。
/// DB 読み込み失敗時はデフォルト値 (medium: 256px) を使用する。
@Riverpod(keepAlive: true)
class ThumbnailSizeSetting extends _$ThumbnailSizeSetting {
  static const _kSettingKey = 'thumbnail_size';

  @override
  ThumbnailSizeOption build() {
    _loadInitial();
    return ThumbnailSizeOption.medium;
  }

  /// DB から保存済みの設定を読み込む
  Future<void> _loadInitial() async {
    try {
      final db = ref.read(appDatabaseProvider);
      final value = await db.getSetting(_kSettingKey);
      if (value != null) {
        final option = _fromString(value);
        if (option != null) {
          state = option;
        }
      }
    } catch (_) {
      // DB 読み込み失敗時はデフォルト値を維持
    }
  }

  /// サムネイルサイズを更新し、DB に永続化する
  Future<void> update(ThumbnailSizeOption size) async {
    state = size;
    try {
      final db = ref.read(appDatabaseProvider);
      await db.setSetting(_kSettingKey, size.name);
    } catch (_) {
      // DB 書き込み失敗時はメモリ上の設定は適用済み
    }
  }

  /// 文字列から ThumbnailSizeOption に変換する
  ThumbnailSizeOption? _fromString(String value) {
    return switch (value) {
      'small' => ThumbnailSizeOption.small,
      'medium' => ThumbnailSizeOption.medium,
      'large' => ThumbnailSizeOption.large,
      _ => null,
    };
  }
}
