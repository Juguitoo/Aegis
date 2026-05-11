import 'package:aegis/presentation/viewmodels/habits_viewmodel.dart';
import 'package:aegis/presentation/widgets/aegis_buttons.dart';
import 'package:aegis/presentation/widgets/aegis_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MobileHabitsSection extends ConsumerWidget {
  const MobileHabitsSection({super.key});

  void _showHabitDialog(BuildContext context, WidgetRef ref,
      {dynamic habitData}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final controller = TextEditingController(text: habitData?.habit.name ?? '');

    void submitHabit(BuildContext dialogContext, String value) {
      if (value.trim().isEmpty) {
        final screenSize = MediaQuery.of(dialogContext).size;
        final sideMargin =
            screenSize.width > 600 ? (screenSize.width - 400) / 2 : 16.0;
        final bottomMargin = (screenSize.height - 120).clamp(16.0, 4000.0);

        ScaffoldMessenger.of(dialogContext).hideCurrentSnackBar();
        ScaffoldMessenger.of(dialogContext).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'El nombre del hábito no puede estar vacío',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
                bottom: bottomMargin, left: sideMargin, right: sideMargin),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 6,
            dismissDirection: DismissDirection.up,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      if (habitData == null) {
        ref.read(habitsViewModelProvider.notifier).addHabit(value.trim());
      } else {
        ref
            .read(habitsViewModelProvider.notifier)
            .updateHabit(habitData.habit.id, value.trim());
      }

      Navigator.pop(dialogContext);
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  habitData == null ? 'Nuevo hábito' : 'Editar hábito',
                  style: textTheme.displayLarge?.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 16),
                AegisTextField(
                  controller: controller,
                  hintText: 'Ej. Beber 2L de agua',
                  minLines: 1,
                  maxLines: 3,
                  maxLength: 80,
                  autofocus: true,
                  onSubmitted: (val) => submitHabit(dialogContext, val),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: AegisButton(
                        text: 'Cancelar',
                        type: ButtonType.secondary,
                        onPressed: () => Navigator.pop(dialogContext),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AegisButton(
                        text: habitData == null ? 'Añadir' : 'Guardar',
                        type: ButtonType.primary,
                        onPressed: () =>
                            submitHabit(dialogContext, controller.text),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
              Text(
                "Hábitos",
                style: textTheme.displayMedium,
              ),
              IconButton(
                icon: const Icon(Icons.add),
                color: colorScheme.primary,
                iconSize: 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _showHabitDialog(context, ref),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorScheme.onSurface.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: habitsAsync.when(
            skipLoadingOnReload: true,
            loading: () => Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: colorScheme.primary),
              ),
            ),
            error: (error, stack) => Center(child: Text('Error: $error')),
            data: (habits) {
              if (habits.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'No tienes hábitos activos.\n¡Añade uno para empezar!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.outline),
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
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
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
                                  ? BoxDecoration(
                                      color: colorScheme.primary,
                                      shape: BoxShape.circle,
                                    )
                                  : null,
                              child: Text(
                                dayInitials,
                                textAlign: TextAlign.center,
                                style: textTheme.bodySmall?.copyWith(
                                  color: isToday
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurfaceVariant,
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
                                      onTap: () => _showHabitDialog(
                                          context, ref,
                                          habitData: habitData),
                                      child: Text(
                                        habitData.habit.name,
                                        style: textTheme.bodyLarge?.copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
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
                                              ? colorScheme.primary
                                              : colorScheme.secondary,
                                          border: Border.all(
                                            color: isCompleted
                                                ? colorScheme.primary
                                                : colorScheme.outline
                                                    .withValues(alpha: 0.2),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: isCompleted
                                            ? Icon(Icons.check,
                                                size: 14,
                                                color: colorScheme.onPrimary)
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
