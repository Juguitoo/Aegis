import 'package:aegis/presentation/screens/tasks/task_list_screen_mobile.dart';
import 'package:aegis/presentation/screens/timer/timer_screen_mobile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 2);

class MainMobileLayout extends ConsumerWidget {
  final Widget? floatingActionButton;
  final PreferredSizeWidget? appBar;

  const MainMobileLayout({
    super.key,
    this.floatingActionButton,
    this.appBar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);

    final screens = [
      const Center(child: Text('Pantalla Calendario')),
      const TimerScreenMobile(),
      const TaskListScreenMobile(),
      const Center(child: Text('Pantalla Estadísticas')),
      const Center(child: Text('Pantalla Diario')),
    ];

    return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(child: screens[currentIndex]),
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
              onTap: (index) {
                ref.read(navigationIndexProvider.notifier).state = index;
              },
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
