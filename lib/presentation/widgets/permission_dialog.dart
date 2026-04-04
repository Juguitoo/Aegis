import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/core/utils/native_app_monitor.dart';

Future<void> checkAndPromptUsagePermission(
    BuildContext context, WidgetRef ref) async {
  final monitor = ref.read(nativeAppMonitorProvider);
  final hasPermission = await monitor.checkPermission();

  if (!hasPermission && context.mounted) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permiso Especial Requerido'),
        content: const Text(
          'Para que el modo concentración funcione y pueda detectar aplicaciones en la lista negra, Aegis necesita el permiso de "Acceso a datos de uso".\n\nAl continuar, serás redirigido a los ajustes del sistema. Por favor, busca Aegis en la lista y activa el interruptor.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Más tarde'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await monitor.requestPermission();
            },
            child: const Text('Ir a Ajustes'),
          ),
        ],
      ),
    );
  }
}
