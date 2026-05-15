import 'package:aegis/core/services/notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'notification_service_test.mocks.dart';

@GenerateMocks([
  FlutterLocalNotificationsPlugin,
  AndroidFlutterLocalNotificationsPlugin,
  IOSFlutterLocalNotificationsPlugin,
  MacOSFlutterLocalNotificationsPlugin,
])
void main() {
  late NotificationService notificationService;
  late MockFlutterLocalNotificationsPlugin mockPlugin;

  setUp(() {
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    notificationService = NotificationService(plugin: mockPlugin);

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Madrid'));

    when(mockPlugin.initialize(
      settings: anyNamed('settings'),
      onDidReceiveNotificationResponse:
          anyNamed('onDidReceiveNotificationResponse'),
    )).thenAnswer((_) async => true);

    when(mockPlugin.getNotificationAppLaunchDetails())
        .thenAnswer((_) async => null);
  });

  group('NotificationService', () {
    test('init inicializa el plugin correctamente', () async {
      await notificationService.init();

      verify(mockPlugin.initialize(
        settings: anyNamed('settings'),
        onDidReceiveNotificationResponse:
            anyNamed('onDidReceiveNotificationResponse'),
      )).called(1);
    });

    test(
        'scheduleNotification delega al plugin correctamente con fechas futuras',
        () async {
      final futureDate = DateTime.now().add(const Duration(days: 1));

      when(mockPlugin.zonedSchedule(
        id: anyNamed('id'),
        title: anyNamed('title'),
        body: anyNamed('body'),
        scheduledDate: anyNamed('scheduledDate'),
        notificationDetails: anyNamed('notificationDetails'),
        androidScheduleMode: anyNamed('androidScheduleMode'),
        payload: anyNamed('payload'),
      )).thenAnswer((_) async => {});

      await notificationService.scheduleNotification(
        id: 42,
        title: 'Title',
        body: 'Body',
        scheduledDate: futureDate,
        payload: 'test_payload',
      );

      verify(mockPlugin.zonedSchedule(
        id: 42,
        title: 'Title',
        body: 'Body',
        scheduledDate: anyNamed('scheduledDate'),
        notificationDetails: anyNamed('notificationDetails'),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'test_payload',
      )).called(1);
    });

    test('scheduleNotification ignora fechas en el pasado', () async {
      final pastDate = DateTime.now().subtract(const Duration(hours: 1));

      await notificationService.scheduleNotification(
        id: 1,
        title: 'Title',
        body: 'Body',
        scheduledDate: pastDate,
      );

      verifyNever(mockPlugin.zonedSchedule(
        id: anyNamed('id'),
        title: anyNamed('title'),
        body: anyNamed('body'),
        scheduledDate: anyNamed('scheduledDate'),
        notificationDetails: anyNamed('notificationDetails'),
        androidScheduleMode: anyNamed('androidScheduleMode'),
        payload: anyNamed('payload'),
      ));
    });

    test('cancelNotification llama a cancel en el plugin', () async {
      when(mockPlugin.cancel(id: anyNamed('id'))).thenAnswer((_) async => {});

      await notificationService.cancelNotification(123);

      verify(mockPlugin.cancel(id: 123)).called(1);
    });

    test('cancelAllNotifications llama a cancelAll en el plugin', () async {
      when(mockPlugin.cancelAll()).thenAnswer((_) async => {});

      await notificationService.cancelAllNotifications();

      verify(mockPlugin.cancelAll()).called(1);
    });

    test('showImmediateNotification llama a show en el plugin', () async {
      when(mockPlugin.show(
        id: anyNamed('id'),
        title: anyNamed('title'),
        body: anyNamed('body'),
        notificationDetails: anyNamed('notificationDetails'),
        payload: anyNamed('payload'),
      )).thenAnswer((_) async => {});

      await notificationService.showImmediateNotification('Hola', 'Mundo');

      verify(mockPlugin.show(
        id: 999,
        title: 'Hola',
        body: 'Mundo',
        notificationDetails: anyNamed('notificationDetails'),
        payload: anyNamed('payload'),
      )).called(1);
    });

    test('requestPermissions en Android solicita permisos nativos', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      final mockAndroidPlugin = MockAndroidFlutterLocalNotificationsPlugin();

      when(mockPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>())
          .thenReturn(mockAndroidPlugin);

      when(mockAndroidPlugin.requestNotificationsPermission())
          .thenAnswer((_) async => true);
      when(mockAndroidPlugin.requestExactAlarmsPermission())
          .thenAnswer((_) async => true);

      await notificationService.requestPermissions();

      verify(mockAndroidPlugin.requestNotificationsPermission()).called(1);
      verify(mockAndroidPlugin.requestExactAlarmsPermission()).called(1);

      debugDefaultTargetPlatformOverride = null;
    });

    test('requestPermissions en iOS solicita permisos nativos', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      final mockIOSPlugin = MockIOSFlutterLocalNotificationsPlugin();

      when(mockPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>())
          .thenReturn(mockIOSPlugin);

      when(mockIOSPlugin.requestPermissions(
        alert: anyNamed('alert'),
        badge: anyNamed('badge'),
        sound: anyNamed('sound'),
      )).thenAnswer((_) async => true);

      await notificationService.requestPermissions();

      verify(mockIOSPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      )).called(1);

      debugDefaultTargetPlatformOverride = null;
    });

    test('requestPermissions en macOS solicita permisos nativos', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      final mockMacOSPlugin = MockMacOSFlutterLocalNotificationsPlugin();

      when(mockPlugin.resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>())
          .thenReturn(mockMacOSPlugin);

      when(mockMacOSPlugin.requestPermissions(
        alert: anyNamed('alert'),
        badge: anyNamed('badge'),
        sound: anyNamed('sound'),
      )).thenAnswer((_) async => true);

      await notificationService.requestPermissions();

      verify(mockMacOSPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      )).called(1);

      debugDefaultTargetPlatformOverride = null;
    });
  });
}
