import 'package:aegis/core/theme/app_theme.dart';
import 'package:aegis/presentation/screens/tasks/components/task_table_view.dart';
import 'package:aegis/presentation/viewmodels/task_list_viewmodel.dart';
import 'package:aegis/presentation/viewmodels/timer_state.dart';
import 'package:aegis/presentation/viewmodels/timer_viewmodel.dart';
import 'package:aegis/core/providers/repository_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/core/utils/color_utils.dart';
import 'package:aegis/presentation/viewmodels/tag_list_viewmodel.dart';
import 'package:aegis/presentation/viewmodels/project_list_viewmodel.dart';

class TasksPanelDesktop extends ConsumerStatefulWidget {
  const TasksPanelDesktop({super.key});

  @override
  ConsumerState<TasksPanelDesktop> createState() => _TasksPanelDesktopState();
}

class _TasksPanelDesktopState extends ConsumerState<TasksPanelDesktop> {
  bool _isExpanded = false;

  Stream<List<Subtask>>? _subtasksStream;
  int? _currentTaskId;

  Color _getPriorityColor(int priority, ColorScheme scheme) {
    switch (priority) {
      case 1:
        return const Color(0xFF22C55E);
      case 2:
        return const Color(0xFFEAB308);
      case 3:
        return scheme.error;
      default:
        return scheme.outline.withValues(alpha: 0.3);
    }
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'Baja';
      case 2:
        return 'Media';
      case 3:
        return 'Alta';
      default:
        return 'Ninguna';
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerViewModelProvider);
    final assignedTask = timerState.assignedTask;
    final tasksAsyncValue = ref.watch(taskListViewModelProvider);

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 350,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tarea en curso',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (assignedTask != null)
            _buildCurrentTaskCard(assignedTask, ref)
          else
            _buildEmptyTaskPlaceholder(),
          const SizedBox(height: 24),
          Text(
            'Otras tareas',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: tasksAsyncValue.when(
              data: (tasks) {
                final otherTasks = tasks
                    .where((t) =>
                        t.id != assignedTask?.id && t.completedAt == null)
                    .toList();

                if (otherTasks.isEmpty) {
                  return Center(
                      child: Text(
                    'No hay tareas pendientes.',
                    style: textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.outline),
                  ));
                }

                return ListView.separated(
                  itemCount: otherTasks.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return _buildTaskListItem(otherTasks[index]);
                  },
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

  Widget _buildEmptyTaskPlaceholder() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_add, color: colorScheme.primary, size: 32),
            const SizedBox(height: 4),
            Text(
              'Reloj libre',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Selecciona una tarea de la lista',
              style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w100,
                  fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTaskCard(Task task, WidgetRef ref) {
    if (_currentTaskId != task.id) {
      _currentTaskId = task.id;
      _subtasksStream =
          ref.read(taskRepositoryProvider).watchSubtasksForTask(task.id);
      _isExpanded = false;
    }

    final timerState = ref.watch(timerViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    int liveSeconds = 0;
    if (timerState.mode == TimerMode.focus) {
      liveSeconds = timerState.initialSeconds - timerState.remainingSeconds;
      if (liveSeconds < 0) liveSeconds = 0;
    }

    final int currentTotalSeconds = (task.actualDuration ?? 0) + liveSeconds;

    final String timeString =
        '${_formatDuration(currentTotalSeconds)} / ${_formatDuration(task.estimatedDuration ?? 0)}';

    final tagIdsAsync = ref.watch(taskTagsProvider(task.id));
    final allTagsAsync = ref.watch(tagListViewModelProvider);
    final projectsAsync = ref.watch(projectListViewModelProvider);

    String? projectName;
    if (task.projectId != null) {
      final projectList = projectsAsync.value;
      if (projectList != null) {
        final project =
            projectList.where((p) => p.id == task.projectId).firstOrNull;
        if (project != null) projectName = project.name;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, top: 16.0, bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                tagIdsAsync.when(
                  data: (tagIds) => allTagsAsync.when(
                    data: (allTags) {
                      final taskTags =
                          allTags.where((t) => tagIds.contains(t.id)).toList();
                      if (taskTags.isEmpty) return const SizedBox.shrink();

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: taskTags.map((tag) {
                            final tagColor =
                                ColorUtils.parseColor(tag.colorHex);
                            return Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: TagPill(
                                label: tag.name.toUpperCase(),
                                backgroundColor: tagColor.withAlpha(20),
                                textColor: tagColor,
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: !_isExpanded
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.secondary,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color:
                                    colorScheme.outline.withValues(alpha: 0.1)),
                          ),
                          child: Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.calendar_today_outlined,
                                      size: 14,
                                      color: colorScheme.onSurfaceVariant),
                                  const SizedBox(width: 6),
                                  Text(
                                    _formatDate(task.dueDate),
                                    style: textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.flag_outlined,
                                      size: 14,
                                      color: colorScheme.onSurfaceVariant),
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(right: 6),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _getPriorityColor(
                                          task.priority, colorScheme),
                                    ),
                                  ),
                                  Text(
                                    _getPriorityText(task.priority),
                                    style: textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface),
                                  ),
                                ],
                              ),
                              if (projectName != null)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.folder_outlined,
                                        size: 14,
                                        color: colorScheme.onSurfaceVariant),
                                    const SizedBox(width: 6),
                                    Text(
                                      projectName,
                                      style: textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurface),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Descripción',
                          style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.description?.isNotEmpty == true
                              ? task.description!
                              : 'Sin descripción',
                          style: textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Subtareas',
                          style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        StreamBuilder<List<Subtask>>(
                          stream: _subtasksStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox(
                                  height: 40,
                                  child: Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2)));
                            }

                            final subtasks = snapshot.data ?? [];

                            if (subtasks.isEmpty) {
                              return Text(
                                'No hay elementos en la lista.',
                                style: textTheme.bodyMedium
                                    ?.copyWith(color: colorScheme.outline),
                              );
                            }

                            final completedCount =
                                subtasks.where((st) => st.isCompleted).length;
                            final progress = subtasks.isEmpty
                                ? 0.0
                                : completedCount / subtasks.length;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          backgroundColor:
                                              colorScheme.secondary,
                                          color: progress == 1.0
                                              ? const Color(0xFF10B981)
                                              : colorScheme.primary,
                                          minHeight: 6,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '$completedCount/${subtasks.length}',
                                      style: textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: progress == 1.0
                                            ? const Color(0xFF10B981)
                                            : colorScheme.outline,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ...subtasks.map((subtask) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 6.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            subtask.isCompleted
                                                ? Icons.check_circle
                                                : Icons.circle_outlined,
                                            size: 18,
                                            color: subtask.isCompleted
                                                ? colorScheme.outline
                                                : colorScheme.onSurface,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              subtask.title,
                                              style: textTheme.bodyMedium
                                                  ?.copyWith(
                                                color: subtask.isCompleted
                                                    ? colorScheme.outline
                                                    : colorScheme.onSurface,
                                                decoration: subtask.isCompleted
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
                            );
                          },
                        ),
                        if (task.notes?.isNotEmpty == true) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Notas',
                            style: textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  colorScheme.secondary.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              task.notes!,
                              style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
          ),
          Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.timer_outlined,
                          size: 16, color: colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        timeString,
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Tooltip(
                      message: 'Desasignar tarea',
                      child: IconButton(
                        icon: Icon(Icons.close_rounded,
                            color: colorScheme.onSurfaceVariant, size: 22),
                        onPressed: () {
                          ref
                              .read(timerViewModelProvider.notifier)
                              .clearAssignedTask();
                        },
                      ),
                    ),
                    Tooltip(
                      message:
                          _isExpanded ? 'Ocultar detalles' : 'Ver detalles',
                      child: IconButton(
                        icon: Icon(
                            _isExpanded
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            color: colorScheme.primary,
                            size: 24),
                        onPressed: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                      ),
                    ),
                    Tooltip(
                      message: 'Marcar como completada',
                      child: IconButton(
                        icon: const Icon(Icons.check_circle_outline_rounded,
                            color: AppTheme.mountainMeadow, size: 22),
                        onPressed: () {
                          ref
                              .read(timerViewModelProvider.notifier)
                              .completeAssignedTask();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskListItem(Task task) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(task.title,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatDuration(task.estimatedDuration ?? 0),
              style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: Icon(Icons.play_circle_fill,
                  color: colorScheme.primary, size: 32),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Asignar al temporizador',
              onPressed: () {
                ref.read(timerViewModelProvider.notifier).assignTask(task);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Sin fecha';
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  String _formatDuration(int totalSeconds) {
    if (totalSeconds == 0) return "0s";
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
