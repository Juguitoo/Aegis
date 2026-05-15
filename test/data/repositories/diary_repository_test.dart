import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/data/repositories/diary_repository.dart';

void main() {
  late AppDatabase db;
  late DiaryRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DiaryRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('DiaryRepository', () {
    test('addNote inserta y getAllNotes recupera', () async {
      final date = DateTime(2023, 10, 10, 15, 30);
      await repository.addNote('Querido diario...', date: date);

      final notes = await repository.getAllNotes();
      expect(notes.length, 1);
      expect(notes.first.content, 'Querido diario...');
      expect(notes.first.createdAt.year, 2023);
    });

    test('getNotesByDate filtra correctamente por rango de 24 horas', () async {
      final targetDate = DateTime(2023, 10, 10);

      await repository.addNote('Día correcto (mañana)',
          date: DateTime(2023, 10, 10, 8, 0));
      await repository.addNote('Día correcto (noche)',
          date: DateTime(2023, 10, 10, 23, 59));
      await repository.addNote('Al día siguiente',
          date: DateTime(2023, 10, 11, 0, 1));
      await repository.addNote('Día anterior',
          date: DateTime(2023, 10, 9, 23, 59));

      final notes = await repository.getNotesByDate(targetDate);

      expect(notes.length, 2);
      expect(notes.map((n) => n.content),
          containsAll(['Día correcto (mañana)', 'Día correcto (noche)']));
    });

    test('updateNote y deleteNote funcionan correctamente', () async {
      final date = DateTime.now();
      final id = await repository.addNote('Nota inicial', date: date);

      var notes = await repository.getAllNotes();
      final noteToEdit = notes.first;

      await repository.updateNoteContent(noteToEdit.id, 'Nota actualizada');
      notes = await repository.getAllNotes();
      expect(notes.first.content, 'Nota actualizada');

      await repository.deleteNoteById(id);
      notes = await repository.getAllNotes();
      expect(notes.isEmpty, isTrue);
    });

    test('watchNotesByDate devuelve el stream correctamente', () async {
      final targetDate = DateTime(2023, 10, 10);

      await repository.addNote('Nota para el stream', date: targetDate);

      final notes = await repository.watchNotesByDate(targetDate).first;

      expect(notes.length, 1);
      expect(notes.first.content, 'Nota para el stream');
    });

    test('watchAllNotes devulve un stream y detecta los cambios correctamente',
        () async {
      final date = DateTime.now();
      final id = await repository.addNote('Nota inicial', date: date);

      final notesStream = repository.watchAllNotes();
      var notes = await notesStream.first;

      expect(notes, isNotEmpty);

      await repository.deleteNoteById(id);
      notes = await notesStream.first;

      expect(notes, isEmpty);
    });
  });
}
