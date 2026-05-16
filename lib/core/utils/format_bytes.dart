/// バイト数フォーマットユーティリティ
///
/// 非負整数のバイト数を人間が読みやすい形式（B / KB / MB / GB）に変換する。
/// 1024 ベースの閾値を使用。
library;

/// 非負整数のバイト数を人間が読みやすい形式に変換する純粋関数
///
/// [bytes]: フォーマット対象のバイト数（非負整数）
///
/// 閾値:
/// - 1024 未満: B（小数なし）
/// - 1024² 未満: KB（小数1桁）
/// - 1024³ 未満: MB（小数1桁）
/// - それ以上: GB（小数2桁）
///
/// 例:
/// - `formatBytes(0)` → `'0 B'`
/// - `formatBytes(512)` → `'512 B'`
/// - `formatBytes(1024)` → `'1.0 KB'`
/// - `formatBytes(1536)` → `'1.5 KB'`
/// - `formatBytes(1048576)` → `'1.0 MB'`
/// - `formatBytes(1073741824)` → `'1.00 GB'`
String formatBytes(int bytes) {
  assert(bytes >= 0, 'bytes must be non-negative');

  const kb = 1024;
  const mb = 1024 * 1024;
  const gb = 1024 * 1024 * 1024;

  if (bytes < kb) {
    return '$bytes B';
  } else if (bytes < mb) {
    final value = bytes / kb;
    return '${value.toStringAsFixed(1)} KB';
  } else if (bytes < gb) {
    final value = bytes / mb;
    return '${value.toStringAsFixed(1)} MB';
  } else {
    final value = bytes / gb;
    return '${value.toStringAsFixed(2)} GB';
  }
}
