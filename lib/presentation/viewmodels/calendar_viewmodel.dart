import 'package:aegis/core/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/presentation/viewmodels/task_list_viewmodel.dart';
import 'package:flutter_riverpod/legacy.dart';

enum CalendarItemType { task, event }

class CalendarItem {
  final int id;
  final String title;
  final DateTime date;
  final CalendarItemType type;
  final bool isCompleted;
  final bool isAllDay;

  CalendarItem({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    this.isCompleted = false,
    this.isAllDay = false,
  });
}

final eventsStreamProvider = StreamProvider<List<Event>>((ref) {
  return ref.watch(eventsRepositoryProvider).watchAllEvents();
});

final calendarItemsProvider =
    Provider<Map<DateTime, List<CalendarItem>>>((ref) {
  final tasksAsync = ref.watch(taskListViewModelProvider);
  final eventsAsync = ref.watch(eventsStreamProvider);

  final Map<DateTime, List<CalendarItem>> map = {};

  if (tasksAsync is AsyncData && tasksAsync.value != null) {
    for (final task in tasksAsync.value!) {
      if (task.dueDate != null) {
        final date = DateTime(
            task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);

        map.putIfAbsent(date, () => []);
        map[date]!.add(CalendarItem(
          id: task.id,
          title: task.title,
          date: task.dueDate!,
          type: CalendarItemType.task,
          isCompleted: task.completedAt != null,
        ));
      }
    }
  }

  if (eventsAsync is AsyncData && eventsAsync.value != null) {
    for (final event in eventsAsync.value!) {
      final date = DateTime(event.date.year, event.date.month, event.date.day);

      map.putIfAbsent(date, () => []);
      map[date]!.add(CalendarItem(
        id: event.id,
        title: event.title,
        date: event.date,
        type: CalendarItemType.event,
        isAllDay: event.isAllDay,
      ));
    }
  }

  return map;
});

class CalendarState {
  final DateTime selectedDay;
  final DateTime focusedDay;

  CalendarState({
    required this.selectedDay,
    required this.focusedDay,
  });

  CalendarState copyWith({
    DateTime? selectedDay,
    DateTime? focusedDay,
  }) {
    return CalendarState(
      selectedDay: selectedDay ?? this.selectedDay,
      focusedDay: focusedDay ?? this.focusedDay,
    );
  }
}

class CalendarViewModel extends StateNotifier<CalendarState> {
  CalendarViewModel()
      : super(CalendarState(
          selectedDay: DateTime.now(),
          focusedDay: DateTime.now(),
        ));

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    state = state.copyWith(
      selectedDay: selectedDay,
      focusedDay: focusedDay,
    );
  }

  void onPageChanged(DateTime focusedDay) {
    state = state.copyWith(focusedDay: focusedDay);
  }
}

final calendarViewModelProvider =
    StateNotifierProvider<CalendarViewModel, CalendarState>((ref) {
  return CalendarViewModel();
});
