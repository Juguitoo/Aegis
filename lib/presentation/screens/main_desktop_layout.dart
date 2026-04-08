import 'package:aegis/presentation/screens/diary/diary_screen_desktop.dart';
import 'package:aegis/presentation/screens/tasks/task_list_screen_desktop.dart';
import 'package:aegis/presentation/screens/timer/timer_screen_desktop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/presentation/screens/settings/settings_dialog_desktop.dart';
import 'package:aegis/presentation/viewmodels/settings_viewmodel.dart';
import 'package:aegis/presentation/screens/main_mobile_layout.dart';

class MainDesktopLayout extends ConsumerWidget {
  const MainDesktopLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);

    final screens = [
      const Center(child: Text('Pantalla Calendario (Escritorio)')),
      const TimerScreenDesktop(),
      const TaskListScreenDesktop(),
      const Center(child: Text('Pantalla Estadísticas (Escritorio)')),
      const DiaryScreenDesktop(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          _SideNavigationRail(ref: ref, currentIndex: currentIndex),
          Expanded(
            child: screens[currentIndex],
          ),
        ],
      ),
    );
  }
}

class _SideNavigationRail extends StatelessWidget {
  final WidgetRef ref;
  final int currentIndex;

  const _SideNavigationRail({
    required this.ref,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsViewModelProvider);

    return Container(
      width: 80,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.flash_on, color: Colors.white),
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
            icon: Icons.check_box,
            isSelected: currentIndex == 2,
            onTap: () => ref.read(navigationIndexProvider.notifier).state = 2,
          ),
          _NavIcon(
            icon: Icons.bar_chart,
            isSelected: currentIndex == 3,
            onTap: () => ref.read(navigationIndexProvider.notifier).state = 3,
          ),
          _NavIcon(
            icon: Icons.menu_book,
            isSelected: currentIndex == 4,
            onTap: () => ref.read(navigationIndexProvider.notifier).state = 4,
          ),
          const Spacer(),
          const _NavIcon(icon: Icons.dark_mode_outlined, isSelected: false),
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
            duration: const Duration(milliseconds: 150),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? const Color(0xFFEEF2FF)
                  : _isHovered
                      ? const Color(0xFFF1F5F9)
                      : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.icon,
              color: widget.isSelected
                  ? const Color(0xFF6366F1)
                  : _isHovered
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
            ),
          ),
        ),
      ),
    );
  }
}
