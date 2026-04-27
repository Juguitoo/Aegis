import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:aegis/presentation/viewmodels/calendar_viewmodel.dart';
import 'package:aegis/presentation/viewmodels/task_list_viewmodel.dart';
import 'package:aegis/presentation/screens/tasks/components/task_card.dart';
import 'package:aegis/presentation/screens/tasks/widgets/task_form_mobile.dart';
import 'package:aegis/presentation/screens/calendar/widgets/event_form_mobile.dart';

class CalendarScreenMobile extends ConsumerWidget {
  const CalendarScreenMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarViewModelProvider);
    final eventsMap = ref.watch(calendarItemsProvider);
    final tasksListAsync = ref.watch(taskListViewModelProvider);
    final eventsListAsync = ref.watch(eventsStreamProvider);

    final normalizedSelectedDay = DateTime(
        state.selectedDay.year, state.selectedDay.month, state.selectedDay.day);
    final selectedItems = eventsMap[normalizedSelectedDay] ?? [];

    final events =
        selectedItems.where((i) => i.type == CalendarItemType.event).toList();
    final calendarTasks =
        selectedItems.where((i) => i.type == CalendarItemType.task).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Calendario',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.add, color: Color(0xFF6366F1), size: 28),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const EventFormMobile(),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 16),
            child: TableCalendar<CalendarItem>(
              locale: 'es_ES',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2050, 12, 31),
              focusedDay: state.focusedDay,
              selectedDayPredicate: (day) => isSameDay(state.selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                ref
                    .read(calendarViewModelProvider.notifier)
                    .onDaySelected(selectedDay, focusedDay);
              },
              onPageChanged: (focusedDay) {
                ref
                    .read(calendarViewModelProvider.notifier)
                    .onPageChanged(focusedDay);
              },
              eventLoader: (day) {
                final normalizedDay = DateTime(day.year, day.month, day.day);
                return eventsMap[normalizedDay] ?? [];
              },
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarBuilders: CalendarBuilders(
                selectedBuilder: (context, date, focusedDay) {
                  return Center(
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6366F1),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${date.day}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
                todayBuilder: (context, date, focusedDay) {
                  return Center(
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEEF2FF),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${date.day}',
                        style: const TextStyle(
                          color: Color(0xFF6366F1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
                markerBuilder: (context, date, events) {
                  if (events.isEmpty) return const SizedBox();
                  return Align(
                    alignment: Alignment.center,
                    child: Transform.translate(
                      offset: const Offset(0, 22),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Color(0xFF6366F1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  DateFormat('EEEE, d MMMM', 'es')
                      .format(state.selectedDay)
                      .capitalize(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),
                if (selectedItems.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 32.0),
                    child: Center(
                      child: Text(
                        'No hay eventos ni tareas para este día',
                        style: TextStyle(color: Color(0xFF94A3B8)),
                      ),
                    ),
                  ),
                if (events.isNotEmpty) ...[
                  const Text(
                    'Eventos',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...events.map((e) {
                    final eventList = eventsListAsync.value ?? [];
                    final eventObj =
                        eventList.where((ev) => ev.id == e.id).firstOrNull;

                    if (eventObj == null) {
                      return const SizedBox();
                    }

                    return _EventCard(
                      item: e,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) =>
                              EventFormMobile(event: eventObj),
                        );
                      },
                    );
                  }),
                  const SizedBox(height: 16),
                ],
                if (calendarTasks.isNotEmpty) ...[
                  const Text(
                    'Tareas',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...calendarTasks.map((ct) {
                    final taskList = tasksListAsync.value ?? [];
                    final taskObj =
                        taskList.where((t) => t.id == ct.id).firstOrNull;

                    if (taskObj == null) {
                      return const SizedBox();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TaskCard(
                        task: taskObj,
                        onToggle: () => ref
                            .read(taskListViewModelProvider.notifier)
                            .toggleTaskCompletion(taskObj),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => TaskFormMobile(task: taskObj),
                          );
                        },
                        onDelete: () => ref
                            .read(taskListViewModelProvider.notifier)
                            .deleteTask(taskObj),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final CalendarItem item;
  final VoidCallback? onTap;

  const _EventCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E7FF)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.event,
                      color: Color(0xFF6366F1), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.isAllDay
                            ? 'Todo el día'
                            : DateFormat('HH:mm').format(item.date),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6366F1),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
