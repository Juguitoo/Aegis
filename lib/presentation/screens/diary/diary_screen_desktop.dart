import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:aegis/presentation/viewmodels/diary_viewmodel.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'diary_state_mixin.dart';

class DiaryScreenDesktop extends ConsumerStatefulWidget {
  const DiaryScreenDesktop({super.key});

  @override
  ConsumerState<DiaryScreenDesktop> createState() => _DiaryScreenDesktopState();
}

class _DiaryScreenDesktopState extends ConsumerState<DiaryScreenDesktop>
    with DiaryStateMixin {
  DateTime _focusedDay = DateTime.now();

  String _formatRecentDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) return 'Hoy';
    if (targetDate == yesterday) return 'Ayer';

    final monthFormat = DateFormat('MMM', 'es');
    return '${date.day} ${monthFormat.format(date)}';
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDiaryDateProvider);
    final notesAsyncValue = ref.watch(diaryViewModelProvider);
    final allNotesAsyncValue = ref.watch(allDiaryNotesProvider);
    final viewModel = ref.read(diaryViewModelProvider.notifier);

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Diario',
              style: textTheme.displayMedium?.copyWith(fontSize: 32),
            ),
            Divider(
                height: 16, color: colorScheme.outline.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 320,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color:
                                    colorScheme.outline.withValues(alpha: 0.1)),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    colorScheme.shadow.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: allNotesAsyncValue.when(
                              data: (allNotes) {
                                return TableCalendar<DiaryNoteData>(
                                  locale: 'es_ES',
                                  firstDay: DateTime.utc(2020, 1, 1),
                                  lastDay: DateTime.utc(2030, 12, 31),
                                  focusedDay: _focusedDay,
                                  selectedDayPredicate: (day) =>
                                      isSameDay(selectedDate, day),
                                  onDaySelected: (selectedDay, focusedDay) {
                                    cancelEdit();
                                    ref
                                        .read(
                                            selectedDiaryDateProvider.notifier)
                                        .state = selectedDay;
                                    setState(() {
                                      _focusedDay = focusedDay;
                                    });
                                  },
                                  onPageChanged: (focusedDay) {
                                    setState(() {
                                      _focusedDay = focusedDay;
                                    });
                                  },
                                  eventLoader: (day) {
                                    return allNotes
                                        .where((note) =>
                                            isSameDay(note.createdAt, day))
                                        .toList();
                                  },
                                  daysOfWeekStyle: DaysOfWeekStyle(
                                    weekdayStyle: TextStyle(
                                        color: colorScheme.onSurfaceVariant,
                                        fontSize: 13),
                                    weekendStyle: TextStyle(
                                        color: colorScheme.onSurfaceVariant,
                                        fontSize: 13),
                                  ),
                                  headerStyle: HeaderStyle(
                                    formatButtonVisible: false,
                                    titleCentered: true,
                                    leftChevronIcon: Icon(Icons.chevron_left,
                                        color: colorScheme.onSurfaceVariant),
                                    rightChevronIcon: Icon(Icons.chevron_right,
                                        color: colorScheme.onSurfaceVariant),
                                    titleTextStyle: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface),
                                  ),
                                  calendarStyle: CalendarStyle(
                                    defaultTextStyle:
                                        TextStyle(color: colorScheme.onSurface),
                                    weekendTextStyle: TextStyle(
                                        color: colorScheme.onSurfaceVariant),
                                    outsideTextStyle: TextStyle(
                                        color: colorScheme.outline
                                            .withValues(alpha: 0.5)),
                                    todayDecoration: BoxDecoration(
                                      color: colorScheme.secondary,
                                      shape: BoxShape.circle,
                                    ),
                                    todayTextStyle:
                                        TextStyle(color: colorScheme.onSurface),
                                    selectedDecoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    markerDecoration: BoxDecoration(
                                      color: colorScheme.error,
                                      shape: BoxShape.circle,
                                    ),
                                    markersMaxCount: 1,
                                  ),
                                );
                              },
                              loading: () => SizedBox(
                                  height: 300,
                                  child: Center(
                                      child: CircularProgressIndicator(
                                          color: colorScheme.primary))),
                              error: (_, __) => SizedBox(
                                  height: 300,
                                  child: Center(
                                      child: Text('Error al cargar calendario',
                                          style: TextStyle(
                                              color: colorScheme.error)))),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Entradas Recientes',
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: allNotesAsyncValue.when(
                            data: (allNotes) {
                              var uniqueDays = allNotes
                                  .map((n) => DateTime(n.createdAt.year,
                                      n.createdAt.month, n.createdAt.day))
                                  .toSet()
                                  .toList();

                              uniqueDays.sort((a, b) => b.compareTo(a));

                              uniqueDays = uniqueDays.take(7).toList();

                              if (uniqueDays.isEmpty) {
                                return Text('No hay entradas recientes',
                                    style:
                                        TextStyle(color: colorScheme.outline));
                              }

                              return ListView.builder(
                                itemCount: uniqueDays.length,
                                itemBuilder: (context, index) {
                                  final date = uniqueDays[index];
                                  final isSelected =
                                      isSameDay(date, selectedDate);

                                  return MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () {
                                        cancelEdit();
                                        ref
                                            .read(selectedDiaryDateProvider
                                                .notifier)
                                            .state = date;
                                        setState(() {
                                          _focusedDay = date;
                                        });
                                      },
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? colorScheme.primary
                                                  .withValues(alpha: 0.1)
                                              : colorScheme.surface,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isSelected
                                                ? colorScheme.primary
                                                    .withValues(alpha: 0.5)
                                                : colorScheme.outline
                                                    .withValues(alpha: 0.1),
                                          ),
                                        ),
                                        child: Text(
                                          _formatRecentDate(date),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? colorScheme.primary
                                                : colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            loading: () => Center(
                                child: CircularProgressIndicator(
                                    color: colorScheme.primary)),
                            error: (_, __) => const Center(
                                child: Text('Error al cargar recientes')),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.1)),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 32, top: 32, right: 32, bottom: 16),
                            child: Text(
                              'Notas',
                              style: textTheme.displayMedium
                                  ?.copyWith(fontSize: 32),
                            ),
                          ),
                          Expanded(
                            child: notesAsyncValue.when(
                              loading: () => Center(
                                  child: CircularProgressIndicator(
                                      color: colorScheme.primary)),
                              error: (error, stack) => Center(
                                  child: Text('Error: $error',
                                      style:
                                          TextStyle(color: colorScheme.error))),
                              data: (allNotes) {
                                final filteredNotes = allNotes
                                    .where((note) =>
                                        isSameDay(note.createdAt, selectedDate))
                                    .toList();

                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  scrollToBottom();
                                });

                                if (filteredNotes.isEmpty) {
                                  return Center(
                                    child: Text(
                                      'No hay notas para este día',
                                      style: TextStyle(
                                          color: colorScheme.outline,
                                          fontSize: 16),
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  controller: scrollController,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32.0, vertical: 16.0),
                                  itemCount: filteredNotes.length,
                                  itemBuilder: (context, index) {
                                    final note = filteredNotes[index];
                                    final timeString =
                                        '${note.createdAt.hour.toString().padLeft(2, '0')}:${note.createdAt.minute.toString().padLeft(2, '0')}';
                                    final isBeingEdited =
                                        editingNoteId == note.id;

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: isBeingEdited
                                            ? colorScheme.primary
                                                .withValues(alpha: 0.1)
                                            : colorScheme.surface,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isBeingEdited
                                              ? colorScheme.primary
                                              : colorScheme.outline
                                                  .withValues(alpha: 0.2),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: colorScheme.shadow
                                                .withValues(alpha: 0.05),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                timeString,
                                                style: textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  MouseRegion(
                                                    cursor: SystemMouseCursors
                                                        .click,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          editingNoteId =
                                                              note.id;
                                                          noteController.text =
                                                              note.content;
                                                        });
                                                        focusNode
                                                            .requestFocus();
                                                      },
                                                      child: Icon(
                                                        Icons.edit_outlined,
                                                        size: 18,
                                                        color: colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  MouseRegion(
                                                    cursor: SystemMouseCursors
                                                        .click,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        if (editingNoteId ==
                                                            note.id) {
                                                          cancelEdit();
                                                        }
                                                        viewModel.deleteNote(
                                                            note.id);
                                                      },
                                                      child: Icon(
                                                        Icons.delete_outline,
                                                        size: 18,
                                                        color: colorScheme
                                                            .onSurfaceVariant,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            note.content,
                                            style:
                                                textTheme.bodyLarge?.copyWith(
                                              height: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(24),
                            child: Container(
                              decoration: BoxDecoration(
                                color: colorScheme.secondary,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                children: [
                                  if (editingNoteId != null)
                                    IconButton(
                                      icon: Icon(Icons.close,
                                          color: colorScheme.onSurfaceVariant),
                                      onPressed: cancelEdit,
                                    ),
                                  Expanded(
                                    child: TextField(
                                      controller: noteController,
                                      focusNode: focusNode,
                                      textInputAction: TextInputAction.send,
                                      onSubmitted: (_) =>
                                          handleSubmit(viewModel),
                                      style: TextStyle(
                                          color: colorScheme.onSurface),
                                      decoration: InputDecoration(
                                        hintText: editingNoteId != null
                                            ? 'Editando nota...'
                                            : 'Escribe tu nota...',
                                        hintStyle: TextStyle(
                                            color:
                                                colorScheme.onSurfaceVariant),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal:
                                                editingNoteId != null ? 0 : 24,
                                            vertical: 18),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: IconButton(
                                      icon: Icon(
                                          editingNoteId != null
                                              ? Icons.check_circle
                                              : Icons.send_outlined,
                                          color: colorScheme.primary),
                                      onPressed: () => handleSubmit(viewModel),
                                    ),
                                  ),
                                ],
                              ),
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
