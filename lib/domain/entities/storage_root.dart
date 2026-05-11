/// StorageRoot Entity (設計書 §9.1)
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import 'entry_id.dart';

part 'storage_root.freezed.dart';
part 'storage_root.g.dart';

/// ストレージの種類
enum StorageType {
  /// 内部ストレージ / ローカルドライブ
  internal,

  /// USB OTG / 外部USB
  usb,

  /// SDカード（将来対応）
  sdCard,
}

extension StorageTypeX on StorageType {
  String get displayName => switch (this) {
        StorageType.internal => '内部ストレージ',
        StorageType.usb => 'USB ストレージ',
        StorageType.sdCard => 'SD カード',
      };
}

/// ストレージルート Entity
@freezed
abstract class StorageRoot with _$StorageRoot {
  const StorageRoot._();

  const factory StorageRoot({
    /// プラットフォーム固有識別子
    required EntryId id,

    /// 表示名（例: "DCIM", "Pictures", "D:\"）
    required String name,

    /// ストレージ種別
    required StorageType type,

    /// アクセス用 URI 文字列
    required String uri,

    /// 接続状態
    @Default(true) bool isConnected,
  }) = _StorageRoot;

  factory StorageRoot.fromJson(Map<String, dynamic> json) =>
      _$StorageRootFromJson(json);
}
