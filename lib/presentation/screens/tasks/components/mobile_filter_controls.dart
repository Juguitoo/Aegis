import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/core/utils/color_utils.dart';
import 'package:aegis/presentation/viewmodels/project_list_viewmodel.dart';
import 'package:aegis/presentation/viewmodels/task_list_viewmodel.dart';
import 'package:aegis/presentation/viewmodels/tag_list_viewmodel.dart';
import 'package:aegis/presentation/screens/tasks/widgets/tag_multi_selector.dart';

class MobileFilterControls extends ConsumerWidget {
  const MobileFilterControls({super.key});

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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(7),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const MobileTaskFiltersBottomSheet(),
                  );
                },
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(7),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.tune, color: Color(0xFF6366F1)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Fila de píldoras activas (Horizontal en móvil)
          if (activeProjectName != null || selectedTagIds.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  if (activeProjectName != null)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
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
                          GestureDetector(
                            onTap: () {
                              ref.read(projectFilterProvider.notifier).state =
                                  null;
                            },
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color:
                                  activeProjectColor ?? const Color(0xFF475569),
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
                            margin: const EdgeInsets.only(right: 8),
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
                                GestureDetector(
                                  onTap: () {
                                    final currentList = List<int>.from(
                                        ref.read(tagFilterProvider));
                                    currentList.remove(tag.id);
                                    ref.read(tagFilterProvider.notifier).state =
                                        currentList;
                                  },
                                  child: Icon(Icons.close,
                                      size: 16, color: tagColor),
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

          const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                _FilterChip(label: 'Todo', isSelected: true),
                _FilterChip(label: 'Completas', isSelected: false),
                _FilterChip(label: 'Pendientes', isSelected: false),
                _FilterChip(label: 'Hoy', isSelected: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MobileTaskFiltersBottomSheet extends ConsumerWidget {
  const MobileTaskFiltersBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectListViewModelProvider);
    final selectedProjectId = ref.watch(projectFilterProvider);
    final selectedTagIds = ref.watch(tagFilterProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          TagMultiSelector(
            initialSelectedIds: selectedTagIds,
            onTagsChanged: (newTags) {
              ref.read(tagFilterProvider.notifier).state = newTags;
            },
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    ref.read(projectFilterProvider.notifier).state = null;
                    ref.read(tagFilterProvider.notifier).state =
                        []; // Limpia etiquetas
                    Navigator.pop(context);
                  },
                  child: const Text('Limpiar',
                      style: TextStyle(color: Color(0xFF64748B))),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Aplicar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterChip({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF475569),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }
}
