import 'package:aegis/data/local/database/app_database.dart';
import 'package:drift/drift.dart';

class ProjectDistributionData {
  final String projectName;
  final String colorHex;
  final int taskCount;

  ProjectDistributionData({
    required this.projectName,
    required this.colorHex,
    required this.taskCount,
  });
}

class StatisticsRepository {
  final AppDatabase _db;

  StatisticsRepository(this._db);

  Future<int> getFocusTimeByDate(DateTime start, DateTime end) async {
    final sumExpr = _db.focusSessions.actualSeconds.sum();

    final query = _db.selectOnly(_db.focusSessions)
      ..addColumns([sumExpr])
      ..where(_db.focusSessions.mode.equals('TimerMode.focus') &
          _db.focusSessions.createdAt.isBetweenValues(start, end));

    final result = await query.getSingle();

    return result.read(sumExpr) ?? 0;
  }

  Future<int> getCompletedTasksCount(DateTime start, DateTime end) async {
    final countExpr = _db.tasks.id.count();

    final query = _db.selectOnly(_db.tasks)
      ..addColumns([countExpr])
      ..where(_db.tasks.completedAt.isNotNull() &
          _db.tasks.completedAt.isBetweenValues(start, end));

    final result = await query.getSingle();

    return result.read(countExpr) ?? 0;
  }

  Future<List<Task>> getTasksWithDurationsByDateRange(
      DateTime start, DateTime end) async {
    return (_db.select(_db.tasks)
          ..where((t) =>
              t.completedAt.isNotNull() &
              t.completedAt.isBetweenValues(start, end) &
              t.estimatedDuration.isNotNull() &
              t.actualDuration.isNotNull()))
        .get();
  }

  Future<List<DateTime>> getDistinctHabitEntryDates() async {
    final dateExpr = _db.habitEntries.date;

    final query = _db.selectOnly(_db.habitEntries, distinct: true)
      ..addColumns([dateExpr])
      ..orderBy([OrderingTerm.desc(dateExpr)]);

    final results = await query.get();

    return results.map((row) => row.read(dateExpr)!).toList();
  }

  Future<int> getDistractionsCount(DateTime start, DateTime end) async {
    final sumExpr = _db.focusSessions.blocklistAttempts.sum();

    final query = _db.selectOnly(_db.focusSessions)
      ..addColumns([sumExpr])
      ..where(_db.focusSessions.createdAt.isBetweenValues(start, end));

    final result = await query.getSingle();

    return result.read(sumExpr) ?? 0;
  }

  Future<List<ProjectDistributionData>> getTaskDistributionByProject(
      DateTime start, DateTime end) async {
    final countExpr = _db.tasks.id.count();

    final query = _db.selectOnly(_db.tasks)
      ..addColumns([_db.projects.name, _db.projects.colorHex, countExpr])
      ..join([
        innerJoin(_db.projects, _db.projects.id.equalsExp(_db.tasks.projectId))
      ])
      ..where(_db.tasks.completedAt.isNotNull() &
          _db.tasks.completedAt.isBetweenValues(start, end))
      ..groupBy([_db.projects.id]);

    final results = await query.get();

    return results.map((row) {
      return ProjectDistributionData(
        projectName: row.read(_db.projects.name) ?? 'Sin Proyecto',
        colorHex: row.read(_db.projects.colorHex) ?? '#000000',
        taskCount: row.read(countExpr) ?? 0,
      );
    }).toList();
  }
}
