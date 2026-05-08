import 'package:aegis/core/utils/adaptive_interval_calculator.dart';
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
import 'package:aegis/core/providers/repository_providers.dart';

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeTaskRepository fakeTaskRepo;
  late FakeSessionRepository fakeSessionRepo;

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        settingsViewModelProvider.overrideWith(() => MockSettingsViewmodel()),
        taskRepositoryProvider.overrideWithValue(fakeTaskRepo),
        sessionRepositoryProvider.overrideWithValue(fakeSessionRepo),
        adaptiveCalculatorProvider
            .overrideWithValue(AdaptiveIntervalCalculator()),
        audioPlayerProvider.overrideWith((ref) => null),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    fakeTaskRepo = FakeTaskRepository();
    fakeSessionRepo = FakeSessionRepository();
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
  });
}
