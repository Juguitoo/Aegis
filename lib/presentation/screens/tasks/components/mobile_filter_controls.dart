import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/core/utils/color_utils.dart';
import 'package:aegis/presentation/viewmodels/area_list_viewmodel.dart';
import 'package:aegis/presentation/viewmodels/task_list_viewmodel.dart';
import 'package:aegis/presentation/viewmodels/tag_list_viewmodel.dart';
import 'package:aegis/presentation/screens/tags/components/tag_multi_selector.dart';
import 'package:aegis/presentation/widgets/aegis_inputs.dart';
import 'package:aegis/presentation/widgets/aegis_buttons.dart';

class MobileFilterControls extends ConsumerWidget {
  const MobileFilterControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedAreaId = ref.watch(areaFilterProvider);
    final selectedTagIds = ref.watch(tagFilterProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final areasAsync = ref.watch(areaListViewModelProvider);
    final tagsAsync = ref.watch(tagListViewModelProvider);

    String? activeAreaName;
    Color? activeAreaColor;

    if (selectedAreaId == -1) {
      activeAreaName = 'Bandeja de entrada';
      activeAreaColor = colorScheme.onSurfaceVariant;
    } else if (selectedAreaId != null) {
      final areaVal =
          areasAsync.value?.where((p) => p.id == selectedAreaId).firstOrNull;
      if (areaVal != null) {
        activeAreaName = areaVal.name;
        activeAreaColor = ColorUtils.parseColor(areaVal.colorHex);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: _MobileSearchBar(),
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
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.onSurface.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(Icons.tune, color: colorScheme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (activeAreaName != null || selectedTagIds.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  if (activeAreaName != null)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: activeAreaColor?.withValues(alpha: 0.1) ??
                            colorScheme.secondary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: activeAreaColor?.withValues(alpha: 0.4) ??
                              colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Area: $activeAreaName',
                            style: textTheme.bodySmall?.copyWith(
                              color: activeAreaColor ??
                                  colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              ref.read(areaFilterProvider.notifier).state =
                                  null;
                            },
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: activeAreaColor ??
                                  colorScheme.onSurfaceVariant,
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
        ],
      ),
    );
  }
}

class MobileTaskFiltersBottomSheet extends ConsumerWidget {
  const MobileTaskFiltersBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areasAsync = ref.watch(areaListViewModelProvider);
    final selectedAreaId = ref.watch(areaFilterProvider);
    final selectedTagIds = ref.watch(tagFilterProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
              Text(
                'Filtros',
                style: textTheme.displayMedium?.copyWith(fontSize: 20),
              ),
              IconButton(
                icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Area',
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          areasAsync.when(
            data: (areas) {
              return AegisDropdown<int?>(
                value: selectedAreaId,
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Todas las areas'),
                  ),
                  DropdownMenuItem<int?>(
                    value: -1,
                    child: Row(
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 18, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text('Bandeja de entrada',
                            style:
                                TextStyle(color: colorScheme.onSurfaceVariant)),
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
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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
                child: AegisButton(
                  text: 'Limpiar',
                  type: ButtonType.secondary,
                  onPressed: () {
                    ref.read(areaFilterProvider.notifier).state = null;
                    ref.read(tagFilterProvider.notifier).state = [];
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AegisButton(
                  text: 'Aplicar',
                  type: ButtonType.primary,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MobileSearchBar extends ConsumerStatefulWidget {
  const _MobileSearchBar();

  @override
  ConsumerState<_MobileSearchBar> createState() => _MobileSearchBarState();
}

class _MobileSearchBarState extends ConsumerState<_MobileSearchBar> {
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
      padding: const EdgeInsets.only(left: 16, right: 8),
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
