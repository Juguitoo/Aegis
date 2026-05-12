import 'package:aegis/core/providers/repository_providers.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/data/repositories/habits_repository.dart';
import 'package:aegis/presentation/viewmodels/habits_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'habits_viewmodel_test.mocks.dart';

@GenerateMocks([HabitsRepository])
void main() {
  group('HabitsViewModel', () {
    late MockHabitsRepository mockHabitsRepository;
    late ProviderContainer container;

    setUp(() {
      mockHabitsRepository = MockHabitsRepository();
      container = ProviderContainer(
        overrides: [
          habitsRepositoryProvider.overrideWithValue(mockHabitsRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('build combines habits and entries', () async {
      final habit1 = Habit(id: 1, name: 'Habit 1');
      final habit2 = Habit(id: 2, name: 'Habit 2');
      final entry1 = HabitEntry(id: 1, habitId: 1, date: DateTime.now());

      when(mockHabitsRepository.watchAllHabits())
          .thenAnswer((_) => Stream<List<Habit>>.value([habit1, habit2]));
      when(mockHabitsRepository.watchAllHabitEntries())
          .thenAnswer((_) => Stream<List<HabitEntry>>.value([entry1]));

      final listener = container.listen(habitsViewModelProvider, (_, __) {});

      final result = await container.read(habitsViewModelProvider.future);

      expect(result.length, 2);
      expect(result[0].habit, habit1);
      expect(result[0].entries.length, 1);
      expect(result[0].entries[0], entry1);
      expect(result[1].habit, habit2);
      expect(result[1].entries.isEmpty, isTrue);

      listener.close();
    });

    test('addHabit calls repository', () async {
      const name = 'New Habit';
      when(mockHabitsRepository.insertHabit(name))
          .thenAnswer((_) => Future<int>.value(1));

      await container.read(habitsViewModelProvider.notifier).addHabit(name);

      verify(mockHabitsRepository.insertHabit(name)).called(1);
    });

    test('addHabit does not add empty habit', () async {
      await container.read(habitsViewModelProvider.notifier).addHabit('  ');
    });

    test('updateHabit calls repository', () async {
      const id = 1;
      const newName = 'Updated Habit';
      when(mockHabitsRepository.updateHabit(id, newName))
          .thenAnswer((_) => Future<int>.value(1));

      await container
          .read(habitsViewModelProvider.notifier)
          .updateHabit(id, newName);

      verify(mockHabitsRepository.updateHabit(id, newName)).called(1);
    });

    test('updateHabit does not update with empty name', () async {
      await container
          .read(habitsViewModelProvider.notifier)
          .updateHabit(1, '  ');
    });

    test('deleteHabit calls repository', () async {
      const id = 1;
      when(mockHabitsRepository.deleteHabit(id))
          .thenAnswer((_) => Future<int>.value(1));

      await container.read(habitsViewModelProvider.notifier).deleteHabit(id);

      verify(mockHabitsRepository.deleteHabit(id)).called(1);
    });

    test('toggleHabitEntry calls repository', () async {
      const habitId = 1;
      final date = DateTime.now();
      when(mockHabitsRepository.toggleHabitEntry(habitId, date))
          .thenAnswer((_) => Future<int>.value(1));

      await container
          .read(habitsViewModelProvider.notifier)
          .toggleHabitEntry(habitId, date);

      verify(mockHabitsRepository.toggleHabitEntry(habitId, date)).called(1);
    });
  });
}
