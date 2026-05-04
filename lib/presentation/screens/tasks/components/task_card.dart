import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/local/database/app_database.dart';
import '../../../viewmodels/task_list_viewmodel.dart';
import '../../../viewmodels/tag_list_viewmodel.dart';
import '../../../../core/utils/color_utils.dart';

class TaskCard extends ConsumerWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  Color _getFlagColor(ColorScheme colorScheme) {
    if (task.priority == 3) {
      return colorScheme.error;
    } else if (task.priority == 2) {
      return const Color(0xFFEAB308);
    } else if (task.priority == 1) {
      return const Color(0xFF22C55E);
    }
    return colorScheme.outline.withValues(alpha: 0.3);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagIdsAsync = ref.watch(taskTagsProvider(task.id));
    final allTagsAsync = ref.watch(tagListViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Dismissible(
          key: ValueKey(task.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => onDelete(),
          background: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            color: colorScheme.onError,
            alignment: Alignment.centerRight,
            child:
                Icon(Icons.delete_outline, color: colorScheme.error, size: 28),
          ),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              color: colorScheme.surface,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 4,
                      color: _getFlagColor(colorScheme),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: onToggle,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: task.completedAt != null
                                        ? colorScheme.outline
                                        : colorScheme.outline
                                            .withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                  color: task.completedAt != null
                                      ? colorScheme.outline
                                      : Colors.transparent,
                                ),
                                child: task.completedAt != null
                                    ? Icon(Icons.check,
                                        size: 16, color: colorScheme.surface)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          task.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: textTheme.bodyLarge?.copyWith(
                                            color: task.completedAt != null
                                                ? colorScheme.outline
                                                : colorScheme.onSurface,
                                            decoration: task.completedAt != null
                                                ? TextDecoration.lineThrough
                                                : null,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      if (task.dueDate != null) ...[
                                        const SizedBox(width: 12),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 2),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                  Icons.calendar_today_outlined,
                                                  size: 14,
                                                  color: colorScheme.outline),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                                                style: textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: colorScheme
                                                      .onSurfaceVariant,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  tagIdsAsync.when(
                                    data: (tagIds) => allTagsAsync.when(
                                      data: (allTags) {
                                        final taskTags = allTags
                                            .where((t) => tagIds.contains(t.id))
                                            .toList();
                                        if (taskTags.isEmpty) {
                                          return const SizedBox(height: 26);
                                        }
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: taskTags.map((tag) {
                                                final tagColor =
                                                    ColorUtils.parseColor(
                                                        tag.colorHex);
                                                return Container(
                                                  margin: const EdgeInsets.only(
                                                      right: 8),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: tagColor.withValues(
                                                        alpha: 0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Text(
                                                    tag.name.toUpperCase(),
                                                    style: textTheme.bodySmall
                                                        ?.copyWith(
                                                      fontSize: 10,
                                                      color: tagColor,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        );
                                      },
                                      loading: () => const SizedBox(height: 26),
                                      error: (_, __) =>
                                          const SizedBox(height: 26),
                                    ),
                                    loading: () => const SizedBox(height: 26),
                                    error: (_, __) =>
                                        const SizedBox(height: 26),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.chevron_right,
                                color:
                                    colorScheme.outline.withValues(alpha: 0.3)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
