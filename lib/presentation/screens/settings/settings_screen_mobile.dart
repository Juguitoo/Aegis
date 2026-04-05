import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/presentation/screens/settings/timer_settings_mobile.dart';
import 'package:aegis/presentation/screens/settings/manage_blacklist_screen.dart';
import 'package:aegis/presentation/screens/settings/system_permissions_screen.dart';

class SettingsScreenMobile extends ConsumerWidget {
  const SettingsScreenMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Ajustes',
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
          _SettingsTile(
            icon: Icons.timer_outlined,
            title: 'Temporizador Pomodoro',
            subtitle: 'Configura tus intervalos de trabajo y descanso',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const TimerSettingsMobile()),
              );
            },
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.block_outlined,
            title: 'Bloqueo de Aplicaciones',
            subtitle: 'Gestiona tu lista negra para evitar distracciones',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ManageBlacklistScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.admin_panel_settings_outlined,
            title: 'Permisos del Sistema',
            subtitle: 'Gestiona los accesos necesarios para el escudo',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SystemPermissionsScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.delete_outline,
            title: 'Borrar Datos de Sesiones',
            subtitle: 'Elimina todo el historial de concentración',
            iconColor: Colors.redAccent,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('¿Borrar historial?'),
                  content: const Text(
                      'Esta acción eliminará todas las sesiones de concentración guardadas y no se puede deshacer.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Borrar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
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
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(10, 0, 0, 0),
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
                color: iconColor != null
                    ? iconColor!.withOpacity(0.1)
                    : const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: iconColor ?? const Color(0xFF6366F1), size: 24),
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
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }
}
