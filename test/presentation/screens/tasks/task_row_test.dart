import 'package:aegis/core/providers/repository_providers.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/data/repositories/tag_repository.dart';
import 'package:aegis/data/repositories/task_repository.dart';
import 'package:aegis/presentation/screens/tasks/components/task_table_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

class MockTagRepository extends Mock implements TagRepository {}

void main() {
  late MockTaskRepository mockTaskRepo;
  late MockTagRepository mockTagRepo;

  setUp(() {
    mockTaskRepo = MockTaskRepository();
    mockTagRepo = MockTagRepository();

    // Le decimos a los mocks que devuelvan listas vacías para que el widget no se queje
    when(() => mockTaskRepo.watchTagIdsForTask(any()))
        .thenAnswer((_) => Stream.value([]));
    when(() => mockTagRepo.watchAllTags()).thenAnswer((_) => Stream.value([]));
  });

  Widget buildTestableTaskRow(Task task) {
    return ProviderScope(
      overrides: [
        taskRepositoryProvider.overrideWithValue(mockTaskRepo),
        tagRepositoryProvider.overrideWithValue(mockTagRepo),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: TaskRow(task: task),
        ),
      ),
    );
  }

  testWidgets('TaskRow renderiza el titulo y no lo tacha si esta pendiente',
      (WidgetTester tester) async {
    final task = Task(
        id: 1, title: 'Configurar servidor', priority: 3, completedAt: null);
    await tester.pumpWidget(buildTestableTaskRow(task));
    expect(find.text('Configurar servidor'), findsOneWidget);
    final titleText = tester.widget<Text>(find.text('Configurar servidor'));
    expect(titleText.style?.decoration, isNull);
  });

  testWidgets('TaskRow renderiza el titulo tachado si esta completada',
      (WidgetTester tester) async {
    final task = Task(
        id: 2,
        title: 'Redactar documentacion',
        priority: 1,
        completedAt: DateTime.now());
    await tester.pumpWidget(buildTestableTaskRow(task));
    expect(find.text('Redactar documentacion'), findsOneWidget);
    final titleText = tester.widget<Text>(find.text('Redactar documentacion'));
    expect(titleText.style?.decoration, TextDecoration.lineThrough);
  });

  testWidgets('TaskRow formatea la fecha correctamente al mes en texto',
      (WidgetTester tester) async {
    final taskDate = DateTime(2026, 8, 5);
    final task = Task(
        id: 3,
        title: 'Reunion de seguimiento',
        priority: 2,
        dueDate: taskDate,
        completedAt: null);
    await tester.pumpWidget(buildTestableTaskRow(task));
    expect(find.text('05, Agosto, 2026'), findsOneWidget);
  });

  testWidgets('TaskRow renderiza "Sin fecha" si dueDate es null',
      (WidgetTester tester) async {
    final task = Task(
        id: 4,
        title: 'Tarea sin prisa',
        priority: 0,
        dueDate: null,
        completedAt: null);
    await tester.pumpWidget(buildTestableTaskRow(task));
    expect(find.text('Sin fecha'), findsOneWidget);
  });

  testWidgets('TaskRow renderiza el menu de opciones (tres puntos)',
      (WidgetTester tester) async {
    final task =
        Task(id: 5, title: 'Revisar PRs', priority: 3, completedAt: null);
    await tester.pumpWidget(buildTestableTaskRow(task));
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
  });
}
