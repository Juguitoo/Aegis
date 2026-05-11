import 'package:aegis/presentation/screens/areas/components/manage_area_bottom_sheet.dart';
import 'package:aegis/presentation/screens/tasks/components/manage_habits_bottom_sheet.dart';
import 'package:aegis/presentation/widgets/aegis_buttons.dart';
import 'package:aegis/presentation/widgets/aegis_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/core/utils/color_utils.dart';
import 'package:aegis/presentation/viewmodels/area_list_viewmodel.dart';
import 'package:aegis/presentation/viewmodels/task_list_viewmodel.dart';
import 'package:aegis/presentation/viewmodels/tag_list_viewmodel.dart';
import 'package:aegis/presentation/screens/tasks/components/task_form_desktop.dart';
import 'package:aegis/presentation/screens/tags/components/manage_tags_bottom_sheet.dart';
import 'package:aegis/presentation/screens/tags/components/tag_multi_selector.dart';

class DesktopFilterControls extends ConsumerWidget {
  const DesktopFilterControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedAreaId = ref.watch(areaFilterProvider);
    final selectedTagIds = ref.watch(tagFilterProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final areasAsync = ref.watch(areaListViewModelProvider);
    final tagsAsync = ref.watch(tagListViewModelProvider);

    String? activeProjectName;
    Color? activeProjectColor;

    if (selectedAreaId == -1) {
      activeProjectName = 'Bandeja de entrada';
      activeProjectColor = colorScheme.onSurfaceVariant;
    } else if (selectedAreaId != null) {
      final areaVal =
          areasAsync.value?.where((p) => p.id == selectedAreaId).firstOrNull;
      if (areaVal != null) {
        activeProjectName = areaVal.name;
        activeProjectColor = ColorUtils.parseColor(areaVal.colorHex);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Expanded(
              child: _DesktopSearchBar(),
            ),
            SizedBox(width: 12),
            FilterIconButton(),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        color: activeProjectColor?.withValues(alpha: 0.1) ??
                            colorScheme.secondary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: activeProjectColor?.withValues(alpha: 0.4) ??
                              colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Área: $activeProjectName',
                            style: textTheme.bodySmall?.copyWith(
                              color: activeProjectColor ??
                                  colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                ref.read(areaFilterProvider.notifier).state =
                                    null;
                              },
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: activeProjectColor ??
                                    colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                              color: tagColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: tagColor.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.label_outline,
                                    size: 14, color: tagColor),
                                const SizedBox(width: 6),
                                Text(
                                  tag.name,
                                  style: textTheme.bodySmall
                                      ?.copyWith(color: tagColor),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AegisButton(
          text: 'Nueva Tarea',
          icon: Icons.add,
          type: ButtonType.primary,
          height: 40,
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const TaskFormDesktop(),
            );
          },
        ),
        const SizedBox(width: 12),
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
          ),
          child: PopupMenuButton(
            icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
            color: colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            position: PopupMenuPosition.under,
            elevation: 4,
            padding: EdgeInsets.zero,
            onSelected: (value) {
              if (value == 1) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const ManageAreasBottomSheet(),
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
              if (value == 3) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const ManageHabitsBottomSheet(),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.folder_open_outlined,
                        color: colorScheme.onSurfaceVariant, size: 20),
                    const SizedBox(width: 12),
                    Text('Gestionar áreas',
                        style: TextStyle(color: colorScheme.onSurface)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 2,
                child: Row(
                  children: [
                    Icon(Icons.label_outlined,
                        color: colorScheme.onSurfaceVariant, size: 20),
                    const SizedBox(width: 12),
                    Text('Gestionar etiquetas',
                        style: TextStyle(color: colorScheme.onSurface)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 3,
                child: Row(
                  children: [
                    Icon(Icons.auto_graph_outlined,
                        color: colorScheme.onSurfaceVariant, size: 20),
                    const SizedBox(width: 12),
                    Text('Gestionar hábitos',
                        style: TextStyle(color: colorScheme.onSurface)),
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
    final colorScheme = Theme.of(context).colorScheme;

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
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.secondary, width: 1),
            boxShadow: [
              BoxShadow(
                color: colorScheme.onSurface
                    .withValues(alpha: _isHovered ? 0.1 : 0.05),
                blurRadius: _isHovered ? 15 : 8,
                offset: _isHovered ? const Offset(0, 8) : const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(Icons.tune, color: colorScheme.primary),
        ),
      ),
    );
  }
}

class TaskFiltersDialog extends ConsumerWidget {
  const TaskFiltersDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areasAsync = ref.watch(areaListViewModelProvider);
    final selectedAreaId = ref.watch(areaFilterProvider);
    final selectedTagIds = ref.watch(tagFilterProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        'Filtros Avanzados',
        style: textTheme.displayMedium,
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Área',
              style:
                  textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            areasAsync.when(
              data: (areas) {
                return AegisDropdown<int?>(
                  value: selectedAreaId,
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Todas las áreas'),
                    ),
                    DropdownMenuItem<int?>(
                      value: -1,
                      child: Row(
                        children: [
                          Icon(Icons.inbox_outlined,
                              size: 18, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Text('Bandeja de entrada',
                              style: TextStyle(
                                  color: colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    ...areas.map((p) => DropdownMenuItem<int?>(
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
                    ref.read(areaFilterProvider.notifier).state = val;
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Error: $e'),
            ),
            const SizedBox(height: 24),
            Text(
              'Etiquetas',
              style:
                  textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
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
        Row(
          children: [
            Expanded(
              child: AegisButton(
                text: 'Limpiar',
                type: ButtonType.secondary,
                onPressed: () {
                  ref.read(areaFilterProvider.notifier).state = null;
                  ref.read(tagFilterProvider.notifier).state = [];
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AegisButton(
                text: 'Aplicar y Cerrar',
                type: ButtonType.primary,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DesktopSearchBar extends ConsumerStatefulWidget {
  const _DesktopSearchBar();

  @override
  ConsumerState<_DesktopSearchBar> createState() => _DesktopSearchBarState();
}

class _DesktopSearchBarState extends ConsumerState<_DesktopSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search() {
    ref.read(searchQueryProvider.notifier).state = _controller.text;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 48,
      padding: const EdgeInsets.only(left: 16, right: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.secondary),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              style:
                  textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Buscar tarea...',
                hintStyle:
                    textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.search, color: colorScheme.primary),
            onPressed: _search,
          ),
        ],
      ),
    );
  }
}
