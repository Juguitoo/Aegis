import 'package:aegis/core/utils/format_utils.dart';
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

class TasksPanelDesktop extends ConsumerStatefulWidget {
  const TasksPanelDesktop({super.key});

  @override
  ConsumerState<TasksPanelDesktop> createState() => _TasksPanelDesktopState();
}

class _TasksPanelDesktopState extends ConsumerState<TasksPanelDesktop> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerViewModelProvider);
    final assignedTask = timerState.assignedTask;
    final tasksAsyncValue = ref.watch(taskListViewModelProvider);

    return Container(
      width: 350,
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tarea en curso',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          if (assignedTask != null)
            _buildCurrentTaskCard(assignedTask, ref)
          else
            _buildEmptyTaskPlaceholder(),
          const SizedBox(height: 24),
          const Text(
            'Otras tareas:',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: tasksAsyncValue.when(
              data: (tasks) {
                final otherTasks = tasks
                    .where((t) =>
                        t.id != assignedTask?.id && t.isCompleted == false)
                    .toList();

                if (otherTasks.isEmpty) {
                  return const Center(child: Text('No hay tareas pendientes.'));
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
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: Colors.grey.shade300, width: 1, style: BorderStyle.solid),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
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
                'Selecciona una tarea para comenzar',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTaskCard(Task task, WidgetRef ref) {
    final timerState = ref.watch(timerViewModelProvider);

    int liveSeconds = 0;
    if (timerState.mode == TimerMode.focus) {
      liveSeconds = timerState.initialSeconds - timerState.remainingSeconds;
      if (liveSeconds < 0) liveSeconds = 0;
    }

    final int currentTotalSeconds = (task.actualDuration ?? 0) + liveSeconds;

    final String timeString =
        '${FormatUtils.formatDuration(currentTotalSeconds)} / ${FormatUtils.formatDuration(task.estimatedDuration ?? 0)}';

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
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
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                            padding: EdgeInsets.all(4.0),
                            child: Icon(Icons.check_circle_outline,
                                color: Colors.green, size: 24),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        borderRadius: BorderRadius.circular(50),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: const Color(0xFF64748B),
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 14, color: Colors.grey),
                                const SizedBox(width: 6),
                                Text(
                                  'Fecha: ${FormatUtils.formatDate(task.dueDate)}',
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.black87),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text('Descripción:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(
                              task.description?.isNotEmpty == true
                                  ? task.description!
                                  : 'Sin descripción',
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black87),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Text('Prioridad: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13)),
                                Icon(
                                  Icons.circle,
                                  size: 12,
                                  color: task.priority > 0
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text('CheckList:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 8),
                            StreamBuilder<List<Subtask>>(
                              stream: ref
                                  .read(taskRepositoryProvider)
                                  .watchSubtasksForTask(task.id),
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
                                  return const Text(
                                      'No hay elementos en la lista.',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 13));
                                }

                                return Column(
                                  children: subtasks
                                      .map((subtask) => Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 6.0),
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
                                                      ? Colors.grey
                                                      : Colors.black87,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    subtask.title,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: subtask.isCompleted
                                                          ? Colors.grey
                                                          : Colors.black87,
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
                                          ))
                                      .toList(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskListItem(Task task) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 6,
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
              FormatUtils.formatDuration(task.estimatedDuration ?? 0),
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.play_circle_fill,
                  color: Color(0xFF6366F1), size: 32),
              onPressed: () {
                ref.read(timerViewModelProvider.notifier).assignTask(task);
              },
            ),
          ],
        ),
      ),
    );
  }
}
