import 'package:aegis/core/utils/color_utils.dart';
import 'package:aegis/presentation/widgets/aegis_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/local/database/app_database.dart';
import '../../../viewmodels/area_list_viewmodel.dart';
import 'area_form_dialog.dart';

class ManageAreasBottomSheet extends ConsumerStatefulWidget {
  const ManageAreasBottomSheet({super.key});

  @override
  ConsumerState<ManageAreasBottomSheet> createState() =>
      _ManageAreasBottomSheetState();
}

class _ManageAreasBottomSheetState
    extends ConsumerState<ManageAreasBottomSheet> {
  void _showAreaDialog([Area? existingArea]) {
    showDialog(
      context: context,
      builder: (context) => AreaFormDialog(existingArea: existingArea),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final areasAsync = ref.watch(areaListViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.7,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom,
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
                  'Gestionar áreas',
                  style: textTheme.displayMedium,
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
            child: areasAsync.when(
              data: (areas) {
                if (areas.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'No tienes áreas aún.',
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: areas.length,
                  itemBuilder: (context, index) {
                    final area = areas[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 4),
                      leading: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: ColorUtils.parseColor(area.colorHex),
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(
                        area.name,
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
                            onPressed: () => _showAreaDialog(area),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline,
                                color: colorScheme.error, size: 20),
                            onPressed: () {
                              ref
                                  .read(areaListViewModelProvider.notifier)
                                  .deleteArea(area);
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
            padding: const EdgeInsets.all(24.0),
            child: AegisButton(
              onPressed: () => _showAreaDialog(),
              text: 'Crear nuevo área',
              icon: Icons.add,
              type: ButtonType.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
