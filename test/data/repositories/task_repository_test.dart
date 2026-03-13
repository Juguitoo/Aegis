import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/data/repositories/task_repository.dart';

void main() {
  late AppDatabase db;
  late TaskRepository taskRepo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory(
      setup: (db) {
        db.execute('PRAGMA foreign_keys = ON;');
      },
    ));
    taskRepo = TaskRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('TaskRepository Persistencia CRUD', () {
    test('Debe insertar una tarea basica y leerla de la base de datos',
        () async {
      final companion = const TasksCompanion(
        title: Value('Tarea de prueba'),
        priority: Value(2),
      );

      final taskId = await taskRepo.insertTask(companion);
      final tasks = await taskRepo.watchAllTasks().first;

      expect(tasks.length, 1);
      expect(tasks.first.id, taskId);
      expect(tasks.first.title, 'Tarea de prueba');
      expect(tasks.first.priority, 2);
      expect(tasks.first.isCompleted, false);
    });

    test('Debe insertar una tarea compleja con notas, etiquetas y subtareas',
        () async {
      final companion = const TasksCompanion(
        title: Value('Tarea Compleja'),
        notes: Value('Anotaciones importantes de la tarea'),
        priority: Value(1),
      );

      final subtasks = [
        const SubtasksCompanion(title: Value('Subtarea 1'), position: Value(0)),
        const SubtasksCompanion(title: Value('Subtarea 2'), position: Value(1)),
      ];

      await db.into(db.tags).insert(
          const TagsCompanion(name: Value('Tag1'), colorHex: Value('#000')));
      await db.into(db.tags).insert(
          const TagsCompanion(name: Value('Tag2'), colorHex: Value('#FFF')));

      final taskId = await taskRepo.insertTask(
        companion,
        tagIds: [1, 2],
        subtasks: subtasks,
      );

      final task = await (db.select(db.tasks)
            ..where((t) => t.id.equals(taskId)))
          .getSingle();
      final savedTagIds = await taskRepo.getTagIdsForTask(taskId);
      final savedSubtasks = await taskRepo.getSubtasksForTask(taskId);

      expect(task.notes, 'Anotaciones importantes de la tarea');
      expect(savedTagIds.length, 2);
      expect(savedTagIds, containsAll([1, 2]));
      expect(savedSubtasks.length, 2);
      expect(savedSubtasks.first.position, 0);
    });

    test('Debe actualizar el titulo y estado de una tarea existente', () async {
      final taskId = await taskRepo.insertTask(
        const TasksCompanion(title: Value('Titulo original')),
      );

      var task = await (db.select(db.tasks)..where((t) => t.id.equals(taskId)))
          .getSingle();

      final updatedTask = task.copyWith(
        title: 'Titulo modificado',
        isCompleted: true,
      );

      await taskRepo.updateTaskBasic(updatedTask);

      final taskAfterUpdate = await (db.select(db.tasks)
            ..where((t) => t.id.equals(taskId)))
          .getSingle();

      expect(taskAfterUpdate.title, 'Titulo modificado');
      expect(taskAfterUpdate.isCompleted, true);
    });

    test('Debe borrar una tarea por su ID', () async {
      final taskId = await taskRepo.insertTask(
        const TasksCompanion(title: Value('Tarea efimera')),
      );

      var tasks = await taskRepo.watchAllTasks().first;
      expect(tasks.length, 1);

      await taskRepo.deleteTaskById(taskId);

      tasks = await taskRepo.watchAllTasks().first;
      expect(tasks.isEmpty, true);
    });
  });
}
