import 'package:aegis/presentation/viewmodels/habits_viewmodel.dart';
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(isEditing ? 'Editar hábito' : 'Nuevo hábito',
            style: const TextStyle(fontSize: 18)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Ej. Beber 2L de agua',
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF6366F1)),
            ),
          ),
          autofocus: true,
          onSubmitted: (value) {
            if (isEditing) {
              ref
                  .read(habitsViewModelProvider.notifier)
                  .updateHabit(habitId, value);
            } else {
              ref.read(habitsViewModelProvider.notifier).addHabit(value);
            }
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () {
              if (isEditing) {
                ref
                    .read(habitsViewModelProvider.notifier)
                    .updateHabit(habitId, controller.text);
              } else {
                ref
                    .read(habitsViewModelProvider.notifier)
                    .addHabit(controller.text);
              }
              Navigator.pop(context);
            },
            child: Text(isEditing ? 'Guardar' : 'Añadir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final habitsAsync = ref.watch(habitsViewModelProvider);

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
                  'Gestionar Hábitos',
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
            child: habitsAsync.when(
              skipLoadingOnReload: true,
              data: (habits) {
                if (habits.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'No tienes hábitos activos.',
                        style: TextStyle(color: Color(0xFF94A3B8)),
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
                            onPressed: () => _showHabitDialog(
                                habitId: habit.id, currentName: habit.name),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Color(0xFFEF4444), size: 20),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: Colors.white,
                                  surfaceTintColor: Colors.transparent,
                                  title: const Text('Eliminar hábito'),
                                  content: Text(
                                      '¿Seguro que quieres eliminar "${habit.name}"? Perderás su historial.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancelar',
                                          style: TextStyle(
                                              color: Color(0xFF94A3B8))),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        ref
                                            .read(habitsViewModelProvider
                                                .notifier)
                                            .deleteHabit(habit.id);
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Eliminar',
                                          style: TextStyle(
                                              color: Color(0xFFEF4444))),
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
              loading: () => const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF6366F1))),
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
              onPressed: () => _showHabitDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Crear nuevo hábito'),
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
