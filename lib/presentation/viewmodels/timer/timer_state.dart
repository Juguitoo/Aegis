enum TimerMode { focus, shortBreak, longBreak }

enum TimerStatus { idle, running, paused }

class TimerState {
  final int remainingSeconds;
  final int sessionsCompleted;
  final int initialSeconds;
  final TimerMode mode;
  final TimerStatus status;

  TimerState({
    required this.remainingSeconds,
    required this.sessionsCompleted,
    required this.initialSeconds,
    required this.mode,
    required this.status,
  });

  TimerState copyWith({
    int? remainingSeconds,
    int? sessionsCompleted,
    int? initialSeconds,
    TimerMode? mode,
    TimerStatus? status,
  }) {
    return TimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
      initialSeconds: initialSeconds ?? this.initialSeconds,
      mode: mode ?? this.mode,
      status: status ?? this.status,
    );
  }
}
