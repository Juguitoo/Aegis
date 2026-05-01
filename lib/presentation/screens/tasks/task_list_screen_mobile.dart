import 'package:aegis/presentation/screens/main_mobile_layout.dart';
import 'package:aegis/presentation/screens/projects/widgets/manage_projects_bottom_sheet.dart';
import 'package:aegis/presentation/screens/settings/settings_screen_mobile.dart';
import 'package:aegis/presentation/screens/tags/widgets/manage_tags_bottom_sheet.dart';
import 'package:aegis/presentation/screens/projects/widgets/project_form_dialog.dart';
import 'package:aegis/presentation/screens/tags/widgets/tag_form_dialog.dart';
import 'package:aegis/presentation/screens/tasks/components/mobile_habits_section.dart';
import 'package:aegis/presentation/screens/tasks/widgets/manage_habits_bottom_sheet.dart';
import 'package:aegis/presentation/screens/tasks/widgets/task_form_mobile.dart';
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => TaskFormMobile(task: task),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskListViewModelProvider);

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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Principal',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        backgroundColor: const Color(0xFFF8FAFC),
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: PopupMenuButton<int>(
              icon: const Icon(Icons.more_vert, color: Color(0xFF1E293B)),
              color: Colors.white,
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
                const PopupMenuItem(
                  value: 1,
                  height: 48,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.folder_outlined,
                          color: Color(0xFF64748B), size: 20),
                      SizedBox(width: 24),
                      Text('Gestionar proyectos',
                          style: TextStyle(color: Color(0xFF1E293B))),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 2,
                  height: 48,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.label_outlined,
                          color: Color(0xFF64748B), size: 20),
                      SizedBox(width: 24),
                      Text('Gestionar etiquetas',
                          style: TextStyle(color: Color(0xFF1E293B))),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 3,
                  height: 48,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_graph_outlined,
                          color: Color(0xFF64748B), size: 20),
                      SizedBox(width: 24),
                      Text('Gestionar hábitos',
                          style: TextStyle(color: Color(0xFF1E293B))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.settings, color: Color(0xFF1E293B)),
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
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        activeBackgroundColor: const Color(0xFF4F46E5),
        activeForegroundColor: Colors.white,
        overlayColor: Colors.black,
        overlayOpacity: 0.4,
        spacing: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.check_circle_outline,
                color: Color(0xFF6366F1)),
            backgroundColor: Colors.white,
            shape: const CircleBorder(),
            onTap: () => _openTaskForm(),
          ),
          SpeedDialChild(
            child: const Icon(Icons.folder_outlined, color: Color(0xFF0284C7)),
            backgroundColor: Colors.white,
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
            backgroundColor: Colors.white,
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
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const MobileHabitsSection(),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          Container(
            alignment: Alignment.centerLeft,
            margin:
                const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
            child: const Text(
              "Tareas",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B)),
              textAlign: TextAlign.left,
            ),
          ),
          const MobileFilterControls(),
          Expanded(
            child: tasksAsync.when(
              data: (tasks) {
                if (tasks.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay tareas para este filtro.',
                      style: TextStyle(color: Color(0xFF94A3B8)),
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
