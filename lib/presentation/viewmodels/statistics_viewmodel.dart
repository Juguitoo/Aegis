import 'package:aegis/core/providers/repository_providers.dart';
import 'package:aegis/data/repositories/statistics_repository.dart';
import 'package:flutter_riverpod/legacy.dart';

enum ChartPeriod { week, month, year }

class ChartDataPoint {
  final String label;
  final int index;
  final int tasksCompleted;
  final int estimatedSeconds;
  final int actualSeconds;

  ChartDataPoint({
    required this.label,
    required this.index,
    required this.tasksCompleted,
    required this.estimatedSeconds,
    required this.actualSeconds,
  });
}

class StatisticsState {
  final bool isLoading;
  final ChartPeriod currentPeriod;
  final DateTime startDate;
  final DateTime endDate;
  final int totalFocusSeconds;
  final int completedTasks;
  final int distractionsCount;
  final double estimationAccuracy;
  final int habitStreak;
  final List<ChartDataPoint> chartData;
  final List<ProjectDistributionData> projectDistribution;

  StatisticsState({
    this.isLoading = true,
    this.currentPeriod = ChartPeriod.week,
    required this.startDate,
    required this.endDate,
    this.totalFocusSeconds = 0,
    this.completedTasks = 0,
    this.distractionsCount = 0,
    this.estimationAccuracy = 0.0,
    this.habitStreak = 0,
    this.chartData = const [],
    this.projectDistribution = const [],
  });

  StatisticsState copyWith({
    bool? isLoading,
    ChartPeriod? currentPeriod,
    DateTime? startDate,
    DateTime? endDate,
    int? totalFocusSeconds,
    int? completedTasks,
    int? distractionsCount,
    double? estimationAccuracy,
    int? habitStreak,
    List<ChartDataPoint>? chartData,
    List<ProjectDistributionData>? projectDistribution,
  }) {
    return StatisticsState(
      isLoading: isLoading ?? this.isLoading,
      currentPeriod: currentPeriod ?? this.currentPeriod,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalFocusSeconds: totalFocusSeconds ?? this.totalFocusSeconds,
      completedTasks: completedTasks ?? this.completedTasks,
      distractionsCount: distractionsCount ?? this.distractionsCount,
      estimationAccuracy: estimationAccuracy ?? this.estimationAccuracy,
      habitStreak: habitStreak ?? this.habitStreak,
      chartData: chartData ?? this.chartData,
      projectDistribution: projectDistribution ?? this.projectDistribution,
    );
  }
}

class StatisticsViewModel extends StateNotifier<StatisticsState> {
  final StatisticsRepository _repository;

  StatisticsViewModel(this._repository) : super(_getInitialState());

  static StatisticsState _getInitialState() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final end =
        start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    return StatisticsState(
      startDate: start,
      endDate: end,
    );
  }

  Future<void> changePeriod(
      ChartPeriod period, DateTime start, DateTime end) async {
    state = state.copyWith(
      currentPeriod: period,
      startDate: start,
      endDate: end,
      isLoading: true,
    );
    await loadStatistics();
  }

  Future<void> loadStatistics() async {
    state = state.copyWith(isLoading: true);

    final start = state.startDate;
    final end = state.endDate;

    final focusTime = await _repository.getFocusTimeByDate(start, end);
    final totalCompleted = await _repository.getCompletedTasksCount(start, end);
    final distractions = await _repository.getDistractionsCount(start, end);
    final projectsData =
        await _repository.getTaskDistributionByProject(start, end);

    final tasksWithDurations =
        await _repository.getTasksWithDurationsByDateRange(start, end);

    int totalEstimated = 0;
    int totalActual = 0;
    for (var task in tasksWithDurations) {
      totalEstimated += task.estimatedDuration ?? 0;
      totalActual += task.actualDuration ?? 0;
    }

    double accuracy = 0.0;
    if (totalActual > 0 && totalEstimated > 0) {
      accuracy = (totalEstimated / totalActual) * 100;
      if (accuracy > 100) accuracy = 100;
    }

    final habitDates = await _repository.getDistinctHabitEntryDates();
    int streak = 0;
    final normalizedDates =
        habitDates.map((d) => DateTime(d.year, d.month, d.day)).toSet();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (normalizedDates.contains(today) ||
        normalizedDates.contains(yesterday)) {
      DateTime streakDate = normalizedDates.contains(today) ? today : yesterday;
      while (normalizedDates.contains(streakDate)) {
        streak++;
        streakDate = streakDate.subtract(const Duration(days: 1));
      }
    }

    List<ChartDataPoint> generatedChartData = [];

    if (state.currentPeriod == ChartPeriod.week) {
      const labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
      for (int i = 0; i < 7; i++) {
        final dayStart = start.add(Duration(days: i));
        final dayEnd =
            dayStart.add(const Duration(hours: 23, minutes: 59, seconds: 59));

        final dailyTasksCount =
            await _repository.getCompletedTasksCount(dayStart, dayEnd);
        final dailyTasksDurations =
            tasksWithDurations.where((t) => t.completedAt?.weekday == (i + 1));

        int dailyEst = 0;
        int dailyAct = 0;
        for (var t in dailyTasksDurations) {
          dailyEst += t.estimatedDuration ?? 0;
          dailyAct += t.actualDuration ?? 0;
        }

        generatedChartData.add(ChartDataPoint(
          label: labels[i],
          index: i,
          tasksCompleted: dailyTasksCount,
          estimatedSeconds: dailyEst,
          actualSeconds: dailyAct,
        ));
      }
    } else if (state.currentPeriod == ChartPeriod.month) {
      final daysInMonth = end.difference(start).inDays + 1;
      for (int i = 0; i < daysInMonth; i++) {
        final dayStart = start.add(Duration(days: i));
        final dayEnd =
            dayStart.add(const Duration(hours: 23, minutes: 59, seconds: 59));

        final dailyTasksCount =
            await _repository.getCompletedTasksCount(dayStart, dayEnd);
        final dailyTasksDurations =
            tasksWithDurations.where((t) => t.completedAt?.day == dayStart.day);

        int dailyEst = 0;
        int dailyAct = 0;
        for (var t in dailyTasksDurations) {
          dailyEst += t.estimatedDuration ?? 0;
          dailyAct += t.actualDuration ?? 0;
        }

        generatedChartData.add(ChartDataPoint(
          label: '${i + 1}',
          index: i,
          tasksCompleted: dailyTasksCount,
          estimatedSeconds: dailyEst,
          actualSeconds: dailyAct,
        ));
      }
    } else if (state.currentPeriod == ChartPeriod.year) {
      const labels = [
        'Ene',
        'Feb',
        'Mar',
        'Abr',
        'May',
        'Jun',
        'Jul',
        'Ago',
        'Sep',
        'Oct',
        'Nov',
        'Dic'
      ];
      for (int i = 0; i < 12; i++) {
        final monthStart = DateTime(start.year, i + 1, 1);
        final nextMonth = DateTime(start.year, i + 2, 1);
        final monthEnd = nextMonth.subtract(const Duration(seconds: 1));

        final monthlyTasksCount =
            await _repository.getCompletedTasksCount(monthStart, monthEnd);
        final monthlyTasksDurations =
            tasksWithDurations.where((t) => t.completedAt?.month == (i + 1));

        int monthlyEst = 0;
        int monthlyAct = 0;
        for (var t in monthlyTasksDurations) {
          monthlyEst += t.estimatedDuration ?? 0;
          monthlyAct += t.actualDuration ?? 0;
        }

        generatedChartData.add(ChartDataPoint(
          label: labels[i],
          index: i,
          tasksCompleted: monthlyTasksCount,
          estimatedSeconds: monthlyEst,
          actualSeconds: monthlyAct,
        ));
      }
    }

    state = state.copyWith(
      isLoading: false,
      totalFocusSeconds: focusTime,
      completedTasks: totalCompleted,
      distractionsCount: distractions,
      estimationAccuracy: accuracy,
      habitStreak: streak,
      chartData: generatedChartData,
      projectDistribution: projectsData,
    );
  }
}

final statisticsViewModelProvider =
    StateNotifierProvider<StatisticsViewModel, StatisticsState>((ref) {
  final repository = ref.watch(statisticsRepositoryProvider);
  return StatisticsViewModel(repository);
});
