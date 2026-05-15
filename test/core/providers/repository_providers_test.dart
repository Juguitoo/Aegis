import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/core/providers/database_provider.dart';
import 'package:aegis/core/providers/repository_providers.dart';
import 'package:aegis/data/repositories/task_repository.dart';
import 'package:aegis/data/repositories/area_repository.dart';
import 'package:aegis/data/repositories/tag_repository.dart';
import 'package:aegis/data/repositories/settings_repository.dart';
import 'package:aegis/data/repositories/blacklist_repository.dart';
import 'package:aegis/data/repositories/sessions_repository.dart';
import 'package:aegis/data/repositories/diary_repository.dart';
import 'package:aegis/data/repositories/habits_repository.dart';
import 'package:aegis/data/repositories/statistics_repository.dart';
import 'package:aegis/data/repositories/events_repository.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  group('Repository Providers', () {
    late MockAppDatabase mockDatabase;
    late ProviderContainer container;

    setUp(() {
      mockDatabase = MockAppDatabase();
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(mockDatabase),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('taskRepositoryProvider devuelve una instancia de TaskRepository', () {
      final repository = container.read(taskRepositoryProvider);
      expect(repository, isA<TaskRepository>());
    });

    test('areaRepositoryProvider devuelve una instancia de AreaRepository', () {
      final repository = container.read(areaRepositoryProvider);
      expect(repository, isA<AreaRepository>());
    });

    test('tagRepositoryProvider devuelve una instancia de TagRepository', () {
      final repository = container.read(tagRepositoryProvider);
      expect(repository, isA<TagRepository>());
    });

    test(
        'settingsRepositoryProvider devuelve una instancia de SettingsRepository',
        () {
      final repository = container.read(settingsRepositoryProvider);
      expect(repository, isA<SettingsRepository>());
    });

    test(
        'blacklistRepositoryProvider devuelve una instancia de BlacklistRepository',
        () {
      final repository = container.read(blacklistRepositoryProvider);
      expect(repository, isA<BlacklistRepository>());
    });

    test(
        'sessionRepositoryProvider devuelve una instancia de SessionRepository',
        () {
      final repository = container.read(sessionRepositoryProvider);
      expect(repository, isA<SessionRepository>());
    });

    test('diaryRepositoryProvider devuelve una instancia de DiaryRepository',
        () {
      final repository = container.read(diaryRepositoryProvider);
      expect(repository, isA<DiaryRepository>());
    });

    test('habitsRepositoryProvider devuelve una instancia de HabitsRepository',
        () {
      final repository = container.read(habitsRepositoryProvider);
      expect(repository, isA<HabitsRepository>());
    });

    test(
        'statisticsRepositoryProvider devuelve una instancia de StatisticsRepository',
        () {
      final repository = container.read(statisticsRepositoryProvider);
      expect(repository, isA<StatisticsRepository>());
    });

    test('eventsRepositoryProvider devuelve una instancia de EventsRepository',
        () {
      final repository = container.read(eventsRepositoryProvider);
      expect(repository, isA<EventsRepository>());
    });
  });
}
