import 'package:aegis/core/utils/color_utils.dart';
import 'package:aegis/presentation/viewmodels/tag_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/presentation/viewmodels/task_list_viewmodel.dart';
import 'package:aegis/presentation/screens/tasks/components/task_form_desktop.dart';

class TaskTableView extends ConsumerWidget {
  const TaskTableView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskListViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.05),
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
                  return Center(
                    child: Text('Sin tareas para este filtro.',
                        style: TextStyle(color: colorScheme.outline)),
                  );
                }
                return ListView.separated(
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: colorScheme.secondary),
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
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        );

    return Container(
      padding: const EdgeInsets.only(left: 4, right: 16, top: 16, bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 48),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Text('Nombre', style: textStyle),
                Icon(Icons.arrow_drop_down,
                    color: colorScheme.onSurfaceVariant, size: 18),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 4,
            child: Text('Etiquetas', style: textStyle),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text('Fecha', style: textStyle),
                Icon(Icons.arrow_drop_down,
                    color: colorScheme.onSurfaceVariant, size: 18),
              ],
            ),
          ),
          const SizedBox(width: 40),
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bool isCompleted = task.completedAt != null;

    Color flagColor = Colors.transparent;
    if (task.priority == 3) {
      flagColor = colorScheme.error;
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
          color: colorScheme.surface,
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
                            activeColor: colorScheme.primary,
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
                            style: textTheme.bodyMedium?.copyWith(
                              color: isCompleted
                                  ? colorScheme.outline
                                  : colorScheme.onSurface,
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
                                    return Text('-',
                                        style: TextStyle(
                                            color: colorScheme.outline));
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
                                          child: TagPill(
                                            label: tag.name.toUpperCase(),
                                            backgroundColor:
                                                tagColor.withValues(alpha: 0.2),
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
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: PopupMenuButton(
                            icon: Icon(Icons.more_vert,
                                color: colorScheme.outline),
                            color: colorScheme.surface,
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
                                    const SnackBar(
                                        content:
                                            Text('Error al eliminar tarea.')),
                                  );
                                  return;
                                }
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 0,
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined,
                                        color: colorScheme.onSurfaceVariant,
                                        size: 20),
                                    const SizedBox(width: 12),
                                    Text('Editar',
                                        style: TextStyle(
                                            color: colorScheme.onSurface)),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 1,
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline,
                                        color: colorScheme.error, size: 20),
                                    const SizedBox(width: 12),
                                    Text('Eliminar',
                                        style: TextStyle(
                                            color: colorScheme.error)),
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

class TagPill extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const TagPill({
    super.key,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Mostrando $taskCount Tareas',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
