import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/presentation/screens/tasks/components/task_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestableTaskCard(Task task, {VoidCallback? onToggle}) {
    return ProviderScope(
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
    final task = Task(
      id: 1,
      title: 'Comprar leche',
      description: null,
      estimatedDuration: 15,
      priority: 1,
      dueDate: null,
      isCompleted: false,
    );

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
      description: null,
      estimatedDuration: 30,
      priority: 2,
      dueDate: null,
      isCompleted: true,
    );

    await tester.pumpWidget(buildTestableTaskCard(task));

    expect(find.text('Llamar al fontanero'), findsOneWidget);

    final titleText = tester.widget<Text>(find.text('Llamar al fontanero'));
    expect(titleText.style?.decoration, TextDecoration.lineThrough);
  });

  testWidgets('TaskCard dispara onToggle al pulsar el circulo de completar',
      (WidgetTester tester) async {
    bool togglePressed = false;

    final task = Task(
      id: 3,
      title: 'Hacer ejercicio',
      description: null,
      estimatedDuration: 60,
      priority: 3,
      dueDate: null,
      isCompleted: false,
    );

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
      description: null,
      estimatedDuration: 45,
      priority: 0,
      dueDate: taskDate,
      isCompleted: false,
    );

    await tester.pumpWidget(buildTestableTaskCard(task));

    expect(find.text('28/2/2026'), findsOneWidget);
    expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
  });
}
