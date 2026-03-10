import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/core/utils/color_utils.dart';
import 'package:aegis/presentation/viewmodels/project_list_viewmodel.dart';
import 'package:aegis/presentation/viewmodels/task_list_viewmodel.dart';
import 'package:aegis/presentation/viewmodels/tag_list_viewmodel.dart';
import 'package:aegis/presentation/screens/tasks/widgets/task_form_desktop.dart';
import 'package:aegis/presentation/screens/projects/widgets/manage_projects_bottom_sheet.dart';
import 'package:aegis/presentation/screens/tags/widgets/manage_tags_bottom_sheet.dart';
import 'package:aegis/presentation/screens/tags/widgets/tag_multi_selector.dart';

class FilterControls extends ConsumerWidget {
  const FilterControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedProjectId = ref.watch(projectFilterProvider);
    final selectedTagIds = ref.watch(tagFilterProvider);

    final projectsAsync = ref.watch(projectListViewModelProvider);
    final tagsAsync = ref.watch(tagListViewModelProvider);

    String? activeProjectName;
    Color? activeProjectColor;

    if (selectedProjectId == -1) {
      activeProjectName = 'Bandeja de entrada';
      activeProjectColor = const Color(0xFF64748B);
    } else if (selectedProjectId != null) {
      final projectVal = projectsAsync.value
          ?.where((p) => p.id == selectedProjectId)
          .firstOrNull;
      if (projectVal != null) {
        activeProjectName = projectVal.name;
        activeProjectColor = ColorUtils.parseColor(projectVal.colorHex);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. FILA DE BÚSQUEDA Y BOTÓN DE AJUSTES
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar tarea...',
                          hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Icon(Icons.search, color: Color(0xFF6366F1)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            const FilterIconButton(),
          ],
        ),
        const SizedBox(height: 16),

        // 2. TOOLBAR: FILTROS ACTIVOS (Izquierda) + BOTONES DE ACCIÓN (Derecha)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contenedor de Píldoras
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (activeProjectName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: activeProjectColor?.withAlpha(20) ??
                            const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: activeProjectColor?.withAlpha(100) ??
                              const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Proyecto: $activeProjectName',
                            style: TextStyle(
                              color:
                                  activeProjectColor ?? const Color(0xFF475569),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                ref.read(projectFilterProvider.notifier).state =
                                    null;
                              },
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: activeProjectColor ??
                                    const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Píldoras de Etiquetas Activas
                  if (selectedTagIds.isNotEmpty)
                    ...tagsAsync.maybeWhen(
                      data: (allTags) {
                        final activeTags =
                            allTags.where((t) => selectedTagIds.contains(t.id));
                        return activeTags.map((tag) {
                          final tagColor = ColorUtils.parseColor(tag.colorHex);
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: tagColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: tagColor.withAlpha(100)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.label_outline,
                                    size: 14, color: tagColor),
                                const SizedBox(width: 6),
                                Text(
                                  tag.name,
                                  style: TextStyle(
                                    color: tagColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      final currentList = List<int>.from(
                                          ref.read(tagFilterProvider));
                                      currentList.remove(tag.id);
                                      ref
                                          .read(tagFilterProvider.notifier)
                                          .state = currentList;
                                    },
                                    child: Icon(Icons.close,
                                        size: 16, color: tagColor),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList();
                      },
                      orElse: () => [const SizedBox()],
                    ),
                ],
              ),
            ),

            // Botones de Acción
            const _ActionButtonsRow(),
          ],
        ),
      ],
    );
  }
}

class _ActionButtonsRow extends StatelessWidget {
  const _ActionButtonsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const TaskFormDesktop(),
            );
          },
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Nueva Tarea',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 4,
            shadowColor: const Color(0xFF6366F1).withAlpha(100),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
            color: Colors.white,
            surfaceTintColor: Colors.transparent,
            position: PopupMenuPosition.under,
            elevation: 4,
            onSelected: (value) {
              if (value == 1) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const ManageProjectsBottomSheet(),
                );
              }
              if (value == 2) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const ManageTagsBottomSheet(),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.folder_open_outlined,
                        color: Color(0xFF64748B), size: 20),
                    SizedBox(width: 12),
                    Text('Gestionar Proyectos',
                        style: TextStyle(color: Color(0xFF1E293B))),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 2,
                child: Row(
                  children: [
                    Icon(Icons.label_outlined,
                        color: Color(0xFF64748B), size: 20),
                    SizedBox(width: 12),
                    Text('Gestionar Etiquetas',
                        style: TextStyle(color: Color(0xFF1E293B))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FilterIconButton extends StatefulWidget {
  const FilterIconButton({super.key});

  @override
  State<FilterIconButton> createState() => _FilterIconButtonState();
}

class _FilterIconButtonState extends State<FilterIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => const TaskFiltersDialog(),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? Colors.black.withAlpha(25)
                    : Colors.black.withAlpha(10),
                blurRadius: _isHovered ? 15 : 8,
                offset: _isHovered ? const Offset(0, 8) : const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.tune, color: Color(0xFF6366F1)),
        ),
      ),
    );
  }
}

class TaskFiltersDialog extends ConsumerWidget {
  const TaskFiltersDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectListViewModelProvider);
    final selectedProjectId = ref.watch(projectFilterProvider);
    final selectedTagIds = ref.watch(tagFilterProvider);

    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text(
        'Filtros Avanzados',
        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Proyecto',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 8),
            projectsAsync.when(
              data: (projects) {
                return DropdownButtonFormField<int?>(
                  initialValue: selectedProjectId,
                  dropdownColor: Colors.white,
                  icon: const Icon(Icons.keyboard_arrow_down,
                      color: Color(0xFF94A3B8)),
                  decoration: InputDecoration(
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
                        horizontal: 16, vertical: 12),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Todos los proyectos'),
                    ),
                    const DropdownMenuItem<int?>(
                      value: -1,
                      child: Row(
                        children: [
                          Icon(Icons.inbox_outlined,
                              size: 18, color: Color(0xFF64748B)),
                          SizedBox(width: 8),
                          Text('Bandeja de entrada',
                              style: TextStyle(color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    ...projects.map((p) => DropdownMenuItem<int?>(
                          value: p.id,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: ColorUtils.parseColor(p.colorHex),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(p.name),
                            ],
                          ),
                        ))
                  ],
                  onChanged: (val) {
                    ref.read(projectFilterProvider.notifier).state = val;
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text('Error: $e'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Etiquetas',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 8),
            // AQUÍ INYECTAMOS EL SELECTOR MULTIPLE PARA FILTROS
            TagMultiSelector(
              initialSelectedIds: selectedTagIds,
              onTagsChanged: (newTags) {
                ref.read(tagFilterProvider.notifier).state = newTags;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(projectFilterProvider.notifier).state = null;
            ref.read(tagFilterProvider.notifier).state =
                []; // Limpia también las etiquetas
          },
          child: const Text('Limpiar filtros',
              style: TextStyle(color: Color(0xFF64748B))),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Aplicar y Cerrar'),
        ),
      ],
    );
  }
}
