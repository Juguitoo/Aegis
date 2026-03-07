import 'package:aegis/core/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../../data/local/database/app_database.dart';
import '../../../viewmodels/project_list_viewmodel.dart';

class ProjectFormDialog extends ConsumerStatefulWidget {
  final Project? existingProject;

  const ProjectFormDialog({super.key, this.existingProject});

  @override
  ConsumerState<ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends ConsumerState<ProjectFormDialog> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController hexController;
  late FocusNode hexFocusNode;
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    final isEditing = widget.existingProject != null;

    nameController =
        TextEditingController(text: widget.existingProject?.name ?? '');
    descriptionController =
        TextEditingController(text: widget.existingProject?.description ?? '');

    selectedColor = isEditing
        ? ColorUtils.parseColor(widget.existingProject!.colorHex)
        : const Color(0xFF3B82F6);

    hexController =
        TextEditingController(text: ColorUtils.colorToHex(selectedColor));
    hexFocusNode = FocusNode();

    hexFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!hexFocusNode.hasFocus) {
      if (ColorUtils.parseColorStrict(hexController.text) == null) {
        hexController.text = ColorUtils.colorToHex(selectedColor);
      }
    }
  }

  @override
  void dispose() {
    hexFocusNode.removeListener(_onFocusChange);
    hexFocusNode.dispose();
    nameController.dispose();
    descriptionController.dispose();
    hexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingProject != null;

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        isEditing ? 'Editar Proyecto' : 'Nuevo Proyecto',
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w600,
              ),
              maxLength: 80,
              decoration: InputDecoration(
                labelText: 'Nombre del proyecto',
                hintText: "Universidad, Trabajo, Personal...",
                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                counterText: "",
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
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: descriptionController,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 120,
              maxLines: 3,
              minLines: 1,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                labelText: 'Descripción del proyecto',
                hintText: 'Detalles sobre el proyecto...',
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const Text(
              'Color',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        Color tempColor = selectedColor;
                        return AlertDialog(
                          title: const Text('Selecciona un color'),
                          content: SingleChildScrollView(
                            child: ColorPicker(
                              pickerColor: selectedColor,
                              onColorChanged: (color) {
                                tempColor = color;
                              },
                              enableAlpha: false,
                              displayThumbColor: true,
                              pickerAreaHeightPercent: 0.8,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  selectedColor = tempColor;
                                  hexController.text =
                                      ColorUtils.colorToHex(selectedColor);
                                });
                                Navigator.pop(context);
                              },
                              child: const Text('Seleccionar'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: selectedColor,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: const Color(0xFFE2E8F0), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: selectedColor.withAlpha(100),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: hexController,
                    focusNode: hexFocusNode,
                    onChanged: (value) {
                      final newColor = ColorUtils.parseColorStrict(value);
                      if (newColor != null) {
                        setState(() {
                          selectedColor = newColor;
                        });
                      }
                    },
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                    decoration: InputDecoration(
                      hintText: '#HEX',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF6366F1), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        Row(
          spacing: 32,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (isEditing) {
                    ref
                        .read(projectListViewModelProvider.notifier)
                        .deleteProject(widget.existingProject!);
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(isEditing ? 'Eliminar' : 'Cancelar'),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isNotEmpty) {
                    final hexToSave = ColorUtils.colorToHex(selectedColor);
                    final description = descriptionController.text.trim();

                    if (isEditing) {
                      final updatedProject = Project(
                        id: widget.existingProject!.id,
                        name: nameController.text.trim(),
                        colorHex: hexToSave,
                        description: description,
                      );
                      ref
                          .read(projectListViewModelProvider.notifier)
                          .updateProject(updatedProject);
                    } else {
                      ref
                          .read(projectListViewModelProvider.notifier)
                          .addProject(
                            ProjectsCompanion.insert(
                              name: nameController.text.trim(),
                              colorHex: drift.Value(hexToSave),
                              description: drift.Value(description),
                            ),
                          );
                    }
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('El nombre del proyecto es obligatorio')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(isEditing ? 'Actualizar' : 'Guardar'),
              ),
            )
          ],
        )
      ],
    );
  }
}
