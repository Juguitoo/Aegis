import 'package:aegis/data/repositories/task_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/repository_providers.dart';
import '../../data/local/database/app_database.dart';

class TaskListViewModel extends StreamNotifier<List<Task>> {
  TaskRepository get _repository => ref.read(taskRepositoryProvider);

  @override
  Stream<List<Task>> build() {
    return ref.watch(taskRepositoryProvider).watchAllTasks();
  }

  Future<int> addTask(TasksCompanion task) {
    return _repository.insertTask(task);
  }

  Future<bool> updateTask(Task task) {
    return _repository.updateTask(task);
  }

  Future<int> deleteTask(Task task) {
    return _repository.deleteTask(task);
  }

  Future<int> deleteTaskById(int id) {
    return _repository.deleteTaskById(id);
  }

  Future<bool> toggleTaskCompletion(Task task) {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    return _repository.updateTask(updatedTask);
  }
}

final taskListViewModelProvider =
    StreamNotifierProvider<TaskListViewModel, List<Task>>(() {
  return TaskListViewModel();
});
