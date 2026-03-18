import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/presentation/screens/settings/settings_dialog_desktop.dart';
import 'package:aegis/presentation/viewmodels/settings_viewmodel.dart';

class MainDesktopLayout extends ConsumerWidget {
  final Widget child;

  const MainDesktopLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          _SideNavigationRail(ref: ref),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}

class _SideNavigationRail extends StatelessWidget {
  final WidgetRef ref;

  const _SideNavigationRail({required this.ref});

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
          const _NavIcon(icon: Icons.calendar_today, isSelected: false),
          const _NavIcon(icon: Icons.check_box, isSelected: true),
          const _NavIcon(icon: Icons.timer_outlined, isSelected: false),
          const _NavIcon(icon: Icons.bar_chart, isSelected: false),
          const _NavIcon(icon: Icons.menu_book, isSelected: false),
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

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const _NavIcon({
    required this.icon,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEEF2FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color:
                isSelected ? const Color(0xFF6366F1) : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}
