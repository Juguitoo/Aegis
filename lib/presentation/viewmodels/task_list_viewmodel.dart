import 'package:aegis/data/repositories/task_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/providers/repository_providers.dart';
import '../../data/local/database/app_database.dart';

final projectFilterProvider = StateProvider<int?>((ref) => null);

class TaskListViewModel extends StreamNotifier<List<Task>> {
  TaskRepository get _repository => ref.read(taskRepositoryProvider);

  @override
  Stream<List<Task>> build() {
    final selectedProjectId = ref.watch(projectFilterProvider);

    return ref.watch(taskRepositoryProvider).watchAllTasks().map((tasks) {
      if (selectedProjectId == null) {
        return tasks;
      } else if (selectedProjectId == -1) {
        return tasks.where((t) => t.projectId == null).toList();
      } else {
        return tasks.where((t) => t.projectId == selectedProjectId).toList();
      }
    });
  }

  Future<List<int>> getTagsForTask(int taskId) {
    return _repository.getTagIdsForTask(taskId);
  }

  Future<int> addTaskWithTags(TasksCompanion task, List<int> tagIds) {
    return _repository.insertTaskWithTags(task, tagIds);
  }

  Future<int> addTask(TasksCompanion task) {
    return _repository.insertTask(task);
  }

  Future<void> updateTaskWithTags(Task task, List<int> tagIds) {
    return _repository.updateTaskWithTags(task, tagIds);
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

final taskTagsProvider = StreamProvider.family<List<int>, int>((ref, taskId) {
  return ref.watch(taskRepositoryProvider).watchTagIdsForTask(taskId);
});
