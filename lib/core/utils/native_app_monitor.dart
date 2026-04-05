import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NativeAppMonitor {
  static const MethodChannel _channel = MethodChannel('com.aegis.app/monitor');
  Timer? _pollingTimer;
  String? _currentForegroundApp;

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  final StreamController<String> _appStreamController =
      StreamController<String>.broadcast();
  Stream<String> get onAppChanged => _appStreamController.stream;

  Future<bool> checkUsagePermission() async {
    if (!_isAndroid) return true;
    try {
      final bool granted = await _channel.invokeMethod('checkUsagePermission');
      return granted;
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<void> requestUsagePermission() async {
    if (!_isAndroid) return;
    try {
      await _channel.invokeMethod('requestUsagePermission');
    } on PlatformException catch (_) {}
  }

  Future<bool> checkOverlayPermission() async {
    if (!_isAndroid) return true;
    try {
      final bool granted =
          await _channel.invokeMethod('checkOverlayPermission');
      return granted;
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<void> requestOverlayPermission() async {
    if (!_isAndroid) return;
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } on PlatformException catch (_) {}
  }

  Future<void> bringToForeground() async {
    if (!_isAndroid) return;
    try {
      await _channel.invokeMethod('bringToForeground');
    } on PlatformException catch (e) {
      debugPrint('Error bringing app to foreground: $e');
    }
  }

  Future<void> sendToBackground() async {
    if (!_isAndroid) return;
    try {
      await _channel.invokeMethod('sendToBackground');
    } on PlatformException catch (_) {}
  }

  void startMonitoring({Duration interval = const Duration(seconds: 2)}) {
    if (!_isAndroid) return;
    if (_pollingTimer != null && _pollingTimer!.isActive) return;

    _pollingTimer = Timer.periodic(interval, (timer) async {
      try {
        final String? packageName =
            await _channel.invokeMethod('getForegroundApp');
        if (packageName != null && packageName != _currentForegroundApp) {
          _currentForegroundApp = packageName;
          _appStreamController.add(packageName);
        }
      } on PlatformException catch (_) {}
    });
  }

  void stopMonitoring() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _currentForegroundApp = null;
  }

  void dispose() {
    stopMonitoring();
    _appStreamController.close();
  }
}

final nativeAppMonitorProvider = Provider<NativeAppMonitor>((ref) {
  final monitor = NativeAppMonitor();
  ref.onDispose(monitor.dispose);
  return monitor;
});
