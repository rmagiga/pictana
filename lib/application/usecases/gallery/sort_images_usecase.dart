/// SortImagesUseCase (設計書 §18.3)
///
/// ソート状態の保存と読み込みを行うユースケース。
/// ユーザーが選択したソート順を DB に永続化し、次回起動時に復元する。
library;

import '../../../domain/value_objects/sort_option.dart';
import '../../../infrastructure/database/app_database.dart';

class SortImagesUseCase {
  const SortImagesUseCase({required AppDatabase database}) : _db = database;

  final AppDatabase _db;
  static const _kSortFieldKey = 'sort_field';
  static const _kSortDirectionKey = 'sort_direction';

  /// 保存されているソート設定を読み込む
  Future<SortOption> loadSortOption() async {
    final fieldStr = await _db.getSetting(_kSortFieldKey);
    final dirStr = await _db.getSetting(_kSortDirectionKey);

    final field = SortField.values.firstWhere(
      (e) => e.name == fieldStr,
      orElse: () => SortField.name,
    );
    final direction = SortDirection.values.firstWhere(
      (e) => e.name == dirStr,
      orElse: () => SortDirection.ascending,
    );

    return SortOption(field: field, direction: direction);
  }

  /// ソート設定を保存する
  Future<void> saveSortOption(SortOption option) async {
    await _db.setSetting(_kSortFieldKey, option.field.name);
    await _db.setSetting(_kSortDirectionKey, option.direction.name);
  }
}
