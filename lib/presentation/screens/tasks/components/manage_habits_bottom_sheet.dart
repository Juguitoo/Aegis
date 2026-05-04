import 'package:aegis/presentation/viewmodels/habits_viewmodel.dart';
import 'package:aegis/presentation/widgets/aegis_buttons.dart';
import 'package:aegis/presentation/widgets/aegis_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManageHabitsBottomSheet extends ConsumerStatefulWidget {
  const ManageHabitsBottomSheet({super.key});

  @override
  ConsumerState<ManageHabitsBottomSheet> createState() =>
      _ManageHabitsBottomSheetState();
}

class _ManageHabitsBottomSheetState
    extends ConsumerState<ManageHabitsBottomSheet> {
  void _showHabitDialog({int? habitId, String currentName = ''}) {
    final controller = TextEditingController(text: currentName);
    final isEditing = habitId != null;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    void submitHabit(String value) {
      if (value.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('El nombre del hábito no puede estar vacío'),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        return;
      }
      if (isEditing) {
        ref
            .read(habitsViewModelProvider.notifier)
            .updateHabit(habitId, value.trim());
      } else {
        ref.read(habitsViewModelProvider.notifier).addHabit(value.trim());
      }
      Navigator.pop(context);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(isEditing ? 'Editar hábito' : 'Nuevo hábito',
            style: textTheme.displayMedium?.copyWith(fontSize: 18)),
        content: AegisTextField(
          controller: controller,
          hintText: 'Ej. Beber 2L de agua',
          autofocus: true,
          onSubmitted: submitHabit,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: AegisButton(
                  text: 'Cancelar',
                  type: ButtonType.secondary,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AegisButton(
                  text: isEditing ? 'Guardar' : 'Añadir',
                  type: ButtonType.primary,
                  onPressed: () => submitHabit(controller.text),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final habitsAsync = ref.watch(habitsViewModelProvider);
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
                  'Gestionar Hábitos',
                  style: textTheme.displayMedium?.copyWith(fontSize: 20),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.2)),
          Flexible(
            child: habitsAsync.when(
              skipLoadingOnReload: true,
              data: (habits) {
                if (habits.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'No tienes hábitos activos.',
                        style: TextStyle(color: colorScheme.outline),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final habit = habits[index].habit;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 4),
                      title: Text(
                        habit.name,
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
                            onPressed: () => _showHabitDialog(
                                habitId: habit.id, currentName: habit.name),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline,
                                color: colorScheme.error, size: 20),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: colorScheme.surface,
                                  surfaceTintColor: Colors.transparent,
                                  title: Text('Eliminar hábito',
                                      style: textTheme.displayMedium
                                          ?.copyWith(fontSize: 18)),
                                  content: Text(
                                      '¿Seguro que quieres eliminar "${habit.name}"? Perderás su historial.',
                                      style: textTheme.bodyMedium),
                                  actions: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: AegisButton(
                                            text: 'Cancelar',
                                            type: ButtonType.secondary,
                                            onPressed: () =>
                                                Navigator.pop(context),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: AegisButton(
                                            text: 'Eliminar',
                                            type: ButtonType.destructive,
                                            onPressed: () {
                                              ref
                                                  .read(habitsViewModelProvider
                                                      .notifier)
                                                  .deleteHabit(habit.id);
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                    child:
                        CircularProgressIndicator(color: colorScheme.primary)),
              ),
              error: (err, stack) => Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                    child: Text('Error: $err',
                        style: TextStyle(color: colorScheme.error))),
              ),
            ),
          ),
          Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.2)),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: AegisButton(
              text: 'Crear nuevo hábito',
              icon: Icons.add,
              type: ButtonType.secondary,
              onPressed: () => _showHabitDialog(),
            ),
          ),
        ],
      ),
    );
  }
}
