import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/presentation/viewmodels/diary_viewmodel.dart';
import 'package:aegis/presentation/screens/settings/settings_screen_mobile.dart';
import 'diary_state_mixin.dart';

class DiaryScreenMobile extends ConsumerStatefulWidget {
  const DiaryScreenMobile({super.key});

  @override
  ConsumerState<DiaryScreenMobile> createState() => _DiaryScreenMobileState();
}

class _DiaryScreenMobileState extends ConsumerState<DiaryScreenMobile>
    with DiaryStateMixin {
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
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDiaryDateProvider);
    final notesAsyncValue = ref.watch(diaryViewModelProvider);
    final viewModel = ref.read(diaryViewModelProvider.notifier);

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final dateString =
        '${_months[selectedDate.month - 1]} ${selectedDate.day} - ${selectedDate.year}';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Diario',
            style: textTheme.displayMedium,
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
              iconSize: 28,
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_left,
                      color: colorScheme.onSurfaceVariant),
                  onPressed: () {
                    cancelEdit();
                    ref.read(selectedDiaryDateProvider.notifier).state =
                        selectedDate.subtract(const Duration(days: 1));
                  },
                ),
                Text(
                  dateString,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_right,
                      color: colorScheme.onSurfaceVariant),
                  onPressed: () {
                    cancelEdit();
                    ref.read(selectedDiaryDateProvider.notifier).state =
                        selectedDate.add(const Duration(days: 1));
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: notesAsyncValue.when(
              loading: () => Center(
                  child: CircularProgressIndicator(color: colorScheme.primary)),
              error: (error, stack) => Center(
                  child: Text('Error: $error',
                      style: TextStyle(color: colorScheme.error))),
              data: (allNotes) {
                final filteredNotes = allNotes
                    .where((note) => isSameDay(note.createdAt, selectedDate))
                    .toList();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  scrollToBottom();
                });

                if (filteredNotes.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay notas para este día',
                      style: textTheme.bodyLarge
                          ?.copyWith(color: colorScheme.outline),
                    ),
                  );
                }

                return ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  itemCount: filteredNotes.length,
                  itemBuilder: (context, index) {
                    final note = filteredNotes[index];
                    final timeString =
                        '${note.createdAt.hour.toString().padLeft(2, '0')}:${note.createdAt.minute.toString().padLeft(2, '0')}';
                    final isBeingEdited = editingNoteId == note.id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isBeingEdited
                            ? colorScheme.primary.withValues(alpha: 0.1)
                            : colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isBeingEdited
                              ? colorScheme.primary
                              : colorScheme.outline.withValues(alpha: 0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                timeString,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        editingNoteId = note.id;
                                        noteController.text = note.content;
                                      });
                                      focusNode.requestFocus();
                                    },
                                    child: Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  GestureDetector(
                                    onTap: () {
                                      if (editingNoteId == note.id) {
                                        cancelEdit();
                                      }
                                      viewModel.deleteNote(note.id);
                                    },
                                    child: Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            note.content,
                            style: textTheme.bodyLarge?.copyWith(
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
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
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
                      onSubmitted: (_) => handleSubmit(viewModel),
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: editingNoteId != null
                            ? 'Editando nota...'
                            : 'Escribe tu nota...',
                        hintStyle:
                            TextStyle(color: colorScheme.onSurfaceVariant),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: editingNoteId != null ? 0 : 20,
                            vertical: 14),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                        editingNoteId != null
                            ? Icons.check_circle
                            : Icons.send_outlined,
                        color: colorScheme.primary),
                    onPressed: () => handleSubmit(viewModel),
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
