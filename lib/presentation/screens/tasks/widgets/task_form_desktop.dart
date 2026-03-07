import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../core/utils/color_utils.dart';
import '../../../../data/local/database/app_database.dart';
import '../../../viewmodels/project_list_viewmodel.dart';
import '../../../viewmodels/task_list_viewmodel.dart';
import 'tag_multi_selector.dart';

class TaskFormDesktop extends ConsumerStatefulWidget {
  final Task? task;

  const TaskFormDesktop({super.key, this.task});

  @override
  ConsumerState<TaskFormDesktop> createState() => _TaskFormDesktopState();
}

class _TaskFormDesktopState extends ConsumerState<TaskFormDesktop> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _estimatedDurationController;

  int _selectedPriority = 0;
  DateTime? _selectedDueDate;
  int? _selectedProjectId;
  List<int> _selectedTagIds = []; // Aquí almacenamos las N etiquetas

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

    // NOTA: Si vas a editar una tarea, aquí deberías cargar sus IDs de etiquetas
    // desde el ViewModel (ej. ref.read(taskListViewModelProvider.notifier).getTagsForTask(widget.task!.id))
    _selectedTagIds = [];
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

    // TODO: Enviar _selectedTagIds al ViewModel para que los guarde en TaskTags
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

    // TODO: Enviar _selectedTagIds al ViewModel para que actualice TaskTags
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
      _selectedTagIds = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectListViewModelProvider);

    const labelStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xFF64748B),
    );

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        width: 750,
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.task == null ? "Crear Nueva Tarea" : "Editar Tarea",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Título', style: labelStyle),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 16, color: Color(0xFF1E293B)),
                decoration: InputDecoration(
                  hintText: '¿Qué quieres hacer?',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF6366F1), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Descripción', style: labelStyle),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 16, color: Color(0xFF1E293B)),
                maxLines: 3,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Añade detalles sobre la tarea',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF6366F1), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Estimación (min)', style: labelStyle),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _estimatedDurationController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                              fontSize: 16, color: Color(0xFF1E293B)),
                          decoration: InputDecoration(
                            hintText: 'Ej: 30',
                            hintStyle:
                                const TextStyle(color: Color(0xFF94A3B8)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Color(0xFFCBD5E1)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFF6366F1), width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Fecha límite', style: labelStyle),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _pickDueDate,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: const Color(0xFFCBD5E1)),
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
                                      fontSize: 16,
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
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Proyecto', style: labelStyle),
                        const SizedBox(height: 8),
                        projectsAsync.when(
                          data: (projectsList) {
                            return DropdownButtonFormField<int?>(
                              initialValue: _selectedProjectId,
                              dropdownColor: Colors.white,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFCBD5E1)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF6366F1), width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 15),
                              ),
                              icon: const Icon(Icons.keyboard_arrow_down,
                                  color: Color(0xFF64748B)),
                              isExpanded: true,
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Row(
                                    children: [
                                      Icon(Icons.inbox_outlined,
                                          size: 18, color: Color(0xFF94A3B8)),
                                      SizedBox(width: 8),
                                      Expanded(
                                          child: Text('Sin proyecto',
                                              style: TextStyle(
                                                  color: Color(0xFF64748B),
                                                  overflow:
                                                      TextOverflow.ellipsis))),
                                    ],
                                  ),
                                ),
                                ...projectsList
                                    .map((p) => DropdownMenuItem<int?>(
                                          value: p.id,
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 14,
                                                height: 14,
                                                decoration: BoxDecoration(
                                                  color: ColorUtils.parseColor(
                                                      p.colorHex),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                  child: Text(p.name,
                                                      style: const TextStyle(
                                                          color:
                                                              Color(0xFF1E293B),
                                                          overflow: TextOverflow
                                                              .ellipsis))),
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
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (err, stack) => Text('Error: $err'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Prioridad', style: labelStyle),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            _CustomPriorityChip(
                              label: 'Ninguna',
                              isSelected: _selectedPriority == 0,
                              activeBgColor: const Color(0xFFE0F2FE),
                              activeTextColor: const Color(0xFF0284C7),
                              onTap: () =>
                                  setState(() => _selectedPriority = 0),
                            ),
                            _CustomPriorityChip(
                              label: 'Baja',
                              isSelected: _selectedPriority == 1,
                              activeBgColor: const Color(0xFFDCFCE7),
                              activeTextColor: const Color(0xFF16A34A),
                              onTap: () =>
                                  setState(() => _selectedPriority = 1),
                            ),
                            _CustomPriorityChip(
                              label: 'Media',
                              isSelected: _selectedPriority == 2,
                              activeBgColor: const Color(0xFFFEF9C3),
                              activeTextColor: const Color(0xFFCA8A04),
                              onTap: () =>
                                  setState(() => _selectedPriority = 2),
                            ),
                            _CustomPriorityChip(
                              label: 'Alta',
                              isSelected: _selectedPriority == 3,
                              activeBgColor: const Color(0xFFFEE2E2),
                              activeTextColor: const Color(0xFFDC2626),
                              onTap: () =>
                                  setState(() => _selectedPriority = 3),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Etiquetas', style: labelStyle),
                        const SizedBox(height: 8),
                        TagMultiSelector(
                          initialSelectedIds: _selectedTagIds,
                          onTagsChanged: (newTagIds) {
                            setState(() {
                              _selectedTagIds = newTagIds;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomPriorityChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color activeBgColor;
  final Color activeTextColor;
  final VoidCallback onTap;

  const _CustomPriorityChip({
    required this.label,
    required this.isSelected,
    required this.activeBgColor,
    required this.activeTextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeBgColor : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.transparent : const Color(0xFFCBD5E1),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? activeTextColor : const Color(0xFF64748B),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
