import 'package:aegis/core/utils/color_utils.dart';
import 'package:aegis/presentation/widgets/aegis_buttons.dart';
import 'package:aegis/presentation/widgets/aegis_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../../data/local/database/app_database.dart';
import '../../../viewmodels/area_list_viewmodel.dart';

class AreaFormDialog extends ConsumerStatefulWidget {
  final Area? existingArea;

  const AreaFormDialog({super.key, this.existingArea});

  @override
  ConsumerState<AreaFormDialog> createState() => _AreaFormDialogState();
}

class _AreaFormDialogState extends ConsumerState<AreaFormDialog> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController hexController;
  late FocusNode hexFocusNode;
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    final isEditing = widget.existingArea != null;

    nameController =
        TextEditingController(text: widget.existingArea?.name ?? '');
    descriptionController =
        TextEditingController(text: widget.existingArea?.description ?? '');

    selectedColor = isEditing
        ? ColorUtils.parseColor(widget.existingArea!.colorHex)
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
    final isEditing = widget.existingArea != null;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        isEditing ? 'Editar área' : 'Nuevo área',
        style: textTheme.displayMedium?.copyWith(fontSize: 20),
      ),
      content: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AegisTextField(
              controller: nameController,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 80,
              labelText: 'Nombre del área',
              hintText: "Universidad, Trabajo, Personal...",
              autofocus: true,
            ),
            const SizedBox(height: 24),
            AegisTextField(
              controller: descriptionController,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 120,
              maxLines: 3,
              minLines: 1,
              labelText: 'Descripción del área',
              hintText: 'Detalles sobre el proyecto...',
            ),
            const SizedBox(height: 16),
            Text(
              'Color',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
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
                      border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.3),
                          width: 2),
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
                  child: AegisTextField(
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
                    hintText: '#HEX',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isEditing)
              Expanded(
                child: AegisButton(
                  height: 44,
                  text: 'Eliminar',
                  onPressed: () {
                    ref
                        .read(areaListViewModelProvider.notifier)
                        .deleteArea(widget.existingArea!);
                    Navigator.pop(context);
                  },
                  type: ButtonType.destructive,
                ),
              )
            else
              Expanded(
                child: AegisButton(
                  height: 44,
                  text: 'Cancelar',
                  onPressed: () => Navigator.pop(context),
                  type: ButtonType.secondary,
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: AegisButton(
                height: 44,
                text: isEditing ? 'Actualizar' : 'Guardar',
                onPressed: () {
                  if (nameController.text.trim().isNotEmpty) {
                    final hexToSave = ColorUtils.colorToHex(selectedColor);
                    final description = descriptionController.text.trim();

                    if (isEditing) {
                      final updatedArea = Area(
                        id: widget.existingArea!.id,
                        name: nameController.text.trim(),
                        colorHex: hexToSave,
                        description: description,
                      );
                      ref
                          .read(areaListViewModelProvider.notifier)
                          .updateArea(updatedArea);
                    } else {
                      ref.read(areaListViewModelProvider.notifier).addArea(
                            nameController.text.trim(),
                            hexToSave,
                            description,
                          );
                    }
                    Navigator.pop(context);
                  } else {
                    final screenSize = MediaQuery.of(context).size;
                    final sideMargin = screenSize.width > 600
                        ? (screenSize.width - 400) / 2
                        : 16.0;
                    final bottomMargin =
                        (screenSize.height - 120).clamp(16.0, 4000.0);

                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.white),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'El nombre del área es obligatorio',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: colorScheme.error,
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.only(
                            bottom: bottomMargin,
                            left: sideMargin,
                            right: sideMargin),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 6,
                        dismissDirection: DismissDirection.up,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                },
              ),
            )
          ],
        )
      ],
    );
  }
}
