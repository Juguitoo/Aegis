import 'package:aegis/presentation/screens/timer/immersive_timer_screen_desktop.dart';
import 'package:aegis/presentation/viewmodels/habits_viewmodel.dart';
import 'package:aegis/presentation/widgets/aegis_buttons.dart';
import 'package:aegis/presentation/widgets/aegis_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DesktopWidgetsSidebar extends StatelessWidget {
  const DesktopWidgetsSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _DesktopHabitsWidget(),
        ),
        SizedBox(height: 24),
        Expanded(
          child: _PomodoroPromoCard(),
        ),
      ],
    );
  }
}

class _DesktopHabitsWidget extends ConsumerWidget {
  const _DesktopHabitsWidget();

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

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Hábitos",
                style: textTheme.displayLarge?.copyWith(fontSize: 24),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: colorScheme.primary,
                iconSize: 28,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Nuevo hábito',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) {
                      final controller = TextEditingController();

                      void submitHabit(String value) {
                        if (value.trim().isEmpty) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(
                              content: const Text(
                                  'El nombre del hábito no puede estar vacío'),
                              backgroundColor: colorScheme.error,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          );
                          return;
                        }
                        ref
                            .read(habitsViewModelProvider.notifier)
                            .addHabit(value.trim());
                        Navigator.pop(dialogContext);
                      }

                      return AlertDialog(
                        backgroundColor: colorScheme.surface,
                        surfaceTintColor: Colors.transparent,
                        title: Text('Nuevo hábito',
                            style: textTheme.displayMedium
                                ?.copyWith(fontSize: 18)),
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
                                  onPressed: () => Navigator.pop(dialogContext),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: AegisButton(
                                  text: 'Añadir',
                                  type: ButtonType.primary,
                                  onPressed: () => submitHabit(controller.text),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: colorScheme.secondary, height: 1),
          const SizedBox(height: 8),
          Expanded(
            child: habitsAsync.when(
              skipLoadingOnReload: true,
              loading: () => Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              ),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
              data: (habits) {
                if (habits.isEmpty) {
                  return Center(
                    child: Text(
                      'No tienes hábitos creados.',
                      style: TextStyle(color: colorScheme.outline),
                    ),
                  );
                }

                int possibleCompletions = habits.length * currentDayOfWeek;
                int actualCompletions = 0;
                for (var h in habits) {
                  actualCompletions += h.entries
                      .where((e) =>
                          !e.date.isBefore(monday) && !e.date.isAfter(today))
                      .length;
                }
                double progress = possibleCompletions == 0
                    ? 0.0
                    : actualCompletions / possibleCompletions;
                if (progress > 1.0) progress = 1.0;
                final progressPercentage = (progress * 100).toInt();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(flex: 3, child: SizedBox()),
                        Expanded(
                          flex: 6,
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
                              return Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      alignment: Alignment.center,
                                      decoration: isToday
                                          ? BoxDecoration(
                                              color: colorScheme.primary,
                                              shape: BoxShape.circle,
                                            )
                                          : null,
                                      child: Text(
                                        dayInitials,
                                        style: textTheme.bodySmall?.copyWith(
                                          color: isToday
                                              ? colorScheme.onPrimary
                                              : colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: habits.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final habitData = habits[index];

                          return Row(
                            key: ValueKey(habitData.habit.id),
                            children: [
                              Expanded(
                                flex: 3,
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
                              Expanded(
                                flex: 6,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: currentWeekDays.map((date) {
                                    final isCompleted = habitData.entries
                                        .any((e) => e.date == date);
                                    final isFuture = date.isAfter(today);

                                    return Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 2.0),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: MouseRegion(
                                            cursor: isFuture
                                                ? SystemMouseCursors.basic
                                                : SystemMouseCursors.click,
                                            child: GestureDetector(
                                              onTap: isFuture
                                                  ? null
                                                  : () {
                                                      ref
                                                          .read(
                                                              habitsViewModelProvider
                                                                  .notifier)
                                                          .toggleHabitEntry(
                                                              habitData
                                                                  .habit.id,
                                                              date);
                                                    },
                                              child: Opacity(
                                                opacity: isFuture ? 0.3 : 1.0,
                                                child: Container(
                                                  width: 24,
                                                  height: 24,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    color: isCompleted
                                                        ? colorScheme.primary
                                                        : Colors.transparent,
                                                    border: Border.all(
                                                      color: isCompleted
                                                          ? colorScheme.primary
                                                          : colorScheme.outline
                                                              .withValues(
                                                                  alpha: 0.3),
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: isCompleted
                                                      ? Icon(Icons.check,
                                                          size: 16,
                                                          color: colorScheme
                                                              .onPrimary)
                                                      : null,
                                                ),
                                              ),
                                            ),
                                          ),
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
                    const SizedBox(height: 8),
                    Divider(color: colorScheme.secondary, height: 1),
                    const SizedBox(height: 8),
                    Text(
                      "Progreso",
                      style: textTheme.bodyLarge?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: colorScheme.secondary,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Has completado el $progressPercentage% de tus hábitos hasta hoy",
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PomodoroPromoCard extends StatelessWidget {
  const _PomodoroPromoCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ImmersiveTimerScreenDesktop(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, const Color(0xFF4F46E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Mantente Enfocado',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Recuerda tomar descansos largos\ndespués de cada hora de trabajo.',
                    style: TextStyle(
                      color: colorScheme.onPrimary.withValues(alpha: 0.7),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Iniciar Pomodoro',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
