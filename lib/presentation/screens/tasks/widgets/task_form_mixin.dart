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
  final notesController = TextEditingController();

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

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color(0xFFDC2626) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
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
      notesController.text = task.notes ?? '';
      if (task.estimatedDuration != null) {
        estimatedDurationController.text =
            (task.estimatedDuration! ~/ 60).toString();
      }
      selectedDueDate = task.dueDate;
      selectedProjectId = task.projectId;
      selectedPriority = task.priority;

      try {
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
      } catch (e) {
        _showSnackBar('Error al cargar los datos de la tarea', isError: true);
      }
    } else {
      if (mounted) {
        setState(() {
          _ensureEmptyItem();
        });
      }
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

  void toggleChecklistItem(int index) {
    final item = currentChecklist[index];
    setState(() {
      currentChecklist[index] = TaskChecklistItem(
        id: item.id,
        title: item.title,
        isCompleted: !item.isCompleted,
        localId: item.localId,
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
    final item = currentChecklist[index];
    setState(() {
      currentChecklist[index] = TaskChecklistItem(
        id: item.id,
        title: newTitle,
        isCompleted: item.isCompleted,
        localId: item.localId,
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
    if (titleController.text.trim().isEmpty) {
      _showSnackBar('El título no puede estar vacío', isError: true);
      return;
    }

    final durationText = estimatedDurationController.text.trim();
    int? duration;

    if (durationText.isNotEmpty) {
      final parsedDuration = int.tryParse(durationText);
      if (parsedDuration != null) {
        duration = parsedDuration * 60;
      }
    }

    final validChecklist =
        currentChecklist.where((item) => item.title.trim().isNotEmpty).toList();

    try {
      await ref.read(taskListViewModelProvider.notifier).addTask(
            title: titleController.text.trim(),
            description: descriptionController.text.trim(),
            notes: notesController.text.trim().isEmpty
                ? null
                : notesController.text.trim(),
            estimatedDuration: duration,
            dueDate: selectedDueDate,
            projectId: selectedProjectId,
            priority: selectedPriority,
            tagIds: selectedTagIds,
            checklist: validChecklist,
          );

      if (mounted) {
        Navigator.of(context).pop();
        _showSnackBar('Tarea creada correctamente');
      }
    } catch (e, stackTrace) {
      debugPrint('🔴 ERROR REAL AL GUARDAR TAREA: $e');
      debugPrint('🔴 STACKTRACE: $stackTrace');
      _showSnackBar('Error al crear la tarea. Inténtalo de nuevo.',
          isError: true);
    }
  }

  Future<void> updateTask() async {
    if (titleController.text.trim().isEmpty || initialTask == null) {
      _showSnackBar('El título no puede estar vacío', isError: true);
      return;
    }

    final durationText = estimatedDurationController.text.trim();
    int? duration;

    if (durationText.isNotEmpty) {
      final parsedDuration = int.tryParse(durationText);
      if (parsedDuration != null) {
        duration = parsedDuration * 60;
      }
    }

    final updatedTask = initialTask!.copyWith(
      title: titleController.text.trim(),
      description: Value(descriptionController.text.trim()),
      notes: Value(notesController.text.trim()),
      estimatedDuration: Value(duration),
      dueDate: Value(selectedDueDate),
      projectId: Value(selectedProjectId),
      priority: selectedPriority,
    );

    final validChecklist =
        currentChecklist.where((item) => item.title.trim().isNotEmpty).toList();

    try {
      await ref.read(taskListViewModelProvider.notifier).updateTask(
            task: updatedTask,
            tagIds: selectedTagIds,
            checklist: validChecklist,
          );

      if (mounted) {
        Navigator.of(context).pop();
        _showSnackBar('Tarea actualizada correctamente');
      }
    } catch (e, stackTrace) {
      debugPrint('🔴 ERROR REAL AL GUARDAR TAREA: $e');
      debugPrint('🔴 STACKTRACE: $stackTrace');
      _showSnackBar('Error al crear la tarea. Inténtalo de nuevo.',
          isError: true);
    }
  }

  Future<void> deleteTask() async {
    if (initialTask == null) return;

    try {
      await ref
          .read(taskListViewModelProvider.notifier)
          .deleteTask(initialTask!);
      if (mounted) {
        Navigator.of(context).pop();
        _showSnackBar('Tarea eliminada');
      }
    } catch (e) {
      _showSnackBar('Error al eliminar la tarea', isError: true);
    }
  }

  void clearTask() {
    setState(() {
      titleController.clear();
      descriptionController.clear();
      estimatedDurationController.clear();
      notesController.clear();
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
    notesController.dispose();
    super.dispose();
  }
}
