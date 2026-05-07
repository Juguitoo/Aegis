import 'package:flutter/material.dart';

import 'components/task_table_view.dart';
import 'components/desktop_filter_controls.dart';
import 'components/desktop_widgets_sidebar.dart';

class TaskListScreenDesktop extends StatelessWidget {
  const TaskListScreenDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 48,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Principal', style: textTheme.displayLarge),
                ],
              ),
            ),
            Divider(
                height: 16, color: colorScheme.outline.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DesktopFilterControls(),
                        SizedBox(height: 16),
                        Expanded(child: TaskTableView()),
                      ],
                    ),
                  ),
                  SizedBox(width: 32),
                  Expanded(
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
