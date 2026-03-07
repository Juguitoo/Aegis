import '../local/database/app_database.dart';

class TaskRepository {
  final AppDatabase _db;

  TaskRepository(this._db);

  Future<List<Task>> getAllTasks() {
    return _db.select(_db.tasks).get();
  }

  Future<Task> getTaskById(int id) {
    return (_db.select(_db.tasks)..where((t) => t.id.equals(id))).getSingle();
  }

  Stream<List<Task>> watchAllTasks() {
    return _db.select(_db.tasks).watch();
  }

  Future<int> insertTaskWithTags(TasksCompanion task, List<int> tagIds) {
    return _db.transaction(() async {
      final taskId = await _db.into(_db.tasks).insert(task);
      for (final tagId in tagIds) {
        await _db.into(_db.taskTags).insert(
              TaskTagsCompanion.insert(
                taskId: taskId,
                tagId: tagId,
              ),
            );
      }
      return taskId;
    });
  }

  Future<int> insertTask(TasksCompanion task) {
    return _db.into(_db.tasks).insert(task);
  }

  Future<void> updateTaskWithTags(Task task, List<int> tagIds) {
    return _db.transaction(() async {
      await _db.update(_db.tasks).replace(task);
      await (_db.delete(_db.taskTags)..where((t) => t.taskId.equals(task.id)))
          .go();
      for (final tagId in tagIds) {
        await _db.into(_db.taskTags).insert(
              TaskTagsCompanion.insert(
                taskId: task.id,
                tagId: tagId,
              ),
            );
      }
    });
  }

  Future<bool> updateTask(Task task) {
    return _db.update(_db.tasks).replace(task);
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

  Future<int> deleteTaskById(int id) {
    return _db.transaction(() async {
      await (_db.delete(_db.taskTags)..where((t) => t.taskId.equals(id))).go();
      return await (_db.delete(_db.tasks)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<int> deleteTask(Task task) {
    return _db.transaction(() async {
      await (_db.delete(_db.taskTags)..where((t) => t.taskId.equals(task.id)))
          .go();
      return await (_db.delete(_db.tasks)..where((t) => t.id.equals(task.id)))
          .go();
    });
  }
}
