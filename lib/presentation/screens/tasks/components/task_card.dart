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

  Color _getFlagColor() {
    if (task.priority == 3) {
      return const Color(0xFFEF4444);
    } else if (task.priority == 2) {
      return const Color(0xFFEAB308);
    } else if (task.priority == 1) {
      return const Color(0xFF22C55E);
    }
    return const Color(0xFFCBD5E1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagIdsAsync = ref.watch(taskTagsProvider(task.id));
    final allTagsAsync = ref.watch(tagListViewModelProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(7),
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
            color: const Color(0xFFFEE2E2),
            alignment: Alignment.centerRight,
            child: const Icon(Icons.delete_outline,
                color: Color(0xFFDC2626), size: 28),
          ),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              color: Colors.white,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 4,
                      color: _getFlagColor(),
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
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFFCBD5E1),
                                    width: 2,
                                  ),
                                  color: task.completedAt != null
                                      ? const Color(0xFF94A3B8)
                                      : Colors.transparent,
                                ),
                                child: task.completedAt != null
                                    ? const Icon(Icons.check,
                                        size: 16, color: Colors.white)
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
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: task.completedAt != null
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF1E293B),
                                            decoration: task.completedAt != null
                                                ? TextDecoration.lineThrough
                                                : null,
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
                                              const Icon(
                                                  Icons.calendar_today_outlined,
                                                  size: 14,
                                                  color: Color(0xFF94A3B8)),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF64748B),
                                                  fontWeight: FontWeight.w500,
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
                                                    color:
                                                        tagColor.withAlpha(20),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Text(
                                                    tag.name,
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: tagColor,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        );
                                      },
                                      loading: () => SizedBox(height: 26),
                                      error: (_, __) => SizedBox(height: 26),
                                    ),
                                    loading: () => SizedBox(height: 26),
                                    error: (_, __) => SizedBox(height: 26),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right,
                                color: Color(0xFFCBD5E1)),
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
