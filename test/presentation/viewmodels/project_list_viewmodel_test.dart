import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/data/repositories/project_repository.dart';
import 'package:aegis/presentation/viewmodels/project_list_viewmodel.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/core/providers/repository_providers.dart';

class MockProjectRepository extends Mock implements ProjectRepository {}

class FakeProject extends Fake implements Project {}

class FakeProjectsCompanion extends Fake implements ProjectsCompanion {}

void main() {
  late MockProjectRepository mockRepository;
  late ProviderContainer container;
  ProviderSubscription? subscription;

  final project1 = Project(id: 1, name: 'Universidad', colorHex: '#FF0000');
  final project2 = Project(id: 2, name: 'Casa', colorHex: '#00FF00');

  setUpAll(() {
    registerFallbackValue(FakeProject());
    registerFallbackValue(FakeProjectsCompanion());
  });

  setUp(() {
    mockRepository = MockProjectRepository();

    when(() => mockRepository.watchAllProjects()).thenAnswer(
        (_) => Stream.fromFuture(Future.microtask(() => [project1, project2])));

    container = ProviderContainer(
      overrides: [
        projectRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );

    subscription = container.listen(projectListViewModelProvider, (_, __) {});
  });

  tearDown(() {
    subscription?.close();
    container.dispose();
  });

  group('ProjectListViewModel', () {
    test('Debe inicializarse y emitir la lista de proyectos del repositorio',
        () async {
      final projects =
          await container.read(projectListViewModelProvider.future);

      expect(projects.length, 2);
      expect(projects.first.name, 'Universidad');
    });

    test('addProject debe llamar a insertProject del repositorio', () async {
      final companion = const ProjectsCompanion(name: Value('Gimnasio'));
      when(() => mockRepository.insertProject(any()))
          .thenAnswer((_) async => 3);

      await container
          .read(projectListViewModelProvider.notifier)
          .addProject(companion);

      verify(() => mockRepository.insertProject(companion)).called(1);
    });

    test('updateProject debe llamar a updateProject del repositorio', () async {
      when(() => mockRepository.updateProject(any()))
          .thenAnswer((_) async => true);

      await container
          .read(projectListViewModelProvider.notifier)
          .updateProject(project1);

      verify(() => mockRepository.updateProject(project1)).called(1);
    });

    test('deleteProject debe llamar a deleteProject del repositorio', () async {
      when(() => mockRepository.deleteProject(any()))
          .thenAnswer((_) async => 1);

      await container
          .read(projectListViewModelProvider.notifier)
          .deleteProject(project1);

      verify(() => mockRepository.deleteProject(project1)).called(1);
    });
  });
}
