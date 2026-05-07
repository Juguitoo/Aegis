import 'package:aegis/core/providers/general_providers.dart';
import 'package:aegis/presentation/screens/projects/components/manage_projects_bottom_sheet.dart';
import 'package:aegis/presentation/screens/settings/settings_screen_mobile.dart';
import 'package:aegis/presentation/screens/tags/components/manage_tags_bottom_sheet.dart';
import 'package:aegis/presentation/screens/projects/components/project_form_dialog.dart';
import 'package:aegis/presentation/screens/tags/components/tag_form_dialog.dart';
import 'package:aegis/presentation/screens/tasks/components/mobile_habits_section.dart';
import 'package:aegis/presentation/screens/tasks/components/manage_habits_bottom_sheet.dart';
import 'package:aegis/presentation/screens/tasks/components/task_form_mobile.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../../../data/local/database/app_database.dart';
import '../../viewmodels/task_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'components/task_card.dart';
import 'components/mobile_filter_controls.dart';

class TaskListScreenMobile extends ConsumerStatefulWidget {
  const TaskListScreenMobile({super.key});

  @override
  ConsumerState<TaskListScreenMobile> createState() =>
      _TaskListScreenMobileState();
}

class _TaskListScreenMobileState extends ConsumerState<TaskListScreenMobile> {
  final ScrollController _mainScrollController = ScrollController();

  @override
  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }

  void _openTaskForm([Task? task]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskFormMobile(task: task),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskListViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    ref.listen(taskToOpenProvider, (previous, next) {
      if (next != null) {
        final taskList = ref.read(taskListViewModelProvider).value;
        if (taskList != null) {
          final taskToOpen = taskList.where((t) => t.id == next).firstOrNull;
          if (taskToOpen != null) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => TaskFormMobile(task: taskToOpen),
            );
          }
        }
        ref.read(taskToOpenProvider.notifier).state = null;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pendingTaskId = ref.read(taskToOpenProvider);
      if (pendingTaskId != null) {
        final taskList = ref.read(taskListViewModelProvider).value;
        if (taskList != null) {
          final taskToOpen =
              taskList.where((t) => t.id == pendingTaskId).firstOrNull;
          if (taskToOpen != null) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => TaskFormMobile(task: taskToOpen),
            );
          }
        }
        ref.read(taskToOpenProvider.notifier).state = null;
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Principal',
            style: textTheme.displayLarge,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: PopupMenuButton<int>(
              icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
              color: colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              position: PopupMenuPosition.under,
              elevation: 4,
              onSelected: (value) {
                if (value == 1) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const ManageProjectsBottomSheet(),
                  );
                } else if (value == 2) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const ManageTagsBottomSheet(),
                  );
                } else if (value == 3) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const ManageHabitsBottomSheet(),
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 1,
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.folder_outlined,
                          color: colorScheme.onSurfaceVariant, size: 20),
                      const SizedBox(width: 24),
                      Text('Gestionar proyectos',
                          style: textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurface)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 2,
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.label_outlined,
                          color: colorScheme.onSurfaceVariant, size: 20),
                      const SizedBox(width: 24),
                      Text('Gestionar etiquetas',
                          style: textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurface)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 3,
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_graph_outlined,
                          color: colorScheme.onSurfaceVariant, size: 20),
                      const SizedBox(width: 24),
                      Text('Gestionar hábitos',
                          style: textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurface)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(Icons.settings, color: colorScheme.onSurface),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreenMobile()),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        activeBackgroundColor: colorScheme.primary,
        activeForegroundColor: colorScheme.onPrimary,
        overlayColor: Colors.black,
        overlayOpacity: 0.4,
        spacing: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        children: [
          SpeedDialChild(
            child: Icon(Icons.check_circle_outline, color: colorScheme.primary),
            backgroundColor: colorScheme.surface,
            shape: const CircleBorder(),
            onTap: () => _openTaskForm(),
          ),
          SpeedDialChild(
            child: const Icon(Icons.folder_outlined, color: Color(0xFF0284C7)),
            backgroundColor: colorScheme.surface,
            shape: const CircleBorder(),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const ProjectFormDialog(),
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.label_outline, color: Color(0xFFDB2777)),
            backgroundColor: colorScheme.surface,
            shape: const CircleBorder(),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => const TagFormDialog(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Divider(color: colorScheme.outline.withValues(alpha: 0.2), height: 1),
          const MobileHabitsSection(),
          const SizedBox(height: 8),
          Divider(color: colorScheme.outline.withValues(alpha: 0.2), height: 1),
          Container(
            alignment: Alignment.centerLeft,
            margin:
                const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
            child: Text(
              "Tareas",
              style: textTheme.displayMedium,
              textAlign: TextAlign.left,
            ),
          ),
          const MobileFilterControls(),
          Expanded(
            child: tasksAsync.when(
              data: (tasks) {
                if (tasks.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay tareas para este filtro.',
                      style: TextStyle(color: colorScheme.outline),
                    ),
                  );
                }
                return Scrollbar(
                  controller: _mainScrollController,
                  thumbVisibility: true,
                  child: ListView.builder(
                    controller: _mainScrollController,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskCard(
                        task: task,
                        onToggle: () async {
                          try {
                            ref
                                .read(taskListViewModelProvider.notifier)
                                .toggleTaskCompletion(task);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Error al actualizar tarea.')),
                            );
                          }
                        },
                        onTap: () => _openTaskForm(task),
                        onDelete: () async {
                          try {
                            ref
                                .read(taskListViewModelProvider.notifier)
                                .deleteTask(task);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Error al eliminar tarea.')),
                            );
                          }
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
