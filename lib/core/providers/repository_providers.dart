import 'package:aegis/data/repositories/project_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/task_repository.dart';
import 'database_provider.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return TaskRepository(database);
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return ProjectRepository(database);
});
