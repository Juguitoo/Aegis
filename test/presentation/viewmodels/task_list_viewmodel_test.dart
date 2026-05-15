import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/data/repositories/task_repository.dart';
import 'package:aegis/presentation/viewmodels/task_list_viewmodel.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/core/providers/repository_providers.dart';
import 'package:aegis/core/services/notification_service.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

class MockNotificationService extends Mock implements NotificationService {}

class FakeTask extends Fake implements Task {}

class FakeTasksCompanion extends Fake implements TasksCompanion {}

void main() {
  late MockTaskRepository mockRepository;
  late MockNotificationService mockNotificationService;
  late ProviderContainer container;
  ProviderSubscription? subscription;

  final task1 =
      Task(id: 1, title: 'Tarea 1', completedAt: null, priority: 0, areaId: 1);
  final task2 =
      Task(id: 2, title: 'Tarea 2', completedAt: null, priority: 0, areaId: 1);
  final task3 =
      Task(id: 3, title: 'Tarea 3', completedAt: null, priority: 0, areaId: 2);
  final task4 = Task(
      id: 4,
      title: 'Bandeja Entrada',
      completedAt: null,
      priority: 0,
      areaId: null);

  setUpAll(() {
    registerFallbackValue(FakeTask());
    registerFallbackValue(FakeTasksCompanion());
    registerFallbackValue(<int>[]);
    registerFallbackValue(<SubtasksCompanion>[]);
  });

  setUp(() {
    mockRepository = MockTaskRepository();
    mockNotificationService = MockNotificationService();

    when(() => mockNotificationService.cancelNotification(any()))
        .thenAnswer((_) async {});

    when(() => mockNotificationService.scheduleNotification(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          payload: any(named: 'payload'),
        )).thenAnswer((_) async {});

    when(() => mockRepository.watchAllTasks()).thenAnswer((_) =>
        Stream.fromFuture(
            Future.microtask(() => [task1, task2, task3, task4])));

    when(() => mockRepository.getTagIdsForTask(1))
        .thenAnswer((_) async => [1, 2]);
    when(() => mockRepository.getTagIdsForTask(2))
        .thenAnswer((_) async => [2, 3]);
    when(() => mockRepository.getTagIdsForTask(3)).thenAnswer((_) async => [1]);
    when(() => mockRepository.getTagIdsForTask(4)).thenAnswer((_) async => []);

    container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(mockRepository),
        notificationServiceProvider.overrideWithValue(mockNotificationService),
      ],
    );

    subscription = container.listen(taskListViewModelProvider, (_, __) {});
  });

  tearDown(() {
    subscription?.close();
    container.dispose();
  });

  group('TaskListViewModel Filters', () {
    test('Debe devolver todas las tareas si no hay filtros activos', () async {
      final tasks = await container.read(taskListViewModelProvider.future);
      expect(tasks.length, 4);
    });

    test('Debe filtrar por proyecto especifico', () async {
      container.read(areaFilterProvider.notifier).state = 1;
      final tasks = await container.read(taskListViewModelProvider.future);
      expect(tasks.length, 2);
      expect(tasks.map((t) => t.id), containsAll([1, 2]));
    });

    test('Debe filtrar por bandeja de entrada (areaId == null)', () async {
      container.read(areaFilterProvider.notifier).state = -1;
      final tasks = await container.read(taskListViewModelProvider.future);
      expect(tasks.length, 1);
      expect(tasks.first.id, 4);
    });

    test('Debe filtrar por etiquetas usando logica ANY (OR)', () async {
      container.read(tagFilterProvider.notifier).state = [3];
      final tasks = await container.read(taskListViewModelProvider.future);
      expect(tasks.length, 1);
      expect(tasks.first.id, 2);
    });

    test(
        'Debe devolver tareas que tengan al menos una etiqueta de varias seleccionadas',
        () async {
      container.read(tagFilterProvider.notifier).state = [2, 3];
      final tasks = await container.read(taskListViewModelProvider.future);
      expect(tasks.length, 2);
      expect(tasks.map((t) => t.id), containsAll([1, 2]));
    });

    test('Debe combinar filtro de proyecto y etiquetas (logica AND)', () async {
      container.read(areaFilterProvider.notifier).state = 2;
      container.read(tagFilterProvider.notifier).state = [1];
      final tasks = await container.read(taskListViewModelProvider.future);
      expect(tasks.length, 1);
      expect(tasks.first.id, 3);
    });
  });

  group('TaskListViewModel Methods (addTask, updateTask, delete)', () {
    test('Debe fabricar los Companions y llamar al repositorio al añadir tarea',
        () async {
      when(() => mockRepository.insertTask(
            any(),
            tagIds: any(named: 'tagIds'),
            subtasks: any(named: 'subtasks'),
          )).thenAnswer((_) async => 5);

      await container.read(taskListViewModelProvider.notifier).addTask(
        title: 'Nueva Tarea',
        priority: 1,
        tagIds: [1, 2],
        checklist: [TaskChecklistItem(title: 'Primer paso')],
      );

      final captured = verify(() => mockRepository.insertTask(
            captureAny(),
            tagIds: captureAny(named: 'tagIds'),
            subtasks: captureAny(named: 'subtasks'),
          )).captured;

      final taskCompanion = captured[0] as TasksCompanion;
      final tagsPassed = captured[1] as List<int>;
      final subtasksPassed = captured[2] as List<SubtasksCompanion>;

      expect(taskCompanion.title.value, 'Nueva Tarea');
      expect(tagsPassed, [1, 2]);
      expect(subtasksPassed.length, 1);
      expect(subtasksPassed.first.title.value, 'Primer paso');
      expect(subtasksPassed.first.position.value, 0);
    });

    test('addTask debe agendar notificación si se proporciona una fecha futura',
        () async {
      when(() => mockRepository.insertTask(
            any(),
            tagIds: any(named: 'tagIds'),
            subtasks: any(named: 'subtasks'),
          )).thenAnswer((_) async => 5);

      final futureDate = DateTime.now().add(const Duration(days: 1));

      await container.read(taskListViewModelProvider.notifier).addTask(
            title: 'Nueva Tarea',
            description: '',
            notificationAt: futureDate,
          );

      verify(() => mockNotificationService.scheduleNotification(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: 'Tienes una tarea pendiente programada',
            scheduledDate: futureDate,
            payload: any(named: 'payload'),
          )).called(1);
    });

    test(
        'updateTask actualiza y cancela notificación si la tarea está completada o no tiene fecha',
        () async {
      when(() => mockRepository.updateTask(
            any(),
            tagIds: any(named: 'tagIds'),
            subtasks: any(named: 'subtasks'),
          )).thenAnswer((_) async {});

      final completedTask = task1.copyWith(completedAt: Value(DateTime.now()));

      await container.read(taskListViewModelProvider.notifier).updateTask(
        task: completedTask,
        tagIds: [1],
        checklist: [TaskChecklistItem(title: 'Subtarea', id: 1)],
      );

      verify(() => mockRepository.updateTask(
            completedTask,
            tagIds: [1],
            subtasks: any(named: 'subtasks'),
          )).called(1);

      verify(() => mockNotificationService.cancelNotification(any())).called(1);
    });

    test(
        'updateTask actualiza y agenda notificación si la tarea está pendiente y tiene fecha futura',
        () async {
      when(() => mockRepository.updateTask(
            any(),
            tagIds: any(named: 'tagIds'),
            subtasks: any(named: 'subtasks'),
          )).thenAnswer((_) async {});

      final futureDate = DateTime.now().add(const Duration(days: 1));
      final taskWithNotif = task1.copyWith(
        completedAt: const Value(null),
        notificationAt: Value(futureDate),
        description: const Value('Descripción test'),
      );

      await container.read(taskListViewModelProvider.notifier).updateTask(
            task: taskWithNotif,
          );

      verify(() => mockNotificationService.scheduleNotification(
            id: any(named: 'id'),
            title: '📋 Tarea: Tarea 1',
            body: 'Descripción test',
            scheduledDate: futureDate,
            payload: any(named: 'payload'),
          )).called(1);
    });

    test('Debe llamar al repositorio al eliminar una tarea', () async {
      when(() => mockRepository.deleteTask(any())).thenAnswer((_) async => 1);

      await container
          .read(taskListViewModelProvider.notifier)
          .deleteTask(task1);

      verify(() => mockRepository.deleteTask(task1)).called(1);
      verify(() => mockNotificationService.cancelNotification(any())).called(1);
    });

    test('Debe llamar al repositorio en getTagsForTask y deleteTaskById',
        () async {
      when(() => mockRepository.getTagIdsForTask(1))
          .thenAnswer((_) async => [10, 20]);
      when(() => mockRepository.deleteTaskById(1)).thenAnswer((_) async => 1);

      final tags = await container
          .read(taskListViewModelProvider.notifier)
          .getTagsForTask(1);
      expect(tags, [10, 20]);

      await container
          .read(taskListViewModelProvider.notifier)
          .deleteTaskById(1);
      verify(() => mockRepository.deleteTaskById(1)).called(1);
      verify(() => mockNotificationService.cancelNotification(any())).called(1);
    });
  });

  group('TaskListViewModel toggleTaskCompletion', () {
    test('Debe hacer toggle de isCompleted y actualizar usando updateTaskBasic',
        () async {
      when(() => mockRepository.updateTaskBasic(any()))
          .thenAnswer((_) async => true);

      await container
          .read(taskListViewModelProvider.notifier)
          .toggleTaskCompletion(task1);

      final captured =
          verify(() => mockRepository.updateTaskBasic(captureAny())).captured;
      final updatedTask = captured.first as Task;

      expect(updatedTask.completedAt, isNotNull);
    });

    test(
        'Al marcar como completada (toggle de pendiente a completada), debe cancelar la notificación',
        () async {
      when(() => mockRepository.updateTaskBasic(any()))
          .thenAnswer((_) async => true);

      await container
          .read(taskListViewModelProvider.notifier)
          .toggleTaskCompletion(task1);

      verify(() => mockNotificationService.cancelNotification(any())).called(1);
    });

    test(
        'Al marcar como pendiente (toggle de completada a pendiente), debe agendar si hay fecha futura',
        () async {
      when(() => mockRepository.updateTaskBasic(any()))
          .thenAnswer((_) async => true);

      final futureDate = DateTime.now().add(const Duration(days: 1));

      final completedTaskWithNotif = task1.copyWith(
        completedAt: Value(DateTime.now()),
        notificationAt: Value(futureDate),
      );

      await container
          .read(taskListViewModelProvider.notifier)
          .toggleTaskCompletion(completedTaskWithNotif);

      verify(() => mockNotificationService.scheduleNotification(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            scheduledDate: futureDate,
            payload: any(named: 'payload'),
          )).called(1);
    });
  });
}
