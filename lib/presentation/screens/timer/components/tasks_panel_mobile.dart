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

class TasksPanelMobile extends ConsumerWidget {
  const TasksPanelMobile({super.key});

  void _showTaskSelector(
      BuildContext context, WidgetRef ref, Task? assignedTask) {
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
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Seleccionar tarea',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
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
                              return const Center(
                                child: Text('No hay tareas pendientes.',
                                    style: TextStyle(color: Colors.grey)),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tarea en curso',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        if (assignedTask != null)
          _buildCurrentTaskCard(assignedTask, ref, context)
        else
          _buildEmptyTaskPlaceholder(context, ref),
      ],
    );
  }

  Widget _buildEmptyTaskPlaceholder(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => _showTaskSelector(context, ref, null),
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
              color: Colors.grey.shade300, width: 1, style: BorderStyle.solid),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.assignment_add, color: Colors.grey, size: 32),
                SizedBox(height: 8),
                Text(
                  'Reloj libre',
                  style: TextStyle(
                      color: Colors.black54, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Toca para seleccionar una tarea',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTaskCard(Task task, WidgetRef ref, BuildContext context) {
    final timerState = ref.watch(timerViewModelProvider);

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => _TaskDetailsDialog(task: task),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          task.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: tagIdsAsync.when(
                                data: (tagIds) => allTagsAsync.when(
                                  data: (allTags) {
                                    final taskTags = allTags
                                        .where((t) => tagIds.contains(t.id))
                                        .toList();
                                    if (taskTags.isEmpty) {
                                      return const SizedBox.shrink();
                                    }

                                    return SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: taskTags.map((tag) {
                                          final tagColor =
                                              ColorUtils.parseColor(
                                                  tag.colorHex);
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                right: 6.0),
                                            child: TagPill(
                                              label: tag.name.toUpperCase(),
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
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2)),
                                  error: (_, __) => const SizedBox.shrink(),
                                ),
                                loading: () => const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2)),
                                error: (_, __) => const SizedBox.shrink(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(timeString,
                                style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  color: const Color(0xFFF1F5F9),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Tooltip(
                        message: 'Cambiar tarea',
                        child: InkWell(
                          onTap: () => _showTaskSelector(context, ref, task),
                          borderRadius: BorderRadius.circular(50),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.swap_horiz,
                                color: Color(0xFF6366F1), size: 24),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Tooltip(
                        message: 'Completar tarea',
                        child: InkWell(
                          onTap: () {
                            ref
                                .read(timerViewModelProvider.notifier)
                                .completeAssignedTask();
                          },
                          borderRadius: BorderRadius.circular(50),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.check_circle_outline,
                                color: Colors.green, size: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheetTaskItem(
      Task task, WidgetRef ref, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        title: Text(task.title, style: const TextStyle(fontSize: 14)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatDuration(task.estimatedDuration ?? 0),
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.play_circle_fill,
                  color: Color(0xFF6366F1), size: 32),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Fecha: ${_formatDate(task.dueDate)}',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Descripción:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 6),
                    Text(
                      task.description?.isNotEmpty == true
                          ? task.description!
                          : 'Sin descripción detallada',
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Prioridad: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        Icon(
                          Icons.circle,
                          size: 14,
                          color: task.priority > 0 ? Colors.red : Colors.grey,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text('CheckList:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 12),
                    StreamBuilder<List<Subtask>>(
                      stream: ref
                          .read(taskRepositoryProvider)
                          .watchSubtasksForTask(task.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                              height: 60,
                              child: Center(
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)));
                        }

                        final subtasks = snapshot.data ?? [];

                        if (subtasks.isEmpty) {
                          return const Text('No hay elementos en la lista.',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14));
                        }

                        return Column(
                          children: subtasks
                              .map((subtask) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          subtask.isCompleted
                                              ? Icons.check_circle
                                              : Icons.circle_outlined,
                                          size: 20,
                                          color: subtask.isCompleted
                                              ? Colors.grey
                                              : Colors.black87,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            subtask.title,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: subtask.isCompleted
                                                  ? Colors.grey
                                                  : Colors.black87,
                                              decoration: subtask.isCompleted
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
