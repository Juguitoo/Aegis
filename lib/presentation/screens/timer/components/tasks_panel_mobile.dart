import 'package:aegis/core/theme/app_theme.dart';
import 'package:aegis/presentation/screens/tasks/components/task_table_view.dart';
import 'package:aegis/presentation/viewmodels/project_list_viewmodel.dart';
import 'package:aegis/presentation/viewmodels/task_list_viewmodel.dart';
import 'package:aegis/presentation/viewmodels/timer_state.dart';
import 'package:aegis/presentation/viewmodels/timer_viewmodel.dart';
import 'package:aegis/core/providers/repository_providers.dart';
import 'package:aegis/presentation/widgets/aegis_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/core/utils/color_utils.dart';
import 'package:aegis/presentation/viewmodels/tag_list_viewmodel.dart';

class TasksPanelMobile extends ConsumerWidget {
  const TasksPanelMobile({super.key});

  void _showTaskSelector(
      BuildContext context, WidgetRef ref, Task? assignedTask) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.outline.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Seleccionar tarea', style: textTheme.displayMedium),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, child) {
                        final tasksAsyncValue =
                            ref.watch(taskListViewModelProvider);

                        return tasksAsyncValue.when(
                          data: (tasks) {
                            final otherTasks = tasks
                                .where((t) =>
                                    t.id != assignedTask?.id &&
                                    t.completedAt == null)
                                .toList();

                            if (otherTasks.isEmpty) {
                              return Center(
                                child: Text('No hay tareas pendientes.',
                                    style: textTheme.bodyMedium
                                        ?.copyWith(color: colorScheme.outline)),
                              );
                            }

                            return ListView.separated(
                              controller: controller,
                              itemCount: otherTasks.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                return _buildBottomSheetTaskItem(
                                    otherTasks[index], ref, context);
                              },
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (err, stack) =>
                              Center(child: Text('Error: $err')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerViewModelProvider);
    final assignedTask = timerState.assignedTask;

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
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
          _buildCurrentTaskCard(assignedTask, ref, context)
        else
          _buildEmptyTaskPlaceholder(context, ref),
      ],
    );
  }

  Widget _buildEmptyTaskPlaceholder(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => _showTaskSelector(context, ref, null),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
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
              const SizedBox(height: 8),
              Text(
                'Reloj libre',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Toca para seleccionar una tarea',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTaskCard(Task task, WidgetRef ref, BuildContext context) {
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

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. ZONA SUPERIOR: Título y Etiquetas (Cuerpo de la tarjeta)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => _TaskDetailsDialog(task: task),
                );
              },
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 16.0, bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    tagIdsAsync.when(
                      data: (tagIds) => allTagsAsync.when(
                        data: (allTags) {
                          final taskTags = allTags
                              .where((t) => tagIds.contains(t.id))
                              .toList();
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
            ),
          ),

          // 2. DIVISOR
          Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.1)),

          // 3. FOOTER: Tiempo (Izquierda) y Botones de acción (Derecha)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tiempo
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

                // Botones Icon-Only compactos
                Row(
                  children: [
                    Tooltip(
                      message: 'Desasignar tarea',
                      child: IconButton(
                        icon: Icon(Icons.close_rounded,
                            color: colorScheme.onSurfaceVariant, size: 22),
                        onPressed: () {
                          // Usamos tu nueva función
                          ref
                              .read(timerViewModelProvider.notifier)
                              .clearAssignedTask();
                        },
                      ),
                    ),
                    Tooltip(
                      message: 'Cambiar por otra',
                      child: IconButton(
                        icon: Icon(Icons.swap_horiz_rounded,
                            color: colorScheme.primary, size: 22),
                        onPressed: () => _showTaskSelector(context, ref, task),
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

  Widget _buildBottomSheetTaskItem(
      Task task, WidgetRef ref, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(task.title,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
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
                  color: colorScheme.primary, size: 36),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                ref.read(timerViewModelProvider.notifier).assignTask(task);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
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

class _TaskDetailsDialog extends ConsumerWidget {
  final Task task;

  const _TaskDetailsDialog({required this.task});

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
    return '${date.day.toString().padLeft(2, '0')} de ${months[date.month - 1]} de ${date.year}';
  }

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
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final projectsAsync = ref.watch(projectListViewModelProvider);
    String? projectName;
    if (task.projectId != null) {
      final projectList = projectsAsync.value;
      if (projectList != null) {
        final project =
            projectList.where((p) => p.id == task.projectId).firstOrNull;
        if (project != null) {
          projectName = project.name;
        }
      }
    }

    final tagIdsAsync = ref.watch(taskTagsProvider(task.id));
    final allTagsAsync = ref.watch(tagListViewModelProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 750),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                task.title,
                style: textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.1)),
                ),
                child: Wrap(
                  spacing: 24,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 18, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(task.dueDate),
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flag_outlined,
                            size: 18, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text(
                          'Prioridad: ',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                _getPriorityColor(task.priority, colorScheme),
                          ),
                        ),
                        Text(
                          _getPriorityText(task.priority),
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (task.estimatedDuration != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.hourglass_empty_rounded,
                              size: 18, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Text(
                            '${task.estimatedDuration! ~/ 60} min',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    if (projectName != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.folder_outlined,
                              size: 18, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Text(
                            projectName,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    tagIdsAsync.when(
                      data: (tagIds) => allTagsAsync.when(
                        data: (allTags) {
                          final taskTags = allTags
                              .where((t) => tagIds.contains(t.id))
                              .toList();
                          if (taskTags.isEmpty) return const SizedBox.shrink();

                          return Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              Icon(Icons.label_outlined,
                                  size: 18,
                                  color: colorScheme.onSurfaceVariant),
                              const SizedBox(width: 2),
                              ...taskTags.map((tag) {
                                final tagColor =
                                    ColorUtils.parseColor(tag.colorHex);
                                return TagPill(
                                  label: tag.name.toUpperCase(),
                                  backgroundColor: tagColor.withAlpha(20),
                                  textColor: tagColor,
                                );
                              }),
                            ],
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
              const SizedBox(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Descripción',
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        task.description?.isNotEmpty == true
                            ? task.description!
                            : 'Esta tarea no tiene una descripción detallada.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: task.description?.isNotEmpty == true
                              ? colorScheme.onSurfaceVariant
                              : colorScheme.outline,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Subtareas',
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      StreamBuilder<List<Subtask>>(
                        stream: ref
                            .read(taskRepositoryProvider)
                            .watchSubtasksForTask(task.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                                height: 60,
                                child:
                                    Center(child: CircularProgressIndicator()));
                          }

                          final subtasks = snapshot.data ?? [];

                          if (subtasks.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: colorScheme.outline
                                        .withValues(alpha: 0.2),
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'No hay elementos en la lista.',
                                style: textTheme.bodyMedium
                                    ?.copyWith(color: colorScheme.outline),
                                textAlign: TextAlign.center,
                              ),
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
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        backgroundColor: colorScheme.secondary,
                                        color: progress == 1.0
                                            ? const Color(0xFF10B981)
                                            : colorScheme.primary,
                                        minHeight: 8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    '$completedCount/${subtasks.length}',
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: progress == 1.0
                                          ? const Color(0xFF10B981)
                                          : colorScheme.outline,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: colorScheme.outline
                                          .withValues(alpha: 0.2)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: subtasks.map((subtask) {
                                    final isLast = subtask == subtasks.last;
                                    return Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 12.0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                subtask.isCompleted
                                                    ? Icons.check_circle
                                                    : Icons.circle_outlined,
                                                size: 22,
                                                color: subtask.isCompleted
                                                    ? const Color(0xFF10B981)
                                                    : colorScheme.outline,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  subtask.title,
                                                  style: textTheme.bodyMedium
                                                      ?.copyWith(
                                                    color: subtask.isCompleted
                                                        ? colorScheme.outline
                                                        : colorScheme.onSurface,
                                                    decoration:
                                                        subtask.isCompleted
                                                            ? TextDecoration
                                                                .lineThrough
                                                            : null,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (!isLast)
                                          Divider(
                                              height: 1,
                                              color: colorScheme.outline
                                                  .withValues(alpha: 0.1)),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      if (task.notes?.isNotEmpty == true) ...[
                        const SizedBox(height: 32),
                        Text(
                          'Notas',
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.secondary.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color:
                                    colorScheme.outline.withValues(alpha: 0.1)),
                          ),
                          child: Text(
                            task.notes!,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AegisButton(
                text: 'Cerrar Detalles',
                type: ButtonType.secondary,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
