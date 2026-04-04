import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/core/utils/native_app_monitor.dart';

Future<void> checkAndPromptPermissions(
    BuildContext context, WidgetRef ref) async {
  final monitor = ref.read(nativeAppMonitorProvider);

  final hasUsagePermission = await monitor.checkUsagePermission();

  if (!hasUsagePermission && context.mounted) {
    await _showPermissionDialog(
      context: context,
      title: 'Permiso Especial Requerido',
      content:
          'Para que el modo concentración funcione y pueda detectar aplicaciones en la lista negra, Aegis necesita el permiso de "Acceso a datos de uso".\n\nAl continuar, serás redirigido a los ajustes del sistema. Por favor, busca Aegis en la lista y activa el interruptor.',
      onRequest: () => monitor.requestUsagePermission(),
    );
    return;
  }

  final hasOverlayPermission = await monitor.checkOverlayPermission();

  if (!hasOverlayPermission && context.mounted) {
    await _showPermissionDialog(
      context: context,
      title: 'Permiso de Superposición',
      content:
          'Para poder protegerte de las distracciones, Aegis necesita mostrar su pantalla de advertencia por encima de otras aplicaciones.\n\nAl continuar, serás redirigido a los ajustes. Por favor, activa el interruptor para Aegis.',
      onRequest: () => monitor.requestOverlayPermission(),
    );
  }
}

Future<void> _showPermissionDialog({
  required BuildContext context,
  required String title,
  required String content,
  required Future<void> Function() onRequest,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Más tarde'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            await onRequest();
          },
          child: const Text('Ir a Ajustes'),
        ),
      ],
    ),
  );
}
