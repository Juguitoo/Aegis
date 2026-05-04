import 'package:aegis/core/utils/color_utils.dart';
import 'package:aegis/presentation/screens/tags/components/tag_form_dialog.dart';
import 'package:aegis/presentation/viewmodels/tag_list_viewmodel.dart';
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
    final tagsAsync = ref.watch(tagListViewModelProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.7,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                const Text(
                  'Gestionar Etiquetas',
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
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          Flexible(
            child: tagsAsync.when(
              data: (tags) {
                if (tags.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'No tienes etiquetas aún.',
                        style: TextStyle(color: Color(0xFF94A3B8)),
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined,
                                color: Color(0xFF64748B), size: 20),
                            onPressed: () => _showTagDialog(tag),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Color(0xFFEF4444), size: 20),
                            onPressed: () async {
                              try {
                                ref
                                    .read(tagListViewModelProvider.notifier)
                                    .deleteTag(tag);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Error al eliminar la etiqueta.')));
                                return;
                              }
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
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: ElevatedButton.icon(
              onPressed: () => _showTagDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Crear nueva etiqueta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                foregroundColor: const Color(0xFF0F172A),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
