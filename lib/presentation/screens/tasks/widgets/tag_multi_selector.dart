import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../viewmodels/tag_list_viewmodel.dart';
import '../../../../data/local/database/app_database.dart';

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
    if (widget.initialSelectedIds != oldWidget.initialSelectedIds) {
      _currentSelectedIds = List.from(widget.initialSelectedIds);
    }
  }

  void _showTagSelectionDialog(BuildContext context, List<Tag> allTags) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Seleccionar Etiquetas',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              content: SizedBox(
                width: 300,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: allTags.map((tag) {
                      final isSelected = _currentSelectedIds.contains(tag.id);
                      final tagColor = ColorUtils.parseColor(tag.colorHex);

                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: const Color(0xFF6366F1),
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
                            Text(
                              tag.name,
                              style: const TextStyle(
                                color: Color(0xFF1E293B),
                                fontWeight: FontWeight.w500,
                              ),
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
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hecho',
                      style: TextStyle(
                          color: Color(0xFF6366F1),
                          fontWeight: FontWeight.bold)),
                ),
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

    return tagsAsync.when(
      data: (allTags) {
        final selectedTags =
            allTags.where((t) => _currentSelectedIds.contains(t.id)).toList();

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...selectedTags.map((tag) {
              final tagColor = ColorUtils.parseColor(tag.colorHex);
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: tagColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: tagColor.withAlpha(100)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tag.name,
                      style: TextStyle(
                        color: tagColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
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
                        child: Icon(Icons.close, size: 16, color: tagColor),
                      ),
                    ),
                  ],
                ),
              );
            }),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _showTagSelectionDialog(context, allTags),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 16, color: Color(0xFF64748B)),
                      SizedBox(width: 4),
                      Text('Añadir',
                          style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2)),
      error: (e, _) => Text('Error: $e'),
    );
  }
}
