import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'timer_state.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/presentation/viewmodels/settings_viewmodel.dart';

class TimerViewmodel extends Notifier<TimerState> with WidgetsBindingObserver {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;
  DateTime? _pausedTime;

  AsyncValue<Setting?> get _settingsValue =>
      ref.watch(settingsViewModelProvider);

  @override
  TimerState build() {
    WidgetsBinding.instance.addObserver(this);

    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      _timer?.cancel();
      _audioPlayer.dispose();
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState appState) {
    if (appState == AppLifecycleState.paused &&
        state.status == TimerStatus.running) {
      _pausedTime = DateTime.now();
    } else if (appState == AppLifecycleState.resumed) {
      if (_pausedTime != null && state.status == TimerStatus.running) {
        final elapsedSeconds =
            DateTime.now().difference(_pausedTime!).inSeconds;
        _pausedTime = null;

        final newRemaining = state.remainingSeconds - elapsedSeconds;

        if (newRemaining <= 0) {
          _timer?.cancel();
          state = state.copyWith(remainingSeconds: 0);
          _playSound();
          _handleSessionComplete();
        } else {
          state = state.copyWith(remainingSeconds: newRemaining);
        }
      }
    }
  }

  void _onTick() {
    if (state.remainingSeconds > 0) {
      state = state.copyWith(
        remainingSeconds: state.remainingSeconds - 1,
      );
    } else {
      _timer?.cancel();
      _playSound();
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

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _onTick());
  }

  void start() {
    if (state.status == TimerStatus.running) return;

    state = state.copyWith(status: TimerStatus.running);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _onTick();
    });
  }

  void pause() {
    _timer?.cancel();
    _pausedTime = null;
    state = state.copyWith(status: TimerStatus.paused);
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    _pausedTime = null;

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

  void add5Minutes() {
    state = state.copyWith(
      remainingSeconds: state.remainingSeconds + 300,
      initialSeconds: state.initialSeconds + 300,
    );
  }

  Future<void> _playSound() async {
    await _audioPlayer.play(AssetSource('audio/ding.mp3'));
  }
}

final timerViewModelProvider = NotifierProvider<TimerViewmodel, TimerState>(
  () => TimerViewmodel(),
);
