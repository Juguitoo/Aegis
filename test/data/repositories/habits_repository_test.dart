import 'package:aegis/data/repositories/habits_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:aegis/data/local/database/app_database.dart';

void main() {
  late AppDatabase db;
  late HabitsRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = HabitsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('HabitsRepository', () {
    test('insertHabit y getAllHabits funcionan correctamente', () async {
      await repository.insertHabit('Habito 1');
      await repository.insertHabit('Habito 2');
      await repository.insertHabit('Habito 3');
      await repository.insertHabit('Habito 4');

      final habits = await repository.getAllHabits();
      expect(habits, isNotEmpty);
      expect(habits.length, 4);
    });

    test('updateHabit actualiza los datos de la base de datos correctamente',
        () async {
      await repository.insertHabit('Habito 1');
      await repository.insertHabit('Habito 2');
      await repository.insertHabit('Habito 3');
      await repository.insertHabit('Habito 4');

      var habits = await repository.getAllHabits();
      await repository.updateHabit(habits.first.id, 'Habito 1 Actualizado');
      habits = await repository.getAllHabits();

      expect(habits, isNotEmpty);
      expect(habits.length, 4);
      expect(habits.first.name, 'Habito 1 Actualizado');
    });

    test('deleteHabit elimina el habito de la base de datos correctamente',
        () async {
      await repository.insertHabit('Habito 1');
      await repository.insertHabit('Habito 2');
      await repository.insertHabit('Habito 3');
      await repository.insertHabit('Habito 4');

      var habits = await repository.getAllHabits();

      expect(habits, isNotEmpty);
      expect(habits.length, 4);

      await repository.deleteHabit(habits.first.id);
      habits = await repository.getAllHabits();

      expect(habits, isNotEmpty);
      expect(habits.length, 3);
    });

    test(
        'watchAllHabits devuelve el Stream y detecta los cambios correctamente',
        () async {
      await repository.insertHabit('Habito 1');
      await repository.insertHabit('Habito 2');
      await repository.insertHabit('Habito 3');
      await repository.insertHabit('Habito 4');

      final habitsStream = repository.watchAllHabits();
      var habits = await habitsStream.first;

      expect(habits, isNotEmpty);
      expect(habits.length, 4);

      await repository.updateHabit(habits.first.id, 'Habito 1 Actualizado');
      habits = await habitsStream.first;
      expect(habits.first.name, 'Habito 1 Actualizado');
    });

    test(
        'toggleHabitEntry funciona y getAllHabitEntries devuelve las entradas correctamente',
        () async {
      await repository.insertHabit('Habito 1');
      final habits = await repository.getAllHabits();
      await repository.toggleHabitEntry(habits.first.id, DateTime.now());
      final habitEntries = await repository.getAllHabitEntries();

      expect(habitEntries, isNotEmpty);
      expect(habitEntries.length, 1);
    });

    test('getHabitEntriesByHabitId funciona correctamente', () async {
      await repository.insertHabit('Habito 1');
      await repository.insertHabit('Habito 2');
      await repository.insertHabit('Habito 3');
      await repository.insertHabit('Habito 4');

      final habits = await repository.getAllHabits();

      for (Habit h in habits) {
        await repository.toggleHabitEntry(h.id, DateTime.now());
        await repository.toggleHabitEntry(
            h.id, DateTime.now().subtract(const Duration(days: 1)));
      }

      final allHabitEntries = await repository.getAllHabitEntries();
      final habitEntries =
          await repository.getHabitEntriesByHabitId(habits.first.id);

      expect(allHabitEntries, isNotEmpty);
      expect(allHabitEntries.length, 8);
      expect(habitEntries, isNotEmpty);
      expect(habitEntries.length, 2);
      expect(habitEntries.first.id, habits.first.id);
    });

    test(
        'watchAllHabitEntries devuelve el Stream y detecta los cambios correctamente',
        () async {
      await repository.insertHabit('Habito 1');
      final habits = await repository.getAllHabits();
      await repository.toggleHabitEntry(habits.first.id, DateTime.now());

      final habitEntriesStream = repository.watchAllHabitEntries();
      var habitEntries = await habitEntriesStream.first;

      expect(habitEntries, isNotEmpty);
      expect(habitEntries.length, 1);

      await repository.toggleHabitEntry(habits.first.id, DateTime.now());

      habitEntries = await habitEntriesStream.first;
      expect(habitEntries, isEmpty);
    });
  });
}
