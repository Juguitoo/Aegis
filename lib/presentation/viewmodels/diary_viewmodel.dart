import 'package:aegis/core/providers/repository_providers.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/data/repositories/diary_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final selectedDiaryDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final diaryViewModelProvider =
    StreamNotifierProvider<DiaryViewModel, List<DiaryNoteData>>(() {
  return DiaryViewModel();
});

final allDiaryNotesProvider = StreamProvider<List<DiaryNoteData>>((ref) {
  final repository = ref.watch(diaryRepositoryProvider);
  return repository.watchAllNotes();
});

class DiaryViewModel extends StreamNotifier<List<DiaryNoteData>> {
  late DiaryRepository _diaryRepository;

  @override
  Stream<List<DiaryNoteData>> build() {
    _diaryRepository = ref.watch(diaryRepositoryProvider);
    final selectedDate = ref.watch(selectedDiaryDateProvider);

    return _diaryRepository.watchNotesByDate(selectedDate);
  }

  Future<void> addNote(String content) async {
    if (content.trim().isEmpty) return;

    final selectedDate = ref.read(selectedDiaryDateProvider);
    final now = DateTime.now();
    final isToday = selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    final dateToSave = isToday
        ? null
        : DateTime(
            selectedDate.year, selectedDate.month, selectedDate.day, 12, 0);

    await _diaryRepository.addNote(content.trim(), date: dateToSave);
  }

  Future<void> deleteNote(int id) async {
    await _diaryRepository.deleteNoteById(id);
  }

  Future<void> updateNoteContent(int id, String newContent) async {
    if (newContent.trim().isEmpty) return;
    await _diaryRepository.updateNoteContent(id, newContent.trim());
  }
}
