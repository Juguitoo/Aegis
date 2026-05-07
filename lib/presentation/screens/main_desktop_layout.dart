import 'package:aegis/core/providers/general_providers.dart';
import 'package:aegis/presentation/screens/calendar/calendar_screen_desktop.dart';
import 'package:aegis/presentation/screens/diary/diary_screen_desktop.dart';
import 'package:aegis/presentation/screens/statistics/statistics_screen_desktop.dart';
import 'package:aegis/presentation/screens/tasks/task_list_screen_desktop.dart';
import 'package:aegis/presentation/screens/timer/timer_screen_desktop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/presentation/screens/settings/settings_dialog_desktop.dart';
import 'package:aegis/presentation/viewmodels/settings_viewmodel.dart';

class MainDesktopLayout extends ConsumerWidget {
  const MainDesktopLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final screens = [
      const CalendarScreenDesktop(),
      const TimerScreenDesktop(),
      const TaskListScreenDesktop(),
      const StatisticsScreenDesktop(),
      const DiaryScreenDesktop(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          _SideNavigationRail(currentIndex: currentIndex),
          VerticalDivider(
              width: 1,
              thickness: 1,
              color: colorScheme.outline.withValues(alpha: 0.15)),
          Expanded(
            child: screens[currentIndex],
          ),
        ],
      ),
    );
  }
}

class _SideNavigationRail extends ConsumerWidget {
  final int currentIndex;

  const _SideNavigationRail({
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Container(
      width: 88,
      color: colorScheme.surface,
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              'assets/icon/app_icon.png',
              width: 44,
              height: 44,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      Icon(Icons.shield_outlined, color: colorScheme.primary),
                );
              },
            ),
          ),
          const SizedBox(height: 48),
          _NavIcon(
            icon: Icons.calendar_today,
            isSelected: currentIndex == 0,
            onTap: () => ref.read(navigationIndexProvider.notifier).state = 0,
          ),
          _NavIcon(
            icon: Icons.timer_outlined,
            isSelected: currentIndex == 1,
            onTap: () => ref.read(navigationIndexProvider.notifier).state = 1,
          ),
          _NavIcon(
            icon: Icons.check_box_outlined,
            isSelected: currentIndex == 2,
            onTap: () => ref.read(navigationIndexProvider.notifier).state = 2,
          ),
          _NavIcon(
            icon: Icons.bar_chart_rounded,
            isSelected: currentIndex == 3,
            onTap: () => ref.read(navigationIndexProvider.notifier).state = 3,
          ),
          _NavIcon(
            icon: Icons.menu_book_rounded,
            isSelected: currentIndex == 4,
            onTap: () => ref.read(navigationIndexProvider.notifier).state = 4,
          ),
          const Spacer(),
          _NavIcon(
              icon:
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              isSelected: false,
              onTap: () {
                ref.read(themeModeProvider.notifier).state =
                    isDark ? ThemeMode.light : ThemeMode.dark;
              }),
          _NavIcon(
            icon: Icons.settings_outlined,
            isSelected: false,
            onTap: () {
              final currentSettings = settingsAsync.value;
              showDialog(
                context: context,
                builder: (context) =>
                    SettingsDialogDesktop(currentSettings: currentSettings),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _NavIcon extends StatefulWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const _NavIcon({
    required this.icon,
    required this.isSelected,
    this.onTap,
  });

  @override
  State<_NavIcon> createState() => _NavIconState();
}

class _NavIconState extends State<_NavIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: widget.onTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? colorScheme.primary.withValues(alpha: 0.15)
                  : _isHovered
                      ? colorScheme.secondary.withValues(alpha: 0.5)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              widget.icon,
              size: 26,
              color: widget.isSelected
                  ? colorScheme.primary
                  : _isHovered
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
