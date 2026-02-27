import 'package:flutter/material.dart';
import '../../../core/presentation/widgets/responsive_layout.dart';
import 'task_list_screen_mobile.dart';
import 'task_list_screen_desktop.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileView: TaskListScreenMobile(),
      desktopView: TaskListScreenDesktop(),
    );
  }
}
