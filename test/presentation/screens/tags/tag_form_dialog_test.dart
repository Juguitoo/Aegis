import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/data/repositories/tag_repository.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/core/providers/repository_providers.dart';
import 'package:aegis/presentation/screens/tags/widgets/tag_form_dialog.dart';

class MockTagRepository extends Mock implements TagRepository {}

class FakeTagsCompanion extends Fake implements TagsCompanion {}

void main() {
  late MockTagRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeTagsCompanion());
  });

  setUp(() {
    mockRepository = MockTagRepository();

    when(() => mockRepository.watchAllTags())
        .thenAnswer((_) => Stream.value([]));
  });

  Widget buildTestableDialog({Tag? existingTag}) {
    return ProviderScope(
      overrides: [
        tagRepositoryProvider.overrideWithValue(mockRepository),
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
                        TagFormDialog(existingTag: existingTag),
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

  group('TagFormDialog Tests de Validacion', () {
    testWidgets('Muestra validacion si se intenta guardar sin nombre',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableDialog());

      await tester.tap(find.text('Abrir Dialogo'));
      await tester.pumpAndSettle();

      expect(find.text('Nueva Etiqueta'), findsOneWidget);

      await tester.tap(find.text('Guardar'));
      await tester.pump(); // Iniciamos animación del SnackBar

      // Comprobamos que el mensaje de error aparece
      expect(find.byType(SnackBar), findsOneWidget);

      // Comprobamos que NO se ha guardado en base de datos
      verifyNever(() => mockRepository.insertTag(any()));

      // Limpiamos los Snackbars para que el test cierre limpiamente
      ScaffoldMessenger.of(tester.element(find.byType(Scaffold)))
          .clearSnackBars();
      await tester.pumpAndSettle();
    });

    testWidgets(
        'Llama al repositorio y cierra el dialogo si el nombre es valido',
        (WidgetTester tester) async {
      when(() => mockRepository.insertTag(any())).thenAnswer((_) async => 1);

      await tester.pumpWidget(buildTestableDialog());

      await tester.tap(find.text('Abrir Dialogo'));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextField).first, 'Etiqueta de Prueba');
      await tester.pump();

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      verify(() => mockRepository.insertTag(any())).called(1);

      expect(find.text('Nueva Etiqueta'), findsNothing);
    });

    testWidgets('El formulario se pre-rellena en modo edicion',
        (WidgetTester tester) async {
      final tagToEdit = Tag(
        id: 1,
        name: 'Gimnasio',
        description: 'Rutina de tarde',
        colorHex: '#000000',
      );

      await tester.pumpWidget(buildTestableDialog(existingTag: tagToEdit));

      await tester.tap(find.text('Abrir Dialogo'));
      await tester.pumpAndSettle();

      expect(find.text('Editar Etiqueta'), findsOneWidget);
      expect(find.text('Gimnasio'), findsOneWidget);
    });
  });
}
