/// 日時の相対表記ヘルパー
library;

/// 指定した日時と現在時刻との差を、「〜時間前」「昨日」などの相対的な文字列にフォーマットする。
String formatRelativeTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inMinutes < 1) {
    return '今';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}分前';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}時間前';
  } else if (difference.inDays == 1) {
    return '昨日';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}日前';
  } else {
    return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}';
  }
}
