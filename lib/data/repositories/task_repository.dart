import 'package:drift/drift.dart';
import '../local/database/app_database.dart';

class TaskRepository {
  final AppDatabase _db;

  TaskRepository(this._db);

  Stream<List<Task>> watchAllTasks() {
    return _db.select(_db.tasks).watch();
  }

  Future<int> deleteTask(Task task) {
    return _db.transaction(() async {
      await (_db.delete(_db.taskTags)..where((t) => t.taskId.equals(task.id)))
          .go();
      await (_db.delete(_db.subtasks)..where((t) => t.taskId.equals(task.id)))
          .go();
      return await _db.delete(_db.tasks).delete(task);
    });
  }

  Future<int> deleteTaskById(int id) {
    return _db.transaction(() async {
      await (_db.delete(_db.taskTags)..where((t) => t.taskId.equals(id))).go();
      await (_db.delete(_db.subtasks)..where((t) => t.taskId.equals(id))).go();
      return await (_db.delete(_db.tasks)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<List<int>> getTagIdsForTask(int taskId) async {
    final query = _db.select(_db.taskTags)
      ..where((t) => t.taskId.equals(taskId));
    final result = await query.get();
    return result.map((row) => row.tagId).toList();
  }

  Stream<List<int>> watchTagIdsForTask(int taskId) {
    final query = _db.select(_db.taskTags)
      ..where((t) => t.taskId.equals(taskId));
    return query.watch().map((rows) => rows.map((row) => row.tagId).toList());
  }

  Future<List<Subtask>> getSubtasksForTask(int taskId) {
    return (_db.select(_db.subtasks)
          ..where((t) => t.taskId.equals(taskId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.position, mode: OrderingMode.asc),
            (t) => OrderingTerm(expression: t.id, mode: OrderingMode.asc),
          ]))
        .get();
  }

  Stream<List<Subtask>> watchSubtasksForTask(int taskId) {
    return (_db.select(_db.subtasks)
          ..where((t) => t.taskId.equals(taskId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.position, mode: OrderingMode.asc),
            (t) => OrderingTerm(expression: t.id, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  Future<int> insertTask(
    TasksCompanion task, {
    List<int> tagIds = const [],
    List<SubtasksCompanion> subtasks = const [],
  }) {
    return _db.transaction(() async {
      final taskId = await _db.into(_db.tasks).insert(task);

      for (final tagId in tagIds) {
        await _db.into(_db.taskTags).insert(
              TaskTagsCompanion.insert(taskId: taskId, tagId: tagId),
            );
      }

      for (final subtask in subtasks) {
        await _db.into(_db.subtasks).insert(
              subtask.copyWith(taskId: Value(taskId)),
            );
      }

      return taskId;
    });
  }

  Future<void> updateTask(
    Task task, {
    List<int> tagIds = const [],
    List<SubtasksCompanion> subtasks = const [],
  }) {
    return _db.transaction(() async {
      await _db.update(_db.tasks).replace(task);

      await (_db.delete(_db.taskTags)..where((t) => t.taskId.equals(task.id)))
          .go();
      for (final tagId in tagIds) {
        await _db.into(_db.taskTags).insert(
              TaskTagsCompanion.insert(taskId: task.id, tagId: tagId),
            );
      }

      await (_db.delete(_db.subtasks)..where((t) => t.taskId.equals(task.id)))
          .go();
      for (final subtask in subtasks) {
        await _db.into(_db.subtasks).insert(
              subtask.copyWith(taskId: Value(task.id)),
            );
      }
    });
  }

  Future<bool> updateTaskBasic(Task task) {
    return _db.update(_db.tasks).replace(task);
  }
}
