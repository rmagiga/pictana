/// UpdateSettingsUseCase (設計書 §18.6)
///
/// テーマや各種設定の永続化を行うユースケース。
/// （現在は Theme のみを管理）
library;

import '../../../infrastructure/database/app_database.dart';

class UpdateSettingsUseCase {
  const UpdateSettingsUseCase({required AppDatabase database}) : _db = database;

  final AppDatabase _db;

  Future<void> execute(String key, String value) async {
    await _db.setSetting(key, value);
  }

  Future<String?> getSetting(String key) async {
    return _db.getSetting(key);
  }
}
