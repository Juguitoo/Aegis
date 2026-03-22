enum TimerMode { focus, shortBreak, longBreak }

enum TimerStatus { idle, running, paused }

class TimerState {
  final int remainingSeconds;
  final int initialSeconds;
  final int sessionsCompleted;
  final TimerMode mode;
  final TimerStatus status;

  TimerState({
    required this.remainingSeconds,
    required this.initialSeconds,
    required this.sessionsCompleted,
    required this.mode,
    required this.status,
  });

  TimerState copyWith({
    int? remainingSeconds,
    int? initialSeconds,
    int? sessionsCompleted,
    TimerMode? mode,
    TimerStatus? status,
  }) {
    return TimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      initialSeconds: initialSeconds ?? this.initialSeconds,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
      mode: mode ?? this.mode,
      status: status ?? this.status,
    );
  }

  factory TimerState.initial() {
    return TimerState(
      remainingSeconds: 25 * 60,
      initialSeconds: 25 * 60,
      sessionsCompleted: 0,
      mode: TimerMode.focus,
      status: TimerStatus.idle,
    );
  }
}
