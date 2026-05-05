import 'package:aegis/core/providers/general_providers.dart';
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.redAccent, size: 28),
            SizedBox(width: 8),
            Text('Atención', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Importar una copia de seguridad sobrescribirá todos los datos actuales de forma irreversible.\n\n¿Estás seguro?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar',
                style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              ref.read(backupViewModelProvider.notifier).importData();
            },
            child: const Text('Sí, Importar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(backupViewModelProvider, (previous, next) {
      next.when(
        data: (_) {
          if (previous is AsyncLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Operación completada con éxito'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        },
        loading: () {},
      );
    });

    final isBackupLoading = ref.watch(backupViewModelProvider).isLoading;
    final isDevMode = ref.watch(devModeProvider); // CORRECCIÓN AQUÍ

    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text('Ajustes',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B))),
      content: SizedBox(
        width: 450,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Temporizador Pomodoro',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6366F1))),
                  const SizedBox(height: 16),
                  _buildSliderSection(
                    'Tiempo de Foco',
                    _pomodoro,
                    10,
                    90,
                    (val) => setState(() => _pomodoro = val),
                  ),
                  const SizedBox(height: 16),
                  _buildSliderSection(
                    'Descanso Corto',
                    _shortBreak,
                    1,
                    15,
                    (val) => setState(() => _shortBreak = val),
                  ),
                  const SizedBox(height: 16),
                  _buildSliderSection(
                    'Descanso Largo',
                    _longBreak,
                    5,
                    45,
                    (val) => setState(() => _longBreak = val),
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 16),
                  const Text('Copia de Seguridad',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6366F1))),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => ref
                              .read(backupViewModelProvider.notifier)
                              .exportData(),
                          icon: const Icon(Icons.upload_file,
                              color: Color(0xFF1E293B)),
                          label: const Text('Exportar',
                              style: TextStyle(color: Color(0xFF1E293B))),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _showImportWarningDialog(context, ref),
                          icon: const Icon(Icons.file_download,
                              color: Colors.redAccent),
                          label: const Text('Importar',
                              style: TextStyle(color: Colors.redAccent)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.redAccent),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFFE2E8F0)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Modo Desarrollador',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF475569))),
                      Switch(
                          value: isDevMode,
                          activeThumbColor: const Color(0xFF6366F1),
                          onChanged: (bool newValue) {
                            ref.read(devModeProvider.notifier).state = newValue;
                          }),
                    ],
                  ),
                ],
              ),
            ),
            if (isBackupLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.white.withValues(alpha: 0.8),
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6366F1)),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        AegisButton(
            text: 'Cancelar',
            onPressed: () => Navigator.pop(context),
            type: ButtonType.secondary),
        AegisButton(
            text: 'Guardar',
            onPressed: () {
              ref.read(settingsViewModelProvider.notifier).upsertSettings(
                    pomodoroDuration: _pomodoro.toInt(),
                    shortBreakDuration: _shortBreak.toInt(),
                    longBreakDuration: _longBreak.toInt(),
                  );
              Navigator.pop(context);
            },
            type: ButtonType.primary),
      ],
    );
  }

  Widget _buildSliderSection(String label, double value, double min, double max,
      ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Color(0xFF475569)),
            ),
            Text(
              '${value.toInt()} min',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          activeColor: const Color(0xFF6366F1),
          inactiveColor: const Color(0xFFE2E8F0),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
