/// Property 14: USB イベントマッチングと状態更新
///
/// 任意の StorageRoot リストと USB イベント（connect/disconnect）に対して、
/// イベントの volumeId または mountPath が StorageRoot の URI に含まれる場合のみ
/// その StorageRoot の isConnected を更新し、他のすべての StorageRoot は変更しない
/// ことを検証するプロパティテスト。
///
/// **Validates: Requirements 9.2, 9.4**
@Tags(['android-saf'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, tearDown, test;
import 'package:pictana/domain/entities/entry_id.dart';
import 'package:pictana/domain/entities/storage_root.dart';

// ---------------------------------------------------------------------------
// USB イベントモデル
// ---------------------------------------------------------------------------

/// USB イベントの種類
enum UsbEventType { connected, disconnected }

/// USB イベントを表すデータクラス
class UsbEvent {
  final UsbEventType type;
  final String volumeId;
  final String mountPath;

  const UsbEvent({
    required this.type,
    required this.volumeId,
    required this.mountPath,
  });

  @override
  String toString() =>
      'UsbEvent(type: ${type.name}, volumeId: $volumeId, mountPath: $mountPath)';
}

// ---------------------------------------------------------------------------
// USB イベント適用ロジック（純粋関数）
// ---------------------------------------------------------------------------

/// USB イベントを StorageRoot リストに適用し、更新されたリストを返す。
///
/// マッチングロジック: イベントの volumeId または mountPath が
/// StorageRoot の URI に含まれる場合、その StorageRoot の isConnected を更新する。
/// - disconnect イベント → isConnected = false
/// - connect イベント → isConnected = true
/// マッチしない StorageRoot はそのまま返す。
List<StorageRoot> applyUsbEvent(List<StorageRoot> roots, UsbEvent event) {
  return roots.map((root) {
    final matches = _matchesEvent(root, event);
    if (!matches) return root;

    final newIsConnected = event.type == UsbEventType.connected;
    return root.copyWith(isConnected: newIsConnected);
  }).toList();
}

/// StorageRoot の URI がイベントの volumeId または mountPath にマッチするか判定する。
bool _matchesEvent(StorageRoot root, UsbEvent event) {
  final uri = root.uri;
  if (event.volumeId.isNotEmpty && uri.contains(event.volumeId)) {
    return true;
  }
  if (event.mountPath.isNotEmpty && uri.contains(event.mountPath)) {
    return true;
  }
  return false;
}

// ---------------------------------------------------------------------------
// テストデータ用ジェネレータ
// ---------------------------------------------------------------------------

/// テスト用 StorageRoot データ
class StorageRootTestData {
  final String name;
  final StorageType type;
  final String volumeSegment;
  final bool isConnected;

  StorageRootTestData({
    required this.name,
    required this.type,
    required this.volumeSegment,
    required this.isConnected,
  });

  /// テストデータから StorageRoot を生成する
  StorageRoot toStorageRoot() => StorageRoot(
    id: EntryId.android('vol:$volumeSegment'),
    name: name,
    type: type,
    uri: 'content://com.android.externalstorage.documents/tree/$volumeSegment',
    isConnected: isConnected,
  );

  @override
  String toString() =>
      'StorageRootTestData(name: $name, type: ${type.name}, '
      'volumeSegment: $volumeSegment, isConnected: $isConnected)';
}

/// USB イベントテストデータ
class UsbEventTestData {
  final UsbEventType type;
  final String volumeId;
  final String mountPath;

  UsbEventTestData({
    required this.type,
    required this.volumeId,
    required this.mountPath,
  });

  UsbEvent toUsbEvent() =>
      UsbEvent(type: type, volumeId: volumeId, mountPath: mountPath);

  @override
  String toString() =>
      'UsbEventTestData(type: ${type.name}, volumeId: $volumeId, '
      'mountPath: $mountPath)';
}

/// テストシナリオ: StorageRoot リスト + USB イベント + ターゲットインデックス
class UsbEventScenario {
  final List<StorageRootTestData> roots;
  final UsbEventTestData event;

  /// イベントがマッチするルートのインデックス（-1 = マッチなし）
  final int targetIndex;

  UsbEventScenario({
    required this.roots,
    required this.event,
    required this.targetIndex,
  });

  @override
  String toString() =>
      'UsbEventScenario(roots: ${roots.length} items, '
      'event: $event, targetIndex: $targetIndex)';
}

extension UsbEventGenerators on Any {
  /// ランダムな UsbEventType を生成する
  Generator<UsbEventType> get usbEventType =>
      any.choose([UsbEventType.connected, UsbEventType.disconnected]);

  /// ランダムな StorageType を生成する
  Generator<StorageType> get storageType =>
      any.choose([StorageType.internal, StorageType.usb]);

  /// ランダムなボリュームセグメント文字列を生成する
  Generator<String> get volumeSegment => any.combine2(
    any.choose(['primary', 'usb', 'sdcard', 'ext']),
    any.intInRange(1, 9999),
    (String prefix, int suffix) => '$prefix:$suffix',
  );

  /// ランダムな StorageRootTestData を生成する
  Generator<StorageRootTestData> get storageRootTestData => any.combine4(
    any.nonEmptyLetters,
    any.storageType,
    any.volumeSegment,
    any.bool,
    (String name, StorageType type, String segment, bool connected) =>
        StorageRootTestData(
          name: name,
          type: type,
          volumeSegment: segment,
          isConnected: connected,
        ),
  );

  /// マッチするターゲットを含む USB イベントシナリオを生成する
  Generator<UsbEventScenario> get usbEventScenarioWithMatch => any.combine3(
    any.listWithLengthInRange(1, 10, any.storageRootTestData),
    any.usbEventType,
    any.bool,
    (
      List<StorageRootTestData> roots,
      UsbEventType eventType,
      bool useVolumeId,
    ) {
      // リストからランダムにターゲットを選ぶ（最初の要素を使用）
      final targetIndex = 0;
      final target = roots[targetIndex];

      // ターゲットの volumeSegment をイベントに使用する
      final event = UsbEventTestData(
        type: eventType,
        volumeId: useVolumeId ? target.volumeSegment : '',
        mountPath: useVolumeId ? '' : target.volumeSegment,
      );

      return UsbEventScenario(
        roots: roots,
        event: event,
        targetIndex: targetIndex,
      );
    },
  );

  /// マッチしない USB イベントシナリオを生成する
  Generator<UsbEventScenario> get usbEventScenarioNoMatch => any.combine3(
    any.listWithLengthInRange(1, 10, any.storageRootTestData),
    any.usbEventType,
    any.nonEmptyLetters,
    (List<StorageRootTestData> roots, UsbEventType eventType, String randomId) {
      // どのルートにもマッチしないイベントを生成する
      final uniqueId = 'nomatch_$randomId';
      final event = UsbEventTestData(
        type: eventType,
        volumeId: uniqueId,
        mountPath: '/storage/$uniqueId',
      );

      return UsbEventScenario(roots: roots, event: event, targetIndex: -1);
    },
  );
}

// ---------------------------------------------------------------------------
// プロパティテスト
// ---------------------------------------------------------------------------

void main() {
  group('Feature: android-saf, Property 14: USB イベントマッチングと状態更新', () {
    Glados(any.usbEventScenarioWithMatch).test(
      'マッチする StorageRoot の isConnected がイベントに応じて更新される',
      (scenario) {
        final roots = scenario.roots.map((d) => d.toStorageRoot()).toList();
        final event = scenario.event.toUsbEvent();

        final result = applyUsbEvent(roots, event);

        // ターゲットの isConnected が正しく更新されていることを検証
        final expectedConnected = event.type == UsbEventType.connected;
        expect(
          result[scenario.targetIndex].isConnected,
          equals(expectedConnected),
          reason:
              '${event.type.name} イベント後、ターゲットの isConnected は '
              '$expectedConnected であるべき',
        );
      },
    );

    Glados(any.usbEventScenarioWithMatch).test('マッチしない StorageRoot は変更されない', (
      scenario,
    ) {
      final roots = scenario.roots.map((d) => d.toStorageRoot()).toList();
      final event = scenario.event.toUsbEvent();

      final result = applyUsbEvent(roots, event);

      // ターゲット以外のルートが変更されていないことを検証
      for (var i = 0; i < roots.length; i++) {
        if (i == scenario.targetIndex) continue;

        // マッチしないルートのみ検証（他のルートも偶然マッチする可能性がある）
        if (!_matchesEvent(roots[i], event)) {
          expect(
            result[i].isConnected,
            equals(roots[i].isConnected),
            reason: 'index $i のルート "${roots[i].name}" は変更されるべきではない',
          );
          expect(result[i].name, equals(roots[i].name));
          expect(result[i].uri, equals(roots[i].uri));
          expect(result[i].type, equals(roots[i].type));
        }
      }
    });

    Glados(any.usbEventScenarioNoMatch).test(
      'どの StorageRoot にもマッチしないイベントではリスト全体が変更されない',
      (scenario) {
        final roots = scenario.roots.map((d) => d.toStorageRoot()).toList();
        final event = scenario.event.toUsbEvent();

        final result = applyUsbEvent(roots, event);

        // すべてのルートが変更されていないことを検証
        expect(result.length, equals(roots.length));
        for (var i = 0; i < roots.length; i++) {
          expect(result[i].isConnected, equals(roots[i].isConnected));
          expect(result[i].name, equals(roots[i].name));
          expect(result[i].uri, equals(roots[i].uri));
          expect(result[i].type, equals(roots[i].type));
        }
      },
    );

    Glados(any.usbEventScenarioWithMatch).test('リストの要素数がイベント適用前後で変わらない', (
      scenario,
    ) {
      final roots = scenario.roots.map((d) => d.toStorageRoot()).toList();
      final event = scenario.event.toUsbEvent();

      final result = applyUsbEvent(roots, event);

      expect(result.length, equals(roots.length));
    });

    Glados(any.usbEventScenarioWithMatch).test(
      'disconnect イベントはマッチするルートの isConnected を false にする',
      (scenario) {
        final roots = scenario.roots.map((d) => d.toStorageRoot()).toList();
        // disconnect イベントを強制する
        final event = UsbEvent(
          type: UsbEventType.disconnected,
          volumeId: scenario.event.volumeId,
          mountPath: scenario.event.mountPath,
        );

        final result = applyUsbEvent(roots, event);

        expect(
          result[scenario.targetIndex].isConnected,
          isFalse,
          reason: 'disconnect イベント後、ターゲットの isConnected は false であるべき',
        );
      },
    );

    Glados(any.usbEventScenarioWithMatch).test(
      'connect イベントはマッチするルートの isConnected を true にする',
      (scenario) {
        final roots = scenario.roots.map((d) => d.toStorageRoot()).toList();
        // connect イベントを強制する
        final event = UsbEvent(
          type: UsbEventType.connected,
          volumeId: scenario.event.volumeId,
          mountPath: scenario.event.mountPath,
        );

        final result = applyUsbEvent(roots, event);

        expect(
          result[scenario.targetIndex].isConnected,
          isTrue,
          reason: 'connect イベント後、ターゲットの isConnected は true であるべき',
        );
      },
    );

    Glados(any.usbEventScenarioWithMatch).test(
      'マッチするルートの isConnected 以外のフィールドは変更されない',
      (scenario) {
        final roots = scenario.roots.map((d) => d.toStorageRoot()).toList();
        final event = scenario.event.toUsbEvent();

        final result = applyUsbEvent(roots, event);

        final original = roots[scenario.targetIndex];
        final updated = result[scenario.targetIndex];

        // isConnected 以外のフィールドが保持されていることを検証
        expect(updated.id, equals(original.id));
        expect(updated.name, equals(original.name));
        expect(updated.type, equals(original.type));
        expect(updated.uri, equals(original.uri));
      },
    );
  });
}
