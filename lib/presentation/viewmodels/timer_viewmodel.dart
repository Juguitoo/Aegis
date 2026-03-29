import 'dart:async';
import 'package:aegis/core/providers/repository_providers.dart';
import 'package:aegis/core/utils/adaptive_interval_calculator.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'timer_state.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/presentation/viewmodels/settings_viewmodel.dart';

final audioPlayerProvider = Provider<AudioPlayer?>((ref) {
  return AudioPlayer();
});

class TimerViewmodel extends Notifier<TimerState> with WidgetsBindingObserver {
  AudioPlayer? _audioPlayer;
  Timer? _timer;
  DateTime? _pausedTime;
  DateTime? _manualPauseTime;

  AsyncValue<Setting?> get _settingsValue =>
      ref.watch(settingsViewModelProvider);

  dynamic get _taskRepository => ref.read(taskRepositoryProvider);
  dynamic get _sessionRepository => ref.read(sessionRepositoryProvider);
  AdaptiveIntervalCalculator get _calculator =>
      ref.read(adaptiveCalculatorProvider);

  @override
  TimerState build() {
    _audioPlayer = ref.read(audioPlayerProvider);
    WidgetsBinding.instance.addObserver(this);

    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      _timer?.cancel();
      _audioPlayer?.dispose();
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
        assignedTask: null,
        isDynamicModeActive: false,
        pauseCount: 0,
        totalPauseDuration: 0,
        addedTime: 0,
        blocklistAttempts: 0,
        pendingSuggestion: null,
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

  void _saveSessionRecord() {
    final int actualSeconds = state.initialSeconds - state.remainingSeconds;

    if (actualSeconds > 0) {
      final session = FocusSessionsCompanion(
        mode: Value(state.mode.toString()),
        actualSeconds: Value(actualSeconds),
        pauseCount: Value(state.pauseCount),
        pauseDuration: Value(state.totalPauseDuration),
        extraTimeAdded: Value(state.addedTime),
        blocklistAttempts: Value(state.blocklistAttempts),
        createdAt: Value(DateTime.now()),
      );
      _sessionRepository.insertSession(session);
    }
  }

  Future<void> _handleSessionComplete() async {
    _saveCurrentProgress();
    _saveSessionRecord();

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
    int baseSeconds;

    switch (newMode) {
      case TimerMode.focus:
        baseSeconds = (settings?.pomodoroDuration ?? 25) * 60;
        break;
      case TimerMode.shortBreak:
        baseSeconds = (settings?.shortBreakDuration ?? 5) * 60;
        break;
      case TimerMode.longBreak:
        baseSeconds = (settings?.longBreakDuration ?? 15) * 60;
        break;
    }

    if (state.isDynamicModeActive) {
      final recentSessions = await _sessionRepository.getLast30FocusSessions();
      final interruptions = state.pauseCount + state.blocklistAttempts;
      final isCompleted = state.assignedTask?.isCompleted ?? false;

      final suggestion = _calculator.calculateNextInterval(
        currentMode: state.mode,
        standardNextMode: newMode,
        baseSeconds: baseSeconds,
        recentSessions: recentSessions,
        currentSessionInterruptions: interruptions,
        isTaskCompleted: isCompleted,
      );

      if (suggestion != null) {
        state = state.copyWith(
          status: TimerStatus.idle,
          sessionsCompleted: newSessionsCompleted,
          pauseCount: 0,
          totalPauseDuration: 0,
          addedTime: 0,
          blocklistAttempts: 0,
          pendingSuggestion: suggestion,
        );
        return;
      }
    }

    state = state.copyWith(
      remainingSeconds: baseSeconds,
      initialSeconds: baseSeconds,
      sessionsCompleted: newSessionsCompleted,
      mode: newMode,
      status: TimerStatus.running,
      pauseCount: 0,
      totalPauseDuration: 0,
      addedTime: 0,
      blocklistAttempts: 0,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _onTick());
  }

  void acceptSuggestion() {
    final suggestion = state.pendingSuggestion;
    if (suggestion == null) return;

    state = state.copyWith(
      mode: suggestion.suggestedMode,
      remainingSeconds: suggestion.suggestedDurationSeconds,
      initialSeconds: suggestion.suggestedDurationSeconds,
      status: TimerStatus.running,
      pendingSuggestion: null,
      clearSuggestion: true,
    );

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _onTick());
  }

  void rejectSuggestion() {
    final suggestion = state.pendingSuggestion;
    if (suggestion == null) return;

    state = state.copyWith(
      mode: suggestion.fallbackMode,
      remainingSeconds: suggestion.fallbackDurationSeconds,
      initialSeconds: suggestion.fallbackDurationSeconds,
      status: TimerStatus.running,
      pendingSuggestion: null,
      clearSuggestion: true,
    );

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _onTick());
  }

  void start() {
    if (state.status == TimerStatus.running) return;

    int extraPause = 0;
    if (_manualPauseTime != null) {
      extraPause = DateTime.now().difference(_manualPauseTime!).inSeconds;
      _manualPauseTime = null;
    }

    state = state.copyWith(
      status: TimerStatus.running,
      totalPauseDuration: state.totalPauseDuration + extraPause,
    );

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _onTick();
    });
  }

  void pause() {
    _timer?.cancel();
    _pausedTime = null;
    _manualPauseTime = DateTime.now();

    state = state.copyWith(
      status: TimerStatus.paused,
      pauseCount: state.pauseCount + 1,
    );
  }

  void reset() {
    _saveSessionRecord();
    _timer?.cancel();
    _timer = null;
    _pausedTime = null;
    _manualPauseTime = null;

    final settings = _settingsValue.value;
    final int resetSeconds = (settings?.pomodoroDuration ?? 25) * 60;

    state = state.copyWith(
      remainingSeconds: resetSeconds,
      initialSeconds: resetSeconds,
      sessionsCompleted: 0,
      mode: TimerMode.focus,
      status: TimerStatus.idle,
      assignedTask: state.assignedTask,
      pauseCount: 0,
      totalPauseDuration: 0,
      addedTime: 0,
      blocklistAttempts: 0,
      pendingSuggestion: null,
      clearSuggestion: true,
    );
  }

  void add5Minutes() {
    state = state.copyWith(
      remainingSeconds: state.remainingSeconds + 300,
      initialSeconds: state.initialSeconds + 300,
      addedTime: state.addedTime + 300,
    );
  }

  void toggleDynamicMode() {
    state = state.copyWith(isDynamicModeActive: !state.isDynamicModeActive);
  }

  void registerBlocklistAttempt() {
    if (state.status == TimerStatus.running) {
      state = state.copyWith(blocklistAttempts: state.blocklistAttempts + 1);
    }
  }

  Future<void> _playSound() async {
    await _audioPlayer?.play(AssetSource('audio/ding.mp3'));
  }

  void assignTask(Task task) {
    if (state.assignedTask?.id == task.id) return;

    if (state.assignedTask != null) {
      _saveCurrentProgress();
    }

    state = state.copyWith(assignedTask: task, clearTask: false);
    reset();
  }

  void clearAssignedTask() {
    state = state.copyWith(clearTask: true);
  }

  void _saveCurrentProgress() {
    if (state.mode == TimerMode.focus && state.assignedTask != null) {
      final int secondsInvested = state.initialSeconds - state.remainingSeconds;

      if (secondsInvested > 0) {
        final task = state.assignedTask!;
        final updatedDuration = (task.actualDuration ?? 0) + secondsInvested;

        final updatedTask =
            task.copyWith(actualDuration: Value(updatedDuration));

        _taskRepository.updateTaskBasic(updatedTask);
        state = state.copyWith(assignedTask: updatedTask);
      }
    }
  }

  void completeAssignedTask() {
    if (state.assignedTask != null) {
      _saveCurrentProgress();
      _saveSessionRecord();

      final task = state.assignedTask!;
      final updatedTask = task.copyWith(isCompleted: true);
      _taskRepository.updateTaskBasic(updatedTask);
      state = state.copyWith(assignedTask: updatedTask);
    }

    _timer?.cancel();
    _timer = null;
    _pausedTime = null;
    _manualPauseTime = null;

    final settings = _settingsValue.value;
    final int resetSeconds = (settings?.pomodoroDuration ?? 25) * 60;

    state = state.copyWith(
      remainingSeconds: resetSeconds,
      initialSeconds: resetSeconds,
      sessionsCompleted: 0,
      mode: TimerMode.focus,
      status: TimerStatus.idle,
      assignedTask: null,
      clearTask: true,
      pauseCount: 0,
      totalPauseDuration: 0,
      addedTime: 0,
      blocklistAttempts: 0,
      pendingSuggestion: null,
      clearSuggestion: true,
    );
  }
}

final timerViewModelProvider = NotifierProvider<TimerViewmodel, TimerState>(
  () => TimerViewmodel(),
);
