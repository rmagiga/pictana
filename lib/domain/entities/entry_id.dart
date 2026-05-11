/// EntryId Value Object (設計書 §9.1)
///
/// Platform固有識別子を抽象化する Value Object。
/// - Android: content:// URI
/// - Windows: file path
///
/// Domain/Application層では EntryId を使用し、
/// Infrastructure層のみで生の値へ変換する。
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'entry_id.freezed.dart';
part 'entry_id.g.dart';

/// プラットフォーム種別
enum PlatformType {
  android,
  windows,
  unknown,
}

/// プラットフォーム固有識別子を抽象化する Value Object
@freezed
abstract class EntryId with _$EntryId {
  const EntryId._();

  const factory EntryId({
    /// 生の識別子文字列
    /// Android: "content://media/external/images/media/1234"
    /// Windows: "C:\\Users\\user\\Pictures\\photo.jpg"
    required String rawValue,

    /// プラットフォーム種別
    required PlatformType platformType,
  }) = _EntryId;

  factory EntryId.fromJson(Map<String, dynamic> json) =>
      _$EntryIdFromJson(json);

  /// Android 用ファクトリ
  factory EntryId.android(String contentUri) => EntryId(
        rawValue: contentUri,
        platformType: PlatformType.android,
      );

  /// Windows 用ファクトリ
  factory EntryId.windows(String filePath) => EntryId(
        rawValue: filePath,
        platformType: PlatformType.windows,
      );
}
