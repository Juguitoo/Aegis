import 'package:aegis/presentation/screens/main_desktop_layout.dart';
import 'package:aegis/presentation/screens/tasks/widgets/task_form_desktop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/database/app_database.dart';
import '../../viewmodels/task_list_viewmodel.dart';

class TaskListScreenDesktop extends ConsumerWidget {
  const TaskListScreenDesktop({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskListViewModelProvider);

    return MainDesktopLayout(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Principal',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
            Divider(height: 16, color: const Color(0xFFE2E8F0)),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: _MainTaskColumn(tasksAsync: tasksAsync, ref: ref),
                  ),
                  const SizedBox(width: 32),
                  const Expanded(
                    flex: 3,
                    child: _WidgetsColumn(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainTaskColumn extends StatelessWidget {
  final AsyncValue<List<Task>> tasksAsync;
  final WidgetRef ref;

  const _MainTaskColumn({required this.tasksAsync, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
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
            FilterIconButton(
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 16),
        Stack(
          children: [
            const SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(bottom: 16, right: 48),
              child: Row(
                children: [
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
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      const Color(0xFFF8FAFC).withAlpha(0),
                      const Color(0xFFF8FAFC),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const TaskFormDesktop(),
              );
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Nueva Tarea',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              shadowColor: const Color(0xFF6366F1).withAlpha(100),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
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
                        return const Center(
                          child: Text('Sin tareas. ¡Añade una nueva!',
                              style: TextStyle(color: Color(0xFF94A3B8))),
                        );
                      }
                      return ListView.separated(
                        itemCount: tasks.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        itemBuilder: (context, index) {
                          return TaskRow(task: tasks[index], ref: ref);
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
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
          ),
        ),
      ],
    );
  }
}

class _TaskTableHeader extends StatelessWidget {
  const _TaskTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFEEF2FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: const Row(
        children: [
          SizedBox(width: 48),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Text('Nombre',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                Icon(Icons.arrow_drop_down, color: Color(0xFF64748B), size: 18),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text('Prioridad',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                Icon(Icons.arrow_drop_down, color: Color(0xFF64748B), size: 18),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text('Etiquetas',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text('Fecha',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                Icon(Icons.arrow_drop_down, color: Color(0xFF64748B), size: 18),
              ],
            ),
          ),
          SizedBox(width: 40),
        ],
      ),
    );
  }
}

class TaskRow extends StatelessWidget {
  final Task task;
  final WidgetRef ref;

  const TaskRow({super.key, required this.task, required this.ref});

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
  Widget build(BuildContext context) {
    final bool isCompleted = task.isCompleted;

    Color flagColor = const Color(0xFF64748B);
    if (task.priority == 3) {
      flagColor = const Color(0xFFEF4444);
    } else if (task.priority == 2) {
      flagColor = const Color(0xFFEAB308);
    } else if (task.priority == 1) {
      flagColor = const Color(0xFF22C55E);
    }

    String tagName = 'UNIVERSIDAD';
    Color tagBgColor = const Color(0xFFE0F2FE);
    Color tagTextColor = const Color(0xFF0284C7);

    if (task.id % 3 == 0) {
      tagName = 'TRABAJO';
      tagBgColor = const Color(0xFFFCE7F3);
      tagTextColor = const Color(0xFFDB2777);
    } else if (task.id % 4 == 0) {
      tagName = 'COMPRAS';
      tagBgColor = const Color(0xFFFEF9C3);
      tagTextColor = const Color(0xFFCA8A04);
    } else if (task.id % 5 == 0) {
      tagName = 'CASA';
      tagBgColor = const Color(0xFFDCFCE7);
      tagTextColor = const Color(0xFF16A34A);
    }

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Row(
            children: [
              SizedBox(
                width: 48,
                child: Checkbox(
                  value: isCompleted,
                  onChanged: (val) {
                    ref.read(taskListViewModelProvider.notifier).updateTask(
                          task.copyWith(isCompleted: val ?? false),
                        );
                  },
                  activeColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  task.title,
                  style: TextStyle(
                    color: isCompleted
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF334155),
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(Icons.flag, color: flagColor, size: 20),
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _TagPill(
                    label: tagName,
                    backgroundColor: tagBgColor,
                    textColor: tagTextColor,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  _formatDate(task.dueDate),
                  style:
                      const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                ),
              ),
              SizedBox(
                width: 40,
                child: PopupMenuButton(
                  icon: Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
                  color: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  onSelected: (value) {
                    if (value == 0) {
                      showDialog(
                        context: context,
                        builder: (context) => TaskFormDesktop(task: task),
                      );
                    } else if (value == 1) {
                      ref
                          .read(taskListViewModelProvider.notifier)
                          .deleteTask(task);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 0,
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined,
                              color: Color(0xFF64748B), size: 20),
                          SizedBox(width: 12),
                          Text('Editar',
                              style: TextStyle(color: Color(0xFF1E293B))),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 1,
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline,
                              color: Color(0xFFEF4444), size: 20),
                          SizedBox(width: 12),
                          Text('Eliminar',
                              style: TextStyle(color: Color(0xFFEF4444))),
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
    );
  }
}

class _TagPill extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _TagPill({
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Mostrando $taskCount Tareas',
            style: const TextStyle(
                color: Color(0xFF64748B), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class FilterIconButton extends StatefulWidget {
  final VoidCallback onTap;

  const FilterIconButton({super.key, required this.onTap});

  @override
  State<FilterIconButton> createState() => _FilterIconButtonState();
}

class _FilterIconButtonState extends State<FilterIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
            onTap: () {},
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: _isHovered
                        ? Colors.black.withAlpha(25)
                        : Colors.black.withAlpha(10),
                    blurRadius: _isHovered ? 15 : 8,
                    offset:
                        _isHovered ? const Offset(0, 8) : const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.tune, color: Color(0xFF6366F1)),
            )));
  }
}

class _FilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;

  const _FilterChip({required this.label, required this.isSelected});

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected ? const Color(0xFF6366F1) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? Colors.black.withAlpha(30)
                    : Colors.black.withAlpha(10),
                blurRadius: _isHovered ? 8 : 4,
                offset: _isHovered ? const Offset(0, 6) : const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: widget.isSelected
                  ? Colors.transparent
                  : const Color(0xFFF1F5F9),
              width: 1,
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.isSelected ? Colors.white : const Color(0xFF475569),
              fontWeight:
                  widget.isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _WidgetsColumn extends StatelessWidget {
  const _WidgetsColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFF1F5F9),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'Widget de Hábitos\n(Próximamente)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          flex: 4,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withAlpha(50),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'Mantente Enfocado\n(Próximamente)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
