import 'package:aegis/core/providers/repository_providers.dart';
import 'package:aegis/data/repositories/statistics_repository.dart';
import 'package:aegis/presentation/viewmodels/statistics_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'statistics_viewmodel_test.mocks.dart';

@GenerateMocks([StatisticsRepository])
void main() {
  group('StatisticsViewModel', () {
    late MockStatisticsRepository mockStatisticsRepository;
    late ProviderContainer container;

    setUp(() {
      mockStatisticsRepository = MockStatisticsRepository();

      when(mockStatisticsRepository.getFocusTimeByDate(any, any))
          .thenAnswer((_) async => 0);
      when(mockStatisticsRepository.getCompletedTasksCount(any, any))
          .thenAnswer((_) async => 0);
      when(mockStatisticsRepository.getDistractionsCount(any, any))
          .thenAnswer((_) async => 0);
      when(mockStatisticsRepository.getTaskDistributionByProject(any, any))
          .thenAnswer((_) async => []);
      when(mockStatisticsRepository.getTasksWithDurationsByDateRange(any, any))
          .thenAnswer((_) async => []);
      when(mockStatisticsRepository.getDistinctHabitEntryDates())
          .thenAnswer((_) async => <DateTime>[]);

      container = ProviderContainer(
        overrides: [
          statisticsRepositoryProvider
              .overrideWithValue(mockStatisticsRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is correct', () {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final expectedStart =
          DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      final expectedEnd = expectedStart
          .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

      final state = container.read(statisticsViewModelProvider);

      expect(state.currentPeriod, ChartPeriod.week);
      expect(state.startDate, expectedStart);
      expect(state.endDate, expectedEnd);
    });

    test('changePeriod updates state and fetches data', () async {
      final newPeriod = ChartPeriod.month;
      final newStart = DateTime(2024, 1, 1);
      final newEnd = DateTime(2024, 1, 31, 23, 59, 59);

      await container
          .read(statisticsViewModelProvider.notifier)
          .changePeriod(newPeriod, newStart, newEnd);

      final state = container.read(statisticsViewModelProvider);
      expect(state.currentPeriod, newPeriod);
      expect(state.startDate, newStart);
      expect(state.endDate, newEnd);
      verify(mockStatisticsRepository.getFocusTimeByDate(newStart, newEnd))
          .called(1);
    });

    test('habit streak calculation is correct', () async {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final twoDaysAgo = today.subtract(const Duration(days: 2));

      when(mockStatisticsRepository.getDistinctHabitEntryDates())
          .thenAnswer((_) async => [today, yesterday, twoDaysAgo]);

      await container
          .read(statisticsViewModelProvider.notifier)
          .loadStatistics();

      final state = container.read(statisticsViewModelProvider);
      expect(state.habitStreak, 3);
    });
  });
}
