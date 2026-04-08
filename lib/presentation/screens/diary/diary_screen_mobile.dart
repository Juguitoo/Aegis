import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/presentation/viewmodels/diary_viewmodel.dart';
import 'package:aegis/presentation/screens/settings/settings_screen_mobile.dart'; // <-- Añadido para los ajustes

class DiaryScreenMobile extends ConsumerStatefulWidget {
  const DiaryScreenMobile({super.key});

  @override
  ConsumerState<DiaryScreenMobile> createState() => _DiaryScreenMobileState();
}

class _DiaryScreenMobileState extends ConsumerState<DiaryScreenMobile> {
  final TextEditingController _noteController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  int? _editingNoteId;

  final List<String> _months = [
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Oct',
    'Nov',
    'Dic'
  ];

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

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDiaryDateProvider);
    final notesAsyncValue = ref.watch(diaryViewModelProvider);
    final viewModel = ref.read(diaryViewModelProvider.notifier);

    final dateString =
        '${_months[selectedDate.month - 1]} ${selectedDate.day} - ${selectedDate.year}';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // --- APPBAR ESTANDARIZADA ---
      appBar: AppBar(
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Diario',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        backgroundColor: const Color(0xFFF8FAFC),
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              iconSize: 28,
              icon: const Icon(Icons.settings, color: Color(0xFF1E293B)),
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
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_left, color: Color(0xFF475569)),
                  onPressed: () {
                    _cancelEdit();
                    ref.read(selectedDiaryDateProvider.notifier).state =
                        selectedDate.subtract(const Duration(days: 1));
                  },
                ),
                Text(
                  dateString,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF334155),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_right, color: Color(0xFF475569)),
                  onPressed: () {
                    _cancelEdit();
                    ref.read(selectedDiaryDateProvider.notifier).state =
                        selectedDate.add(const Duration(days: 1));
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: notesAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (allNotes) {
                final filteredNotes = allNotes
                    .where((note) => _isSameDay(note.createdAt, selectedDate))
                    .toList();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                if (filteredNotes.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay notas para este día',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  itemCount: filteredNotes.length,
                  itemBuilder: (context, index) {
                    final note = filteredNotes[index];
                    final timeString =
                        '${note.createdAt.hour.toString().padLeft(2, '0')}:${note.createdAt.minute.toString().padLeft(2, '0')}';
                    final isBeingEdited = _editingNoteId == note.id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isBeingEdited
                            ? const Color(0xFFFDE68A)
                            : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(16),
                        border: isBeingEdited
                            ? Border.all(
                                color: const Color(0xFFF59E0B), width: 1)
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _editingNoteId = note.id;
                                        _noteController.text = note.content;
                                      });
                                      _focusNode.requestFocus();
                                    },
                                    child: const Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  GestureDetector(
                                    onTap: () {
                                      if (_editingNoteId == note.id) {
                                        _cancelEdit();
                                      }
                                      viewModel.deleteNote(note.id);
                                    },
                                    child: const Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                      color: Color(0xFF475569),
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
                              height: 1.4,
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
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  if (_editingNoteId != null)
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                      onPressed: _cancelEdit,
                    ),
                  Expanded(
                    child: TextField(
                      controller: _noteController,
                      focusNode: _focusNode,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSubmit(viewModel),
                      decoration: InputDecoration(
                        hintText: _editingNoteId != null
                            ? 'Editando nota...'
                            : 'Escribe tu nota...',
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: _editingNoteId != null ? 0 : 20,
                            vertical: 14),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                        _editingNoteId != null
                            ? Icons.check_circle
                            : Icons.send_outlined,
                        color: const Color(0xFF6366F1)),
                    onPressed: () => _handleSubmit(viewModel),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
