import 'package:aegis/core/providers/general_providers.dart';
import 'package:aegis/presentation/viewmodels/settings_viewmodel.dart';
import 'package:aegis/presentation/widgets/aegis_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/presentation/screens/settings/timer_settings_mobile.dart';
import 'package:aegis/presentation/screens/settings/manage_blacklist_screen.dart';
import 'package:aegis/presentation/screens/settings/system_permissions_screen.dart';
import 'package:aegis/presentation/viewmodels/backup_viewmodel.dart';

class SettingsScreenMobile extends ConsumerWidget {
  const SettingsScreenMobile({super.key});

  void _showImportWarningDialog(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: colorScheme.error, size: 28),
            const SizedBox(width: 8),
            const Text('Atención',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Importar una copia de seguridad sobrescribirá todos los datos actuales de la aplicación de forma irreversible.\n\n¿Estás completamente seguro de que deseas continuar?',
        ),
        actions: [
          AegisButton(
            text: 'Cancelar',
            onPressed: () => Navigator.pop(context),
            type: ButtonType.secondary,
          ),
          AegisButton(
            text: 'Sí, importar',
            onPressed: () {
              Navigator.pop(context);
              ref.read(backupViewModelProvider.notifier).importData();
            },
            type: ButtonType.destructive,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    ref.listen<AsyncValue<void>>(backupViewModelProvider, (previous, next) {
      final screenSize = MediaQuery.of(context).size;
      final sideMargin =
          screenSize.width > 600 ? (screenSize.width - 400) / 2 : 16.0;
      final bottomMargin = (screenSize.height - 120).clamp(16.0, 4000.0);

      void showToast(String message, bool isError) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(isError ? Icons.error_outline : Icons.check_circle_outline,
                    color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor:
                isError ? colorScheme.error : const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
                bottom: bottomMargin, left: sideMargin, right: sideMargin),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 6,
            dismissDirection: DismissDirection.up,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      next.when(
        data: (_) {
          if (previous is AsyncLoading) {
            showToast('Operación completada con éxito', false);
          }
        },
        error: (error, stackTrace) {
          showToast(error.toString().replaceAll('Exception: ', ''), true);
        },
        loading: () {},
      );
    });

    final isBackupLoading = ref.watch(backupViewModelProvider).isLoading;
    final isDevMode = ref.watch(devModeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Ajustes',
          style: textTheme.displayMedium,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
      ),
      body: Stack(
        children: [
          Divider(color: colorScheme.outline.withValues(alpha: 0.2), height: 1),
          ListView(
            padding: EdgeInsets.only(
              top: 16,
              right: 16,
              left: 16,
              bottom: MediaQuery.paddingOf(context).bottom + 24,
            ),
            children: [
              _SettingsTile(
                icon: Icons.timer_outlined,
                title: 'Temporizador pomodoro',
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
                title: 'Bloqueo de aplicaciones',
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
                title: 'Permisos del sistema',
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
                icon: Icons.upload_file,
                title: 'Exportar datos',
                subtitle: 'Guardar copia de seguridad en el dispositivo',
                onTap: () =>
                    ref.read(backupViewModelProvider.notifier).exportData(),
              ),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.file_download,
                title: 'Importar datos',
                subtitle: 'Restaurar información desde un archivo JSON',
                iconColor: colorScheme.error,
                onTap: () => _showImportWarningDialog(context, ref),
              ),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.delete_forever_outlined,
                title: 'Restablecer aplicación',
                subtitle: 'Borra todos los datos de forma permanente.',
                iconColor: colorScheme.error,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: colorScheme.surface,
                      title: const Text('¿Restablecer la aplicación?'),
                      content: const Text(
                          'Todos los datos de la aplicación (tareas, proyectos, configuraciones, etc.) se eliminarán de forma permanente. Esta acción no se puede deshacer.'),
                      actions: [
                        AegisButton(
                          text: 'Cancelar',
                          onPressed: () => Navigator.pop(context),
                          type: ButtonType.secondary,
                        ),
                        AegisButton(
                          text: 'Restablecer',
                          onPressed: () {
                            ref
                                .read(settingsViewModelProvider.notifier)
                                .deleteAllData();
                            Navigator.pop(context);
                          },
                          type: ButtonType.destructive,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
                child: Text('APARIENCIA',
                    style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2)),
              ),
              _SettingsTile(
                icon: isDark ? Icons.dark_mode : Icons.light_mode,
                title: 'Modo oscuro',
                subtitle: 'Cambia entre el tema claro y oscuro',
                iconColor: colorScheme.primary,
                trailing: Switch(
                  value: isDark,
                  activeThumbColor: colorScheme.primary,
                  onChanged: (bool newValue) {
                    ref.read(themeModeProvider.notifier).state =
                        newValue ? ThemeMode.dark : ThemeMode.light;
                  },
                ),
                onTap: () {
                  ref.read(themeModeProvider.notifier).state =
                      isDark ? ThemeMode.light : ThemeMode.dark;
                },
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
                child: Text('AVANZADO',
                    style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2)),
              ),
              _SettingsTile(
                icon: Icons.developer_mode,
                title: 'Modo desarrollador',
                subtitle: 'Habilita herramientas y botones de prueba',
                iconColor: Colors.deepPurpleAccent,
                trailing: Switch(
                  value: isDevMode,
                  activeThumbColor: colorScheme.primary,
                  onChanged: (bool newValue) {
                    ref.read(devModeProvider.notifier).state = newValue;
                  },
                ),
                onTap: () {
                  ref.read(devModeProvider.notifier).state = !isDevMode;
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
          if (isBackupLoading)
            Container(
              color: colorScheme.surface.withValues(alpha: 0.8),
              child: Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              ),
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
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
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
                color: iconColor != null
                    ? iconColor!.withValues(alpha: 0.1)
                    : colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  Icon(icon, color: iconColor ?? colorScheme.primary, size: 24),
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
                      color: iconColor ?? colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            trailing ?? Icon(Icons.chevron_right, color: colorScheme.outline),
          ],
        ),
      ),
    );
  }
}
