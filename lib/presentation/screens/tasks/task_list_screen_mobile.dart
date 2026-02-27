import 'package:aegis/presentation/screens/main_mobile_layout.dart';
import 'package:aegis/presentation/screens/tasks/widgets/task_form_mobile.dart';
import '../../../data/local/database/app_database.dart';
import '../../viewmodels/task_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskListScreenMobile extends ConsumerStatefulWidget {
  const TaskListScreenMobile({super.key});

  @override
  ConsumerState<TaskListScreenMobile> createState() =>
      _TaskListScreenMobileState();
}

class _TaskListScreenMobileState extends ConsumerState<TaskListScreenMobile> {
  final ScrollController _mainScrollController = ScrollController();

  @override
  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }

  void _openTaskForm([Task? task]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => TaskFormMobile(task: task),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskListViewModelProvider);

    return MainMobileLayout(
      currentIndex: 2,
      appBar: AppBar(
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Principal',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        backgroundColor: const Color(0xFFF8FAFC),
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.settings, color: Color(0xFF1E293B)),
              onPressed: () {},
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6366F1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) => const TaskFormMobile(),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      child: Column(
        children: [
          Divider(color: Color(0xFFE2E8F0)),
          const _HabitsSectionPlaceholder(),
          Divider(color: Color(0xFFE2E8F0)),
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Text(
              "Tareas",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B)),
              textAlign: TextAlign.left,
            ),
          ),
          const _SearchBarAndFilters(),
          Expanded(
            child: tasksAsync.when(
              data: (tasks) {
                if (tasks.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay tareas. ¡Pulsa + para crear una!',
                      style: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  );
                }
                return Scrollbar(
                  controller: _mainScrollController,
                  thumbVisibility: true,
                  child: ListView.builder(
                    controller: _mainScrollController,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return _TaskCard(
                        task: task,
                        onToggle: () {
                          ref
                              .read(taskListViewModelProvider.notifier)
                              .toggleTaskCompletion(task);
                        },
                        onTap: () => _openTaskForm(task),
                      );
                    },
                  ),
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
}

class _HabitsSectionPlaceholder extends StatelessWidget {
  const _HabitsSectionPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: Text(
            "Hábitos",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B)),
            textAlign: TextAlign.left,
          ),
        ),
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          height: 128,
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2FE),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: const [
              Icon(Icons.auto_graph, color: Color(0xFF0284C7)),
              SizedBox(width: 12),
              Text(
                'Sección de hábitos (en desarrollo)',
                style: TextStyle(
                  color: Color(0xFF0284C7),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _SearchBarAndFilters extends StatefulWidget {
  const _SearchBarAndFilters();

  @override
  State<_SearchBarAndFilters> createState() => _SearchBarAndFiltersState();
}

class _SearchBarAndFiltersState extends State<_SearchBarAndFilters> {
  final ScrollController _filterScrollController = ScrollController();

  @override
  void dispose() {
    _filterScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(7),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Buscar tarea...',
                            hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Icon(Icons.search, color: Color(0xFF6366F1)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(7),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.tune, color: Color(0xFF6366F1)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Scrollbar(
            controller: _filterScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _filterScrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: const [
                  _FilterChip(label: 'Todo', isSelected: true),
                  _FilterChip(label: 'Completas', isSelected: false),
                  _FilterChip(label: 'Pendientes', isSelected: false),
                  _FilterChip(label: 'Alta Prioridad', isSelected: false),
                  _FilterChip(label: 'Media Prioridad', isSelected: false),
                  _FilterChip(label: 'Baja Prioridad', isSelected: false),
                  _FilterChip(label: 'Hoy', isSelected: false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterChip({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF475569),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const _TaskCard(
      {required this.task, required this.onToggle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(7),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
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
                    color: task.isCompleted
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFFCBD5E1),
                    width: 2,
                  ),
                  color: task.isCompleted
                      ? const Color(0xFF94A3B8)
                      : Colors.transparent,
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: task.isCompleted
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF1E293B),
                      decoration:
                          task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'PROYECTO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.outlined_flag,
              color: task.priority == 1
                  ? const Color(0xFF16A34A)
                  : task.priority == 2
                      ? const Color(0xFFCA8A04)
                      : task.priority == 3
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}
