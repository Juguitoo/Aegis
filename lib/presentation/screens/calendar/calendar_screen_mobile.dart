import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:aegis/presentation/viewmodels/calendar_viewmodel.dart';
import 'package:aegis/presentation/viewmodels/task_list_viewmodel.dart';
import 'package:aegis/presentation/screens/tasks/components/task_card.dart';
import 'package:aegis/presentation/screens/tasks/components/task_form_mobile.dart';
import 'package:aegis/presentation/screens/calendar/components/event_form_mobile.dart';
import 'package:aegis/presentation/screens/settings/settings_screen_mobile.dart';

class CalendarScreenMobile extends ConsumerWidget {
  const CalendarScreenMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarViewModelProvider);
    final eventsMap = ref.watch(calendarItemsProvider);
    final tasksListAsync = ref.watch(taskListViewModelProvider);
    final eventsListAsync = ref.watch(eventsStreamProvider);

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final normalizedSelectedDay = DateTime(
        state.selectedDay.year, state.selectedDay.month, state.selectedDay.day);
    final selectedItems = eventsMap[normalizedSelectedDay] ?? [];

    final events =
        selectedItems.where((i) => i.type == CalendarItemType.event).toList();
    final calendarTasks =
        selectedItems.where((i) => i.type == CalendarItemType.task).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Calendario',
            style: textTheme.displayLarge,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(Icons.settings, color: colorScheme.onSurface),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreenMobile()),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Divider(color: colorScheme.outline.withValues(alpha: 0.2), height: 1),
          Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.only(bottom: 16),
            child: TableCalendar<CalendarItem>(
              locale: 'es_ES',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2050, 12, 31),
              focusedDay: state.focusedDay,
              daysOfWeekHeight: 32,
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
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                weekendStyle: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              calendarStyle: CalendarStyle(
                defaultTextStyle: TextStyle(color: colorScheme.onSurface),
                weekendTextStyle:
                    TextStyle(color: colorScheme.onSurfaceVariant),
                outsideTextStyle: TextStyle(
                    color: colorScheme.outline.withValues(alpha: 0.5)),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronIcon: Icon(Icons.chevron_left,
                    color: colorScheme.onSurfaceVariant),
                rightChevronIcon: Icon(Icons.chevron_right,
                    color: colorScheme.onSurfaceVariant),
                titleTextStyle: textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                selectedBuilder: (context, date, focusedDay) {
                  return Center(
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          color: colorScheme.onPrimary,
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
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
                markerBuilder: (context, date, items) {
                  if (items.isEmpty) return const SizedBox();

                  if (isSameDay(state.selectedDay, date)) {
                    return const SizedBox();
                  }

                  final hasTasks =
                      items.any((i) => i.type == CalendarItemType.task);
                  final hasEvents =
                      items.any((i) => i.type == CalendarItemType.event);

                  Color indicatorColor = colorScheme.primary;
                  if (hasTasks && hasEvents) {
                    indicatorColor = Colors.purple.shade400;
                  } else if (hasEvents) {
                    indicatorColor = Colors.orange.shade400;
                  }

                  return Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: indicatorColor.withValues(alpha: 0.05),
                        border: Border.all(
                          color: indicatorColor.withValues(alpha: 0.6),
                          width: 2.0,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('EEEE, d MMMM', 'es')
                          .format(state.selectedDay)
                          .capitalize(),
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const EventFormMobile(),
                        );
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add,
                            color: colorScheme.primary, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (selectedItems.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 32.0),
                    child: Center(
                      child: Text(
                        'No hay eventos ni tareas para este día',
                        style: TextStyle(color: colorScheme.outline),
                      ),
                    ),
                  ),
                if (events.isNotEmpty) ...[
                  Text(
                    'Eventos',
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...events.map((e) {
                    final eventList = eventsListAsync.value ?? [];
                    final eventObj =
                        eventList.where((ev) => ev.id == e.id).firstOrNull;
                    if (eventObj == null) return const SizedBox();

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
                  Text(
                    'Tareas',
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...calendarTasks.map((ct) {
                    final taskList = tasksListAsync.value ?? [];
                    final taskObj =
                        taskList.where((t) => t.id == ct.id).firstOrNull;

                    if (taskObj == null) return const SizedBox();

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
                            useSafeArea: true,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.15)),
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
                  decoration: BoxDecoration(
                      color: colorScheme.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ]),
                  child:
                      Icon(Icons.event, color: colorScheme.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.isAllDay
                            ? 'Todo el día'
                            : DateFormat('HH:mm').format(item.date),
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
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
