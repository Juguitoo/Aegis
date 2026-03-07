import 'package:aegis/core/utils/color_utils.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/presentation/screens/tasks/widgets/task_form_mixin.dart';
import 'package:aegis/presentation/viewmodels/project_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tags/widgets/tag_multi_selector.dart'; // Importante añadir esto

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
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 16),
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: estimatedDurationController,
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
                    onTap: pickDueDate,
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
                      selectedProjectId = value;
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
                  selected: selectedPriority == 0,
                  onSelected: (selected) =>
                      setState(() => selectedPriority = 0),
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
                  onSelected: (selected) =>
                      setState(() => selectedPriority = 1),
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
                  onSelected: (selected) =>
                      setState(() => selectedPriority = 2),
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
                  onSelected: (selected) =>
                      setState(() => selectedPriority = 3),
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
              onTagsChanged: (newTagIds) {
                setState(() {
                  selectedTagIds = newTagIds;
                });
              },
            ),
            const SizedBox(height: 24),
            Row(
              spacing: 16,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: widget.task != null ? deleteTask : clearTask,
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
                    onPressed: widget.task == null ? saveTask : updateTask,
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
