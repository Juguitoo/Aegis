import 'dart:async';
import 'package:aegis/core/utils/native_app_monitor.dart';
import 'package:aegis/core/services/notification_service.dart';
import 'package:aegis/presentation/screens/blocker/block_overlay_screen.dart';
import 'package:aegis/presentation/screens/calendar/calendar_screen_mobile.dart';
import 'package:aegis/presentation/screens/diary/diary_screen_mobile.dart';
import 'package:aegis/presentation/screens/statistics/statistics_screen_mobile.dart';
import 'package:aegis/presentation/screens/tasks/task_list_screen_mobile.dart';
import 'package:aegis/presentation/screens/timer/timer_screen_mobile.dart';
import 'package:aegis/presentation/viewmodels/timer_viewmodel.dart';
import 'package:aegis/presentation/viewmodels/calendar_viewmodel.dart';
import 'package:aegis/presentation/widgets/permission_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 2);
final taskToOpenProvider = StateProvider<int?>((ref) => null);

class MainMobileLayout extends ConsumerStatefulWidget {
  final Widget? floatingActionButton;
  final PreferredSizeWidget? appBar;

  const MainMobileLayout({
    super.key,
    this.floatingActionButton,
    this.appBar,
  });

  @override
  ConsumerState<MainMobileLayout> createState() => _MainMobileLayoutState();
}

class _MainMobileLayoutState extends ConsumerState<MainMobileLayout>
    with WidgetsBindingObserver {
  StreamSubscription<String?>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAndPromptPermissions(context, ref);
    });

    _notificationSubscription =
        NotificationService.selectNotificationStream.stream.listen((payload) {
      if (payload != null) {
        _handleNotificationClick(payload);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notificationSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkAndPromptPermissions(context, ref);
    }
  }

  void _handleNotificationClick(String payload) {
    final parts = payload.split('|');
    if (parts.isEmpty) return;

    if (parts[0] == 'event') {
      ref.read(navigationIndexProvider.notifier).state = 0;
      if (parts.length >= 3) {
        final date = DateTime.tryParse(parts[2]);
        if (date != null) {
          ref
              .read(calendarViewModelProvider.notifier)
              .onDaySelected(date, date);
        }
      }
    } else if (parts[0] == 'task') {
      ref.read(navigationIndexProvider.notifier).state = 2;
      if (parts.length >= 2) {
        final taskId = int.tryParse(parts[1]);
        if (taskId != null) {
          ref.read(taskToOpenProvider.notifier).state = taskId;
        }
      }
    } else if (parts[0] == 'timer') {
      ref.read(navigationIndexProvider.notifier).state = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(blockedAppTriggerProvider, (previous, next) async {
      if (next != null) {
        await ref.read(nativeAppMonitorProvider).bringToForeground();
        await Future.delayed(const Duration(milliseconds: 100));
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BlockOverlayScreen()),
          );
        }
        ref.read(blockedAppTriggerProvider.notifier).state = null;
      }
    });

    final currentIndex = ref.watch(navigationIndexProvider);

    final screens = [
      const CalendarScreenMobile(),
      const TimerScreenMobile(),
      const TaskListScreenMobile(),
      const StatisticsScreenMobile(),
      const DiaryScreenMobile(),
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
        ),
      ),
    );
  }
}
