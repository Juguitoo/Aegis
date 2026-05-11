import 'package:aegis/core/theme/app_theme.dart';
import 'package:aegis/core/utils/format_utils.dart';
import 'package:aegis/presentation/screens/timer/components/task_details_components.dart';
import 'package:aegis/presentation/viewmodels/task_list_viewmodel.dart';
import 'package:aegis/presentation/viewmodels/timer_state.dart';
import 'package:aegis/presentation/viewmodels/timer_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/data/local/database/app_database.dart';

class TasksPanelDesktop extends ConsumerStatefulWidget {
  const TasksPanelDesktop({super.key});

  @override
  ConsumerState<TasksPanelDesktop> createState() => _TasksPanelDesktopState();
}

class _TasksPanelDesktopState extends ConsumerState<TasksPanelDesktop> {
  bool _isExpanded = false;
  int? _currentTaskId;

  final ScrollController _detailsScrollController = ScrollController();

  @override
  void dispose() {
    _detailsScrollController.dispose();
    super.dispose();
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
            Flexible(
              flex: _isExpanded ? 7 : 0,
              fit: _isExpanded ? FlexFit.tight : FlexFit.loose,
              child: _buildCurrentTaskCard(assignedTask, ref),
            )
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
            flex: _isExpanded ? 3 : 1,
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
            Icon(Icons.assignment_add, color: colorScheme.onSurface, size: 32),
            const SizedBox(height: 4),
            Text(
              'Reloj libre',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Selecciona una tarea de la lista',
              style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
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
        '${FormatUtils.formatDuration(currentTotalSeconds)} / ${FormatUtils.formatDuration(task.estimatedDuration ?? 0)}';

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
        mainAxisSize: _isExpanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  task.title,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          if (_isExpanded)
            Divider(
                height: 1, color: colorScheme.outline.withValues(alpha: 0.1)),
          if (_isExpanded)
            Expanded(
              child: Scrollbar(
                controller: _detailsScrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _detailsScrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
                    child: TaskDetailsContent(task: task),
                  ),
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
              FormatUtils.formatDuration(task.estimatedDuration ?? 0),
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
}
