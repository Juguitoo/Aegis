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
    db = AppDatabase.forTesting(NativeDatabase.memory());
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
        name: Value('Urgente'),
        colorHex: Value('#FF0000'),
      ));

      final taskId = await taskRepo.insertTaskWithTags(
        const TasksCompanion(
            title: Value('Tarea con etiqueta'), priority: Value(1)),
        [tagId],
      );

      var taskTags = await taskRepo.getTagIdsForTask(taskId);
      expect(taskTags.length, 1);

      final tag = await db.select(db.tags).getSingle();
      await tagRepo.deleteTag(tag);

      taskTags = await taskRepo.getTagIdsForTask(taskId);
      expect(taskTags.isEmpty, true);
    });

    test('Al borrar una tarea, se eliminan sus relaciones en la tabla TaskTags',
        () async {
      final tagId = await tagRepo.insertTag(const TagsCompanion(
        name: Value('Email'),
        colorHex: Value('#0000FF'),
      ));

      await taskRepo.insertTaskWithTags(
        const TasksCompanion(
            title: Value('Tarea a borrar'), priority: Value(1)),
        [tagId],
      );

      var allIntermediateRows = await db.select(db.taskTags).get();
      expect(allIntermediateRows.length, 1);

      final task = await db.select(db.tasks).getSingle();
      await taskRepo.deleteTask(task);

      allIntermediateRows = await db.select(db.taskTags).get();
      expect(allIntermediateRows.isEmpty, true);
    });

    test('Al borrar un proyecto, sus tareas pasan a la Bandeja de entrada',
        () async {
      final projectId = await projectRepo.insertProject(const ProjectsCompanion(
        name: Value('TFG'),
        colorHex: Value('#00FF00'),
      ));

      await taskRepo.insertTask(TasksCompanion(
        title: const Value('Investigar Drift'),
        priority: const Value(2),
        projectId: Value(projectId),
      ));

      var task = await db.select(db.tasks).getSingle();
      expect(task.projectId, projectId);

      final project = await db.select(db.projects).getSingle();
      await projectRepo.deleteProject(project);

      task = await db.select(db.tasks).getSingle();
      expect(task.projectId, null);
    });
  });
}
