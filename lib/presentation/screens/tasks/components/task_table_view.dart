import 'package:aegis/core/utils/color_utils.dart';
import 'package:aegis/presentation/viewmodels/tag_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/presentation/viewmodels/task_list_viewmodel.dart';
import 'package:aegis/presentation/screens/tasks/widgets/task_form_desktop.dart';

class TaskTableView extends ConsumerWidget {
  const TaskTableView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskListViewModelProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const _TaskTableHeader(),
          Expanded(
            child: tasksAsync.when(
              data: (tasks) {
                if (tasks.isEmpty) {
                  return const Center(
                    child: Text('Sin tareas para este filtro.',
                        style: TextStyle(color: Color(0xFF94A3B8))),
                  );
                }
                return ListView.separated(
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  itemBuilder: (context, index) {
                    return TaskRow(task: tasks[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
          _TableFooter(
            taskCount: tasksAsync.maybeWhen(
              data: (tasks) => tasks.length,
              orElse: () => 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskTableHeader extends StatelessWidget {
  const _TaskTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 4, right: 16, top: 16, bottom: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFEEF2FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: const Row(
        children: [
          SizedBox(width: 48),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Text('Nombre',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                Icon(Icons.arrow_drop_down, color: Color(0xFF64748B), size: 18),
              ],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 4,
            child: Text('Etiquetas',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text('Fecha',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                Icon(Icons.arrow_drop_down, color: Color(0xFF64748B), size: 18),
              ],
            ),
          ),
          SizedBox(width: 40),
        ],
      ),
    );
  }
}

class TaskRow extends ConsumerWidget {
  final Task task;

  const TaskRow({super.key, required this.task});

  String _formatDate(DateTime? date) {
    if (date == null) return 'Sin fecha';
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return '${date.day.toString().padLeft(2, '0')}, ${months[date.month - 1]}, ${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isCompleted = task.isCompleted;

    Color flagColor = Colors.transparent;
    if (task.priority == 3) {
      flagColor = const Color(0xFFEF4444);
    } else if (task.priority == 2) {
      flagColor = const Color(0xFFEAB308);
    } else if (task.priority == 1) {
      flagColor = const Color(0xFF22C55E);
    }

    final tagIdsAsync = ref.watch(taskTagsProvider(task.id));
    final allTagsAsync = ref.watch(tagListViewModelProvider);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => TaskFormDesktop(task: task),
          );
        },
        child: Container(
          color: Colors.white,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  color: flagColor,
                ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(right: 16, top: 12, bottom: 12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 48,
                          child: Checkbox(
                            value: isCompleted,
                            onChanged: (val) async {
                              try {
                                ref
                                    .read(taskListViewModelProvider.notifier)
                                    .toggleTaskCompletion(task);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Error al actualizar tarea: $e')),
                                );
                              }
                            },
                            activeColor: const Color(0xFF6366F1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            task.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isCompleted
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF334155),
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 4,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: tagIdsAsync.when(
                              data: (tagIds) => allTagsAsync.when(
                                data: (allTags) {
                                  final taskTags = allTags
                                      .where((t) => tagIds.contains(t.id))
                                      .toList();
                                  if (taskTags.isEmpty) {
                                    return const Text('-',
                                        style: TextStyle(
                                            color: Color(0xFF94A3B8)));
                                  }
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: taskTags.map((tag) {
                                        final tagColor =
                                            ColorUtils.parseColor(tag.colorHex);
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: _TagPill(
                                            label: tag.name,
                                            backgroundColor:
                                                tagColor.withAlpha(20),
                                            textColor: tagColor,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  );
                                },
                                loading: () => const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2)),
                                error: (_, __) => const SizedBox(),
                              ),
                              loading: () => const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)),
                              error: (_, __) => const SizedBox(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: Text(
                            _formatDate(task.dueDate),
                            style: const TextStyle(
                                color: Color(0xFF64748B), fontSize: 13),
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: PopupMenuButton(
                            icon: const Icon(Icons.more_vert,
                                color: Color(0xFF94A3B8)),
                            color: Colors.white,
                            surfaceTintColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            onSelected: (value) {
                              if (value == 0) {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      TaskFormDesktop(task: task),
                                );
                              } else if (value == 1) {
                                try {
                                  ref
                                      .read(taskListViewModelProvider.notifier)
                                      .deleteTask(task);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Error al eliminar tarea.')),
                                  );
                                  return;
                                }
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 0,
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined,
                                        color: Color(0xFF64748B), size: 20),
                                    SizedBox(width: 12),
                                    Text('Editar',
                                        style: TextStyle(
                                            color: Color(0xFF1E293B))),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 1,
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline,
                                        color: Color(0xFFEF4444), size: 20),
                                    SizedBox(width: 12),
                                    Text('Eliminar',
                                        style: TextStyle(
                                            color: Color(0xFFEF4444))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _TagPill({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _TableFooter extends StatelessWidget {
  final int taskCount;

  const _TableFooter({required this.taskCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFEEF2FF),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Mostrando $taskCount Tareas',
            style: const TextStyle(
                color: Color(0xFF64748B), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
