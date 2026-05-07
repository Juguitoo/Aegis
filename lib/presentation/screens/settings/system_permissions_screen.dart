import 'package:aegis/core/services/notification_service.dart';
import 'package:aegis/core/utils/native_app_monitor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SystemPermissionsScreen extends ConsumerStatefulWidget {
  const SystemPermissionsScreen({super.key});

  @override
  ConsumerState<SystemPermissionsScreen> createState() =>
      _SystemPermissionsScreenState();
}

class _SystemPermissionsScreenState
    extends ConsumerState<SystemPermissionsScreen> with WidgetsBindingObserver {
  bool _hasUsagePermission = false;
  bool _hasOverlayPermission = false;
  final bool _hasRequestedNotifications = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    final monitor = ref.read(nativeAppMonitorProvider);
    final usage = await monitor.checkUsagePermission();
    final overlay = await monitor.checkOverlayPermission();

    if (mounted) {
      setState(() {
        _hasUsagePermission = usage;
        _hasOverlayPermission = overlay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Permisos del sistema',
          style: textTheme.displayMedium,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        elevation: 1,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Aegis necesita estos permisos para poder detectar distracciones y mostrar la pantalla de bloqueo. Pulsa sobre ellos para gestionarlos.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          _PermissionItem(
            title: 'Acceso a datos de uso',
            description:
                'Permite saber qué aplicación tienes abierta en pantalla en todo momento.',
            icon: Icons.data_usage,
            isGranted: _hasUsagePermission,
            onTap: () =>
                ref.read(nativeAppMonitorProvider).requestUsagePermission(),
          ),
          const SizedBox(height: 16),
          _PermissionItem(
            title: 'Mostrar sobre otras apps',
            description:
                'Permite lanzar la pantalla de advertencia por encima de tu distracción.',
            icon: Icons.layers_outlined,
            isGranted: _hasOverlayPermission,
            onTap: () =>
                ref.read(nativeAppMonitorProvider).requestOverlayPermission(),
          ),
          const SizedBox(height: 16),
          _PermissionItem(
            title: 'Notificaciones',
            description:
                'Permite que Aegis te avise sobre tareas y eventos programados.',
            icon: Icons.notifications_active_outlined,
            isGranted: _hasRequestedNotifications,
            onTap: () async {
              await NotificationService.requestPermissions();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        const Text('Permisos de notificaciones solicitados.'),
                    backgroundColor: colorScheme.primary,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _PermissionItem extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isGranted;
  final VoidCallback onTap;

  const _PermissionItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.isGranted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final successColor = Colors.green.shade400;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isGranted
                ? successColor
                : colorScheme.outline.withValues(alpha: 0.2),
            width: isGranted ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isGranted
                    ? successColor.withValues(alpha: 0.1)
                    : colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isGranted ? Icons.check_circle : icon,
                color: isGranted ? successColor : colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: colorScheme.outline),
          ],
        ),
      ),
    );
  }
}
