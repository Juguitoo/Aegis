import 'package:flutter/material.dart';
import 'task_list_screen_mobile.dart';
import 'task_list_screen_desktop.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Si la ventana tiene menos de 800 píxeles de ancho, mostramos el móvil
        if (constraints.maxWidth < 800) {
          return const TaskListScreenMobile();
        }
        // Si es más ancha, mostramos el diseño de escritorio
        else {
          return const TaskListScreenDesktop();
        }
      },
    );
  }
}
