import 'package:aegis/core/utils/color_utils.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/presentation/screens/tasks/widgets/task_form_mixin.dart';
import 'package:aegis/presentation/viewmodels/project_list_viewmodel.dart';
import 'package:aegis/presentation/viewmodels/task_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../tags/widgets/tag_multi_selector.dart';

class TaskFormMobile extends ConsumerStatefulWidget {
  final Task? task;

  const TaskFormMobile({super.key, this.task});

  @override
  ConsumerState<TaskFormMobile> createState() => _TaskFormMobileState();
}

class _TaskFormMobileState extends ConsumerState<TaskFormMobile>
    with TaskFormMixin {
  @override
  Task? get initialTask => widget.task;

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectListViewModelProvider);
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: screenHeight * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: DefaultTabController(
          length: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Text(
                  widget.task == null ? "Crear Nueva Tarea" : "Editar Tarea",
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B)),
                ),
              ),
              const SizedBox(height: 16),
              const TabBar(
                labelColor: Color(0xFF6366F1),
                unselectedLabelColor: Color(0xFF94A3B8),
                indicatorColor: Color(0xFF6366F1),
                dividerColor: Color(0xFFE2E8F0),
                tabs: [
                  Tab(text: 'Detalles'),
                  Tab(text: 'Subtareas'),
                  Tab(text: 'Notas'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _TaskDetailsTab(
                      titleController: titleController,
                      descriptionController: descriptionController,
                      estimatedDurationController: estimatedDurationController,
                      selectedDueDate: selectedDueDate,
                      onPickDueDate: pickDueDate,
                      selectedNotificationDate: selectedNotificationDate,
                      onPickNotificationDate: pickNotificationDate,
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
                    _TaskChecklistTab(
                      checklist: currentChecklist,
                      onUpdate: updateChecklistItem,
                      onToggle: toggleChecklistItem,
                      onRemove: removeChecklistItem,
                      onReorder: reorderChecklist,
                    ),
                    _TaskNotesTab(notesController: notesController),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    spacing: 16,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              widget.task != null ? deleteTask : clearTask,
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
                            widget.task != null ? 'Eliminar' : 'Limpiar',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              widget.task == null ? saveTask : updateTask,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskDetailsTab extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController estimatedDurationController;
  final DateTime? selectedDueDate;
  final VoidCallback onPickDueDate;
  final DateTime? selectedNotificationDate;
  final VoidCallback onPickNotificationDate;
  final AsyncValue<List<Project>> projectsAsync;
  final int? selectedProjectId;
  final ValueChanged<int?> onProjectChanged;
  final int selectedPriority;
  final ValueChanged<int> onPriorityChanged;
  final List<int> selectedTagIds;
  final ValueChanged<List<int>> onTagsChanged;

  const _TaskDetailsTab({
    required this.titleController,
    required this.descriptionController,
    required this.estimatedDurationController,
    required this.selectedDueDate,
    required this.onPickDueDate,
    required this.selectedNotificationDate,
    required this.onPickNotificationDate,
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
      padding: const EdgeInsets.all(16),
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
          TextField(
            controller: descriptionController,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 3,
            minLines: 1,
            maxLength: 500,
            decoration: InputDecoration(
              labelText: 'Descripción',
              hintText: 'Añade detalles sobre la tarea',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
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
          TextField(
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
            children: [
              Expanded(
                child: InkWell(
                  onTap: onPickDueDate,
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
                            selectedDueDate == null
                                ? 'Sin fecha'
                                : '${selectedDueDate!.day}/${selectedDueDate!.month}/${selectedDueDate!.year}',
                            style: TextStyle(
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
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: onPickNotificationDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                      borderRadius: BorderRadius.circular(12),
                      color: selectedNotificationDate != null
                          ? const Color(0xFFEEF2FF)
                          : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.notifications_active_outlined,
                            size: 20,
                            color: selectedNotificationDate != null
                                ? const Color(0xFF6366F1)
                                : const Color(0xFF64748B)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            selectedNotificationDate == null
                                ? 'Recordatorio'
                                : DateFormat('dd/MM HH:mm')
                                    .format(selectedNotificationDate!),
                            style: TextStyle(
                              fontSize: 16,
                              color: selectedNotificationDate == null
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF6366F1),
                              fontWeight: selectedNotificationDate != null
                                  ? FontWeight.bold
                                  : FontWeight.normal,
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
                initialValue: selectedProjectId,
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          const SizedBox(height: 16),
          const Text(
            'Etiquetas',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          TagMultiSelector(
            initialSelectedIds: selectedTagIds,
            onTagsChanged: onTagsChanged,
          ),
        ],
      ),
    );
  }
}

class _TaskChecklistTab extends StatelessWidget {
  final List<TaskChecklistItem> checklist;
  final void Function(int, String) onUpdate;
  final ValueChanged<int> onToggle;
  final ValueChanged<int> onRemove;
  final void Function(int oldIndex, int newIndex) onReorder;

  const _TaskChecklistTab({
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
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
                        minHeight: 8,
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
        ],
        Expanded(
          child: ReorderableListView.builder(
            itemCount: checklist.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
      color: widget.isLastEmpty ? Colors.transparent : Colors.white,
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
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) {
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

class _TaskNotesTab extends StatelessWidget {
  final TextEditingController notesController;

  const _TaskNotesTab({required this.notesController});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: notesController,
          textCapitalization: TextCapitalization.sentences,
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          decoration: InputDecoration(
            hintText: 'Añade cualquier información adicional sobre la tarea',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ));
  }
}
