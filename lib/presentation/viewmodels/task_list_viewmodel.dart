import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/repository_providers.dart';
import '../../data/local/database/app_database.dart';

class TaskListViewModel extends StreamNotifier<List<Task>> {
  @override
  Stream<List<Task>> build() {
    final taskRepository = ref.watch(taskRepositoryProvider);
    return taskRepository.watchAllTasks();
  }

  Future<void> addTask(TasksCompanion task) async {
    final taskRepository = ref.read(taskRepositoryProvider);
    await taskRepository.insertTask(task);
  }

  Future<void> updateTask(Task task) async {
    final taskRepository = ref.read(taskRepositoryProvider);
    await taskRepository.updateTask(task);
  }

  Future<void> deleteTask(Task task) async {
    final taskRepository = ref.read(taskRepositoryProvider);
    await taskRepository.deleteTask(task);
  }

  Future<void> deleteTaskById(int id) async {
    final taskRepository = ref.read(taskRepositoryProvider);
    await taskRepository.deleteTaskById(id);
  }

  Future<void> toggleTaskCompletion(Task task) async {
    final taskRepository = ref.read(taskRepositoryProvider);
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await taskRepository.updateTask(updatedTask);
  }
}

final taskListViewModelProvider =
    StreamNotifierProvider<TaskListViewModel, List<Task>>(() {
  return TaskListViewModel();
});
