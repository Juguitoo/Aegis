import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aegis/core/utils/native_app_monitor.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NativeAppMonitor Tests (Android)', () {
    late NativeAppMonitor monitor;
    const MethodChannel channel = MethodChannel('com.aegis.app/monitor');
    String? mockedForegroundApp;
    bool forcePlatformException = false;

    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      monitor = NativeAppMonitor();
      mockedForegroundApp = 'com.example.app';
      forcePlatformException = false;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (forcePlatformException) {
          throw PlatformException(code: 'ERROR');
        }
        switch (methodCall.method) {
          case 'checkUsagePermission':
            return true;
          case 'checkOverlayPermission':
            return true;
          case 'getForegroundApp':
            return mockedForegroundApp;
          default:
            return null;
        }
      });
    });

    tearDown(() {
      monitor.dispose();
      debugDefaultTargetPlatformOverride = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('checkUsagePermission devuelve true mediante el canal', () async {
      final result = await monitor.checkUsagePermission();
      expect(result, isTrue);
    });

    test('checkUsagePermission devuelve false si lanza excepcion', () async {
      forcePlatformException = true;
      final result = await monitor.checkUsagePermission();
      expect(result, isFalse);
    });

    test('requestUsagePermission se llama sin explotar', () async {
      await expectLater(monitor.requestUsagePermission(), completes);
    });

    test('checkOverlayPermission devuelve true mediante el canal', () async {
      final result = await monitor.checkOverlayPermission();
      expect(result, isTrue);
    });

    test('checkOverlayPermission devuelve false si lanza excepcion', () async {
      forcePlatformException = true;
      final result = await monitor.checkOverlayPermission();
      expect(result, isFalse);
    });

    test('requestOverlayPermission se llama sin explotar', () async {
      await expectLater(monitor.requestOverlayPermission(), completes);
    });

    test('bringToForeground se llama sin explotar', () async {
      await expectLater(monitor.bringToForeground(), completes);
    });

    test('sendToBackground se llama sin explotar', () async {
      await expectLater(monitor.sendToBackground(), completes);
    });

    test('startMonitoring emite cambios en la aplicacion en primer plano',
        () async {
      final streamList = <String>[];
      final subscription = monitor.onAppChanged.listen((app) {
        streamList.add(app);
      });

      monitor.startMonitoring(interval: const Duration(milliseconds: 10));

      await Future.delayed(const Duration(milliseconds: 50));
      expect(streamList, contains('com.example.app'));

      mockedForegroundApp = 'com.new.app';
      await Future.delayed(const Duration(milliseconds: 50));
      expect(streamList, contains('com.new.app'));

      subscription.cancel();
    });
  });

  group('NativeAppMonitor Tests (No Android)', () {
    late NativeAppMonitor monitor;

    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      monitor = NativeAppMonitor();
    });

    tearDown(() {
      monitor.dispose();
      debugDefaultTargetPlatformOverride = null;
    });

    test(
        'Metodos devuelven valores por defecto o terminan de inmediato en iOS/Web',
        () async {
      expect(await monitor.checkUsagePermission(), isTrue);
      expect(await monitor.checkOverlayPermission(), isTrue);

      await expectLater(monitor.requestUsagePermission(), completes);
      await expectLater(monitor.requestOverlayPermission(), completes);
      await expectLater(monitor.bringToForeground(), completes);
      await expectLater(monitor.sendToBackground(), completes);

      monitor.startMonitoring();
    });
  });
}
