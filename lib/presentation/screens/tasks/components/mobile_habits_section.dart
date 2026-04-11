import 'package:aegis/presentation/viewmodels/habits_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MobileHabitsSection extends ConsumerWidget {
  const MobileHabitsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsViewModelProvider);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final currentDayOfWeek = today.weekday;
    final monday = today.subtract(Duration(days: currentDayOfWeek - 1));

    final currentWeekDays =
        List.generate(7, (index) => monday.add(Duration(days: index)));

    final currentMonthStr =
        toBeginningOfSentenceCase(DateFormat('MMMM yyyy', 'es').format(monday));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Hábitos",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B)),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: const Color(0xFF6366F1),
                iconSize: 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      final controller = TextEditingController();
                      return AlertDialog(
                        backgroundColor: Colors.white,
                        surfaceTintColor: Colors.transparent,
                        title: const Text('Nuevo hábito',
                            style: TextStyle(fontSize: 18)),
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
                            ref
                                .read(habitsViewModelProvider.notifier)
                                .addHabit(value);
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
                              ref
                                  .read(habitsViewModelProvider.notifier)
                                  .addHabit(controller.text);
                              Navigator.pop(context);
                            },
                            child: const Text('Añadir'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: habitsAsync.when(
            skipLoadingOnReload: true,
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: Color(0xFF6366F1)),
              ),
            ),
            error: (error, stack) => Center(child: Text('Error: $error')),
            data: (habits) {
              if (habits.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No tienes hábitos activos.\n¡Añade uno para empezar!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          currentMonthStr,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: currentWeekDays.map((date) {
                            final isToday = date.day == today.day &&
                                date.month == today.month &&
                                date.year == today.year;
                            final dayInitials = DateFormat('E', 'es')
                                .format(date)
                                .substring(0, 1)
                                .toUpperCase();

                            return Container(
                              width: 24,
                              height: 24,
                              alignment: Alignment.center,
                              decoration: isToday
                                  ? const BoxDecoration(
                                      color: Color(0xFF6366F1),
                                      shape: BoxShape.circle,
                                    )
                                  : null,
                              child: Text(
                                dayInitials,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isToday
                                      ? Colors.white
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 144),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: habits.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final habitData = habits[index];

                        return Row(
                          key: ValueKey(habitData.habit.id),
                          children: [
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            final controller =
                                                TextEditingController(
                                                    text: habitData.habit.name);
                                            return AlertDialog(
                                              backgroundColor: Colors.white,
                                              surfaceTintColor:
                                                  Colors.transparent,
                                              title: const Text('Editar hábito',
                                                  style:
                                                      TextStyle(fontSize: 18)),
                                              content: TextField(
                                                controller: controller,
                                                decoration:
                                                    const InputDecoration(
                                                  focusedBorder:
                                                      UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color:
                                                            Color(0xFF6366F1)),
                                                  ),
                                                ),
                                                autofocus: true,
                                                onSubmitted: (value) {
                                                  ref
                                                      .read(
                                                          habitsViewModelProvider
                                                              .notifier)
                                                      .updateHabit(
                                                          habitData.habit.id,
                                                          value);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text('Cancelar',
                                                      style: TextStyle(
                                                          color: Color(
                                                              0xFF94A3B8))),
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFF6366F1),
                                                    foregroundColor:
                                                        Colors.white,
                                                    elevation: 0,
                                                  ),
                                                  onPressed: () {
                                                    ref
                                                        .read(
                                                            habitsViewModelProvider
                                                                .notifier)
                                                        .updateHabit(
                                                            habitData.habit.id,
                                                            controller.text);
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Guardar'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Text(
                                        habitData.habit.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF334155),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: currentWeekDays.map((date) {
                                  final isCompleted = habitData.entries
                                      .any((e) => e.date == date);
                                  final isFuture = date.isAfter(today);

                                  return GestureDetector(
                                    onTap: isFuture
                                        ? null
                                        : () {
                                            ref
                                                .read(habitsViewModelProvider
                                                    .notifier)
                                                .toggleHabitEntry(
                                                    habitData.habit.id, date);
                                          },
                                    child: Opacity(
                                      opacity: isFuture ? 0.3 : 1.0,
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          color: isCompleted
                                              ? const Color(0xFF6366F1)
                                              : const Color(0xFFF8FAFC),
                                          border: Border.all(
                                            color: isCompleted
                                                ? const Color(0xFF6366F1)
                                                : const Color(0xFFE2E8F0),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: isCompleted
                                            ? const Icon(Icons.check,
                                                size: 14, color: Colors.white)
                                            : null,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
