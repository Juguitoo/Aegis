import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/presentation/screens/tasks/components/task_table_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestableTaskRow(Task task) {
    return ProviderScope(
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
      id: 1,
      title: 'Configurar servidor',
      description: null,
      estimatedDuration: 120,
      priority: 3,
      dueDate: null,
      isCompleted: false,
    );

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
      description: null,
      estimatedDuration: 45,
      priority: 1,
      dueDate: null,
      isCompleted: true,
    );

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
      description: null,
      estimatedDuration: 30,
      priority: 2,
      dueDate: taskDate,
      isCompleted: false,
    );

    await tester.pumpWidget(buildTestableTaskRow(task));

    expect(find.text('05, Agosto, 2026'), findsOneWidget);
  });

  testWidgets('TaskRow renderiza "Sin fecha" si dueDate es null',
      (WidgetTester tester) async {
    final task = Task(
      id: 4,
      title: 'Tarea sin prisa',
      description: null,
      estimatedDuration: 15,
      priority: 0,
      dueDate: null,
      isCompleted: false,
    );

    await tester.pumpWidget(buildTestableTaskRow(task));

    expect(find.text('Sin fecha'), findsOneWidget);
  });

  testWidgets('TaskRow renderiza el menu de opciones (tres puntos)',
      (WidgetTester tester) async {
    final task = Task(
      id: 5,
      title: 'Revisar PRs',
      description: null,
      estimatedDuration: 60,
      priority: 3,
      dueDate: null,
      isCompleted: false,
    );

    await tester.pumpWidget(buildTestableTaskRow(task));

    expect(find.byIcon(Icons.more_vert), findsOneWidget);
  });
}
