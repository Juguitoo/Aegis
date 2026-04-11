import 'package:aegis/presentation/screens/timer/immersive_timer_screen_desktop.dart';
import 'package:aegis/presentation/viewmodels/habits_viewmodel.dart';
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

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentDayOfWeek = today.weekday;
    final monday = today.subtract(Duration(days: currentDayOfWeek - 1));
    final currentWeekDays =
        List.generate(7, (index) => monday.add(Duration(days: index)));

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
              const Text(
                "Hábitos",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: const Color(0xFF6366F1),
                iconSize: 28,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Nuevo hábito',
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
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 8),
          Expanded(
            child: habitsAsync.when(
              skipLoadingOnReload: true,
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF6366F1)),
              ),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
              data: (habits) {
                if (habits.isEmpty) {
                  return const Center(
                    child: Text(
                      'No tienes hábitos creados.',
                      style: TextStyle(color: Color(0xFF94A3B8)),
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
                          flex: 5,
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
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: isToday
                                    ? const BoxDecoration(
                                        color: Color(0xFF6366F1),
                                        shape: BoxShape.circle,
                                      )
                                    : null,
                                child: Text(
                                  dayInitials,
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
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF334155),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: currentWeekDays.map((date) {
                                    final isCompleted = habitData.entries
                                        .any((e) => e.date == date);
                                    final isFuture = date.isAfter(today);

                                    return MouseRegion(
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
                                                        habitData.habit.id,
                                                        date);
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
                                                  : Colors.transparent,
                                              border: Border.all(
                                                color: isCompleted
                                                    ? const Color(0xFF6366F1)
                                                    : const Color(0xFF94A3B8),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: isCompleted
                                                ? const Icon(Icons.check,
                                                    size: 16,
                                                    color: Colors.white)
                                                : null,
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
                    const Divider(color: Color(0xFFF1F5F9), height: 1),
                    const SizedBox(height: 8),
                    const Text(
                      "Progreso",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFEEF2FF),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF6366F1)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Has completado el $progressPercentage% de tus hábitos hasta hoy",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
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
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.3),
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
                  const Text(
                    'Mantente Enfocado',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Recuerda tomar descansos largos\ndespués de cada hora de trabajo.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Iniciar Pomodoro',
                      style: TextStyle(
                        color: Color(0xFF4F46E5),
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
