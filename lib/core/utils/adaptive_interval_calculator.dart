import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/presentation/viewmodels/timer_state.dart';

class SuggestionResult {
  final TimerMode suggestedMode;
  final int suggestedDurationSeconds;
  final String reason;
  final TimerMode fallbackMode;
  final int fallbackDurationSeconds;
  final bool isFlowExtension;

  SuggestionResult({
    required this.suggestedMode,
    required this.suggestedDurationSeconds,
    required this.reason,
    required this.fallbackMode,
    required this.fallbackDurationSeconds,
    this.isFlowExtension = false,
  });
}

class AdaptiveIntervalCalculator {
  SuggestionResult? calculateNextInterval({
    required TimerMode currentMode,
    required TimerMode standardNextMode,
    required int baseSeconds,
    required List<FocusSession> recentSessions,
    required int currentSessionInterruptions,
    required int currentSessionPauseDuration,
    required bool isTaskCompleted,
  }) {
    final now = DateTime.now();
    final todaysSessions = recentSessions
        .where((s) =>
            s.createdAt.year == now.year &&
            s.createdAt.month == now.month &&
            s.createdAt.day == now.day)
        .toList();

    int totalSecondsToday = 0;
    for (var s in todaysSessions) {
      totalSecondsToday += s.actualSeconds;
    }

    double fatigueIndex = totalSecondsToday / 7200.0;

    if (currentMode == TimerMode.focus && standardNextMode != TimerMode.focus) {
      if (currentSessionInterruptions == 0 &&
          currentSessionPauseDuration == 0 &&
          !isTaskCompleted &&
          fatigueIndex < 0.6) {
        return SuggestionResult(
          suggestedMode: TimerMode.focus,
          suggestedDurationSeconds: 15 * 60,
          reason:
              "Estás en estado de flujo y no has terminado la tarea. ¿Quieres extender la sesión 15 minutos?",
          fallbackMode: standardNextMode,
          fallbackDurationSeconds: baseSeconds,
          isFlowExtension: true,
        );
      }

      if (currentSessionInterruptions > 2 || currentSessionPauseDuration > 60) {
        final int extraPenaltySeconds =
            (3 * 60) + (currentSessionPauseDuration ~/ 2);

        return SuggestionResult(
          suggestedMode: TimerMode.shortBreak,
          suggestedDurationSeconds: baseSeconds + extraPenaltySeconds,
          reason:
              "Hemos detectado distracciones o pausas largas. Te hemos añadido un descanso proporcional para que despejes la mente.",
          fallbackMode: standardNextMode,
          fallbackDurationSeconds: baseSeconds,
        );
      }

      if (fatigueIndex > 0.8) {
        return SuggestionResult(
          suggestedMode: TimerMode.longBreak,
          suggestedDurationSeconds: 20 * 60,
          reason:
              "Tu índice de fatiga es alto. Llevas mucha concentración acumulada hoy. Es hora de una recarga completa.",
          fallbackMode: standardNextMode,
          fallbackDurationSeconds: baseSeconds,
        );
      }
    }

    return null;
  }
}

final adaptiveCalculatorProvider = Provider<AdaptiveIntervalCalculator>((ref) {
  return AdaptiveIntervalCalculator();
});
