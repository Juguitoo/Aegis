import 'package:aegis/core/utils/color_utils.dart';
import 'package:aegis/presentation/screens/tags/components/tag_form_dialog.dart';
import 'package:aegis/presentation/viewmodels/tag_list_viewmodel.dart';
import 'package:aegis/presentation/widgets/aegis_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/local/database/app_database.dart';

class ManageTagsBottomSheet extends ConsumerStatefulWidget {
  const ManageTagsBottomSheet({super.key});

  @override
  ConsumerState<ManageTagsBottomSheet> createState() =>
      _ManageTagsBottomSheetState();
}

class _ManageTagsBottomSheetState extends ConsumerState<ManageTagsBottomSheet> {
  void _showTagDialog([Tag? existingTag]) {
    showDialog(
      context: context,
      builder: (context) => TagFormDialog(existingTag: existingTag),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final tagsAsync = ref.watch(tagListViewModelProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.7,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 24, right: 16, top: 20, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gestionar etiquetas',
                  style: textTheme.displayMedium?.copyWith(fontSize: 20),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: colorScheme.outline),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(color: colorScheme.outline.withValues(alpha: 0.2), height: 1),
          Flexible(
            child: tagsAsync.when(
              data: (tags) {
                if (tags.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'No tienes etiquetas aún.',
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: tags.length,
                  itemBuilder: (context, index) {
                    final tag = tags[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 4),
                      leading: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: ColorUtils.parseColor(tag.colorHex),
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(
                        tag.name,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit_outlined,
                                color: colorScheme.onSurfaceVariant, size: 20),
                            onPressed: () => _showTagDialog(tag),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline,
                                color: colorScheme.error, size: 20),
                            onPressed: () {
                              ref
                                  .read(tagListViewModelProvider.notifier)
                                  .deleteTag(tag);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(child: Text('Error: $err')),
              ),
            ),
          ),
          Divider(color: colorScheme.outline.withValues(alpha: 0.2), height: 1),
          Padding(
            padding: EdgeInsets.only(
                top: 24.0,
                left: 24.0,
                right: 24.0,
                bottom: MediaQuery.of(context).padding.bottom + 24),
            child: AegisButton(
              onPressed: () => _showTagDialog(),
              text: 'Crear nueva etiqueta',
              icon: Icons.add,
              type: ButtonType.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
