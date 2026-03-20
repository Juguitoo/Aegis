import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart' hide isNotNull;
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/data/repositories/settings_repository.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository settingsRepo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory(
      setup: (db) {
        db.execute('PRAGMA foreign_keys = ON;');
      },
    ));
    settingsRepo = SettingsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('SettingsRepository Persistencia CRUD', () {
    test('Debe insertar una configuración y leerla de la base de datos',
        () async {
      final companion = const SettingsCompanion(
        pomodoroDuration: Value(60),
        shortBreakDuration: Value(10),
        longBreakDuration: Value(25),
      );
      await settingsRepo.upsertSettings(companion);

      final settings = await settingsRepo.getSettings();
      expect(settings?.pomodoroDuration, 60);
      expect(settings?.shortBreakDuration, 10);
      expect(settings?.longBreakDuration, 25);
    });

    test('Debe actualizar una configuración existente', () async {
      final initialCompanion = const SettingsCompanion(
        pomodoroDuration: Value(60),
        shortBreakDuration: Value(10),
        longBreakDuration: Value(25),
      );
      await settingsRepo.upsertSettings(initialCompanion);

      final updatedCompanion = const SettingsCompanion(
        pomodoroDuration: Value(45),
      );
      await settingsRepo.upsertSettings(updatedCompanion);

      final settings = await settingsRepo.getSettings();
      expect(settings?.pomodoroDuration, 45);
      expect(settings?.shortBreakDuration, 10);
      expect(settings?.longBreakDuration, 25);
    });

    test('Debe eliminar la configuración', () async {
      final companion = const SettingsCompanion(
        pomodoroDuration: Value(60),
        shortBreakDuration: Value(10),
        longBreakDuration: Value(25),
      );
      await settingsRepo.upsertSettings(companion);

      await settingsRepo.deleteSettings();
      final settings = await settingsRepo.getSettings();
      expect(settings, null);
    });
  });
}
