import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/presentation/viewmodels/timer_state.dart';
import 'package:aegis/core/utils/adaptive_interval_calculator.dart';

void main() {
  late AdaptiveIntervalCalculator calculator;

  setUp(() {
    calculator = AdaptiveIntervalCalculator();
  });

  FocusSession createDummySession(int actualSeconds) {
    return FocusSession(
      id: 1,
      mode: TimerMode.focus.toString(),
      actualSeconds: actualSeconds,
      pauseCount: 0,
      pauseDuration: 0,
      extraTimeAdded: 0,
      blocklistAttempts: 0,
      createdAt: DateTime.now(),
    );
  }

  group('AdaptiveIntervalCalculator - Static', () {
    test('Debe devolver sugerencia de Flow si no hay pausas y fatiga es baja',
        () {
      final result = calculator.calculateNextInterval(
        currentMode: TimerMode.focus,
        standardNextMode: TimerMode.shortBreak,
        baseSeconds: 300,
        recentSessions: [],
        currentSessionInterruptions: 0,
        currentSessionPauseDuration: 0,
        isTaskCompleted: false,
      );

      expect(result, isNotNull);
      expect(result!.isFlowExtension, isTrue);
      expect(result.suggestedMode, TimerMode.focus);
      expect(result.suggestedDurationSeconds, 900);
    });

    test('Debe devolver descanso largo si el Índice de Fatiga es mayor a 0.8',
        () {
      final List<FocusSession> heavySessions = [
        createDummySession(3600),
        createDummySession(3600),
      ];

      final result = calculator.calculateNextInterval(
        currentMode: TimerMode.focus,
        standardNextMode: TimerMode.shortBreak,
        baseSeconds: 300,
        recentSessions: heavySessions,
        currentSessionInterruptions: 0,
        currentSessionPauseDuration: 0,
        isTaskCompleted: true,
      );

      expect(result, isNotNull);
      expect(result!.suggestedMode, TimerMode.longBreak);
      expect(result.suggestedDurationSeconds, 1200);
    });

    test('Debe añadir penalizacion si hay mas de 2 interrupciones', () {
      final result = calculator.calculateNextInterval(
        currentMode: TimerMode.focus,
        standardNextMode: TimerMode.shortBreak,
        baseSeconds: 300,
        recentSessions: [],
        currentSessionInterruptions: 3,
        currentSessionPauseDuration: 0,
        isTaskCompleted: false,
      );

      expect(result, isNotNull);
      expect(result!.suggestedMode, TimerMode.shortBreak);
      expect(result.suggestedDurationSeconds, 480);
    });

    test(
        'Debe añadir penalizacion combinada si hay interrupciones y pausas largas',
        () {
      final result = calculator.calculateNextInterval(
        currentMode: TimerMode.focus,
        standardNextMode: TimerMode.shortBreak,
        baseSeconds: 300,
        recentSessions: [],
        currentSessionInterruptions: 1,
        currentSessionPauseDuration: 120,
        isTaskCompleted: false,
      );

      expect(result, isNotNull);
      expect(result!.suggestedMode, TimerMode.shortBreak);
      expect(result.suggestedDurationSeconds, 540);
    });

    test('Debe devolver null si el ciclo es estandar y no hay anomalias', () {
      final result = calculator.calculateNextInterval(
        currentMode: TimerMode.focus,
        standardNextMode: TimerMode.shortBreak,
        baseSeconds: 300,
        recentSessions: [createDummySession(1500)],
        currentSessionInterruptions: 1,
        currentSessionPauseDuration: 10,
        isTaskCompleted: true,
      );

      expect(result, isNull);
    });
  });

  group('AdaptiveIntervalCalculator - Property-Based Testing', () {
    final random = Random();

    test('El algoritmo no debe fallar con entradas extremas o aleatorias', () {
      final int totalIteraciones = 10000;

      for (int i = 0; i < totalIteraciones; i++) {
        final randomInterruptions = random.nextInt(50);
        final randomPauseDuration = random.nextInt(3600);
        final isTaskCompleted = random.nextBool();

        final numSessions = random.nextInt(20);
        final randomSessions = List.generate(numSessions, (index) {
          return FocusSession(
            id: random.nextInt(10000),
            mode: random.nextBool() ? 'focus' : 'shortBreak',
            actualSeconds: random.nextInt(3600),
            pauseCount: random.nextInt(20),
            pauseDuration: random.nextInt(1800),
            extraTimeAdded: random.nextInt(300),
            blocklistAttempts: random.nextInt(15),
            createdAt: DateTime.now(),
          );
        });

        try {
          final result = calculator.calculateNextInterval(
            currentMode: TimerMode.focus,
            standardNextMode: TimerMode.shortBreak,
            baseSeconds: 300,
            recentSessions: randomSessions,
            currentSessionInterruptions: randomInterruptions,
            currentSessionPauseDuration: randomPauseDuration,
            isTaskCompleted: isTaskCompleted,
          );

          if (result != null) {
            expect(result.suggestedDurationSeconds, greaterThanOrEqualTo(0),
                reason:
                    'Falló en iteración $i con interrupciones: $randomInterruptions');
            expect(result.fallbackMode, isNotNull);

            if (randomInterruptions > 2 || randomPauseDuration > 60) {
              expect(
                  result.suggestedDurationSeconds, greaterThanOrEqualTo(300));
            }
          }
        } catch (e) {
          fail('💥 El algoritmo crasheó con la iteración $i. Error: $e');
        }
      }
    });
  });
}
