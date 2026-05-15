import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/core/providers/general_providers.dart';

void main() {
  group('General Providers', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('navigationIndexProvider tiene valor inicial 2 y cambia correctamente',
        () {
      expect(container.read(navigationIndexProvider), 2);

      container.read(navigationIndexProvider.notifier).state = 0;
      expect(container.read(navigationIndexProvider), 0);
    });

    test('taskToOpenProvider tiene valor inicial null y cambia correctamente',
        () {
      expect(container.read(taskToOpenProvider), isNull);

      container.read(taskToOpenProvider.notifier).state = 123;
      expect(container.read(taskToOpenProvider), 123);
    });

    test('devModeProvider tiene valor inicial false y cambia correctamente',
        () {
      expect(container.read(devModeProvider), isFalse);

      container.read(devModeProvider.notifier).state = true;
      expect(container.read(devModeProvider), isTrue);
    });

    test(
        'themeModeProvider tiene valor inicial ThemeMode.light y cambia correctamente',
        () {
      expect(container.read(themeModeProvider), ThemeMode.light);

      container.read(themeModeProvider.notifier).state = ThemeMode.dark;
      expect(container.read(themeModeProvider), ThemeMode.dark);
    });

    test('textScaleProvider tiene valor inicial 1.0 y cambia correctamente',
        () {
      expect(container.read(textScaleProvider), 1.0);

      container.read(textScaleProvider.notifier).state = 1.5;
      expect(container.read(textScaleProvider), 1.5);
    });
  });
}
