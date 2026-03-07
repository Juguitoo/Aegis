import 'package:aegis/presentation/screens/projects/widgets/project_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/data/repositories/project_repository.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/core/providers/repository_providers.dart';

class MockProjectRepository extends Mock implements ProjectRepository {}

class FakeProjectsCompanion extends Fake implements ProjectsCompanion {}

void main() {
  late MockProjectRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeProjectsCompanion());
  });

  setUp(() {
    mockRepository = MockProjectRepository();

    when(() => mockRepository.watchAllProjects())
        .thenAnswer((_) => Stream.value([]));
  });

  Widget buildTestableDialog({Project? existingProject}) {
    return ProviderScope(
      overrides: [
        projectRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        ProjectFormDialog(existingProject: existingProject),
                  );
                },
                child: const Text('Abrir Dialogo'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('ProjectFormDialog Tests de Validacion', () {
    testWidgets('Muestra validacion si se intenta guardar sin nombre',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableDialog());

      await tester.tap(find.text('Abrir Dialogo'));
      await tester.pumpAndSettle();

      expect(find.text('Nuevo Proyecto'), findsOneWidget);

      await tester.tap(find.text('Guardar'));
      await tester.pump();

      // Comprobamos la alerta
      expect(find.byType(SnackBar), findsOneWidget);

      // Comprobamos la seguridad (no guarda datos)
      verifyNever(() => mockRepository.insertProject(any()));

      // Limpieza
      ScaffoldMessenger.of(tester.element(find.byType(Scaffold)))
          .clearSnackBars();
      await tester.pumpAndSettle();
    });

    testWidgets(
        'Llama al repositorio y cierra el dialogo si el nombre es valido',
        (WidgetTester tester) async {
      when(() => mockRepository.insertProject(any()))
          .thenAnswer((_) async => 1);

      await tester.pumpWidget(buildTestableDialog());

      await tester.tap(find.text('Abrir Dialogo'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Proyecto Prueba');
      await tester.pump();

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      verify(() => mockRepository.insertProject(any())).called(1);

      expect(find.text('Nuevo Proyecto'), findsNothing);
    });

    testWidgets('El formulario se pre-rellena en modo edicion',
        (WidgetTester tester) async {
      final projectToEdit = Project(
        id: 1,
        name: 'Desarrollo App',
        colorHex: '#6366F1',
      );

      await tester
          .pumpWidget(buildTestableDialog(existingProject: projectToEdit));

      await tester.tap(find.text('Abrir Dialogo'));
      await tester.pumpAndSettle();

      expect(find.text('Editar Proyecto'), findsOneWidget);
      expect(find.text('Desarrollo App'), findsOneWidget);
    });
  });
}
