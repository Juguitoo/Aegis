import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/data/repositories/area_repository.dart';
import 'package:aegis/presentation/viewmodels/area_list_viewmodel.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/core/providers/repository_providers.dart';

class MockAreaRepository extends Mock implements AreaRepository {}

class FakeArea extends Fake implements Area {}

class FakeAreasCompanion extends Fake implements AreasCompanion {}

void main() {
  late MockAreaRepository mockRepository;
  late ProviderContainer container;
  ProviderSubscription? subscription;

  final area1 = Area(id: 1, name: 'Universidad', colorHex: '#FF0000');
  final area2 = Area(id: 2, name: 'Casa', colorHex: '#00FF00');

  setUpAll(() {
    registerFallbackValue(FakeArea());
    registerFallbackValue(FakeAreasCompanion());
  });

  setUp(() {
    mockRepository = MockAreaRepository();

    when(() => mockRepository.watchAllAreas()).thenAnswer(
        (_) => Stream.fromFuture(Future.microtask(() => [area1, area2])));

    container = ProviderContainer(
      overrides: [
        areaRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );

    subscription = container.listen(areaListViewModelProvider, (_, __) {});
  });

  tearDown(() {
    subscription?.close();
    container.dispose();
  });

  group('AreaListViewModel', () {
    test('Debe inicializarse y emitir la lista de proyectos del repositorio',
        () async {
      final areas = await container.read(areaListViewModelProvider.future);

      expect(areas.length, 2);
      expect(areas.first.name, 'Universidad');
    });

    test('addArea debe llamar a insertArea del repositorio', () async {
      when(() => mockRepository.insertArea(any())).thenAnswer((_) async => 3);

      await container
          .read(areaListViewModelProvider.notifier)
          .addArea('Gimnasio', '#FF0000', 'Proyecto para el gimnasio');

      final captured =
          verify(() => mockRepository.insertArea(captureAny())).captured;
      final capturedCompanion = captured.first as AreasCompanion;

      expect(capturedCompanion.name.value, 'Gimnasio');
      expect(capturedCompanion.colorHex.value, '#FF0000');
      expect(capturedCompanion.description.value, 'Proyecto para el gimnasio');
    });

    test('updateArea debe llamar a updateArea del repositorio', () async {
      when(() => mockRepository.updateArea(any()))
          .thenAnswer((_) async => true);

      await container
          .read(areaListViewModelProvider.notifier)
          .updateArea(area1);

      verify(() => mockRepository.updateArea(area1)).called(1);
    });

    test('deleteArea debe llamar a deleteArea del repositorio', () async {
      when(() => mockRepository.deleteArea(any())).thenAnswer((_) async => 1);

      await container
          .read(areaListViewModelProvider.notifier)
          .deleteArea(area1);

      verify(() => mockRepository.deleteArea(area1)).called(1);
    });
  });
}
