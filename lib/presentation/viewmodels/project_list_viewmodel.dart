import 'package:aegis/core/providers/repository_providers.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/data/repositories/project_repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectListViewmodel extends StreamNotifier<List<Project>> {
  ProjectRepository get _repository => ref.read(projectRepositoryProvider);

  @override
  Stream<List<Project>> build() {
    return ref.watch(projectRepositoryProvider).watchAllProjects();
  }

  Future<int> addProject(String name, String? colorHex, String? description) {
    return _repository.insertProject(ProjectsCompanion(
      name: Value(name),
      colorHex: Value(colorHex),
      description: Value(description),
    ));
  }

  Future<bool> updateProject(Project project) {
    return _repository.updateProject(project);
  }

  Future<int> deleteProject(Project project) {
    return _repository.deleteProject(project);
  }
}

final projectListViewModelProvider =
    StreamNotifierProvider<ProjectListViewmodel, List<Project>>(() {
  return ProjectListViewmodel();
});
