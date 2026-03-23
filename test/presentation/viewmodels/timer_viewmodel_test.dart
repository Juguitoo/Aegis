import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:aegis/presentation/viewmodels/timer_state.dart';
import 'package:aegis/presentation/viewmodels/timer_viewmodel.dart';
import 'package:aegis/presentation/viewmodels/settings_viewmodel.dart';
import 'package:aegis/data/local/database/app_database.dart';

class MockSettingsViewmodel extends SettingsViewmodel {
  @override
  Stream<Setting?> build() {
    return Stream.value(
      Setting(
        id: 1,
        pomodoroDuration: 25,
        shortBreakDuration: 5,
        longBreakDuration: 15,
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        settingsViewModelProvider.overrideWith(() => MockSettingsViewmodel()),
        audioPlayerProvider.overrideWith((ref) => null),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('TimerViewmodel Tests', () {
    test('El estado inicial se configura correctamente basado en los settings',
        () async {
      final container = createContainer();

      await Future.microtask(() {});

      final state = container.read(timerViewModelProvider);

      expect(state.status, TimerStatus.idle);
      expect(state.mode, TimerMode.focus);
      expect(state.sessionsCompleted, 0);
      expect(state.remainingSeconds, 25 * 60);
      expect(state.initialSeconds, 25 * 60);
    });

    test('start() cambia el estado a running', () async {
      final container = createContainer();
      await Future.microtask(() {});
      final notifier = container.read(timerViewModelProvider.notifier);

      notifier.start();
      final state = container.read(timerViewModelProvider);

      expect(state.status, TimerStatus.running);
    });

    test('pause() cambia el estado a paused', () async {
      final container = createContainer();
      await Future.microtask(() {});
      final notifier = container.read(timerViewModelProvider.notifier);

      notifier.start();
      notifier.pause();
      final state = container.read(timerViewModelProvider);

      expect(state.status, TimerStatus.paused);
    });

    test('reset() devuelve el timer a su estado inicial', () async {
      final container = createContainer();
      await Future.microtask(() {});
      final notifier = container.read(timerViewModelProvider.notifier);

      notifier.start();
      notifier.pause();
      notifier.add5Minutes();

      notifier.reset();
      final state = container.read(timerViewModelProvider);

      expect(state.status, TimerStatus.idle);
      expect(state.remainingSeconds, 25 * 60);
      expect(state.mode, TimerMode.focus);
    });

    test('add5Minutes() suma 300 segundos correctamente', () async {
      final container = createContainer();
      await Future.microtask(() {});
      final notifier = container.read(timerViewModelProvider.notifier);
      final initialState = container.read(timerViewModelProvider);

      notifier.add5Minutes();
      final newState = container.read(timerViewModelProvider);

      expect(newState.remainingSeconds, initialState.remainingSeconds + 300);
      expect(newState.initialSeconds, initialState.initialSeconds + 300);
    });

    test('didChangeAppLifecycleState gestiona la pausa del sistema operativo',
        () async {
      final container = createContainer();
      await Future.microtask(() {});
      final notifier = container.read(timerViewModelProvider.notifier);

      notifier.start();

      notifier.didChangeAppLifecycleState(AppLifecycleState.paused);
      notifier.didChangeAppLifecycleState(AppLifecycleState.resumed);

      final state = container.read(timerViewModelProvider);

      expect(state.status, TimerStatus.running);
      expect(state.remainingSeconds, lessThanOrEqualTo(25 * 60));
    });
  });
}
