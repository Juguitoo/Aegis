import 'package:aegis/core/providers/repository_providers.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/data/repositories/tag_repository.dart';
import 'package:aegis/data/repositories/task_repository.dart';
import 'package:aegis/presentation/screens/tasks/components/task_card.dart';
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

    when(() => mockTaskRepo.watchTagIdsForTask(any()))
        .thenAnswer((_) => Stream.value([]));
    when(() => mockTagRepo.watchAllTags()).thenAnswer((_) => Stream.value([]));
  });

  Widget buildTestableTaskCard(Task task, {VoidCallback? onToggle}) {
    return ProviderScope(
      overrides: [
        taskRepositoryProvider.overrideWithValue(mockTaskRepo),
        tagRepositoryProvider.overrideWithValue(mockTagRepo),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: TaskCard(
            task: task,
            onToggle: onToggle ?? () {},
            onTap: () {},
            onDelete: () {},
          ),
        ),
      ),
    );
  }

  testWidgets('TaskCard renderiza el titulo y no lo tacha si esta pendiente',
      (WidgetTester tester) async {
    final task =
        Task(id: 1, title: 'Comprar leche', priority: 1, completedAt: null);
    await tester.pumpWidget(buildTestableTaskCard(task));
    expect(find.text('Comprar leche'), findsOneWidget);
    final titleText = tester.widget<Text>(find.text('Comprar leche'));
    expect(titleText.style?.decoration, isNull);
  });

  testWidgets('TaskCard renderiza el titulo tachado si esta completada',
      (WidgetTester tester) async {
    final task = Task(
        id: 2,
        title: 'Llamar al fontanero',
        priority: 2,
        completedAt: DateTime.now());
    await tester.pumpWidget(buildTestableTaskCard(task));
    expect(find.text('Llamar al fontanero'), findsOneWidget);
    final titleText = tester.widget<Text>(find.text('Llamar al fontanero'));
    expect(titleText.style?.decoration, TextDecoration.lineThrough);
  });

  testWidgets('TaskCard dispara onToggle al pulsar el circulo de completar',
      (WidgetTester tester) async {
    bool togglePressed = false;
    final task =
        Task(id: 3, title: 'Hacer ejercicio', priority: 3, completedAt: null);

    await tester.pumpWidget(
      buildTestableTaskCard(
        task,
        onToggle: () {
          togglePressed = true;
        },
      ),
    );

    final checkCircle = find.byWidgetPredicate((widget) =>
        widget is Container &&
        widget.decoration is BoxDecoration &&
        (widget.decoration as BoxDecoration).shape == BoxShape.circle);

    await tester.tap(checkCircle);
    await tester.pump();

    expect(togglePressed, isTrue);
  });

  testWidgets('TaskCard muestra la fecha si dueDate no es null',
      (WidgetTester tester) async {
    final taskDate = DateTime(2026, 2, 28);
    final task = Task(
        id: 4,
        title: 'Renovar el DNI',
        priority: 0,
        dueDate: taskDate,
        completedAt: null);

    await tester.pumpWidget(buildTestableTaskCard(task));

    expect(find.text('28/2/2026'), findsOneWidget);
    expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
  });
}
