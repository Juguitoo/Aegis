import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:aegis/presentation/viewmodels/diary_viewmodel.dart';
import 'package:aegis/data/local/database/app_database.dart';

class DiaryScreenDesktop extends ConsumerStatefulWidget {
  const DiaryScreenDesktop({super.key});

  @override
  ConsumerState<DiaryScreenDesktop> createState() => _DiaryScreenDesktopState();
}

class _DiaryScreenDesktopState extends ConsumerState<DiaryScreenDesktop> {
  final TextEditingController _noteController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  int? _editingNoteId;
  DateTime _focusedDay = DateTime.now();

  @override
  void dispose() {
    _noteController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSubmit(DiaryViewModel viewModel) {
    final text = _noteController.text;
    if (text.trim().isEmpty) return;

    if (_editingNoteId != null) {
      viewModel.updateNoteContent(_editingNoteId!, text);
      setState(() {
        _editingNoteId = null;
      });
    } else {
      viewModel.addNote(text);
    }

    _noteController.clear();
  }

  void _cancelEdit() {
    setState(() {
      _editingNoteId = null;
    });
    _noteController.clear();
    _focusNode.unfocus();
  }

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

    return Scaffold(
      backgroundColor: Colors
          .transparent, // Ajustado para ser como las demás vistas de escritorio
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CABECERA ESTANDARIZADA ---
            const Text(
              'Diario',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
            const Divider(height: 16, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 16),
            // ------------------------------

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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
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
                                      _isSameDay(selectedDate, day),
                                  onDaySelected: (selectedDay, focusedDay) {
                                    _cancelEdit();
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
                                            _isSameDay(note.createdAt, day))
                                        .toList();
                                  },
                                  headerStyle: const HeaderStyle(
                                    formatButtonVisible: false,
                                    titleCentered: true,
                                    leftChevronIcon: Icon(Icons.chevron_left,
                                        color: Color(0xFF475569)),
                                    rightChevronIcon: Icon(Icons.chevron_right,
                                        color: Color(0xFF475569)),
                                    titleTextStyle: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B)),
                                  ),
                                  calendarStyle: const CalendarStyle(
                                    todayDecoration: BoxDecoration(
                                      color: Color(0xFFE2E8F0),
                                      shape: BoxShape.circle,
                                    ),
                                    todayTextStyle:
                                        TextStyle(color: Color(0xFF1E293B)),
                                    selectedDecoration: BoxDecoration(
                                      color: Color(0xFF6366F1),
                                      shape: BoxShape.circle,
                                    ),
                                    markerDecoration: BoxDecoration(
                                      color: Color(0xFFF43F5E),
                                      shape: BoxShape.circle,
                                    ),
                                    markersMaxCount: 1,
                                  ),
                                );
                              },
                              loading: () => const SizedBox(
                                  height: 300,
                                  child: Center(
                                      child: CircularProgressIndicator())),
                              error: (_, __) => const SizedBox(
                                  height: 300,
                                  child: Center(
                                      child:
                                          Text('Error al cargar calendario'))),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Entradas Recientes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
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
                                return const Text('No hay entradas recientes',
                                    style: TextStyle(color: Color(0xFF94A3B8)));
                              }

                              return ListView.builder(
                                itemCount: uniqueDays.length,
                                itemBuilder: (context, index) {
                                  final date = uniqueDays[index];
                                  final isSelected =
                                      _isSameDay(date, selectedDate);

                                  return MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () {
                                        _cancelEdit();
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
                                              ? const Color(0xFFEEF2FF)
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isSelected
                                                ? const Color(0xFF6366F1)
                                                    .withValues(alpha: 0.2)
                                                : Colors.transparent,
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
                                                ? const Color(0xFF6366F1)
                                                : const Color(0xFF475569),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            loading: () => const Center(
                                child: CircularProgressIndicator()),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
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
                          const Padding(
                            padding: EdgeInsets.only(
                                left: 32, top: 32, right: 32, bottom: 16),
                            child: Text(
                              'Notas',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          Expanded(
                            child: notesAsyncValue.when(
                              loading: () => const Center(
                                  child: CircularProgressIndicator()),
                              error: (error, stack) =>
                                  Center(child: Text('Error: $error')),
                              data: (allNotes) {
                                final filteredNotes = allNotes
                                    .where((note) => _isSameDay(
                                        note.createdAt, selectedDate))
                                    .toList();

                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  _scrollToBottom();
                                });

                                if (filteredNotes.isEmpty) {
                                  return const Center(
                                    child: Text(
                                      'No hay notas para este día',
                                      style: TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 16),
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32.0, vertical: 16.0),
                                  itemCount: filteredNotes.length,
                                  itemBuilder: (context, index) {
                                    final note = filteredNotes[index];
                                    final timeString =
                                        '${note.createdAt.hour.toString().padLeft(2, '0')}:${note.createdAt.minute.toString().padLeft(2, '0')}';
                                    final isBeingEdited =
                                        _editingNoteId == note.id;

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: isBeingEdited
                                            ? const Color(0xFFFDE68A)
                                            : const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(16),
                                        border: isBeingEdited
                                            ? Border.all(
                                                color: const Color(0xFFF59E0B),
                                                width: 1)
                                            : null,
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
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFF94A3B8),
                                                  fontWeight: FontWeight.w500,
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
                                                          _editingNoteId =
                                                              note.id;
                                                          _noteController.text =
                                                              note.content;
                                                        });
                                                        _focusNode
                                                            .requestFocus();
                                                      },
                                                      child: const Icon(
                                                        Icons.edit_outlined,
                                                        size: 18,
                                                        color:
                                                            Color(0xFF475569),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  MouseRegion(
                                                    cursor: SystemMouseCursors
                                                        .click,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        if (_editingNoteId ==
                                                            note.id) {
                                                          _cancelEdit();
                                                        }
                                                        viewModel.deleteNote(
                                                            note.id);
                                                      },
                                                      child: const Icon(
                                                        Icons.delete_outline,
                                                        size: 18,
                                                        color:
                                                            Color(0xFF475569),
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
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF334155),
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
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                children: [
                                  if (_editingNoteId != null)
                                    IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Color(0xFF94A3B8)),
                                      onPressed: _cancelEdit,
                                    ),
                                  Expanded(
                                    child: TextField(
                                      controller: _noteController,
                                      focusNode: _focusNode,
                                      textInputAction: TextInputAction.send,
                                      onSubmitted: (_) =>
                                          _handleSubmit(viewModel),
                                      decoration: InputDecoration(
                                        hintText: _editingNoteId != null
                                            ? 'Editando nota...'
                                            : 'Escribe tu nota...',
                                        hintStyle: const TextStyle(
                                            color: Color(0xFF94A3B8)),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal:
                                                _editingNoteId != null ? 0 : 24,
                                            vertical: 18),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: IconButton(
                                      icon: Icon(
                                          _editingNoteId != null
                                              ? Icons.check_circle
                                              : Icons.send_outlined,
                                          color: const Color(0xFF6366F1)),
                                      onPressed: () => _handleSubmit(viewModel),
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
