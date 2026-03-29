import 'package:aegis/core/utils/adaptive_interval_calculator.dart';
import 'package:aegis/data/local/database/app_database.dart';

enum TimerMode { focus, shortBreak, longBreak }

enum TimerStatus { idle, running, paused }

class TimerState {
  final int remainingSeconds;
  final int initialSeconds;
  final int sessionsCompleted;
  final TimerMode mode;
  final TimerStatus status;
  final Task? assignedTask;
  final bool isDynamicModeActive;
  final int pauseCount;
  final int totalPauseDuration;
  final int addedTime;
  final int blocklistAttempts;
  final SuggestionResult? pendingSuggestion;

  TimerState({
    required this.remainingSeconds,
    required this.initialSeconds,
    required this.sessionsCompleted,
    required this.mode,
    required this.status,
    this.assignedTask,
    required this.isDynamicModeActive,
    required this.pauseCount,
    required this.totalPauseDuration,
    required this.addedTime,
    required this.blocklistAttempts,
    this.pendingSuggestion,
  });

  factory TimerState.initial() {
    return TimerState(
      remainingSeconds: 25 * 60,
      initialSeconds: 25 * 60,
      sessionsCompleted: 0,
      mode: TimerMode.focus,
      status: TimerStatus.idle,
      assignedTask: null,
      isDynamicModeActive: false,
      pauseCount: 0,
      totalPauseDuration: 0,
      addedTime: 0,
      blocklistAttempts: 0,
      pendingSuggestion: null,
    );
  }

  TimerState copyWith({
    int? remainingSeconds,
    int? initialSeconds,
    int? sessionsCompleted,
    TimerMode? mode,
    TimerStatus? status,
    Task? assignedTask,
    bool clearTask = false,
    bool? isDynamicModeActive,
    int? pauseCount,
    int? totalPauseDuration,
    int? addedTime,
    int? blocklistAttempts,
    SuggestionResult? pendingSuggestion,
    bool clearSuggestion = false,
  }) {
    return TimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      initialSeconds: initialSeconds ?? this.initialSeconds,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      assignedTask: clearTask ? null : (assignedTask ?? this.assignedTask),
      isDynamicModeActive: isDynamicModeActive ?? this.isDynamicModeActive,
      pauseCount: pauseCount ?? this.pauseCount,
      totalPauseDuration: totalPauseDuration ?? this.totalPauseDuration,
      addedTime: addedTime ?? this.addedTime,
      blocklistAttempts: blocklistAttempts ?? this.blocklistAttempts,
      pendingSuggestion: clearSuggestion
          ? null
          : (pendingSuggestion ?? this.pendingSuggestion),
    );
  }
}
