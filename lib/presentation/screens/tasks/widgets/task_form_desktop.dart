import 'package:aegis/core/utils/color_utils.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/presentation/screens/tasks/widgets/task_form_mixin.dart';
import 'package:aegis/presentation/viewmodels/project_list_viewmodel.dart';
import 'package:aegis/presentation/viewmodels/task_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tags/widgets/tag_multi_selector.dart';

class TaskFormDesktop extends ConsumerStatefulWidget {
  final Task? task;

  const TaskFormDesktop({super.key, this.task});

  @override
  ConsumerState<TaskFormDesktop> createState() => _TaskFormDesktopState();
}

class _TaskFormDesktopState extends ConsumerState<TaskFormDesktop>
    with TaskFormMixin {
  @override
  Task? get initialTask => widget.task;

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectListViewModelProvider);

    return Scaffold(
      backgroundColor: const Color.fromARGB(104, 226, 232, 240),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1100,
            maxHeight: 850,
          ),
          child: Material(
            elevation: 4,
            shadowColor: Colors.black12,
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.task == null
                            ? "Crear Nueva Tarea"
                            : "Editar Tarea",
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                        onPressed: () {
                          if (mounted) Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 7,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: _TaskDetailsColumn(
                              titleController: titleController,
                              descriptionController: descriptionController,
                              estimatedDurationController:
                                  estimatedDurationController,
                              selectedDueDate: selectedDueDate,
                              onPickDueDate: pickDueDate,
                              projectsAsync: projectsAsync,
                              selectedProjectId: selectedProjectId,
                              onProjectChanged: (value) =>
                                  setState(() => selectedProjectId = value),
                              selectedPriority: selectedPriority,
                              onPriorityChanged: (value) =>
                                  setState(() => selectedPriority = value),
                              selectedTagIds: selectedTagIds,
                              onTagsChanged: (value) =>
                                  setState(() => selectedTagIds = value),
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const Text(
                                        'Lista de Control',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Expanded(
                                        child: _TaskChecklistColumn(
                                          checklist: currentChecklist,
                                          onUpdate: updateChecklistItem,
                                          onToggle: toggleChecklistItem,
                                          onRemove: removeChecklistItem,
                                          onReorder: reorderChecklist,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        const Text(
                                          "Notas",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Expanded(
                                          child: TextField(
                                            controller: notesController,
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            maxLines: null,
                                            expands: true,
                                            textAlignVertical:
                                                TextAlignVertical.top,
                                            decoration: InputDecoration(
                                              hintText:
                                                  'Añade cualquier información adicional sobre la tarea',
                                              hintStyle: const TextStyle(
                                                  color: Color(0xFF94A3B8)),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                    color: Color(0xFFCBD5E1)),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: const BorderSide(
                                                    color: Color(0xFF6366F1),
                                                    width: 2),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: widget.task != null ? deleteTask : clearTask,
                        style: TextButton.styleFrom(
                          foregroundColor: widget.task != null
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF475569),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                        ),
                        child: Text(
                          widget.task != null
                              ? 'Eliminar Tarea'
                              : 'Limpiar Campos',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: widget.task == null ? saveTask : updateTask,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          widget.task == null
                              ? 'Guardar Tarea'
                              : 'Actualizar Tarea',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskDetailsColumn extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController estimatedDurationController;
  final DateTime? selectedDueDate;
  final VoidCallback onPickDueDate;
  final AsyncValue<List<Project>> projectsAsync;
  final int? selectedProjectId;
  final ValueChanged<int?> onProjectChanged;
  final int selectedPriority;
  final ValueChanged<int> onPriorityChanged;
  final List<int> selectedTagIds;
  final ValueChanged<List<int>> onTagsChanged;

  const _TaskDetailsColumn({
    required this.titleController,
    required this.descriptionController,
    required this.estimatedDurationController,
    required this.selectedDueDate,
    required this.onPickDueDate,
    required this.projectsAsync,
    required this.selectedProjectId,
    required this.onProjectChanged,
    required this.selectedPriority,
    required this.onPriorityChanged,
    required this.selectedTagIds,
    required this.onTagsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: titleController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 80,
            decoration: InputDecoration(
              labelText: 'Título',
              hintText: '¿Qué quieres hacer?',
              counterText: "",
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFF6366F1), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: descriptionController,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 4,
            minLines: 2,
            maxLength: 500,
            decoration: InputDecoration(
              labelText: 'Descripción',
              hintText: 'Añade detalles sobre la tarea',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: Color(0xFF6366F1), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: estimatedDurationController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    labelText: 'Estimación (min)',
                    hintText: 'Ej: 30',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: Color(0xFF6366F1), width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: InkWell(
                  onTap: onPickDueDate,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 20, color: Color(0xFF64748B)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            selectedDueDate == null
                                ? 'Sin fecha'
                                : '${selectedDueDate!.day}/${selectedDueDate!.month}/${selectedDueDate!.year}',
                            style: TextStyle(
                              fontSize: 16,
                              color: selectedDueDate == null
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
          const SizedBox(height: 24),
          projectsAsync.when(
            data: (projectsList) {
              return DropdownButtonFormField<int?>(
                initialValue: selectedProjectId,
                decoration: InputDecoration(
                  labelText: 'Proyecto',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFF6366F1), width: 2),
                  ),
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
                                style:
                                    const TextStyle(color: Color(0xFF1E293B))),
                          ],
                        ),
                      )),
                ],
                onChanged: onProjectChanged,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Error al cargar proyectos: $err'),
          ),
          const SizedBox(height: 24),
          const Text(
            'Prioridad',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [
              ChoiceChip(
                label: const Text('Ninguna'),
                selected: selectedPriority == 0,
                onSelected: (selected) => onPriorityChanged(0),
                selectedColor: const Color(0xFFE0F2FE),
                labelStyle: TextStyle(
                  color: selectedPriority == 0
                      ? const Color(0xFF0284C7)
                      : const Color(0xFF64748B),
                  fontWeight: selectedPriority == 0
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                side: BorderSide(
                  color: selectedPriority == 0
                      ? Colors.transparent
                      : const Color(0xFFCBD5E1),
                ),
              ),
              ChoiceChip(
                label: const Text('Baja'),
                selected: selectedPriority == 1,
                onSelected: (selected) => onPriorityChanged(1),
                selectedColor: const Color(0xFFDCFCE7),
                labelStyle: TextStyle(
                  color: selectedPriority == 1
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF64748B),
                  fontWeight: selectedPriority == 1
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                side: BorderSide(
                  color: selectedPriority == 1
                      ? Colors.transparent
                      : const Color(0xFFCBD5E1),
                ),
              ),
              ChoiceChip(
                label: const Text('Media'),
                selected: selectedPriority == 2,
                onSelected: (selected) => onPriorityChanged(2),
                selectedColor: const Color(0xFFFEF9C3),
                labelStyle: TextStyle(
                  color: selectedPriority == 2
                      ? const Color(0xFFCA8A04)
                      : const Color(0xFF64748B),
                  fontWeight: selectedPriority == 2
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                side: BorderSide(
                  color: selectedPriority == 2
                      ? Colors.transparent
                      : const Color(0xFFCBD5E1),
                ),
              ),
              ChoiceChip(
                label: const Text('Alta'),
                selected: selectedPriority == 3,
                onSelected: (selected) => onPriorityChanged(3),
                selectedColor: const Color(0xFFFEE2E2),
                labelStyle: TextStyle(
                  color: selectedPriority == 3
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF64748B),
                  fontWeight: selectedPriority == 3
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                side: BorderSide(
                  color: selectedPriority == 3
                      ? Colors.transparent
                      : const Color(0xFFCBD5E1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Etiquetas',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          TagMultiSelector(
            initialSelectedIds: selectedTagIds,
            onTagsChanged: onTagsChanged,
          ),
        ],
      ),
    );
  }
}

class _TaskChecklistColumn extends StatelessWidget {
  final List<TaskChecklistItem> checklist;
  final void Function(int, String) onUpdate;
  final ValueChanged<int> onToggle;
  final ValueChanged<int> onRemove;
  final void Function(int oldIndex, int newIndex) onReorder;

  const _TaskChecklistColumn({
    required this.checklist,
    required this.onUpdate,
    required this.onToggle,
    required this.onRemove,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final validItems =
        checklist.where((item) => item.title.trim().isNotEmpty).toList();
    final total = validItems.length;
    final completed = validItems.where((item) => item.isCompleted).length;
    final progress = total == 0 ? 0.0 : completed / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (total > 0) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      builder: (context, value, _) => LinearProgressIndicator(
                        value: value,
                        backgroundColor: const Color(0xFFE2E8F0),
                        color: value == 1.0
                            ? const Color(0xFF10B981)
                            : const Color(0xFF6366F1),
                        minHeight: 6,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '$completed/$total',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: progress == 1.0
                        ? const Color(0xFF10B981)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 8),
        ],
        Expanded(
          child: ReorderableListView.builder(
            itemCount: checklist.length,
            buildDefaultDragHandles: false,
            onReorder: (oldIndex, newIndex) {
              final lastIndex = checklist.length - 1;
              if (oldIndex == lastIndex) return;
              if (newIndex > lastIndex) newIndex = lastIndex;
              onReorder(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final item = checklist[index];
              final isLastEmpty =
                  index == checklist.length - 1 && item.title.isEmpty;

              return _InlineChecklistRow(
                key: ValueKey(item.localId),
                index: index,
                item: item,
                isLastEmpty: isLastEmpty,
                onChanged: (text) => onUpdate(index, text),
                onToggle: () => onToggle(index),
                onRemove: () => onRemove(index),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _InlineChecklistRow extends StatefulWidget {
  final int index;
  final TaskChecklistItem item;
  final bool isLastEmpty;
  final ValueChanged<String> onChanged;
  final VoidCallback onToggle;
  final VoidCallback onRemove;

  const _InlineChecklistRow({
    super.key,
    required this.index,
    required this.item,
    required this.isLastEmpty,
    required this.onChanged,
    required this.onToggle,
    required this.onRemove,
  });

  @override
  State<_InlineChecklistRow> createState() => _InlineChecklistRowState();
}

class _InlineChecklistRowState extends State<_InlineChecklistRow> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.item.title);
    _focusNode = FocusNode();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        if (_controller.text != widget.item.title) {
          widget.onChanged(_controller.text);
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant _InlineChecklistRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.title != widget.item.title &&
        _controller.text != widget.item.title &&
        !_focusNode.hasFocus) {
      _controller.value = _controller.value.copyWith(
        text: widget.item.title,
        selection: TextSelection.collapsed(offset: widget.item.title.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: widget.isLastEmpty ? Colors.transparent : const Color(0xFFF8FAFC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color:
              widget.isLastEmpty ? Colors.transparent : const Color(0xFFE2E8F0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            if (!widget.isLastEmpty)
              Checkbox(
                value: widget.item.isCompleted,
                onChanged: (_) => widget.onToggle(),
                activeColor: const Color(0xFF6366F1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Icon(Icons.add, color: Color(0xFF94A3B8), size: 20),
              ),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                minLines: 1,
                maxLines: 2,
                maxLength: 70,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.sentences,
                onEditingComplete: () {
                  widget.onChanged(_controller.text);
                  Future.delayed(const Duration(milliseconds: 50), () {
                    if (mounted) FocusScope.of(context).nextFocus();
                  });
                },
                style: TextStyle(
                  color: widget.item.isCompleted
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF1E293B),
                  decoration: widget.item.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
                decoration: InputDecoration(
                  counterText: "",
                  hintText: widget.isLastEmpty ? "Añadir subpaso..." : "",
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            if (!widget.isLastEmpty)
              IconButton(
                icon:
                    const Icon(Icons.close, color: Color(0xFFCBD5E1), size: 20),
                onPressed: widget.onRemove,
              ),
            if (!widget.isLastEmpty)
              ReorderableDragStartListener(
                index: widget.index,
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(8, 8, 12, 8),
                  child: Icon(Icons.drag_indicator, color: Color(0xFFE2E8F0)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
