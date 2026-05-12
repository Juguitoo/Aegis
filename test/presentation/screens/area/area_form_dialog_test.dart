import 'package:aegis/presentation/screens/areas/components/area_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/data/repositories/area_repository.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/core/providers/repository_providers.dart';

class MockAreaRepository extends Mock implements AreaRepository {}

class FakeAreasCompanion extends Fake implements AreasCompanion {}

void main() {
  late MockAreaRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeAreasCompanion());
  });

  setUp(() {
    mockRepository = MockAreaRepository();

    when(() => mockRepository.watchAllAreas())
        .thenAnswer((_) => Stream.value([]));
  });

  Widget buildTestableDialog({Area? existingArea}) {
    return ProviderScope(
      overrides: [
        areaRepositoryProvider.overrideWithValue(mockRepository),
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
                        AreaFormDialog(existingArea: existingArea),
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

  group('AreaFormDialog Tests de Validacion', () {
    testWidgets('Muestra validacion si se intenta guardar sin nombre',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableDialog());

      await tester.tap(find.text('Abrir Dialogo'));
      await tester.pumpAndSettle();

      expect(find.text('Nuevo área'), findsOneWidget);

      await tester.tap(find.text('Guardar'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);

      verifyNever(() => mockRepository.insertArea(any()));

      ScaffoldMessenger.of(tester.element(find.byType(Scaffold)))
          .clearSnackBars();
      await tester.pumpAndSettle();
    });

    testWidgets(
        'Llama al repositorio y cierra el dialogo si el nombre es valido',
        (WidgetTester tester) async {
      when(() => mockRepository.insertArea(any())).thenAnswer((_) async => 1);

      await tester.pumpWidget(buildTestableDialog());

      await tester.tap(find.text('Abrir Dialogo'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Área Prueba');
      await tester.pump();

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      verify(() => mockRepository.insertArea(any())).called(1);

      expect(find.text('Nuevo área'), findsNothing);
    });

    testWidgets('El formulario se pre-rellena en modo edicion',
        (WidgetTester tester) async {
      final areaToEdit = Area(
        id: 1,
        name: 'Desarrollo App',
        colorHex: '#6366F1',
      );

      await tester.pumpWidget(buildTestableDialog(existingArea: areaToEdit));

      await tester.tap(find.text('Abrir Dialogo'));
      await tester.pumpAndSettle();

      expect(find.text('Editar área'), findsOneWidget);
      expect(find.text('Desarrollo App'), findsOneWidget);
    });
  });
}
