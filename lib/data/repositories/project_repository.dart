import 'package:aegis/data/local/database/app_database.dart';

class ProjectRepository {
  final AppDatabase _db;

  ProjectRepository(this._db);

  Future<List<Project>> getAllProjects() {
    return _db.select(_db.projects).get();
  }

  Future<Project?> getProjectById(int id) {
    return (_db.select(_db.projects)..where((p) => p.id.equals(id)))
        .getSingleOrNull();
  }

  Stream<List<Project>> watchAllProjects() {
    return _db.select(_db.projects).watch();
  }

  Future<int> insertProject(ProjectsCompanion project) {
    return _db.into(_db.projects).insert(project);
  }

  Future<bool> updateProject(Project project) {
    return _db.update(_db.projects).replace(project);
  }

  Future<int> deleteProject(Project project) {
    return _db.delete(_db.projects).delete(project);
  }
}
