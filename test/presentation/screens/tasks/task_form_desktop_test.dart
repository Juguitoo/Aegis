import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/data/repositories/task_repository.dart';
import 'package:aegis/data/repositories/project_repository.dart';
import 'package:aegis/data/repositories/tag_repository.dart';
import 'package:aegis/core/providers/repository_providers.dart';
import 'package:aegis/presentation/screens/tasks/widgets/task_form_desktop.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

class MockProjectRepository extends Mock implements ProjectRepository {}

class MockTagRepository extends Mock implements TagRepository {}

class FakeTasksCompanion extends Fake implements TasksCompanion {}

void main() {
  late MockTaskRepository mockTaskRepo;
  late MockProjectRepository mockProjectRepo;
  late MockTagRepository mockTagRepo;

  setUpAll(() {
    registerFallbackValue(FakeTasksCompanion());
  });

  setUp(() {
    mockTaskRepo = MockTaskRepository();
    mockProjectRepo = MockProjectRepository();
    mockTagRepo = MockTagRepository();

    when(() => mockProjectRepo.watchAllProjects())
        .thenAnswer((_) => Stream.value([]));
    when(() => mockTagRepo.watchAllTags()).thenAnswer((_) => Stream.value([]));
  });

  testWidgets(
      'Rellenar el formulario de escritorio y pulsar Guardar Tarea inserta la tarea y muestra un SnackBar',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    when(() => mockTaskRepo.insertTask(
          any(),
          tagIds: any(named: 'tagIds'),
          subtasks: any(named: 'subtasks'),
        )).thenAnswer((_) async => 1);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskRepositoryProvider.overrideWithValue(mockTaskRepo),
          projectRepositoryProvider.overrideWithValue(mockProjectRepo),
          tagRepositoryProvider.overrideWithValue(mockTagRepo),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: TaskFormDesktop(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final titleField = find.widgetWithText(TextField, 'Título');
    await tester.enterText(titleField, 'Tarea en escritorio');

    final descField = find.widgetWithText(TextField, 'Descripción');
    await tester.enterText(descField, 'Probando la doble columna');

    final saveButton = find.widgetWithText(ElevatedButton, 'Guardar Tarea');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final captured = verify(() => mockTaskRepo.insertTask(
          captureAny(),
          tagIds: any(named: 'tagIds'),
          subtasks: any(named: 'subtasks'),
        )).captured;

    final companion = captured.first as TasksCompanion;
    expect(companion.title.value, 'Tarea en escritorio');
    expect(companion.description.value, 'Probando la doble columna');

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Tarea creada correctamente'), findsOneWidget);
  });

  testWidgets(
      'Intentar guardar en escritorio sin título muestra un SnackBar de error y no guarda',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskRepositoryProvider.overrideWithValue(mockTaskRepo),
          projectRepositoryProvider.overrideWithValue(mockProjectRepo),
          tagRepositoryProvider.overrideWithValue(mockTagRepo),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: TaskFormDesktop(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final saveButton = find.widgetWithText(ElevatedButton, 'Guardar Tarea');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    verifyNever(() => mockTaskRepo.insertTask(
          any(),
          tagIds: any(named: 'tagIds'),
          subtasks: any(named: 'subtasks'),
        ));

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('El título no puede estar vacío'), findsOneWidget);
  });
}
