import 'package:aegis/core/utils/color_utils.dart';
import 'package:aegis/presentation/viewmodels/tag_list_viewmodel.dart';
import 'package:aegis/presentation/widgets/aegis_buttons.dart';
import 'package:aegis/presentation/widgets/aegis_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../../data/local/database/app_database.dart';

class TagFormDialog extends ConsumerStatefulWidget {
  final Tag? existingTag;

  const TagFormDialog({super.key, this.existingTag});

  @override
  ConsumerState<TagFormDialog> createState() => _TagFormDialogState();
}

class _TagFormDialogState extends ConsumerState<TagFormDialog> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController hexController;
  late FocusNode hexFocusNode;
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    final isEditing = widget.existingTag != null;

    nameController =
        TextEditingController(text: widget.existingTag?.name ?? '');
    descriptionController =
        TextEditingController(text: widget.existingTag?.description ?? '');

    selectedColor = isEditing
        ? ColorUtils.parseColor(widget.existingTag!.colorHex)
        : const Color(0xFF6366F1);

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
    final isEditing = widget.existingTag != null;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      title: Text(isEditing ? 'Editar etiqueta' : 'Nueva etiqueta',
          style: textTheme.displayMedium?.copyWith(fontSize: 20)),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AegisTextField(
                controller: nameController,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 80,
                labelText: 'Nombre de la etiqueta',
                hintText: "Email, 5mins...",
                autofocus: true,
              ),
              const SizedBox(height: 16),
              AegisTextField(
                controller: descriptionController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                minLines: 1,
                maxLength: 120,
                labelText: 'Descripción de la etiqueta',
                hintText: 'Detalles sobre la etiqueta...',
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
      ),
      actions: [
        Expanded(
          child: Row(
            children: [
              if (isEditing)
                Expanded(
                  child: AegisButton(
                    height: 44,
                    text: 'Eliminar',
                    onPressed: () {
                      ref
                          .read(tagListViewModelProvider.notifier)
                          .deleteTag(widget.existingTag!);
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
                        final updatedTag = Tag(
                          id: widget.existingTag!.id,
                          name: nameController.text.trim(),
                          colorHex: hexToSave,
                          description: description,
                        );
                        ref
                            .read(tagListViewModelProvider.notifier)
                            .updateTag(updatedTag);
                      } else {
                        ref.read(tagListViewModelProvider.notifier).addTag(
                              nameController.text.trim(),
                              hexToSave,
                              description,
                            );
                      }
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            backgroundColor: colorScheme.error,
                            content: Text(
                                'El nombre de la etiqueta es obligatorio')),
                      );
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
