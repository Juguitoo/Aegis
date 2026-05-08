import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/presentation/viewmodels/diary_viewmodel.dart';

mixin DiaryStateMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  final TextEditingController noteController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  int? editingNoteId;

  @override
  void dispose() {
    noteController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void handleSubmit(DiaryViewModel viewModel) {
    final text = noteController.text;
    if (text.trim().isEmpty) return;

    if (editingNoteId != null) {
      viewModel.updateNoteContent(editingNoteId!, text);
      setState(() {
        editingNoteId = null;
      });
    } else {
      viewModel.addNote(text);
    }

    noteController.clear();
  }

  void cancelEdit() {
    setState(() {
      editingNoteId = null;
    });
    noteController.clear();
    focusNode.unfocus();
  }
}
