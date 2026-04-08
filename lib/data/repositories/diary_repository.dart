import 'package:aegis/data/local/database/app_database.dart';
import 'package:drift/drift.dart';

class DiaryRepository {
  final AppDatabase _db;

  DiaryRepository(this._db);

  Future<List<DiaryNoteData>> getAllNotes() async {
    return await _db.select(_db.diaryNote).get();
  }

  Future<List<DiaryNoteData>> getNotesByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await (_db.select(_db.diaryNote)
          ..where((t) =>
              t.createdAt.isBiggerOrEqualValue(startOfDay) &
              t.createdAt.isSmallerThanValue(endOfDay)))
        .get();
  }

  Stream<List<DiaryNoteData>> watchNotesByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (_db.select(_db.diaryNote)
          ..where((t) =>
              t.createdAt.isBiggerOrEqualValue(startOfDay) &
              t.createdAt.isSmallerThanValue(endOfDay)))
        .watch();
  }

  Stream<List<DiaryNoteData>> watchAllNotes() {
    return _db.select(_db.diaryNote).watch();
  }

  Future<int> addNote(String content, {DateTime? date}) {
    return _db.into(_db.diaryNote).insert(
          DiaryNoteCompanion.insert(
            content: content,
            createdAt: date != null ? Value(date) : const Value.absent(),
          ),
        );
  }

  Future<int> deleteNoteById(int id) {
    return (_db.delete(_db.diaryNote)..where((t) => t.id.equals(id))).go();
  }

  Future<int> updateNoteContent(int id, String newContent) {
    return (_db.update(_db.diaryNote)..where((t) => t.id.equals(id))).write(
      DiaryNoteCompanion(content: Value(newContent)),
    );
  }
}
