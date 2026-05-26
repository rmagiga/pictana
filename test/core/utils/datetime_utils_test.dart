import 'package:flutter_test/flutter_test.dart';
import 'package:pictana/core/utils/datetime_utils.dart';

void main() {
  group('formatRelativeTime', () {
    test('1分未満は「今」と返すこと', () {
      final now = DateTime.now();
      expect(formatRelativeTime(now), '今');
      expect(formatRelativeTime(now.subtract(const Duration(seconds: 30))), '今');
    });

    test('60分未満は「N分前」と返すこと', () {
      final now = DateTime.now();
      expect(formatRelativeTime(now.subtract(const Duration(minutes: 5))), '5分前');
      expect(formatRelativeTime(now.subtract(const Duration(minutes: 59))), '59分前');
    });

    test('24時間未満は「N時間前」と返すこと', () {
      final now = DateTime.now();
      expect(formatRelativeTime(now.subtract(const Duration(hours: 1))), '1時間前');
      expect(formatRelativeTime(now.subtract(const Duration(hours: 23))), '23時間前');
    });

    test('1日〜2日未満は「昨日」と返すこと', () {
      final now = DateTime.now();
      expect(formatRelativeTime(now.subtract(const Duration(hours: 25))), '昨日');
    });

    test('2日〜7日未満は「N日前」と返すこと', () {
      final now = DateTime.now();
      expect(formatRelativeTime(now.subtract(const Duration(days: 2))), '2日前');
      expect(formatRelativeTime(now.subtract(const Duration(days: 6))), '6日前');
    });

    test('7日以上は絶対日付（yyyy/MM/dd）を返すこと', () {
      final target = DateTime(2026, 5, 10, 14, 30);
      expect(formatRelativeTime(target), '2026/05/10');
    });
  });
}
