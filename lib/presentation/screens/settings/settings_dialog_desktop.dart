import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/presentation/viewmodels/settings_viewmodel.dart';
import 'package:aegis/presentation/viewmodels/backup_viewmodel.dart';
import 'package:aegis/presentation/widgets/aegis_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsDialogDesktop extends ConsumerStatefulWidget {
  final Setting? currentSettings;
  const SettingsDialogDesktop({super.key, this.currentSettings});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends ConsumerState<SettingsDialogDesktop> {
  late double _pomodoro;
  late double _shortBreak;
  late double _longBreak;

  @override
  void initState() {
    super.initState();
    _pomodoro = widget.currentSettings?.pomodoroDuration.toDouble() ?? 25.0;
    _shortBreak = widget.currentSettings?.shortBreakDuration.toDouble() ?? 5.0;
    _longBreak = widget.currentSettings?.longBreakDuration.toDouble() ?? 15.0;
  }

  void _showImportWarningDialog(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: colorScheme.error, size: 28),
            const SizedBox(width: 8),
            Text('Atención',
                style: textTheme.displayMedium?.copyWith(fontSize: 20)),
          ],
        ),
        content: Text(
          'Importar una copia de seguridad sobrescribirá todos los datos actuales de forma irreversible.\n\n¿Estás seguro de que deseas continuar?',
          style: textTheme.bodyMedium
              ?.copyWith(color: colorScheme.onSurfaceVariant),
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

  void _showDeleteAllWarningDialog(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.delete_forever_rounded,
                color: colorScheme.error, size: 28),
            const SizedBox(width: 8),
            Text('Borrar todo',
                style: textTheme.displayMedium?.copyWith(fontSize: 20)),
          ],
        ),
        content: Text(
          'Esta acción eliminará permanentemente todas tus tareas, proyectos, etiquetas e historial. No se puede deshacer.\n\n¿Estás absolutamente seguro?',
          style: textTheme.bodyMedium
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        actions: [
          AegisButton(
            text: 'Cancelar',
            onPressed: () => Navigator.pop(context),
            type: ButtonType.secondary,
          ),
          AegisButton(
            text: 'Borrar permanentemente',
            onPressed: () {
              Navigator.pop(context);
              ref.read(settingsViewModelProvider.notifier).deleteAllData();
            },
            type: ButtonType.destructive,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Icon(Icons.settings_outlined, color: colorScheme.primary, size: 28),
          const SizedBox(width: 12),
          Text('Ajustes', style: textTheme.displayMedium),
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 700,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionCard(
                    context: context,
                    title: 'Temporizador pomodoro',
                    icon: Icons.timer_outlined,
                    child: Column(
                      children: [
                        _buildSliderSection('Tiempo de foco', _pomodoro, 10, 90,
                            (val) => setState(() => _pomodoro = val)),
                        const SizedBox(height: 16),
                        _buildSliderSection('Descanso corto', _shortBreak, 1,
                            15, (val) => setState(() => _shortBreak = val)),
                        const SizedBox(height: 16),
                        _buildSliderSection('Descanso largo', _longBreak, 5, 45,
                            (val) => setState(() => _longBreak = val)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    context: context,
                    title: 'Datos y seguridad',
                    icon: Icons.sd_storage_outlined,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: AegisButton(
                                onPressed: () => ref
                                    .read(backupViewModelProvider.notifier)
                                    .exportData(),
                                icon: Icons.upload_file,
                                text: 'Exportar copia',
                                type: ButtonType.secondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AegisButton(
                                onPressed: () =>
                                    _showImportWarningDialog(context, ref),
                                icon: Icons.file_download,
                                text: 'Importar copia',
                                type: ButtonType.destructive,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        AegisButton(
                          onPressed: () =>
                              _showDeleteAllWarningDialog(context, ref),
                          icon: Icons.delete_forever_rounded,
                          text: 'Borrar toda la base de datos',
                          type: ButtonType.destructive,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isBackupLoading)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child:
                        CircularProgressIndicator(color: colorScheme.primary),
                  ),
                ),
              ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        AegisButton(
          text: 'Cancelar',
          onPressed: () => Navigator.pop(context),
          type: ButtonType.secondary,
        ),
        const SizedBox(width: 8),
        AegisButton(
          text: 'Guardar cambios',
          onPressed: () {
            ref.read(settingsViewModelProvider.notifier).upsertSettings(
                  pomodoroDuration: _pomodoro.toInt(),
                  shortBreakDuration: _shortBreak.toInt(),
                  longBreakDuration: _longBreak.toInt(),
                );
            Navigator.pop(context);
          },
          type: ButtonType.primary,
        ),
      ],
    );
  }

  Widget _buildSectionCard(
      {required BuildContext context,
      required String title,
      required IconData icon,
      required Widget child}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                title,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildSliderSection(String label, double value, double min, double max,
      ValueChanged<double> onChanged) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style:
                  textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${value.toInt()} min',
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            activeTrackColor: colorScheme.primary,
            inactiveTrackColor: colorScheme.outline.withValues(alpha: 0.2),
            thumbColor: colorScheme.primary,
            overlayColor: colorScheme.primary.withValues(alpha: 0.1),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
