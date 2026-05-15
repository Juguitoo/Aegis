import 'package:aegis/core/utils/adaptive_interval_calculator.dart';
import 'package:aegis/core/utils/native_app_monitor.dart';
import 'package:aegis/data/repositories/blacklist_repository.dart';
import 'package:aegis/data/repositories/sessions_repository.dart';
import 'package:aegis/data/repositories/task_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:aegis/presentation/viewmodels/timer_state.dart';
import 'package:aegis/presentation/viewmodels/timer_viewmodel.dart';
import 'package:aegis/presentation/viewmodels/settings_viewmodel.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/core/services/notification_service.dart';
import 'package:aegis/core/providers/repository_providers.dart';
import 'package:mocktail/mocktail.dart';

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

class FakeTaskRepository implements TaskRepository {
  Task? lastUpdatedTask;

  @override
  Future<bool> updateTaskBasic(Task task) async {
    lastUpdatedTask = task;
    return true;
  }

  @override
  Future<int> deleteTask(Task task) {
    throw UnimplementedError();
  }

  @override
  Future<int> deleteTaskById(int id) {
    throw UnimplementedError();
  }

  @override
  Future<List<Subtask>> getSubtasksForTask(int taskId) {
    throw UnimplementedError();
  }

  @override
  Future<List<int>> getTagIdsForTask(int taskId) {
    throw UnimplementedError();
  }

  @override
  Future<int> insertTask(TasksCompanion task,
      {List<int> tagIds = const [],
      List<SubtasksCompanion> subtasks = const []}) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateTask(Task task,
      {List<int> tagIds = const [],
      List<SubtasksCompanion> subtasks = const []}) {
    throw UnimplementedError();
  }

  @override
  Stream<List<Task>> watchAllTasks() {
    throw UnimplementedError();
  }

  @override
  Stream<List<Subtask>> watchSubtasksForTask(int taskId) {
    throw UnimplementedError();
  }

  @override
  Stream<List<int>> watchTagIdsForTask(int taskId) {
    throw UnimplementedError();
  }
}

class FakeSessionRepository implements SessionRepository {
  @override
  Future<int> insertSession(FocusSessionsCompanion session) async {
    return 1;
  }

  @override
  Future<List<FocusSession>> getLast30FocusSessions() async {
    return [];
  }

  @override
  Future<void> deleteAllSessions() async {
    return;
  }
}

class MockNativeAppMonitor extends Mock implements NativeAppMonitor {}

class MockBlacklistRepository extends Mock implements BlacklistRepository {}

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(const Duration(seconds: 1));
  });

  late FakeTaskRepository fakeTaskRepo;
  late FakeSessionRepository fakeSessionRepo;
  late MockNativeAppMonitor mockMonitor;
  late MockBlacklistRepository mockBlacklistRepo;
  late MockNotificationService mockNotificationService;

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        settingsViewModelProvider.overrideWith(() => MockSettingsViewmodel()),
        taskRepositoryProvider.overrideWithValue(fakeTaskRepo),
        sessionRepositoryProvider.overrideWithValue(fakeSessionRepo),
        adaptiveCalculatorProvider
            .overrideWithValue(AdaptiveIntervalCalculator()),
        audioPlayerProvider.overrideWith((ref) => null),
        nativeAppMonitorProvider.overrideWithValue(mockMonitor),
        blacklistRepositoryProvider.overrideWithValue(mockBlacklistRepo),
        notificationServiceProvider.overrideWithValue(mockNotificationService),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    fakeTaskRepo = FakeTaskRepository();
    fakeSessionRepo = FakeSessionRepository();
    mockMonitor = MockNativeAppMonitor();
    mockBlacklistRepo = MockBlacklistRepository();
    mockNotificationService = MockNotificationService();

    when(() => mockMonitor.onAppChanged)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockMonitor.startMonitoring(interval: any(named: 'interval')))
        .thenAnswer((_) {});
    when(() => mockMonitor.stopMonitoring()).thenAnswer((_) {});
    when(() => mockBlacklistRepo.getBlacklistedPackages())
        .thenAnswer((_) async => ['com.evil.app']);
    when(() => mockNotificationService.showImmediateNotification(any(), any(),
        payload: any(named: 'payload'))).thenAnswer((_) async {});
  });

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

    test(
        'assignTask debe actualizar la tarea asignada y resetear el temporizador',
        () {
      final container = createContainer();
      final dummyTask = Task(
        id: 1,
        title: 'Tarea de prueba',
        description: 'Descripción de prueba',
        priority: 1,
        estimatedDuration: 1500,
        actualDuration: 0,
        completedAt: null,
      );
      final notifier = container.read(timerViewModelProvider.notifier);

      notifier.assignTask(dummyTask);
      final state = container.read(timerViewModelProvider);

      expect(state.assignedTask, isNotNull);
      expect(state.assignedTask!.id, dummyTask.id);
      expect(state.status, TimerStatus.idle);
    });

    test(
        'completeAssignedTask debe marcar la tarea como completada, guardar el progreso y limpiar el estado',
        () {
      final container = createContainer();
      final dummyTask = Task(
        id: 1,
        title: 'Tarea de prueba',
        description: 'Descripción de prueba',
        priority: 1,
        estimatedDuration: 1500,
        actualDuration: 0,
        completedAt: null,
      );
      final notifier = container.read(timerViewModelProvider.notifier);

      notifier.assignTask(dummyTask);

      notifier.start();

      container.read(timerViewModelProvider.notifier).state =
          container.read(timerViewModelProvider).copyWith(
                remainingSeconds: 1400,
              );

      notifier.completeAssignedTask();

      final state = container.read(timerViewModelProvider);

      expect(state.assignedTask, isNull);
      expect(state.status, TimerStatus.idle);

      expect(fakeTaskRepo.lastUpdatedTask, isNotNull);
      expect(fakeTaskRepo.lastUpdatedTask!.completedAt, isNotNull);
      expect(fakeTaskRepo.lastUpdatedTask!.actualDuration, 100);
    });

    test('clearAssignedTask debe quitar la tarea sin guardarla como completada',
        () {
      final container = createContainer();
      final dummyTask = Task(
        id: 1,
        title: 'Tarea de prueba',
        description: 'Descripción de prueba',
        priority: 1,
        estimatedDuration: 1500,
        actualDuration: 0,
        completedAt: null,
      );
      final notifier = container.read(timerViewModelProvider.notifier);

      notifier.assignTask(dummyTask);
      notifier.clearAssignedTask();

      final state = container.read(timerViewModelProvider);

      expect(state.assignedTask, isNull);
    });

    test('updateAssignedTask actualiza la tarea si los IDs coinciden', () {
      final container = createContainer();
      final dummyTask = Task(
        id: 1,
        title: 'Tarea 1',
        description: '',
        priority: 1,
        estimatedDuration: 1500,
        actualDuration: 0,
      );

      final updatedTask = Task(
        id: 1,
        title: 'Tarea 1 Actualizada',
        description: '',
        priority: 1,
        estimatedDuration: 1500,
        actualDuration: 0,
      );

      final notifier = container.read(timerViewModelProvider.notifier);

      notifier.assignTask(dummyTask);
      notifier.updateAssignedTask(updatedTask);

      final state = container.read(timerViewModelProvider);
      expect(state.assignedTask!.title, 'Tarea 1 Actualizada');
    });

    test('registerBlocklistAttempt incrementa el contador si esta corriendo',
        () {
      final container = createContainer();
      final notifier = container.read(timerViewModelProvider.notifier);

      notifier.start();
      notifier.registerBlocklistAttempt();

      final state = container.read(timerViewModelProvider);
      expect(state.blocklistAttempts, 1);
    });

    test('toggleDynamicMode cambia el estado del modo dinamico', () {
      final container = createContainer();
      final notifier = container.read(timerViewModelProvider.notifier);

      expect(
          container.read(timerViewModelProvider).isDynamicModeActive, isFalse);

      notifier.toggleDynamicMode();

      expect(
          container.read(timerViewModelProvider).isDynamicModeActive, isTrue);
    });

    test('acceptSuggestion aplica el modo sugerido y arranca el timer', () {
      final container = createContainer();
      final notifier = container.read(timerViewModelProvider.notifier);

      final suggestion = SuggestionResult(
          suggestedMode: TimerMode.longBreak,
          suggestedDurationSeconds: 1200,
          fallbackMode: TimerMode.shortBreak,
          fallbackDurationSeconds: 300,
          reason: "Descanso sugerido");

      container.read(timerViewModelProvider.notifier).state = container
          .read(timerViewModelProvider)
          .copyWith(pendingSuggestion: suggestion);

      notifier.acceptSuggestion();

      final state = container.read(timerViewModelProvider);
      expect(state.mode, TimerMode.longBreak);
      expect(state.remainingSeconds, 1200);
      expect(state.status, TimerStatus.running);
      expect(state.pendingSuggestion, isNull);
    });

    test('rejectSuggestion aplica el modo fallback y arranca el timer', () {
      final container = createContainer();
      final notifier = container.read(timerViewModelProvider.notifier);

      final suggestion = SuggestionResult(
          suggestedMode: TimerMode.longBreak,
          suggestedDurationSeconds: 1200,
          fallbackMode: TimerMode.shortBreak,
          fallbackDurationSeconds: 300,
          reason: "Descanso sugerido");

      container.read(timerViewModelProvider.notifier).state = container
          .read(timerViewModelProvider)
          .copyWith(pendingSuggestion: suggestion);

      notifier.rejectSuggestion();

      final state = container.read(timerViewModelProvider);
      expect(state.mode, TimerMode.shortBreak);
      expect(state.remainingSeconds, 300);
      expect(state.status, TimerStatus.running);
      expect(state.pendingSuggestion, isNull);
    });

    test('_handleForegroundAppChange dispara provider si app está en blacklist',
        () async {
      final streamController = StreamController<String>();
      when(() => mockMonitor.onAppChanged)
          .thenAnswer((_) => streamController.stream);

      final container = createContainer();
      final notifier = container.read(timerViewModelProvider.notifier);

      notifier.start();

      streamController.add('com.evil.app');

      await Future.delayed(const Duration(milliseconds: 50));

      final triggeredApp = container.read(blockedAppTriggerProvider);
      expect(triggeredApp, 'com.evil.app');

      await streamController.close();
    });

    test('_handleSessionComplete avanza modo de focus a short break', () async {
      final container = createContainer();
      final notifier = container.read(timerViewModelProvider.notifier);

      container.read(timerViewModelProvider.notifier).state = container
          .read(timerViewModelProvider)
          .copyWith(remainingSeconds: 0, status: TimerStatus.running);

      notifier.didChangeAppLifecycleState(AppLifecycleState.paused);
      notifier.didChangeAppLifecycleState(AppLifecycleState.resumed);

      final state = container.read(timerViewModelProvider);

      expect(state.mode, TimerMode.shortBreak);
      expect(state.sessionsCompleted, 1);
    });
  });
}
