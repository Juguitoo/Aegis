import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../../data/local/database/app_database.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../viewmodels/task_list_viewmodel.dart';

mixin TaskFormMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  Task? get initialTask;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final estimatedDurationController = TextEditingController();

  DateTime? selectedDueDate;
  int? selectedProjectId;
  int selectedPriority = 0;
  List<int> selectedTagIds = [];
  List<TaskChecklistItem> currentChecklist = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _ensureEmptyItem() {
    if (currentChecklist.isEmpty || currentChecklist.last.title.isNotEmpty) {
      currentChecklist.add(TaskChecklistItem(title: ''));
    }
  }

  Future<void> _loadInitialData() async {
    final task = initialTask;
    if (task != null) {
      titleController.text = task.title;
      descriptionController.text = task.description ?? '';
      if (task.estimatedDuration != null) {
        estimatedDurationController.text = task.estimatedDuration.toString();
      }
      selectedDueDate = task.dueDate;
      selectedProjectId = task.projectId;
      selectedPriority = task.priority;

      final tags = await ref
          .read(taskListViewModelProvider.notifier)
          .getTagsForTask(task.id);
      final subtasks =
          await ref.read(taskRepositoryProvider).getSubtasksForTask(task.id);

      if (mounted) {
        setState(() {
          selectedTagIds = tags;
          currentChecklist = subtasks
              .map((st) => TaskChecklistItem(
                    id: st.id,
                    title: st.title,
                    isCompleted: st.isCompleted,
                  ))
              .toList();
          _ensureEmptyItem();
        });
      }
    } else if (mounted) {
      setState(() {
        _ensureEmptyItem();
      });
    }
  }

  Future<void> pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null && mounted) {
      setState(() {
        selectedDueDate = date;
      });
    }
  }

  void addChecklistItem(String title) {
    if (title.trim().isEmpty) return;
    setState(() {
      currentChecklist.add(TaskChecklistItem(title: title.trim()));
    });
  }

  void toggleChecklistItem(int index) {
    final item = currentChecklist[index];
    setState(() {
      currentChecklist[index] = TaskChecklistItem(
        id: item.id,
        title: item.title,
        isCompleted: !item.isCompleted,
      );
    });
  }

  void removeChecklistItem(int index) {
    setState(() {
      currentChecklist.removeAt(index);
      _ensureEmptyItem();
    });
  }

  void updateChecklistItem(int index, String newTitle) {
    if (newTitle.trim().isEmpty) return;
    final item = currentChecklist[index];
    setState(() {
      currentChecklist[index] = TaskChecklistItem(
        id: item.id,
        title: newTitle.trim(),
        isCompleted: item.isCompleted,
      );
      _ensureEmptyItem();
    });
  }

  void reorderChecklist(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = currentChecklist.removeAt(oldIndex);
      currentChecklist.insert(newIndex, item);
      _ensureEmptyItem();
    });
  }

  Future<void> saveTask() async {
    if (titleController.text.trim().isEmpty) return;

    final durationText = estimatedDurationController.text.trim();
    final duration =
        durationText.isNotEmpty ? int.tryParse(durationText) : null;

    final validChecklist =
        currentChecklist.where((item) => item.title.trim().isNotEmpty).toList();

    await ref.read(taskListViewModelProvider.notifier).addTask(
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          estimatedDuration: duration,
          dueDate: selectedDueDate,
          projectId: selectedProjectId,
          priority: selectedPriority,
          tagIds: selectedTagIds,
          checklist: validChecklist,
        );

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> updateTask() async {
    if (titleController.text.trim().isEmpty || initialTask == null) return;

    final durationText = estimatedDurationController.text.trim();
    final duration =
        durationText.isNotEmpty ? int.tryParse(durationText) : null;

    final updatedTask = initialTask!.copyWith(
      title: titleController.text.trim(),
      description: Value(descriptionController.text.trim()),
      estimatedDuration: Value(duration),
      dueDate: Value(selectedDueDate),
      projectId: Value(selectedProjectId),
      priority: selectedPriority,
    );

    final validChecklist =
        currentChecklist.where((item) => item.title.trim().isNotEmpty).toList();

    await ref.read(taskListViewModelProvider.notifier).updateTask(
          task: updatedTask,
          tagIds: selectedTagIds,
          checklist: validChecklist,
        );

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> deleteTask() async {
    if (initialTask == null) return;
    await ref.read(taskListViewModelProvider.notifier).deleteTask(initialTask!);
    if (mounted) Navigator.of(context).pop();
  }

  void clearTask() {
    setState(() {
      titleController.clear();
      descriptionController.clear();
      estimatedDurationController.clear();
      selectedDueDate = null;
      selectedProjectId = null;
      selectedPriority = 0;
      selectedTagIds = [];
      currentChecklist = [];
      _ensureEmptyItem();
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    estimatedDurationController.dispose();
    super.dispose();
  }
}
