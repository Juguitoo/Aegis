import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/data/repositories/task_repository.dart';
import 'package:aegis/data/repositories/tag_repository.dart';
import 'package:aegis/data/repositories/project_repository.dart';

void main() {
  late AppDatabase db;
  late TaskRepository taskRepo;
  late TagRepository tagRepo;
  late ProjectRepository projectRepo;

  setUp(() {
    // AQUÍ ESTÁ EL TRUCO PARA LOS TESTS: Encendemos el borrado en cascada (Foreign Keys)
    db = AppDatabase.forTesting(NativeDatabase.memory(
      setup: (db) {
        db.execute('PRAGMA foreign_keys = ON;');
      },
    ));
    taskRepo = TaskRepository(db);
    tagRepo = TagRepository(db);
    projectRepo = ProjectRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Tests de Integracion: Limpieza de Datos Muertos y Relaciones', () {
    test(
        'Al borrar una etiqueta, se eliminan sus relaciones en la tabla TaskTags',
        () async {
      final tagId = await tagRepo.insertTag(const TagsCompanion(
        name: Value('Urgente Test'),
        colorHex: Value('#FF0000'),
      ));

      final taskId = await taskRepo.insertTask(
        const TasksCompanion(
            title: Value('Tarea con etiqueta'), priority: Value(1)),
        tagIds: [tagId],
      );

      var taskTags = await taskRepo.getTagIdsForTask(taskId);
      expect(taskTags.length, 1);

      // Filtramos por ID para no chocar con las etiquetas del Seed
      final tag = await (db.select(db.tags)..where((t) => t.id.equals(tagId)))
          .getSingle();
      await tagRepo.deleteTag(tag);

      taskTags = await taskRepo.getTagIdsForTask(taskId);
      expect(taskTags.isEmpty, true);
    });

    test('Al borrar una tarea, se eliminan sus relaciones en la tabla TaskTags',
        () async {
      final tagId = await tagRepo.insertTag(const TagsCompanion(
        name: Value('Email Test'),
        colorHex: Value('#0000FF'),
      ));

      final taskId = await taskRepo.insertTask(
        const TasksCompanion(
            title: Value('Tarea a borrar'), priority: Value(1)),
        tagIds: [tagId],
      );

      var allIntermediateRows = await db.select(db.taskTags).get();
      expect(allIntermediateRows.length, 1);

      final task = await (db.select(db.tasks)
            ..where((t) => t.id.equals(taskId)))
          .getSingle();
      await taskRepo.deleteTask(task);

      allIntermediateRows = await db.select(db.taskTags).get();
      expect(allIntermediateRows.isEmpty, true);
    });

    test('Al borrar un proyecto, sus tareas pasan a la Bandeja de entrada',
        () async {
      final projectId = await projectRepo.insertProject(const ProjectsCompanion(
        name: Value('TFG Test'),
        colorHex: Value('#00FF00'),
      ));

      final taskId = await taskRepo.insertTask(TasksCompanion(
        title: const Value('Investigar Drift'),
        priority: const Value(2),
        projectId: Value(projectId),
      ));

      var task = await (db.select(db.tasks)..where((t) => t.id.equals(taskId)))
          .getSingle();
      expect(task.projectId, projectId);

      // Filtramos por ID para no chocar con los proyectos del Seed
      final project = await (db.select(db.projects)
            ..where((p) => p.id.equals(projectId)))
          .getSingle();
      await projectRepo.deleteProject(project);

      task = await (db.select(db.tasks)..where((t) => t.id.equals(taskId)))
          .getSingle();
      expect(task.projectId, null);
    });
  });

  group('Tests de Integracion: Modulo de Subtareas', () {
    test(
        'Debe guardar una tarea junto con sus subtareas en una sola transacción',
        () async {
      final taskId = await taskRepo.insertTask(
        const TasksCompanion(title: Value('Comprar la compra')),
        subtasks: [
          const SubtasksCompanion(title: Value('Leche'), position: Value(0)),
          const SubtasksCompanion(title: Value('Huevos'), position: Value(1)),
        ],
      );

      final subtasks = await taskRepo.getSubtasksForTask(taskId);

      expect(subtasks.length, 2);
      expect(subtasks[0].title, 'Leche');
      expect(subtasks[1].title, 'Huevos');
    });

    test('Al borrar una tarea, sus subtareas se eliminan en cascada', () async {
      final taskId = await taskRepo.insertTask(
        const TasksCompanion(title: Value('Hacer la colada')),
        subtasks: [
          const SubtasksCompanion(
              title: Value('Separar ropa'), position: Value(0)),
        ],
      );

      var subtasks = await db.select(db.subtasks).get();
      expect(subtasks.length, 1);

      final task = await (db.select(db.tasks)
            ..where((t) => t.id.equals(taskId)))
          .getSingle();
      await taskRepo.deleteTask(task);

      subtasks = await db.select(db.subtasks).get();
      expect(subtasks.isEmpty, true);
    });

    test(
        'updateTask debe sobrescribir la lista antigua de subtareas por la nueva',
        () async {
      final taskId = await taskRepo.insertTask(
        const TasksCompanion(title: Value('Estudiar')),
        subtasks: [
          const SubtasksCompanion(title: Value('Tema 1'), position: Value(0)),
          const SubtasksCompanion(title: Value('Tema 2'), position: Value(1)),
        ],
      );

      final task = await (db.select(db.tasks)
            ..where((t) => t.id.equals(taskId)))
          .getSingle();

      await taskRepo.updateTask(
        task,
        subtasks: [
          const SubtasksCompanion(
              title: Value('Tema 3 (Nuevo)'), position: Value(0)),
        ],
      );

      final updatedSubtasks = await taskRepo.getSubtasksForTask(taskId);
      expect(updatedSubtasks.length, 1);
      expect(updatedSubtasks.first.title, 'Tema 3 (Nuevo)');
    });
  });
}
