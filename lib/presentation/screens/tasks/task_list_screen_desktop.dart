import 'package:flutter/material.dart';
import 'package:aegis/presentation/screens/main_desktop_layout.dart';

import 'components/task_table_view.dart';
import 'components/desktop_filter_controls.dart';
import 'components/desktop_widgets_sidebar.dart';

class TaskListScreenDesktop extends StatelessWidget {
  const TaskListScreenDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return MainDesktopLayout(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Principal',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
            const Divider(height: 16, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        DesktopFilterControls(),
                        SizedBox(height: 16),
                        Expanded(child: TaskTableView()),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  const Expanded(
                    flex: 3,
                    child: DesktopWidgetsSidebar(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
