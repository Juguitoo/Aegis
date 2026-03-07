import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/data/repositories/tag_repository.dart';
import 'package:aegis/presentation/viewmodels/tag_list_viewmodel.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/core/providers/repository_providers.dart';

class MockTagRepository extends Mock implements TagRepository {}

class FakeTag extends Fake implements Tag {}

class FakeTagsCompanion extends Fake implements TagsCompanion {}

void main() {
  late MockTagRepository mockRepository;
  late ProviderContainer container;
  ProviderSubscription? subscription;

  final tag1 = Tag(id: 1, name: 'Urgente', colorHex: '#EF4444');
  final tag2 = Tag(id: 2, name: 'Email', colorHex: '#3B82F6');

  setUpAll(() {
    registerFallbackValue(FakeTag());
    registerFallbackValue(FakeTagsCompanion());
  });

  setUp(() {
    mockRepository = MockTagRepository();

    when(() => mockRepository.watchAllTags()).thenAnswer(
        (_) => Stream.fromFuture(Future.microtask(() => [tag1, tag2])));

    container = ProviderContainer(
      overrides: [
        tagRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );

    subscription = container.listen(tagListViewModelProvider, (_, __) {});
  });

  tearDown(() {
    subscription?.close();
    container.dispose();
  });

  group('TagListViewModel', () {
    test('Debe inicializarse y emitir la lista de etiquetas del repositorio',
        () async {
      final tags = await container.read(tagListViewModelProvider.future);

      expect(tags.length, 2);
      expect(tags.first.name, 'Urgente');
    });

    test('addTag debe llamar a insertTag del repositorio', () async {
      final companion = const TagsCompanion(name: Value('Llamada'));
      when(() => mockRepository.insertTag(any())).thenAnswer((_) async => 3);

      await container.read(tagListViewModelProvider.notifier).addTag(companion);

      verify(() => mockRepository.insertTag(companion)).called(1);
    });

    test('updateTag debe llamar a updateTag del repositorio', () async {
      when(() => mockRepository.updateTag(any())).thenAnswer((_) async => true);

      await container.read(tagListViewModelProvider.notifier).updateTag(tag1);

      verify(() => mockRepository.updateTag(tag1)).called(1);
    });

    test('deleteTag debe llamar a deleteTag del repositorio', () async {
      when(() => mockRepository.deleteTag(any())).thenAnswer((_) async => 1);

      await container.read(tagListViewModelProvider.notifier).deleteTag(tag1);

      verify(() => mockRepository.deleteTag(tag1)).called(1);
    });
  });
}
