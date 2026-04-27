import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:aegis/presentation/viewmodels/calendar_viewmodel.dart';
import 'package:aegis/presentation/viewmodels/task_list_viewmodel.dart';
import 'package:aegis/presentation/screens/tasks/components/task_card.dart';
import 'package:aegis/presentation/screens/tasks/widgets/task_form_desktop.dart';
import 'package:aegis/presentation/screens/calendar/widgets/event_form_desktop.dart';

class CalendarScreenDesktop extends ConsumerWidget {
  const CalendarScreenDesktop({super.key});

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
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Calendario',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
            const Divider(height: 16, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TableCalendar<CalendarItem>(
                        locale: 'es_ES',
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2050, 12, 31),
                        focusedDay: state.focusedDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(state.selectedDay, day),
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
                          final normalizedDay =
                              DateTime(day.year, day.month, day.day);
                          return eventsMap[normalizedDay] ?? [];
                        },
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        shouldFillViewport: true,
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        calendarBuilders: CalendarBuilders(
                          selectedBuilder: (context, date, focusedDay) {
                            return Center(
                              child: Container(
                                width: 50,
                                height: 50,
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
                                width: 50,
                                height: 50,
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
                                offset: const Offset(0, 30),
                                child: Container(
                                  width: 6,
                                  height: 6,
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
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Planificación',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    barrierColor:
                                        Colors.black.withValues(alpha: 0.4),
                                    builder: (context) =>
                                        const EventFormDesktop(),
                                  );
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Nuevo Evento'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6366F1),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 32, color: Color(0xFFE2E8F0)),
                          Text(
                            DateFormat('EEEE, d MMMM', 'es')
                                .format(state.selectedDay)
                                .capitalize(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: selectedItems.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No hay eventos ni tareas para este día',
                                      style:
                                          TextStyle(color: Color(0xFF94A3B8)),
                                    ),
                                  )
                                : ListView(
                                    padding: EdgeInsets.zero,
                                    children: [
                                      if (events.isNotEmpty) ...[
                                        const Text(
                                          'Eventos',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        ...events.map((e) {
                                          final eventList =
                                              eventsListAsync.value ?? [];
                                          final eventObj = eventList
                                              .where((ev) => ev.id == e.id)
                                              .firstOrNull;

                                          if (eventObj == null) {
                                            return const SizedBox();
                                          }

                                          return _EventCard(
                                            item: e,
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                barrierColor: Colors.black
                                                    .withValues(alpha: 0.4),
                                                builder: (context) =>
                                                    EventFormDesktop(
                                                        event: eventObj),
                                              );
                                            },
                                          );
                                        }),
                                        const SizedBox(height: 24),
                                      ],
                                      if (calendarTasks.isNotEmpty) ...[
                                        const Text(
                                          'Tareas',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        ...calendarTasks.map((ct) {
                                          final taskList =
                                              tasksListAsync.value ?? [];
                                          final taskObj = taskList
                                              .where((t) => t.id == ct.id)
                                              .firstOrNull;

                                          if (taskObj == null) {
                                            return const SizedBox();
                                          }

                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 12.0),
                                            child: TaskCard(
                                              task: taskObj,
                                              onToggle: () => ref
                                                  .read(
                                                      taskListViewModelProvider
                                                          .notifier)
                                                  .toggleTaskCompletion(
                                                      taskObj),
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  barrierColor: Colors.black
                                                      .withValues(alpha: 0.4),
                                                  builder: (context) =>
                                                      TaskFormDesktop(
                                                          task: taskObj),
                                                );
                                              },
                                              onDelete: () => ref
                                                  .read(
                                                      taskListViewModelProvider
                                                          .notifier)
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
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
