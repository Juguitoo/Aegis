import 'package:aegis/core/utils/format_utils.dart';
import 'package:aegis/presentation/screens/tasks/components/task_table_view.dart';
import 'package:aegis/presentation/viewmodels/task_list_viewmodel.dart';
import 'package:aegis/presentation/widgets/aegis_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/core/utils/color_utils.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/presentation/viewmodels/tag_list_viewmodel.dart';
import 'package:aegis/presentation/viewmodels/area_list_viewmodel.dart';
import 'package:aegis/core/providers/repository_providers.dart';

class TaskDetailsContent extends ConsumerWidget {
  final Task task;

  const TaskDetailsContent({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final tagIdsAsync = ref.watch(taskTagsProvider(task.id));
    final allTagsAsync = ref.watch(tagListViewModelProvider);
    final areasAsync = ref.watch(areaListViewModelProvider);

    String? areaName;
    if (task.areaId != null) {
      final areaList = areasAsync.value;
      if (areaList != null) {
        final area = areaList.where((p) => p.id == task.areaId).firstOrNull;
        if (area != null) areaName = area.name;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.secondary,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
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
                      size: 14, color: colorScheme.onSurface),
                  const SizedBox(width: 6),
                  Text(
                    FormatUtils.formatDate(task.dueDate),
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
                      size: 14, color: colorScheme.onSurface),
                  const SizedBox(width: 6),
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorUtils.getPriorityColor(
                          task.priority, colorScheme),
                    ),
                  ),
                  Text(
                    FormatUtils.getPriorityText(task.priority),
                    style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface),
                  ),
                ],
              ),
              if (task.estimatedDuration != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.hourglass_empty_rounded,
                        size: 14, color: colorScheme.onSurface),
                    const SizedBox(width: 6),
                    Text(
                      '${task.estimatedDuration! ~/ 60} min',
                      style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface),
                    ),
                  ],
                ),
              if (areaName != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.folder_outlined,
                        size: 14, color: colorScheme.onSurface),
                    const SizedBox(width: 6),
                    Text(
                      areaName,
                      style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface),
                    ),
                  ],
                ),
              tagIdsAsync.when(
                data: (tagIds) => allTagsAsync.when(
                  data: (allTags) {
                    final taskTags =
                        allTags.where((t) => tagIds.contains(t.id)).toList();
                    if (taskTags.isEmpty) return const SizedBox.shrink();

                    return Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        Icon(Icons.label_outlined,
                            size: 14, color: colorScheme.onSurface),
                        const SizedBox(width: 2),
                        ...taskTags.map((tag) {
                          final tagColor = ColorUtils.parseColor(tag.colorHex);
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
        const SizedBox(height: 16),
        Text(
          'Descripción',
          style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant),
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
              fontWeight: FontWeight.bold, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<Subtask>>(
          stream:
              ref.read(taskRepositoryProvider).watchSubtasksForTask(task.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                  height: 40,
                  child:
                      Center(child: CircularProgressIndicator(strokeWidth: 2)));
            }

            final subtasks = snapshot.data ?? [];

            if (subtasks.isEmpty) {
              return Text(
                'No hay elementos en la lista.',
                style:
                    textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
              );
            }

            final completedCount =
                subtasks.where((st) => st.isCompleted).length;
            final progress =
                subtasks.isEmpty ? 0.0 : completedCount / subtasks.length;

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
                          backgroundColor: colorScheme.secondary,
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
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                              style: textTheme.bodyMedium?.copyWith(
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
              color: colorScheme.secondary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              task.notes!,
              style: textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ],
    );
  }
}

class TaskDetailsDialogMobile extends StatelessWidget {
  final Task task;

  const TaskDetailsDialogMobile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: TaskDetailsContent(task: task),
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
