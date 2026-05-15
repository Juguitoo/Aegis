import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/data/repositories/statistics_repository.dart';

void main() {
  late AppDatabase db;
  late StatisticsRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = StatisticsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  final DateTime start = DateTime(2026, 5, 1);
  final DateTime middle = DateTime(2026, 5, 10);
  final DateTime end = DateTime(2026, 5, 20);

  group('StatisticsRepository', () {
    test(
        'getFocusTimeByDate devuelve la suma de tiempo de sesiones de focus y 0 si no hay',
        () async {
      final emptyResult = await repository.getFocusTimeByDate(start, end);
      expect(emptyResult, 0);

      await db.into(db.focusSessions).insert(FocusSessionsCompanion(
            mode: const Value('TimerMode.focus'),
            createdAt: Value(middle),
            actualSeconds: const Value(1500),
            blocklistAttempts: const Value(0),
            pauseCount: const Value(0),
            pauseDuration: const Value(0),
            extraTimeAdded: const Value(0),
          ));

      await db.into(db.focusSessions).insert(FocusSessionsCompanion(
            mode: const Value('TimerMode.focus'),
            createdAt: Value(DateTime(2026, 6, 1)),
            actualSeconds: const Value(500),
            blocklistAttempts: const Value(0),
            pauseCount: const Value(0),
            pauseDuration: const Value(0),
            extraTimeAdded: const Value(0),
          ));

      await db.into(db.focusSessions).insert(FocusSessionsCompanion(
            mode: const Value('TimerMode.shortBreak'),
            createdAt: Value(middle),
            actualSeconds: const Value(300),
            blocklistAttempts: const Value(0),
            pauseCount: const Value(0),
            pauseDuration: const Value(0),
            extraTimeAdded: const Value(0),
          ));

      final result = await repository.getFocusTimeByDate(start, end);
      expect(result, 1500);
    });

    test(
        'getCompletedTasksCount devuelve el número correcto de tareas completadas',
        () async {
      expect(await repository.getCompletedTasksCount(start, end), 0);

      await db.into(db.tasks).insert(TasksCompanion(
            title: const Value('Task 1'),
            completedAt: Value(middle),
          ));

      await db.into(db.tasks).insert(TasksCompanion(
            title: const Value('Task 2'),
            completedAt: const Value(null),
          ));

      await db.into(db.tasks).insert(TasksCompanion(
            title: const Value('Task 3'),
            completedAt: Value(DateTime(2026, 6, 1)),
          ));

      final count = await repository.getCompletedTasksCount(start, end);
      expect(count, 1);
    });

    test(
        'getTasksWithDurationsByDateRange devuelve sólo tareas completadas con duración',
        () async {
      await db.into(db.tasks).insert(TasksCompanion(
            title: const Value('Valid'),
            completedAt: Value(middle),
            estimatedDuration: const Value(1500),
            actualDuration: const Value(1600),
          ));

      await db.into(db.tasks).insert(TasksCompanion(
            title: const Value('Missing estimated'),
            completedAt: Value(middle),
            actualDuration: const Value(1600),
          ));

      await db.into(db.tasks).insert(TasksCompanion(
            title: const Value('Out of range'),
            completedAt: Value(DateTime(2026, 6, 1)),
            estimatedDuration: const Value(1500),
            actualDuration: const Value(1600),
          ));

      final tasks =
          await repository.getTasksWithDurationsByDateRange(start, end);
      expect(tasks.length, 1);
      expect(tasks.first.title, 'Valid');
    });

    test('getDistinctHabitEntryDates devuelve fechas únicas ordenadas',
        () async {
      final date1 = DateTime(2026, 5, 10);
      final date2 = DateTime(2026, 5, 12);

      final habitId = await db
          .into(db.habits)
          .insert(HabitsCompanion(name: const Value('Habit')));

      await db.into(db.habitEntries).insert(HabitEntriesCompanion(
            habitId: Value(habitId),
            date: Value(date1),
          ));

      await db.into(db.habitEntries).insert(HabitEntriesCompanion(
            habitId: Value(habitId),
            date: Value(date1),
          ));

      await db.into(db.habitEntries).insert(HabitEntriesCompanion(
            habitId: Value(habitId),
            date: Value(date2),
          ));

      final dates = await repository.getDistinctHabitEntryDates();

      expect(dates.length, 2);
      expect(dates[0], date2);
      expect(dates[1], date1);
    });

    test('getDistractionsCount suma blocklistAttempts', () async {
      expect(await repository.getDistractionsCount(start, end), 0);

      await db.into(db.focusSessions).insert(FocusSessionsCompanion(
            mode: const Value('TimerMode.focus'),
            createdAt: Value(middle),
            actualSeconds: const Value(0),
            blocklistAttempts: const Value(3),
            pauseCount: const Value(0),
            pauseDuration: const Value(0),
            extraTimeAdded: const Value(0),
          ));

      await db.into(db.focusSessions).insert(FocusSessionsCompanion(
            mode: const Value('TimerMode.focus'),
            createdAt: Value(middle),
            actualSeconds: const Value(0),
            blocklistAttempts: const Value(2),
            pauseCount: const Value(0),
            pauseDuration: const Value(0),
            extraTimeAdded: const Value(0),
          ));

      await db.into(db.focusSessions).insert(FocusSessionsCompanion(
            mode: const Value('TimerMode.focus'),
            createdAt: Value(DateTime(2026, 6, 1)),
            actualSeconds: const Value(0),
            blocklistAttempts: const Value(5),
            pauseCount: const Value(0),
            pauseDuration: const Value(0),
            extraTimeAdded: const Value(0),
          ));

      expect(await repository.getDistractionsCount(start, end), 5);
    });

    test('getTaskDistributionByProject agrupa por area', () async {
      final area1Id = await db.into(db.areas).insert(AreasCompanion(
          name: const Value('Trabajo'), colorHex: const Value('#FF0000')));

      final area2Id = await db.into(db.areas).insert(AreasCompanion(
          name: const Value('Personal'), colorHex: const Value('#00FF00')));

      await db.into(db.tasks).insert(TasksCompanion(
            title: const Value('T1'),
            areaId: Value(area1Id),
            completedAt: Value(middle),
          ));
      await db.into(db.tasks).insert(TasksCompanion(
            title: const Value('T2'),
            areaId: Value(area1Id),
            completedAt: Value(middle),
          ));

      await db.into(db.tasks).insert(TasksCompanion(
            title: const Value('T3'),
            areaId: Value(area2Id),
            completedAt: Value(middle),
          ));

      await db.into(db.tasks).insert(TasksCompanion(
            title: const Value('T4'),
            completedAt: Value(middle),
          ));

      await db.into(db.tasks).insert(TasksCompanion(
            title: const Value('T5'),
            areaId: Value(area1Id),
            completedAt: Value(DateTime(2026, 6, 1)),
          ));

      final distribution =
          await repository.getTaskDistributionByProject(start, end);

      expect(distribution.length, 2);

      final trabajo = distribution.firstWhere((d) => d.areaName == 'Trabajo');
      expect(trabajo.colorHex, '#FF0000');
      expect(trabajo.taskCount, 2);

      final personal = distribution.firstWhere((d) => d.areaName == 'Personal');
      expect(personal.colorHex, '#00FF00');
      expect(personal.taskCount, 1);
    });
  });
}
