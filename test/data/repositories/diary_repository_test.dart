import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/data/repositories/diary_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DiaryRepository diaryRepo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory(
      setup: (db) {
        db.execute('PRAGMA foreign_keys = ON;');
      },
    ));
    diaryRepo = DiaryRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('DiaryRepository CRUD', () {
    test('Debe insertar una entrada de diario y leerla de la base de datos',
        () async {
      final noteId = await diaryRepo.addNote('Mi primera nota de diario',
          date: DateTime(2024, 6, 1));

      final notes = await diaryRepo.getAllNotes();
      expect(notes.length, 1);
      expect(notes.first.id, noteId);
      expect(notes.first.content, 'Mi primera nota de diario');
    });

    test('Debe actualizar el contenido de una nota de diario', () async {
      final noteId = await diaryRepo.addNote('Mi primera nota de diario',
          date: DateTime(2024, 6, 1));

      await diaryRepo.updateNoteContent(noteId, 'Contenido actualizado');
      final notes = await diaryRepo.getAllNotes();
      expect(notes.length, 1);
      expect(notes.first.id, noteId);
      expect(notes.first.content, 'Contenido actualizado');
    });

    test('Debe eliminar una nota de diario por su ID', () async {
      final noteId = await diaryRepo.addNote('Mi primera nota de diario',
          date: DateTime(2024, 6, 1));

      await diaryRepo.deleteNoteById(noteId);
      final notes = await diaryRepo.getAllNotes();
      expect(notes.length, 0);
    });

    test('Debe obtener notas por fecha', () async {
      await diaryRepo.addNote('Nota del 1 de junio',
          date: DateTime(2024, 6, 1));
      await diaryRepo.addNote('Nota del 2 de junio',
          date: DateTime(2024, 6, 2));

      final notesJune1 = await diaryRepo.getNotesByDate(DateTime(2024, 6, 1));
      expect(notesJune1.length, 1);
      expect(notesJune1.first.content, 'Nota del 1 de junio');

      final notesJune2 = await diaryRepo.getNotesByDate(DateTime(2024, 6, 2));
      expect(notesJune2.length, 1);
      expect(notesJune2.first.content, 'Nota del 2 de junio');
    });

    test('Debe obtener todas las notas de diario', () async {
      await diaryRepo.addNote('Nota del 1 de junio',
          date: DateTime(2024, 6, 1));
      await diaryRepo.addNote('Nota del 2 de junio',
          date: DateTime(2024, 6, 2));

      final allNotes = await diaryRepo.getAllNotes();
      expect(allNotes.length, 2);
    });
  });
}
