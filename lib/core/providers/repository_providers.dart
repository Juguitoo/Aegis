import 'package:aegis/data/repositories/blacklist_repository.dart';
import 'package:aegis/data/repositories/diary_repository.dart';
import 'package:aegis/data/repositories/habits_repository.dart';
import 'package:aegis/data/repositories/project_repository.dart';
import 'package:aegis/data/repositories/sessions_repository.dart';
import 'package:aegis/data/repositories/settings_repository.dart';
import 'package:aegis/data/repositories/statistics_repository.dart';
import 'package:aegis/data/repositories/tag_repository.dart';
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

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return TagRepository(database);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return SettingsRepository(database);
});

final blacklistRepositoryProvider = Provider<BlacklistRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return BlacklistRepository(database);
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return SessionRepository(database);
});

final diaryRepositoryProvider = Provider<DiaryRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return DiaryRepository(database);
});

final habitsRepositoryProvider = Provider<HabitsRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return HabitsRepository(database);
});

final statisticsRepositoryProvider = Provider<StatisticsRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return StatisticsRepository(database);
});
