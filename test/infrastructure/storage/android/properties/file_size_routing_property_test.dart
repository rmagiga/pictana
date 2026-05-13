/// Property 12: ファイルサイズルーティング
///
/// 任意の画像ファイルサイズに対して、システムが以下のルーティングを行うことを検証する:
/// - size > 100MB → OutOfMemoryException（エラー）
/// - 10MB < size <= 100MB → 一時ファイル転送（getImageBytesViaFile）
/// - size <= 10MB → 直接バイト配列転送（getImageBytes via MethodChannel）
///
/// **Validates: Requirements 6.3, 6.6**
@Tags(['android-saf', 'property-test'])
library;

import 'package:glados/glados.dart';

/// 転送方式を表す列挙型
enum TransferMethod {
  /// 直接バイト配列転送（MethodChannel 経由、<= 10MB）
  directByteArray,

  /// 一時ファイル転送（> 10MB, <= 100MB）
  temporaryFile,

  /// メモリ不足エラー（> 100MB）
  outOfMemoryError,
}

/// ファイルサイズの閾値定数
const int tenMb = 10 * 1024 * 1024; // 10MB
const int hundredMb = 100 * 1024 * 1024; // 100MB

/// ファイルサイズに基づいて転送方式を決定する純粋関数。
///
/// SafCommands.getImageBytes / getImageBytesViaFile のルーティングロジックと同等。
/// - [fileSize] > 100MB → [TransferMethod.outOfMemoryError]
/// - [fileSize] > 10MB かつ <= 100MB → [TransferMethod.temporaryFile]
/// - [fileSize] <= 10MB → [TransferMethod.directByteArray]
TransferMethod determineTransferMethod(int fileSize) {
  if (fileSize > hundredMb) {
    return TransferMethod.outOfMemoryError;
  }
  if (fileSize > tenMb) {
    return TransferMethod.temporaryFile;
  }
  return TransferMethod.directByteArray;
}

/// ファイルサイズジェネレータ拡張
extension FileSizeGenerators on Any {
  /// 0 〜 200MB+ の範囲でランダムなファイルサイズを生成するジェネレータ
  /// 全範囲をカバーするため、0 〜 250MB の範囲で生成する
  /// intInRange は [min, max) （min 含む、max 含まない）
  Generator<int> get fileSize => any.intInRange(0, 250 * 1024 * 1024 + 1);

  /// 0 〜 10MB のファイルサイズを生成するジェネレータ（直接転送範囲）
  Generator<int> get smallFileSize => any.intInRange(0, tenMb + 1);

  /// 10MB + 1 〜 100MB のファイルサイズを生成するジェネレータ（一時ファイル転送範囲）
  Generator<int> get mediumFileSize => any.intInRange(tenMb + 1, hundredMb + 1);

  /// 100MB + 1 〜 250MB のファイルサイズを生成するジェネレータ（エラー範囲）
  Generator<int> get largeFileSize =>
      any.intInRange(hundredMb + 1, 250 * 1024 * 1024 + 1);
}

void main() {
  group('Feature: android-saf, Property 12: ファイルサイズルーティング', () {
    Glados(any.fileSize).test('任意のファイルサイズに対して、正しい転送方式が選択される', (fileSize) {
      final method = determineTransferMethod(fileSize);

      if (fileSize > hundredMb) {
        expect(
          method,
          equals(TransferMethod.outOfMemoryError),
          reason: 'ファイルサイズ $fileSize (> 100MB) は OutOfMemoryError になるべき',
        );
      } else if (fileSize > tenMb) {
        expect(
          method,
          equals(TransferMethod.temporaryFile),
          reason: 'ファイルサイズ $fileSize (> 10MB, <= 100MB) は一時ファイル転送になるべき',
        );
      } else {
        expect(
          method,
          equals(TransferMethod.directByteArray),
          reason: 'ファイルサイズ $fileSize (<= 10MB) は直接バイト配列転送になるべき',
        );
      }
    });

    Glados(any.smallFileSize).test('10MB 以下のファイルは直接バイト配列転送が選択される', (fileSize) {
      final method = determineTransferMethod(fileSize);

      expect(
        method,
        equals(TransferMethod.directByteArray),
        reason: 'ファイルサイズ $fileSize (<= 10MB) は直接バイト配列転送になるべき',
      );
    });

    Glados(any.mediumFileSize).test('10MB 超 100MB 以下のファイルは一時ファイル転送が選択される', (
      fileSize,
    ) {
      final method = determineTransferMethod(fileSize);

      expect(
        method,
        equals(TransferMethod.temporaryFile),
        reason: 'ファイルサイズ $fileSize (> 10MB, <= 100MB) は一時ファイル転送になるべき',
      );
    });

    Glados(any.largeFileSize).test('100MB 超のファイルは OutOfMemoryError が発生する', (
      fileSize,
    ) {
      final method = determineTransferMethod(fileSize);

      expect(
        method,
        equals(TransferMethod.outOfMemoryError),
        reason: 'ファイルサイズ $fileSize (> 100MB) は OutOfMemoryError になるべき',
      );
    });

    // 境界値テスト: ちょうど 10MB
    Glados(any.always(tenMb)).test('境界値: ちょうど 10MB は直接バイト配列転送が選択される', (
      fileSize,
    ) {
      final method = determineTransferMethod(fileSize);

      expect(
        method,
        equals(TransferMethod.directByteArray),
        reason: 'ちょうど 10MB は直接バイト配列転送になるべき（<= 10MB）',
      );
    });

    // 境界値テスト: 10MB + 1
    Glados(any.always(tenMb + 1)).test('境界値: 10MB + 1 バイトは一時ファイル転送が選択される', (
      fileSize,
    ) {
      final method = determineTransferMethod(fileSize);

      expect(
        method,
        equals(TransferMethod.temporaryFile),
        reason: '10MB + 1 バイトは一時ファイル転送になるべき（> 10MB）',
      );
    });

    // 境界値テスト: ちょうど 100MB
    Glados(any.always(hundredMb)).test('境界値: ちょうど 100MB は一時ファイル転送が選択される', (
      fileSize,
    ) {
      final method = determineTransferMethod(fileSize);

      expect(
        method,
        equals(TransferMethod.temporaryFile),
        reason: 'ちょうど 100MB は一時ファイル転送になるべき（<= 100MB）',
      );
    });

    // 境界値テスト: 100MB + 1
    Glados(any.always(hundredMb + 1)).test(
      '境界値: 100MB + 1 バイトは OutOfMemoryError が発生する',
      (fileSize) {
        final method = determineTransferMethod(fileSize);

        expect(
          method,
          equals(TransferMethod.outOfMemoryError),
          reason: '100MB + 1 バイトは OutOfMemoryError になるべき（> 100MB）',
        );
      },
    );

    // 境界値テスト: 0 バイト
    Glados(any.always(0)).test('境界値: 0 バイトは直接バイト配列転送が選択される', (fileSize) {
      final method = determineTransferMethod(fileSize);

      expect(
        method,
        equals(TransferMethod.directByteArray),
        reason: '0 バイトは直接バイト配列転送になるべき（<= 10MB）',
      );
    });
  });
}
