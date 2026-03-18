import 'package:drift/drift.dart';
import 'package:aegis/data/local/database/app_database.dart';

class SettingsRepository {
  final AppDatabase _db;

  SettingsRepository(this._db);

  Stream<Setting?> watchSettings() {
    return _db.select(_db.settings).watch().map((rows) => rows.firstOrNull);
  }

  Future<Setting?> getSettings() async {
    final rows = await _db.select(_db.settings).get();
    return rows.firstOrNull;
  }

  Future<void> upsertSettings(SettingsCompanion companion) async {
    final currentSettings = await getSettings();

    if (currentSettings == null) {
      await _db.into(_db.settings).insert(companion);
    } else {
      await (_db.update(_db.settings)
            ..where((t) => t.id.equals(currentSettings.id)))
          .write(
        SettingsCompanion(
          pomodoroDuration: companion.pomodoroDuration.present
              ? companion.pomodoroDuration
              : Value(currentSettings.pomodoroDuration),
          shortBreakDuration: companion.shortBreakDuration.present
              ? companion.shortBreakDuration
              : Value(currentSettings.shortBreakDuration),
          longBreakDuration: companion.longBreakDuration.present
              ? companion.longBreakDuration
              : Value(currentSettings.longBreakDuration),
        ),
      );
    }
  }

  Future<int> deleteSettings() {
    return _db.delete(_db.settings).go();
  }
}
