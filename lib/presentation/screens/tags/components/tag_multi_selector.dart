import 'package:aegis/presentation/widgets/aegis_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../viewmodels/tag_list_viewmodel.dart';
import '../../../../data/local/database/app_database.dart';
import 'package:collection/collection.dart';

class TagMultiSelector extends ConsumerStatefulWidget {
  final List<int> initialSelectedIds;
  final ValueChanged<List<int>> onTagsChanged;

  const TagMultiSelector({
    super.key,
    required this.initialSelectedIds,
    required this.onTagsChanged,
  });

  @override
  ConsumerState<TagMultiSelector> createState() => _TagMultiSelectorState();
}

class _TagMultiSelectorState extends ConsumerState<TagMultiSelector> {
  late List<int> _currentSelectedIds;

  @override
  void initState() {
    super.initState();
    _currentSelectedIds = List.from(widget.initialSelectedIds);
  }

  @override
  void didUpdateWidget(covariant TagMultiSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    final Function eq = const IterableEquality().equals;
    if (!eq(widget.initialSelectedIds, oldWidget.initialSelectedIds)) {
      _currentSelectedIds = List.from(widget.initialSelectedIds);
    }
  }

  void _showTagSelectionDialog(BuildContext context, List<Tag> allTags) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              title: Text(
                'Seleccionar etiquetas',
                style: textTheme.displayMedium,
              ),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                  maxWidth: 320.0,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: allTags.map((tag) {
                      final isSelected = _currentSelectedIds.contains(tag.id);
                      final tagColor = ColorUtils.parseColor(tag.colorHex);

                      return CheckboxListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: colorScheme.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        title: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: tagColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(tag.name,
                                  style: textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                        value: isSelected,
                        onChanged: (bool? checked) {
                          setStateDialog(() {
                            if (checked == true) {
                              _currentSelectedIds.add(tag.id);
                            } else {
                              _currentSelectedIds.remove(tag.id);
                            }
                          });
                          setState(() {});
                          widget.onTagsChanged(_currentSelectedIds);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                AegisButton(
                    text: 'Hecho',
                    onPressed: () => Navigator.pop(context),
                    type: ButtonType.primary,
                    height: 40)
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tagsAsync = ref.watch(tagListViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return tagsAsync.when(
      data: (allTags) {
        final selectedTags =
            allTags.where((t) => _currentSelectedIds.contains(t.id)).toList();

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...selectedTags.map((tag) => _buildTagChip(tag, textTheme)),
            _buildAddButton(context, allTags, colorScheme, textTheme),
          ],
        );
      },
      loading: () => const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 2)),
      error: (e, _) => Text('Error: $e'),
    );
  }

  Widget _buildTagChip(Tag tag, TextTheme textTheme) {
    final tagColor = ColorUtils.parseColor(tag.colorHex);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tagColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tagColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag.name,
            style: textTheme.bodySmall?.copyWith(
              color: tagColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 6),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _currentSelectedIds.remove(tag.id);
                });
                widget.onTagsChanged(_currentSelectedIds);
              },
              child: Icon(Icons.close_rounded, size: 14, color: tagColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, List<Tag> allTags,
      ColorScheme colorScheme, TextTheme textTheme) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showTagSelectionDialog(context, allTags),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border:
                Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded,
                  size: 16, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text('Añadir',
                  style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
