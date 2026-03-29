import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get description => text().nullable()();
  TextColumn get colorHex => text().nullable()();
}

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  IntColumn get projectId => integer().nullable().references(Projects, #id)();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  IntColumn get estimatedDuration => integer().nullable()();
  IntColumn get actualDuration => integer().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
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

@DriftDatabase(tables: [
  Tasks,
  Projects,
  Tags,
  TaskTags,
  Subtasks,
  Settings,
  BlacklistedApps,
  FocusSessions,
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
          batch.insertAll(projects, [
            ProjectsCompanion.insert(
              name: 'Personal',
              colorHex: Value('#3B82F6'),
            ),
            ProjectsCompanion.insert(
              name: 'Trabajo',
              colorHex: Value('#10B981'),
            ),
            ProjectsCompanion.insert(
              name: 'Estudios',
              colorHex: Value('#8B5CF6'),
            ),
          ]);

          batch.insertAll(tags, [
            TagsCompanion.insert(
              name: 'Urgente',
              colorHex: Value('#EF4444'),
            ),
            TagsCompanion.insert(
              name: 'Salud',
              colorHex: Value('#EC4899'),
            ),
            TagsCompanion.insert(
              name: 'Casa',
              colorHex: Value('#F59E0B'),
            ),
            TagsCompanion.insert(
              name: 'Ocio',
              colorHex: Value('#06B6D4'),
            ),
          ]);
        });
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'aegis_db.sqlite'));
    return NativeDatabase(file);
  });
}
