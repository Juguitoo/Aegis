import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/data/repositories/task_repository.dart';
import 'package:aegis/presentation/viewmodels/task_list_viewmodel.dart';
import 'package:aegis/core/providers/repository_providers.dart';
import 'package:aegis/core/services/notification_service.dart';

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late AppDatabase db;
  late TaskRepository realRepository;
  late ProviderContainer container;
  ProviderSubscription? subscription;
  late MockNotificationService mockNotificationService;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory(
      setup: (db) {
        db.execute('PRAGMA foreign_keys = ON;');
      },
    ));

    realRepository = TaskRepository(db);
    mockNotificationService = MockNotificationService();

    when(() => mockNotificationService.cancelNotification(any()))
        .thenAnswer((_) async {});

    when(() => mockNotificationService.scheduleNotification(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          payload: any(named: 'payload'),
        )).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        taskRepositoryProvider.overrideWithValue(realRepository),
        notificationServiceProvider.overrideWithValue(mockNotificationService),
      ],
    );

    subscription = container.listen(taskListViewModelProvider, (_, __) {});
  });

  tearDown(() async {
    subscription?.close();
    container.dispose();
    await db.close();
  });

  group('TaskListViewModel Integracion con Base de Datos', () {
    test('addTask debe persistir la tarea y actualizar el stream del ViewModel',
        () async {
      await container.read(taskListViewModelProvider.future);

      await container.read(taskListViewModelProvider.notifier).addTask(
        title: 'Tarea desde ViewModel',
        notes: 'Nota de integracion',
        priority: 3,
        checklist: [
          TaskChecklistItem(title: 'Paso 1'),
        ],
      );

      await Future.delayed(const Duration(milliseconds: 50));
      final tasks = container.read(taskListViewModelProvider).value ?? [];

      expect(tasks.length, 1);
      expect(tasks.first.title, 'Tarea desde ViewModel');
      expect(tasks.first.notes, 'Nota de integracion');
      expect(tasks.first.priority, 3);

      final subtasks = await realRepository.getSubtasksForTask(tasks.first.id);
      expect(subtasks.length, 1);
      expect(subtasks.first.title, 'Paso 1');
    });

    test('toggleTaskCompletion debe persistir el cambio de estado', () async {
      await container.read(taskListViewModelProvider.notifier).addTask(
            title: 'Tarea para completar',
          );

      await Future.delayed(const Duration(milliseconds: 50));
      var tasks = container.read(taskListViewModelProvider).value ?? [];

      final taskToToggle = tasks.first;
      expect(taskToToggle.completedAt, null);

      await container
          .read(taskListViewModelProvider.notifier)
          .toggleTaskCompletion(taskToToggle);

      await Future.delayed(const Duration(milliseconds: 50));
      tasks = container.read(taskListViewModelProvider).value ?? [];

      expect(tasks.first.completedAt, isNotNull);
      expect(tasks.first.id, taskToToggle.id);
    });

    test('deleteTask debe borrar la tarea de la base de datos y del stream',
        () async {
      await container.read(taskListViewModelProvider.notifier).addTask(
            title: 'Tarea a eliminar',
          );

      await Future.delayed(const Duration(milliseconds: 50));
      var tasks = container.read(taskListViewModelProvider).value ?? [];
      expect(tasks.length, 1);

      await container
          .read(taskListViewModelProvider.notifier)
          .deleteTask(tasks.first);

      await Future.delayed(const Duration(milliseconds: 50));
      tasks = container.read(taskListViewModelProvider).value ?? [];

      expect(tasks.isEmpty, true);
    });
  });
}
