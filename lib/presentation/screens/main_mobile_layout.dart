import 'package:flutter/material.dart';

class MainMobileLayout extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? appBar;

  const MainMobileLayout(
      {super.key,
      required this.child,
      this.currentIndex = 1,
      this.floatingActionButton,
      this.appBar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: appBar,
        body: SafeArea(child: child),
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) {},
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF6366F1),
              unselectedItemColor: const Color(0xFF94A3B8),
              showSelectedLabels: true,
              showUnselectedLabels: false,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today),
                  label: 'Calendario',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.timer_outlined),
                  label: 'Temporizador',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.check_box),
                  label: 'Tareas',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart),
                  label: 'Estadísticas',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu_book),
                  label: 'Diario',
                ),
              ],
            )));
  }
}
