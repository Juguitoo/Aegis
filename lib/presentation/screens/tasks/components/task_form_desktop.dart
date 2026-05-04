import 'package:aegis/core/utils/color_utils.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/presentation/screens/tasks/components/task_form_mixin.dart';
import 'package:aegis/presentation/viewmodels/project_list_viewmodel.dart';
import 'package:aegis/presentation/viewmodels/task_list_viewmodel.dart';
import 'package:aegis/presentation/widgets/aegis_buttons.dart';
import 'package:aegis/presentation/widgets/aegis_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../tags/components/tag_multi_selector.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.onSurface.withValues(alpha: 0.2),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1100,
            maxHeight: 850,
          ),
          child: Material(
            elevation: 4,
            shadowColor: Colors.black12,
            color: colorScheme.surface,
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
                        style: textTheme.displayLarge?.copyWith(fontSize: 28),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: colorScheme.outline),
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
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: colorScheme.outline
                                      .withValues(alpha: 0.2)),
                            ),
                            child: _TaskDetailsColumn(
                              titleController: titleController,
                              descriptionController: descriptionController,
                              estimatedDurationController:
                                  estimatedDurationController,
                              selectedDueDate: selectedDueDate,
                              onPickDueDate: pickDueDate,
                              selectedNotificationDate:
                                  selectedNotificationDate,
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
                                    color: colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: colorScheme.outline
                                            .withValues(alpha: 0.2)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'Lista de Control',
                                        style: textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.bold),
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
                                    color: colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: colorScheme.outline
                                            .withValues(alpha: 0.2)),
                                  ),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          "Notas",
                                          style: textTheme.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 16),
                                        Expanded(
                                          child: AegisTextField(
                                            controller: notesController,
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            expands: true,
                                            textAlignVertical:
                                                TextAlignVertical.top,
                                            hintText:
                                                'Añade cualquier información adicional sobre la tarea',
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
                      SizedBox(
                        width: 180,
                        child: AegisButton(
                          text: widget.task != null ? 'Eliminar' : 'Limpiar',
                          type: widget.task != null
                              ? ButtonType.destructive
                              : ButtonType.secondary,
                          onPressed:
                              widget.task != null ? deleteTask : clearTask,
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 180,
                        child: AegisButton(
                          text: widget.task == null
                              ? 'Guardar Tarea'
                              : 'Actualizar Tarea',
                          type: ButtonType.primary,
                          onPressed:
                              widget.task == null ? saveTask : updateTask,
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
  final DateTime? selectedNotificationDate;
  final VoidCallback onPickNotificationDate;
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AegisTextField(
            controller: titleController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 80,
            labelText: 'Título',
            hintText: '¿Qué quieres hacer?',
          ),
          const SizedBox(height: 24),
          AegisTextField(
            controller: descriptionController,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 4,
            minLines: 2,
            maxLength: 500,
            labelText: 'Descripción',
            hintText: 'Añade detalles sobre la tarea',
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: AegisTextField(
                  controller: estimatedDurationController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  labelText: 'Estimación (min)',
                  hintText: 'Ej: 30',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AegisTextField(
                  readOnly: true,
                  onTap: onPickDueDate,
                  hintText: selectedDueDate == null
                      ? 'Sin fecha'
                      : '${selectedDueDate!.day}/${selectedDueDate!.month}/${selectedDueDate!.year}',
                  prefixIcon: Icons.calendar_today,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AegisTextField(
                  readOnly: true,
                  onTap: onPickNotificationDate,
                  hintText: selectedNotificationDate == null
                      ? 'Recordatorio'
                      : DateFormat('dd/MM HH:mm')
                          .format(selectedNotificationDate!),
                  prefixIcon: Icons.notifications_active_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          projectsAsync.when(
            data: (projectsList) {
              return AegisDropdown<int?>(
                value: selectedProjectId,
                labelText: 'Proyecto',
                prefixIcon: Icons.folder_outlined,
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Seleccionar proyecto'),
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
                            Text(p.name),
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
          Text(
            'Prioridad',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
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
                selectedColor: colorScheme.secondary,
                labelStyle: textTheme.bodyMedium?.copyWith(
                  color: selectedPriority == 0
                      ? colorScheme.primary
                      : colorScheme.outline,
                  fontWeight: selectedPriority == 0
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                side: BorderSide(
                  color: selectedPriority == 0
                      ? Colors.transparent
                      : colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              ChoiceChip(
                label: const Text('Baja'),
                selected: selectedPriority == 1,
                onSelected: (selected) => onPriorityChanged(1),
                selectedColor: const Color(0xFFDCFCE7),
                labelStyle: textTheme.bodyMedium?.copyWith(
                  color: selectedPriority == 1
                      ? const Color(0xFF16A34A)
                      : colorScheme.outline,
                  fontWeight: selectedPriority == 1
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                side: BorderSide(
                  color: selectedPriority == 1
                      ? Colors.transparent
                      : colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              ChoiceChip(
                label: const Text('Media'),
                selected: selectedPriority == 2,
                onSelected: (selected) => onPriorityChanged(2),
                selectedColor: const Color(0xFFFEF9C3),
                labelStyle: textTheme.bodyMedium?.copyWith(
                  color: selectedPriority == 2
                      ? const Color(0xFFCA8A04)
                      : colorScheme.outline,
                  fontWeight: selectedPriority == 2
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                side: BorderSide(
                  color: selectedPriority == 2
                      ? Colors.transparent
                      : colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              ChoiceChip(
                label: const Text('Alta'),
                selected: selectedPriority == 3,
                onSelected: (selected) => onPriorityChanged(3),
                selectedColor: colorScheme.onError,
                labelStyle: textTheme.bodyMedium?.copyWith(
                  color: selectedPriority == 3
                      ? colorScheme.error
                      : colorScheme.outline,
                  fontWeight: selectedPriority == 3
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                side: BorderSide(
                  color: selectedPriority == 3
                      ? Colors.transparent
                      : colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Etiquetas',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (total > 0) ...[
          Row(
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
                      backgroundColor: colorScheme.secondary,
                      color: value == 1.0
                          ? const Color(0xFF10B981)
                          : colorScheme.primary,
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
                      : colorScheme.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: widget.isLastEmpty ? Colors.transparent : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: widget.isLastEmpty
              ? Colors.transparent
              : colorScheme.outline.withValues(alpha: 0.2),
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
                activeColor: colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Icon(Icons.add, color: colorScheme.outline, size: 20),
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
                style: textTheme.bodyLarge?.copyWith(
                  color: widget.item.isCompleted
                      ? colorScheme.outline
                      : colorScheme.onSurface,
                  decoration: widget.item.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
                decoration: InputDecoration(
                  counterText: "",
                  hintText: widget.isLastEmpty ? "Añadir subpaso..." : "",
                  hintStyle: textTheme.bodyMedium
                      ?.copyWith(color: colorScheme.outline),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            if (!widget.isLastEmpty)
              IconButton(
                icon: Icon(Icons.close,
                    color: colorScheme.outline.withValues(alpha: 0.5),
                    size: 20),
                onPressed: widget.onRemove,
              ),
            if (!widget.isLastEmpty)
              ReorderableDragStartListener(
                index: widget.index,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
                  child: Icon(Icons.drag_indicator,
                      color: colorScheme.outline.withValues(alpha: 0.3)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
