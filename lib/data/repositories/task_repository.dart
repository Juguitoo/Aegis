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

  Future<int> insertTask(TasksCompanion task) {
    return _db.into(_db.tasks).insert(task);
  }

  Future<bool> updateTask(Task task) {
    return _db.update(_db.tasks).replace(task);
  }

  Future<int> deleteTaskById(int id) {
    return (_db.delete(_db.tasks)..where((t) => t.id.equals(id))).go();
  }

  Future<int> deleteTask(Task task) {
    return (_db.delete(_db.tasks)).delete(task);
  }
}
