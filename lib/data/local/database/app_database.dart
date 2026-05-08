import 'dart:io';
import 'dart:math';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class Areas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get description => text().nullable()();
  TextColumn get colorHex => text().nullable()();
}

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  IntColumn get areaId => integer().nullable().references(Areas, #id)();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  IntColumn get estimatedDuration => integer().nullable()();
  IntColumn get actualDuration => integer().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get notificationAt => dateTime().nullable()();
}

class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 30)();
  TextColumn get description => text().nullable()();
  TextColumn get colorHex => text().nullable()();
}

class TaskTags extends Table {
  IntColumn get taskId => integer().references(Tasks, #id)();
  IntColumn get tagId => integer().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {taskId, tagId};
}

class Subtasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId => integer().references(Tasks, #id)();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get position => integer().withDefault(const Constant(0))();
}

class Settings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get pomodoroDuration => integer().withDefault(const Constant(25))();
  IntColumn get shortBreakDuration =>
      integer().withDefault(const Constant(5))();
  IntColumn get longBreakDuration =>
      integer().withDefault(const Constant(15))();
}

class BlacklistedApps extends Table {
  TextColumn get packageName => text().withLength()();
  TextColumn get appName => text().withLength()();

  @override
  Set<Column> get primaryKey => {packageName};
}

@DataClassName('FocusSession')
class FocusSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get mode => text()();
  IntColumn get actualSeconds => integer()();
  IntColumn get pauseCount => integer()();
  IntColumn get pauseDuration => integer()();
  IntColumn get extraTimeAdded => integer()();
  IntColumn get blocklistAttempts => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class DiaryNote extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
}

class HabitEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId => integer().references(Habits, #id)();
  DateTimeColumn get date => dateTime()();
}

class Events extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  BoolColumn get isAllDay => boolean().withDefault(const Constant(false))();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get notificationAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(tables: [
  Tasks,
  Areas,
  Tags,
  TaskTags,
  Subtasks,
  Settings,
  BlacklistedApps,
  FocusSessions,
  DiaryNote,
  Habits,
  HabitEntries,
  Events,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();

        await batch((batch) {
          batch.insertAll(areas, [
            AreasCompanion.insert(
              name: 'Personal',
              colorHex: const Value('#3B82F6'),
            ),
            AreasCompanion.insert(
              name: 'Trabajo',
              colorHex: const Value('#10B981'),
            ),
            AreasCompanion.insert(
              name: 'Estudios',
              colorHex: const Value('#8B5CF6'),
            ),
          ]);

          batch.insertAll(tags, [
            TagsCompanion.insert(
              name: 'Urgente',
              colorHex: const Value('#EF4444'),
            ),
            TagsCompanion.insert(
              name: 'Salud',
              colorHex: const Value('#EC4899'),
            ),
            TagsCompanion.insert(
              name: 'Casa',
              colorHex: const Value('#F59E0B'),
            ),
            TagsCompanion.insert(
              name: 'Ocio',
              colorHex: const Value('#06B6D4'),
            ),
          ]);
        });
      },
    );
  }

  Future<void> seedTestStatistics() async {
    await customStatement('PRAGMA foreign_keys = OFF');
    await delete(focusSessions).go();
    await delete(habitEntries).go();
    await delete(tasks).go();
    await delete(habits).go();
    await customStatement('PRAGMA foreign_keys = ON');

    var existingAreas = await select(areas).get();

    if (existingAreas.isEmpty) {
      await batch((batch) {
        batch.insertAll(areas, [
          AreasCompanion.insert(
            name: 'Personal',
            colorHex: const Value('#3B82F6'),
          ),
          AreasCompanion.insert(
            name: 'Trabajo',
            colorHex: const Value('#10B981'),
          ),
          AreasCompanion.insert(
            name: 'Estudios',
            colorHex: const Value('#8B5CF6'),
          ),
        ]);
      });
      existingAreas = await select(areas).get();
    }

    final areaIds = existingAreas.map((p) => p.id).toList();

    final h1Id = await into(habits).insert(
      HabitsCompanion.insert(name: 'Leer 20 mins'),
    );
    final h2Id = await into(habits).insert(
      HabitsCompanion.insert(name: 'Ejercicio'),
    );

    final random = Random();
    final now = DateTime.now();

    for (int i = 0; i <= 30; i++) {
      final currentDay = now.subtract(Duration(days: i));

      if (i <= 12) {
        await into(habitEntries).insert(
          HabitEntriesCompanion.insert(
            habitId: h1Id,
            date: currentDay,
          ),
        );
        if (random.nextBool()) {
          await into(habitEntries).insert(
            HabitEntriesCompanion.insert(
              habitId: h2Id,
              date: currentDay,
            ),
          );
        }
      }

      final numTasks = random.nextInt(5) + 1;
      for (int j = 0; j < numTasks; j++) {
        final isCompleted = random.nextDouble() > 0.2;
        final estSeconds = (random.nextInt(4) + 1) * 1800;
        final actSeconds = estSeconds + (random.nextInt(1800) - 900);

        await into(tasks).insert(
          TasksCompanion.insert(
            title: 'Tarea generada $j',
            areaId: areaIds.isNotEmpty
                ? Value(areaIds[random.nextInt(areaIds.length)])
                : const Value.absent(),
            estimatedDuration: Value(estSeconds),
            actualDuration:
                Value(isCompleted ? (actSeconds > 0 ? actSeconds : 600) : null),
            completedAt: Value(isCompleted ? currentDay : null),
          ),
        );
      }

      final numSessions = random.nextInt(4) + 1;
      for (int k = 0; k < numSessions; k++) {
        await into(focusSessions).insert(
          FocusSessionsCompanion.insert(
            mode: 'TimerMode.focus',
            actualSeconds: random.nextInt(2400) + 1200,
            pauseCount: random.nextInt(3),
            pauseDuration: random.nextInt(300),
            extraTimeAdded: 0,
            createdAt: Value(currentDay),
            blocklistAttempts: random.nextInt(4),
          ),
        );
      }
    }
  }

  Future<void> deleteAllData() {
    return transaction(() async {
      await delete(habitEntries).go();
      await delete(taskTags).go();
      await delete(subtasks).go();
      await delete(tasks).go();
      await delete(areas).go();
      await delete(tags).go();
      await delete(habits).go();
      await delete(settings).go();
      await delete(blacklistedApps).go();
      await delete(focusSessions).go();
      await delete(diaryNote).go();
      await delete(events).go();
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_database_v2.sqlite'));
    return NativeDatabase(file);
  });
}
