import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/data/repositories/task_repository.dart';
import 'package:aegis/data/repositories/project_repository.dart';
import 'package:aegis/data/repositories/tag_repository.dart';
import 'package:aegis/core/providers/repository_providers.dart';
import 'package:aegis/presentation/screens/tasks/components/task_form_mobile.dart';

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
      'Rellenar el formulario y pulsar Guardar inserta la tarea y muestra un SnackBar',
      (WidgetTester tester) async {
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
            body: TaskFormMobile(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final titleField = find.widgetWithText(TextField, 'Título');
    await tester.enterText(titleField, 'Aprender Widget Tests');

    final descField = find.widgetWithText(TextField, 'Descripción');
    await tester.enterText(descField, 'Simulando pulsaciones de teclado');

    final saveButton = find.widgetWithText(ElevatedButton, 'Guardar');
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
    expect(companion.title.value, 'Aprender Widget Tests');
    expect(companion.description.value, 'Simulando pulsaciones de teclado');

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Tarea creada correctamente'), findsOneWidget);
  });

  testWidgets(
      'Intentar guardar sin título muestra un SnackBar de error y no guarda',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskRepositoryProvider.overrideWithValue(mockTaskRepo),
          projectRepositoryProvider.overrideWithValue(mockProjectRepo),
          tagRepositoryProvider.overrideWithValue(mockTagRepo),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: TaskFormMobile(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final saveButton = find.widgetWithText(ElevatedButton, 'Guardar');
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
