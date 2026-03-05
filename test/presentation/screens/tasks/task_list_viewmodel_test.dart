import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/data/repositories/task_repository.dart';
import 'package:aegis/core/providers/repository_providers.dart';
import 'package:aegis/presentation/viewmodels/task_list_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeTaskRepository implements TaskRepository {
  @override
  Stream<List<Task>> watchAllTasks() async* {
    yield [
      Task(
        id: 1,
        title: 'Tarea Bandeja',
        description: null,
        estimatedDuration: 10,
        priority: 0,
        isCompleted: false,
        projectId: null,
      ),
      Task(
        id: 2,
        title: 'Tarea Proyecto Universidad',
        description: null,
        estimatedDuration: 20,
        priority: 1,
        isCompleted: false,
        projectId: 99,
      ),
    ];
  }

  // Métodos vacíos necesarios para cumplir con el contrato de la interfaz
  @override
  Future<int> insertTask(TasksCompanion task) async => 1;
  @override
  Future<bool> updateTask(Task task) async => true;
  @override
  Future<int> deleteTask(Task task) async => 1;
  @override
  Future<int> deleteTaskById(int id) async => 1;

  @override
  Future<List<Task>> getAllTasks() async => [
        Task(
          id: 1,
          title: 'Tarea Bandeja',
          description: null,
          estimatedDuration: 10,
          priority: 0,
          isCompleted: false,
          projectId: null,
        ),
        Task(
          id: 2,
          title: 'Tarea Proyecto Universidad',
          description: null,
          estimatedDuration: 20,
          priority: 1,
          isCompleted: false,
          projectId: 99,
        ),
      ];

  @override
  Future<Task> getTaskById(int id) async => Task(
        id: id,
        title: 'Tarea de prueba',
        description: null,
        estimatedDuration: 15,
        priority: 1,
        isCompleted: false,
        projectId: null,
      );
}

void main() {
  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(FakeTaskRepository()),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('El ViewModel muestra todas las tareas si no hay filtro de proyecto',
      () async {
    final container = createContainer();

    final subscription = container.listen(
      taskListViewModelProvider,
      (_, __) {},
    );

    final tasks = await container.read(taskListViewModelProvider.future);

    expect(tasks.length, 2);
    expect(tasks[0].title, 'Tarea Bandeja');
    expect(tasks[1].title, 'Tarea Proyecto Universidad');

    subscription.close();
  });

  test('El ViewModel filtra correctamente por Bandeja de entrada (id: -1)',
      () async {
    final container = createContainer();

    final subscription = container.listen(
      taskListViewModelProvider,
      (_, __) {},
    );

    // Cambiamos el estado del filtro a "Bandeja de entrada"
    container.read(projectFilterProvider.notifier).state = -1;

    // Leemos el resultado filtrado
    final filteredTasks =
        await container.read(taskListViewModelProvider.future);

    expect(filteredTasks.length, 1);
    expect(filteredTasks.first.title, 'Tarea Bandeja');
    expect(filteredTasks.first.projectId, isNull);

    subscription.close();
  });

  test('El ViewModel filtra correctamente por un ID de proyecto especifico',
      () async {
    final container = createContainer();

    final subscription = container.listen(
      taskListViewModelProvider,
      (_, __) {},
    );

    // Cambiamos el estado del filtro al proyecto 99
    container.read(projectFilterProvider.notifier).state = 99;

    // Leemos el resultado filtrado
    final filteredTasks =
        await container.read(taskListViewModelProvider.future);

    expect(filteredTasks.length, 1);
    expect(filteredTasks.first.title, 'Tarea Proyecto Universidad');
    expect(filteredTasks.first.projectId, 99);

    subscription.close();
  });
}
