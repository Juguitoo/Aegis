import 'dart:async';
import 'package:aegis/core/providers/repository_providers.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HabitWithEntries {
  final Habit habit;
  final List<HabitEntry> entries;

  HabitWithEntries({required this.habit, required this.entries});
}

final habitsStreamProvider = StreamProvider<List<Habit>>((ref) {
  return ref.watch(habitsRepositoryProvider).watchAllHabits();
});

final habitEntriesStreamProvider = StreamProvider<List<HabitEntry>>((ref) {
  return ref.watch(habitsRepositoryProvider).watchAllHabitEntries();
});

class HabitsViewModel extends AsyncNotifier<List<HabitWithEntries>> {
  @override
  FutureOr<List<HabitWithEntries>> build() async {
    final habits = await ref.watch(habitsStreamProvider.future);
    final entries = await ref.watch(habitEntriesStreamProvider.future);

    return habits.map((habit) {
      final habitEntries = entries.where((e) => e.habitId == habit.id).toList();
      return HabitWithEntries(habit: habit, entries: habitEntries);
    }).toList();
  }

  Future<void> addHabit(String name) async {
    if (name.trim().isEmpty) return;
    await ref.read(habitsRepositoryProvider).insertHabit(name.trim());
  }

  Future<void> updateHabit(int id, String newName) async {
    if (newName.trim().isEmpty) return;
    await ref.read(habitsRepositoryProvider).updateHabit(id, newName);
  }

  Future<void> deleteHabit(int id) async {
    await ref.read(habitsRepositoryProvider).deleteHabit(id);
  }

  Future<void> toggleHabitEntry(int habitId, DateTime date) async {
    await ref.read(habitsRepositoryProvider).toggleHabitEntry(habitId, date);
  }
}

final habitsViewModelProvider =
    AsyncNotifierProvider<HabitsViewModel, List<HabitWithEntries>>(() {
  return HabitsViewModel();
});
