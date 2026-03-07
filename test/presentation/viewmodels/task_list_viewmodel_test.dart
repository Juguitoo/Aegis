import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/data/repositories/task_repository.dart';
import 'package:aegis/presentation/viewmodels/task_list_viewmodel.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/core/providers/repository_providers.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

class FakeTask extends Fake implements Task {}

class FakeTasksCompanion extends Fake implements TasksCompanion {}

void main() {
  late MockTaskRepository mockRepository;
  late ProviderContainer container;
  ProviderSubscription? subscription;

  final task1 = Task(
      id: 1, title: 'Tarea 1', isCompleted: false, priority: 0, projectId: 1);
  final task2 = Task(
      id: 2, title: 'Tarea 2', isCompleted: false, priority: 0, projectId: 1);
  final task3 = Task(
      id: 3, title: 'Tarea 3', isCompleted: false, priority: 0, projectId: 2);
  final task4 = Task(
      id: 4,
      title: 'Bandeja Entrada',
      isCompleted: false,
      priority: 0,
      projectId: null);

  setUpAll(() {
    registerFallbackValue(FakeTask());
    registerFallbackValue(FakeTasksCompanion());
  });

  setUp(() {
    mockRepository = MockTaskRepository();

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
      container.read(projectFilterProvider.notifier).state = 1;
      final tasks = await container.read(taskListViewModelProvider.future);
      expect(tasks.length, 2);
      expect(tasks.map((t) => t.id), containsAll([1, 2]));
    });

    test('Debe filtrar por bandeja de entrada (projectId == null)', () async {
      container.read(projectFilterProvider.notifier).state = -1;
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
      container.read(projectFilterProvider.notifier).state = 2;
      container.read(tagFilterProvider.notifier).state = [1];
      final tasks = await container.read(taskListViewModelProvider.future);
      expect(tasks.length, 1);
      expect(tasks.first.id, 3);
    });
  });

  group('TaskListViewModel Methods', () {
    test('Debe llamar al repositorio al añadir tarea con etiquetas', () async {
      final companion =
          const TasksCompanion(title: Value('Nueva'), priority: Value(0));
      when(() => mockRepository.insertTaskWithTags(any(), any()))
          .thenAnswer((_) async => 5);

      await container
          .read(taskListViewModelProvider.notifier)
          .addTaskWithTags(companion, [1, 2]);
      verify(() => mockRepository.insertTaskWithTags(companion, [1, 2]))
          .called(1);
    });

    test('Debe llamar al repositorio al eliminar una tarea', () async {
      when(() => mockRepository.deleteTask(any())).thenAnswer((_) async => 1);
      await container
          .read(taskListViewModelProvider.notifier)
          .deleteTask(task1);
      verify(() => mockRepository.deleteTask(task1)).called(1);
    });

    test('Debe hacer toggle de isCompleted y actualizar la tarea', () async {
      when(() => mockRepository.updateTask(any()))
          .thenAnswer((_) async => true);
      await container
          .read(taskListViewModelProvider.notifier)
          .toggleTaskCompletion(task1);

      final captured =
          verify(() => mockRepository.updateTask(captureAny())).captured;
      final updatedTask = captured.first as Task;
      expect(updatedTask.isCompleted, true);
    });
  });
}
