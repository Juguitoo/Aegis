import 'package:aegis/data/local/database/app_database.dart';
import 'package:drift/drift.dart';

class HabitsRepository {
  final AppDatabase _db;

  HabitsRepository(this._db);

  Future<List<Habit>> getAllHabits() async {
    return await _db.select(_db.habits).get();
  }

  Stream<List<Habit>> watchAllHabits() {
    return _db.select(_db.habits).watch();
  }

  Future<List<HabitEntry>> getAllHabitEntries() async {
    return await _db.select(_db.habitEntries).get();
  }

  Stream<List<HabitEntry>> watchAllHabitEntries() {
    return _db.select(_db.habitEntries).watch();
  }

  Future<List<HabitEntry>> getHabitEntriesByHabitId(int habitId) async {
    return await (_db.select(_db.habitEntries)
          ..where((e) => e.habitId.equals(habitId)))
        .get();
  }

  Future<int> insertHabit(String name) async {
    return await _db
        .into(_db.habits)
        .insert(HabitsCompanion(name: Value(name)));
  }

  Future<int> updateHabit(int habitId, String newName) async {
    return await (_db.update(_db.habits)..where((h) => h.id.equals(habitId)))
        .write(HabitsCompanion(name: Value(newName)));
  }

  Future<int> deleteHabit(int habitId) {
    return _db.transaction(() async {
      await (_db.delete(_db.habitEntries)
            ..where((e) => e.habitId.equals(habitId)))
          .go();
      return await (_db.delete(_db.habits)..where((h) => h.id.equals(habitId)))
          .go();
    });
  }

  Future<int> toggleHabitEntry(int habitId, DateTime date) async {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    final existingEntry = await (_db.select(_db.habitEntries)
          ..where((e) =>
              (e.habitId.equals(habitId)) & (e.date.equals(normalizedDate))))
        .getSingleOrNull();

    if (existingEntry != null) {
      return await (_db.delete(_db.habitEntries)
            ..where((e) =>
                (e.habitId.equals(habitId)) & (e.date.equals(normalizedDate))))
          .go();
    } else {
      return await _db.into(_db.habitEntries).insert(HabitEntriesCompanion(
          habitId: Value(habitId), date: Value(normalizedDate)));
    }
  }
}
