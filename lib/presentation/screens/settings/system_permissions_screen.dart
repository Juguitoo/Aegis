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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Permisos del Sistema',
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        elevation: 1,
        shadowColor: const Color.fromARGB(25, 0, 0, 0),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Aegis necesita estos permisos para poder detectar distracciones y mostrar la pantalla de bloqueo. Pulsa sobre ellos para gestionarlos.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 15),
          ),
          const SizedBox(height: 24),
          _PermissionItem(
            title: 'Acceso a Datos de Uso',
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
                  const SnackBar(
                    content: Text('Permisos de notificaciones solicitados.'),
                    backgroundColor: Color(0xFF10B981),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isGranted ? Colors.green.shade400 : const Color(0xFFE2E8F0),
            width: isGranted ? 2 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(10, 0, 0, 0),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isGranted
                    ? Colors.green.withValues(alpha: 0.1)
                    : const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isGranted ? Icons.check_circle : icon,
                color: isGranted ? Colors.green : const Color(0xFF6366F1),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}
