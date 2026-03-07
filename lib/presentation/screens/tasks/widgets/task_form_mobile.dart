import 'package:aegis/core/utils/color_utils.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/presentation/viewmodels/project_list_viewmodel.dart';
import 'package:aegis/presentation/viewmodels/task_list_viewmodel.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskFormMobile extends ConsumerStatefulWidget {
  final Task? task;

  const TaskFormMobile({super.key, this.task});

  @override
  ConsumerState<TaskFormMobile> createState() => _TaskFormMobileState();
}

class _TaskFormMobileState extends ConsumerState<TaskFormMobile> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _estimatedDurationController;

  int _selectedPriority = 0;
  DateTime? _selectedDueDate;
  int? _selectedProjectId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');
    _estimatedDurationController = TextEditingController(
        text: widget.task?.estimatedDuration?.toString() ?? '');
    _selectedPriority = widget.task?.priority ?? 0;
    _selectedDueDate = widget.task?.dueDate;
    _selectedProjectId = widget.task?.projectId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedDurationController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
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
        _selectedDueDate = pickedDate;
      });
    }
  }

  void _saveTask() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final estimatedDuration =
        int.tryParse(_estimatedDurationController.text.trim());
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El título es obligatorio')),
      );
      return;
    }

    ref.read(taskListViewModelProvider.notifier).addTask(TasksCompanion.insert(
        title: title,
        description: drift.Value(description.isEmpty ? null : description),
        estimatedDuration: drift.Value(estimatedDuration),
        priority: drift.Value(_selectedPriority),
        dueDate: drift.Value(_selectedDueDate),
        projectId: drift.Value(_selectedProjectId)));

    Navigator.of(context).pop();
  }

  void _updateTask() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final estimatedDuration =
        int.tryParse(_estimatedDurationController.text.trim());
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El título es obligatorio')),
      );
      return;
    }

    final updatedTask = widget.task!.copyWith(
      title: title,
      description: drift.Value(description.isEmpty ? null : description),
      estimatedDuration: drift.Value(estimatedDuration),
      priority: _selectedPriority,
      dueDate: drift.Value(_selectedDueDate),
      projectId: drift.Value(_selectedProjectId),
    );

    ref.read(taskListViewModelProvider.notifier).updateTask(updatedTask);
    Navigator.of(context).pop();
  }

  void _deleteTask() {
    ref.read(taskListViewModelProvider.notifier).deleteTask(widget.task!);
    Navigator.of(context).pop();
  }

  void _clearTask() {
    _titleController.clear();
    _descriptionController.clear();
    _estimatedDurationController.clear();
    setState(() {
      _selectedPriority = 0;
      _selectedDueDate = null;
      _selectedProjectId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectListViewModelProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.task == null ? "Crear Nueva Tarea" : "Editar Tarea",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B)),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _titleController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Título',
                hintText: '¿Qué quieres hacer?',
                hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFCBD5E1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF6366F1), width: 2),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              minLines: 1,
              decoration: InputDecoration(
                labelText: 'Descripción',
                hintText: 'Añade detalles sobre la tarea',
                hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFCBD5E1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF6366F1), width: 2),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _estimatedDurationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Estimación (min)',
                      hintText: 'Ej: 30',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF6366F1), width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: _pickDueDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 20, color: Color(0xFF64748B)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedDueDate == null
                                  ? 'Sin fecha'
                                  : '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}',
                              style: TextStyle(
                                color: _selectedDueDate == null
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF1E293B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            projectsAsync.when(
              data: (projectsList) {
                return DropdownButtonFormField<int?>(
                  initialValue: _selectedProjectId,
                  decoration: InputDecoration(
                    labelText: 'Proyecto',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFF6366F1), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down,
                      color: Color(0xFF64748B)),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Row(
                        children: [
                          Icon(Icons.folder_outlined,
                              size: 18, color: Color(0xFF94A3B8)),
                          SizedBox(width: 12),
                          Text('Seleccionar proyecto',
                              style: TextStyle(color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    ...projectsList.map((p) => DropdownMenuItem<int?>(
                          value: p.id,
                          child: Row(
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: ColorUtils.parseColor(p.colorHex),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(p.name,
                                  style: const TextStyle(
                                      color: Color(0xFF1E293B))),
                            ],
                          ),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedProjectId = value;
                    });
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error al cargar proyectos: $err'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Prioridad',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Ninguna'),
                  selected: _selectedPriority == 0,
                  onSelected: (selected) =>
                      setState(() => _selectedPriority = 0),
                  selectedColor: const Color(0xFFE0F2FE),
                  labelStyle: TextStyle(
                    color: _selectedPriority == 0
                        ? const Color(0xFF0284C7)
                        : const Color(0xFF64748B),
                    fontWeight: _selectedPriority == 0
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                ChoiceChip(
                  label: const Text('Baja'),
                  selected: _selectedPriority == 1,
                  onSelected: (selected) =>
                      setState(() => _selectedPriority = 1),
                  selectedColor: const Color(0xFFDCFCE7),
                  labelStyle: TextStyle(
                    color: _selectedPriority == 1
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF64748B),
                    fontWeight: _selectedPriority == 1
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                ChoiceChip(
                  label: const Text('Media'),
                  selected: _selectedPriority == 2,
                  onSelected: (selected) =>
                      setState(() => _selectedPriority = 2),
                  selectedColor: const Color(0xFFFEF9C3),
                  labelStyle: TextStyle(
                    color: _selectedPriority == 2
                        ? const Color(0xFFCA8A04)
                        : const Color(0xFF64748B),
                    fontWeight: _selectedPriority == 2
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                ChoiceChip(
                  label: const Text('Alta'),
                  selected: _selectedPriority == 3,
                  onSelected: (selected) =>
                      setState(() => _selectedPriority = 3),
                  selectedColor: const Color(0xFFFEE2E2),
                  labelStyle: TextStyle(
                    color: _selectedPriority == 3
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF64748B),
                    fontWeight: _selectedPriority == 3
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              spacing: 16,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.task != null ? _deleteTask : _clearTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.task != null
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFF1F5F9),
                      foregroundColor: widget.task != null
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF475569),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      widget.task != null ? 'Eliminar tarea' : 'Limpiar',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.task == null ? _saveTask : _updateTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      widget.task == null ? 'Guardar' : 'Actualizar',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
