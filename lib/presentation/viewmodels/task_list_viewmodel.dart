import 'dart:async';
import 'dart:math';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/providers/repository_providers.dart';
import '../../data/local/database/app_database.dart';
import '../../data/repositories/task_repository.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/notification_id_manager.dart';

class TaskChecklistItem {
  final int? id;
  final String title;
  final bool isCompleted;
  final String localId;

  TaskChecklistItem({
    this.id,
    required this.title,
    this.isCompleted = false,
    String? localId,
  }) : localId = localId ??
            '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(10000)}';
}

final projectFilterProvider = StateProvider<int?>((ref) => null);
final tagFilterProvider = StateProvider<List<int>>((ref) => []);
final searchQueryProvider = StateProvider<String>((ref) => '');

class TaskListViewModel extends StreamNotifier<List<Task>> {
  TaskRepository get _repository => ref.read(taskRepositoryProvider);

  @override
  Stream<List<Task>> build() {
    final selectedProjectId = ref.watch(projectFilterProvider);
    final selectedTagIds = ref.watch(tagFilterProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return ref
        .watch(taskRepositoryProvider)
        .watchAllTasks()
        .asyncMap((tasks) async {
      List<Task> filteredTasks = tasks;

      if (selectedProjectId == -1) {
        filteredTasks = tasks.where((t) => t.projectId == null).toList();
      } else if (selectedProjectId != null) {
        filteredTasks =
            tasks.where((t) => t.projectId == selectedProjectId).toList();
      }

      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        filteredTasks = filteredTasks
            .where((t) => t.title.toLowerCase().contains(query))
            .toList();
      }

      if (selectedTagIds.isNotEmpty) {
        final List<Task> tasksWithSelectedTags = [];
        for (final t in filteredTasks) {
          final List<int> taskTagIds = await _repository.getTagIdsForTask(t.id);
          if (selectedTagIds.any((tagId) => taskTagIds.contains(tagId))) {
            tasksWithSelectedTags.add(t);
          }
        }
        filteredTasks = tasksWithSelectedTags;
      }

      return filteredTasks;
    });
  }

  Future<List<int>> getTagsForTask(int taskId) {
    return _repository.getTagIdsForTask(taskId);
  }

  Future<int> addTask({
    required String title,
    String? description,
    int? estimatedDuration,
    DateTime? dueDate,
    DateTime? notificationAt,
    int? projectId,
    int priority = 0,
    List<int> tagIds = const [],
    List<TaskChecklistItem> checklist = const [],
    String? notes,
  }) async {
    final taskCompanion = TasksCompanion.insert(
      title: title,
      description: Value(description ?? ''),
      estimatedDuration: Value(estimatedDuration),
      actualDuration: const Value(0),
      dueDate: Value(dueDate),
      notificationAt: Value(notificationAt),
      projectId: Value(projectId),
      priority: Value(priority),
      notes: Value(notes ?? ''),
      completedAt: const Value(null),
    );

    final subtasksCompanions = checklist.asMap().entries.map((entry) {
      return SubtasksCompanion(
        title: Value(entry.value.title),
        isCompleted: Value(entry.value.isCompleted),
        position: Value(entry.key),
      );
    }).toList();

    final taskId = await _repository.insertTask(
      taskCompanion,
      tagIds: tagIds,
      subtasks: subtasksCompanions,
    );

    if (notificationAt != null && notificationAt.isAfter(DateTime.now())) {
      await NotificationService.scheduleNotification(
        id: NotificationIdManager.getTaskId(taskId),
        title: '📋 Tarea: $title',
        body: description?.isNotEmpty == true
            ? description!
            : 'Tienes una tarea pendiente programada',
        scheduledDate: notificationAt,
      );
    }

    return taskId;
  }

  Future<void> updateTask({
    required Task task,
    List<int> tagIds = const [],
    List<TaskChecklistItem> checklist = const [],
  }) async {
    final subtasksCompanions = checklist.asMap().entries.map((entry) {
      return SubtasksCompanion(
        id: entry.value.id != null
            ? Value(entry.value.id!)
            : const Value.absent(),
        title: Value(entry.value.title),
        isCompleted: Value(entry.value.isCompleted),
        position: Value(entry.key),
      );
    }).toList();

    await _repository.updateTask(task,
        tagIds: tagIds, subtasks: subtasksCompanions);

    final notifId = NotificationIdManager.getTaskId(task.id);
    if (task.completedAt == null &&
        task.notificationAt != null &&
        task.notificationAt!.isAfter(DateTime.now())) {
      await NotificationService.scheduleNotification(
        id: notifId,
        title: '📋 Tarea: ${task.title}',
        body: task.description?.isNotEmpty == true
            ? task.description!
            : 'Tienes una tarea pendiente programada',
        scheduledDate: task.notificationAt!,
      );
    } else {
      await NotificationService.cancelNotification(notifId);
    }
  }

  Future<int> deleteTask(Task task) async {
    await NotificationService.cancelNotification(
        NotificationIdManager.getTaskId(task.id));
    return await _repository.deleteTask(task);
  }

  Future<int> deleteTaskById(int id) async {
    await NotificationService.cancelNotification(
        NotificationIdManager.getTaskId(id));
    return await _repository.deleteTaskById(id);
  }

  Future<bool> toggleTaskCompletion(Task task) async {
    final isCurrentlyCompleted = task.completedAt != null;
    final updatedTask = task.copyWith(
      completedAt:
          isCurrentlyCompleted ? const Value(null) : Value(DateTime.now()),
    );

    final result = await _repository.updateTaskBasic(updatedTask);
    final notifId = NotificationIdManager.getTaskId(task.id);

    if (isCurrentlyCompleted) {
      if (task.notificationAt != null &&
          task.notificationAt!.isAfter(DateTime.now())) {
        await NotificationService.scheduleNotification(
          id: notifId,
          title: '📋 Tarea: ${task.title}',
          body: task.description?.isNotEmpty == true
              ? task.description!
              : 'Tienes una tarea pendiente programada',
          scheduledDate: task.notificationAt!,
        );
      }
    } else {
      await NotificationService.cancelNotification(notifId);
    }

    return result;
  }
}

final taskListViewModelProvider =
    StreamNotifierProvider<TaskListViewModel, List<Task>>(() {
  return TaskListViewModel();
});

final taskTagsProvider = StreamProvider.family<List<int>, int>((ref, taskId) {
  return ref.watch(taskRepositoryProvider).watchTagIdsForTask(taskId);
});
