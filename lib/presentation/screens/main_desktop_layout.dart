import 'package:flutter/material.dart';

class MainDesktopLayout extends StatelessWidget {
  final Widget child;

  const MainDesktopLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          const _SideNavigationRail(),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}

class _SideNavigationRail extends StatelessWidget {
  const _SideNavigationRail();

  @override
  Widget build(BuildContext context) {
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
          const _NavIcon(icon: Icons.settings_outlined, isSelected: false),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;

  const _NavIcon({required this.icon, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEEF2FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF94A3B8),
      ),
    );
  }
}
