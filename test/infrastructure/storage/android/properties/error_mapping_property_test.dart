/// Property 3: プラットフォームエラー → ドメイン例外マッピング
/// Property 15: 未実装メソッドエラーメッセージ
///
/// PlatformException のエラーコードに基づいて正しいドメイン例外に
/// マッピングされることを検証するプロパティテスト。
/// また、MissingPluginException 発生時に UnsupportedError メッセージに
/// メソッド名が含まれることを検証する。
///
/// **Validates: Requirements 1.4, 4.6, 4.7, 6.4, 10.4**
@Tags(['android-saf', 'property-test'])
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, setUp, tearDown, test;
import 'package:optrig/core/errors/app_exceptions.dart';
import 'package:optrig/infrastructure/storage/android/saf_platform_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SafPlatformChannel channel;

  setUp(() {
    channel = SafPlatformChannel();
  });

  /// MethodChannel モックを設定し、指定されたエラーコードとメッセージで
  /// PlatformException をスローするようにする。
  void setupMethodChannelError(String errorCode, String message) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('com.example.optrig/saf'),
          (MethodCall methodCall) async {
            throw PlatformException(code: errorCode, message: message);
          },
        );
  }

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('com.example.optrig/saf'),
          null,
        );
  });

  group('Property 3: プラットフォームエラー → ドメイン例外マッピング', () {
    Glados(any.lowercaseLetters).test(
      'PERMISSION_DENIED エラーコードは PermissionDeniedException にマッピングされる',
      (message) async {
        setupMethodChannelError('PERMISSION_DENIED', message);

        expect(
          () => channel.getStorageRoots(),
          throwsA(
            isA<PermissionDeniedException>().having(
              (e) => e.cause,
              'cause',
              isA<PlatformException>().having(
                (e) => e.code,
                'code',
                'PERMISSION_DENIED',
              ),
            ),
          ),
        );
      },
    );

    Glados(any.lowercaseLetters).test(
      'STORAGE_DISCONNECTED エラーコードは StorageDisconnectedException にマッピングされる',
      (message) async {
        setupMethodChannelError('STORAGE_DISCONNECTED', message);

        expect(
          () => channel.getStorageRoots(),
          throwsA(
            isA<StorageDisconnectedException>().having(
              (e) => e.cause,
              'cause',
              isA<PlatformException>().having(
                (e) => e.code,
                'code',
                'STORAGE_DISCONNECTED',
              ),
            ),
          ),
        );
      },
    );

    Glados(any.lowercaseLetters).test(
      'OUT_OF_MEMORY エラーコードは OutOfMemoryException にマッピングされる',
      (message) async {
        setupMethodChannelError('OUT_OF_MEMORY', message);

        expect(
          () => channel.getStorageRoots(),
          throwsA(
            isA<OutOfMemoryException>().having(
              (e) => e.cause,
              'cause',
              isA<PlatformException>().having(
                (e) => e.code,
                'code',
                'OUT_OF_MEMORY',
              ),
            ),
          ),
        );
      },
    );

    Glados2(any.lowercaseLetters, any.lowercaseLetters).test(
      '未知のエラーコードは StorageDisconnectedException にマッピングされる',
      (unknownCode, message) async {
        // 既知のエラーコードを除外
        if (unknownCode == 'PERMISSION_DENIED' ||
            unknownCode == 'STORAGE_DISCONNECTED' ||
            unknownCode == 'OUT_OF_MEMORY') {
          return;
        }

        setupMethodChannelError(unknownCode, message);

        expect(
          () => channel.getStorageRoots(),
          throwsA(
            isA<StorageDisconnectedException>().having(
              (e) => e.cause,
              'cause',
              isA<PlatformException>().having(
                (e) => e.code,
                'code',
                unknownCode,
              ),
            ),
          ),
        );
      },
    );

    Glados(any.lowercaseLetters).test(
      'すべてのマッピングされた例外は cause フィールドに元のエラーを保持する',
      (message) async {
        // 各既知のエラーコードについて cause が保持されることを検証
        for (final errorCode in [
          'PERMISSION_DENIED',
          'STORAGE_DISCONNECTED',
          'OUT_OF_MEMORY',
        ]) {
          setupMethodChannelError(errorCode, message);

          try {
            await channel.getStorageRoots();
            fail('例外がスローされるべき');
          } on AppException catch (e) {
            expect(e.cause, isNotNull, reason: 'cause は null であってはならない');
            expect(
              e.cause,
              isA<PlatformException>(),
              reason: 'cause は PlatformException であるべき',
            );
            final platformException = e.cause! as PlatformException;
            expect(
              platformException.code,
              errorCode,
              reason: 'cause のエラーコードが一致するべき',
            );
            expect(
              platformException.message,
              message,
              reason: 'cause のメッセージが一致するべき',
            );
          }
        }
      },
    );

    Glados(any.lowercaseLetters).test(
      'PERMISSION_DENIED は selectFolder 経由でも正しくマッピングされる',
      (message) async {
        setupMethodChannelError('PERMISSION_DENIED', message);

        expect(
          () => channel.selectFolder(),
          throwsA(isA<PermissionDeniedException>()),
        );
      },
    );

    Glados(any.lowercaseLetters).test(
      'STORAGE_DISCONNECTED は getChildFolders 経由でも正しくマッピングされる',
      (message) async {
        setupMethodChannelError('STORAGE_DISCONNECTED', message);

        expect(
          () => channel.getChildFolders('content://test', null),
          throwsA(isA<StorageDisconnectedException>()),
        );
      },
    );

    Glados(any.lowercaseLetters).test(
      'OUT_OF_MEMORY は getImageBytes 経由でも正しくマッピングされる',
      (message) async {
        setupMethodChannelError('OUT_OF_MEMORY', message);

        expect(
          () => channel.getImageBytes('content://test/image.jpg'),
          throwsA(isA<OutOfMemoryException>()),
        );
      },
    );
  });

  group('Feature: android-saf, Property 15: 未実装メソッドエラーメッセージ', () {
    /// **Validates: Requirements 10.4**
    ///
    /// MissingPluginException 発生時に UnsupportedError メッセージに
    /// メソッド名が含まれることを検証する。
    /// glados でランダムなメソッド名文字列を生成し、
    /// SafPlatformChannel の _invokeMethod が正しくメソッド名を埋め込むことを検証する。

    Glados(
      any.lowercaseLetters,
    ).test('ランダムなメソッド名で MissingPluginException が発生した場合、'
        'UnsupportedError メッセージにそのメソッド名が含まれる', (randomMethodName) async {
      // MethodChannel モックで、呼び出されたメソッド名を記録しつつ
      // MissingPluginException をスローする
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('com.example.optrig/saf'),
            (MethodCall methodCall) async {
              throw MissingPluginException(
                'No implementation found for method '
                '${methodCall.method} on channel com.example.optrig/saf',
              );
            },
          );

      // SafPlatformChannel の公開メソッドを通じてテスト。
      // ランダム文字列のハッシュでメソッドを選択し、
      // 各メソッドが正しくメソッド名を UnsupportedError に埋め込むことを検証する。
      final methodTests = <String, Future<void> Function()>{
        'selectFolder': () async => await channel.selectFolder(),
        'getStorageRoots': () async => await channel.getStorageRoots(),
        'getChildFolders': () async =>
            await channel.getChildFolders('content://$randomMethodName', null),
        'getImages': () async => await channel.getImages(
          'content://$randomMethodName',
          'doc',
          0,
          50,
        ),
        'getImageBytes': () async =>
            await channel.getImageBytes('content://$randomMethodName'),
        'getImageBytesViaFile': () async =>
            await channel.getImageBytesViaFile('content://$randomMethodName'),
        'getThumbnail': () async =>
            await channel.getThumbnail('content://$randomMethodName', 256, 256),
        'persistUriPermission': () async =>
            await channel.persistUriPermission('content://$randomMethodName'),
        'getPersistedUriPermissions': () async =>
            await channel.getPersistedUriPermissions(),
        'releaseUriPermission': () async =>
            await channel.releaseUriPermission('content://$randomMethodName'),
        'getDefaultImageFolder': () async =>
            await channel.getDefaultImageFolder(),
      };

      final entries = methodTests.entries.toList();
      final selectedEntry = entries[randomMethodName.length % entries.length];
      final expectedMethodName = selectedEntry.key;

      try {
        await selectedEntry.value();
        fail('UnsupportedError がスローされるべき');
      } on UnsupportedError catch (e) {
        expect(
          e.message,
          contains(expectedMethodName),
          reason: 'UnsupportedError メッセージにメソッド名 "$expectedMethodName" が含まれるべき',
        );
      }
    });

    Glados(any.lowercaseLetters).test('MissingPluginException のメッセージ内容に関わらず、'
        'UnsupportedError にはメソッド名が含まれる', (exceptionMessage) async {
      // MissingPluginException のメッセージをランダムに変えても
      // UnsupportedError にメソッド名が含まれることを検証
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('com.example.optrig/saf'),
            (MethodCall methodCall) async {
              throw MissingPluginException(exceptionMessage);
            },
          );

      try {
        await channel.getStorageRoots();
        fail('UnsupportedError がスローされるべき');
      } on UnsupportedError catch (e) {
        expect(
          e.message,
          contains('getStorageRoots'),
          reason:
              'MissingPluginException メッセージ "$exceptionMessage" に関わらず、'
              'UnsupportedError にメソッド名が含まれるべき',
        );
      }
    });

    Glados(any.intInRange(0, 10)).test(
      '全公開メソッドで MissingPluginException → UnsupportedError 変換が正しく動作する',
      (index) async {
        // ハンドラを null に設定して MissingPluginException を発生させる
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('com.example.optrig/saf'),
              null,
            );

        final methodTests = <String, Future<void> Function()>{
          'selectFolder': () async => await channel.selectFolder(),
          'getStorageRoots': () async => await channel.getStorageRoots(),
          'getChildFolders': () async =>
              await channel.getChildFolders('content://test', null),
          'getImages': () async =>
              await channel.getImages('content://test', 'doc', 0, 50),
          'getImageBytes': () async =>
              await channel.getImageBytes('content://test/img.jpg'),
          'getImageBytesViaFile': () async =>
              await channel.getImageBytesViaFile('content://test/img.jpg'),
          'getThumbnail': () async =>
              await channel.getThumbnail('content://test/img.jpg', 256, 256),
          'persistUriPermission': () async =>
              await channel.persistUriPermission('content://test'),
          'getPersistedUriPermissions': () async =>
              await channel.getPersistedUriPermissions(),
          'releaseUriPermission': () async =>
              await channel.releaseUriPermission('content://test'),
          'getDefaultImageFolder': () async =>
              await channel.getDefaultImageFolder(),
        };

        final entries = methodTests.entries.toList();
        final entry = entries[index];
        final expectedMethodName = entry.key;

        try {
          await entry.value();
          fail('UnsupportedError がスローされるべき: $expectedMethodName');
        } on UnsupportedError catch (e) {
          expect(
            e.message,
            contains(expectedMethodName),
            reason:
                'メソッド "$expectedMethodName" の UnsupportedError メッセージに'
                'メソッド名が含まれるべき',
          );
        }
      },
    );
  });
}
