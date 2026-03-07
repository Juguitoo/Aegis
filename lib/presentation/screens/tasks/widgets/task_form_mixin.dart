import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../data/local/database/app_database.dart';
import '../../../viewmodels/task_list_viewmodel.dart';

mixin TaskFormMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  Task? get initialTask;

  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController estimatedDurationController;

  int selectedPriority = 0;
  DateTime? selectedDueDate;
  int? selectedProjectId;
  List<int> selectedTagIds = [];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: initialTask?.title ?? '');
    descriptionController =
        TextEditingController(text: initialTask?.description ?? '');
    estimatedDurationController = TextEditingController(
        text: initialTask?.estimatedDuration?.toString() ?? '');
    selectedPriority = initialTask?.priority ?? 0;
    selectedDueDate = initialTask?.dueDate;
    selectedProjectId = initialTask?.projectId;
    selectedTagIds = [];

    if (initialTask != null) {
      ref
          .read(taskListViewModelProvider.notifier)
          .getTagsForTask(initialTask!.id)
          .then((tags) {
        if (mounted) {
          setState(() {
            selectedTagIds = tags;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    estimatedDurationController.dispose();
    super.dispose();
  }

  Future<void> pickDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6366F1),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        selectedDueDate = pickedDate;
      });
    }
  }

  void saveTask() {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final estimatedDuration =
        int.tryParse(estimatedDurationController.text.trim());

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El título es obligatorio')),
      );
      return;
    }

    ref.read(taskListViewModelProvider.notifier).addTaskWithTags(
          TasksCompanion.insert(
              title: title,
              description:
                  drift.Value(description.isEmpty ? null : description),
              estimatedDuration: drift.Value(estimatedDuration),
              priority: drift.Value(selectedPriority),
              dueDate: drift.Value(selectedDueDate),
              projectId: drift.Value(selectedProjectId)),
          selectedTagIds,
        );

    Navigator.of(context).pop();
  }

  void updateTask() {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final estimatedDuration =
        int.tryParse(estimatedDurationController.text.trim());

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El título es obligatorio')),
      );
      return;
    }

    final updatedTask = initialTask!.copyWith(
      title: title,
      description: drift.Value(description.isEmpty ? null : description),
      estimatedDuration: drift.Value(estimatedDuration),
      priority: selectedPriority,
      dueDate: drift.Value(selectedDueDate),
      projectId: drift.Value(selectedProjectId),
    );

    ref
        .read(taskListViewModelProvider.notifier)
        .updateTaskWithTags(updatedTask, selectedTagIds);
    Navigator.of(context).pop();
  }

  void deleteTask() {
    ref.read(taskListViewModelProvider.notifier).deleteTask(initialTask!);
    Navigator.of(context).pop();
  }

  void clearTask() {
    titleController.clear();
    descriptionController.clear();
    estimatedDurationController.clear();
    setState(() {
      selectedPriority = 0;
      selectedDueDate = null;
      selectedProjectId = null;
      selectedTagIds = [];
    });
  }
}
