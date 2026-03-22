import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'timer_state.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/presentation/viewmodels/settings_viewmodel.dart';

class TimerViewmodel extends Notifier<TimerState> {
  Timer? _timer;

  AsyncValue<Setting?> get _settingsValue =>
      ref.watch(settingsViewModelProvider);

  @override
  TimerState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });

    final settings = _settingsValue.value;

    if (settings != null) {
      final int initialSeconds = settings.pomodoroDuration * 60;
      return TimerState(
        remainingSeconds: initialSeconds,
        initialSeconds: initialSeconds,
        sessionsCompleted: 0,
        mode: TimerMode.focus,
        status: TimerStatus.idle,
      );
    } else {
      return TimerState.initial();
    }
  }

  void _onTick() {
    if (state.remainingSeconds > 0) {
      state = state.copyWith(
        remainingSeconds: state.remainingSeconds - 1,
      );
    } else {
      _handleSessionComplete();
    }
  }

  void _handleSessionComplete() {
    int newSessionsCompleted = state.sessionsCompleted;
    TimerMode newMode;

    if (state.mode == TimerMode.focus) {
      newSessionsCompleted++;
      newMode = (newSessionsCompleted % 4 == 0)
          ? TimerMode.longBreak
          : TimerMode.shortBreak;
    } else {
      newMode = TimerMode.focus;
    }

    final settings = _settingsValue.value;
    int newSeconds;

    switch (newMode) {
      case TimerMode.focus:
        newSeconds = (settings?.pomodoroDuration ?? 25) * 60;
        break;
      case TimerMode.shortBreak:
        newSeconds = (settings?.shortBreakDuration ?? 5) * 60;
        break;
      case TimerMode.longBreak:
        newSeconds = (settings?.longBreakDuration ?? 15) * 60;
        break;
    }

    state = state.copyWith(
      remainingSeconds: newSeconds,
      initialSeconds: newSeconds,
      sessionsCompleted: newSessionsCompleted,
      mode: newMode,
      status: TimerStatus.running,
    );
  }

  void start() {
    if (state.status == TimerStatus.running) return;

    state = state.copyWith(status: TimerStatus.running);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _onTick();
    });
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(status: TimerStatus.paused);
  }

  void reset() {
    _timer?.cancel();
    _timer = null;

    final settings = _settingsValue.value;
    final int resetSeconds = (settings?.pomodoroDuration ?? 25) * 60;

    state = TimerState(
      remainingSeconds: resetSeconds,
      initialSeconds: resetSeconds,
      sessionsCompleted: 0,
      mode: TimerMode.focus,
      status: TimerStatus.idle,
    );
  }
}

final timerViewModelProvider = NotifierProvider<TimerViewmodel, TimerState>(
  () => TimerViewmodel(),
);
