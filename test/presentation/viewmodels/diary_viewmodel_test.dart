import 'package:aegis/core/providers/repository_providers.dart';
import 'package:aegis/data/repositories/diary_repository.dart';
import 'package:aegis/presentation/viewmodels/diary_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDiaryRepository extends Mock implements DiaryRepository {}

void main() {
  late MockDiaryRepository mockDiaryRepository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(DateTime.now());
  });

  setUp(() {
    mockDiaryRepository = MockDiaryRepository();

    when(() => mockDiaryRepository.watchAllNotes())
        .thenAnswer((_) => Stream.fromFuture(Future.microtask(() => [])));

    container = ProviderContainer(
      overrides: [
        diaryRepositoryProvider.overrideWithValue(mockDiaryRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('DiaryViewModel Logic', () {
    test('addNote no debe llamar al repositorio si el contenido está vacío',
        () async {
      final viewModel = container.read(diaryViewModelProvider.notifier);

      await viewModel.addNote('   ');
      await viewModel.addNote('');

      verifyNever(
          () => mockDiaryRepository.addNote(any(), date: any(named: 'date')));
    });

    test('addNote para el día de HOY debe pasar date: null al repositorio',
        () async {
      when(() => mockDiaryRepository.addNote(any(), date: any(named: 'date')))
          .thenAnswer((_) async => 1);

      container.read(selectedDiaryDateProvider.notifier).state = DateTime.now();

      final viewModel = container.read(diaryViewModelProvider.notifier);
      await viewModel.addNote('Nota de hoy');

      verify(() => mockDiaryRepository.addNote('Nota de hoy', date: null))
          .called(1);
    });

    test('addNote para un día DISTINTO a hoy debe guardar la nota a las 12:00',
        () async {
      when(() => mockDiaryRepository.addNote(any(), date: any(named: 'date')))
          .thenAnswer((_) async => 1);

      final pastDate = DateTime(2024, 3, 15);
      container.read(selectedDiaryDateProvider.notifier).state = pastDate;

      final viewModel = container.read(diaryViewModelProvider.notifier);
      await viewModel.addNote('Nota del pasado');

      final expectedDate = DateTime(2024, 3, 15, 12, 0);
      verify(() => mockDiaryRepository.addNote('Nota del pasado',
          date: expectedDate)).called(1);
    });

    test('updateNoteContent no debe actualizar si el texto está vacío',
        () async {
      final viewModel = container.read(diaryViewModelProvider.notifier);

      await viewModel.updateNoteContent(1, '   ');

      verifyNever(() => mockDiaryRepository.updateNoteContent(any(), any()));
    });

    test(
        'updateNoteContent debe llamar al repositorio con el texto limpio (trim)',
        () async {
      when(() => mockDiaryRepository.updateNoteContent(any(), any()))
          .thenAnswer((_) async => 1);

      final viewModel = container.read(diaryViewModelProvider.notifier);
      await viewModel.updateNoteContent(1, '  Nota editada  ');

      verify(() => mockDiaryRepository.updateNoteContent(1, 'Nota editada'))
          .called(1);
    });

    test('deleteNoteById debe llamar al método correspondiente del repositorio',
        () async {
      when(() => mockDiaryRepository.deleteNoteById(any()))
          .thenAnswer((_) async => 1);

      final viewModel = container.read(diaryViewModelProvider.notifier);
      await viewModel.deleteNote(5);

      verify(() => mockDiaryRepository.deleteNoteById(5)).called(1);
    });
  });
}
