import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/presentation/viewmodels/settings_viewmodel.dart';
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text('Ajustes del temporizador',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B))),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar',
              style: TextStyle(color: Color(0xFF64748B))),
        ),
        ElevatedButton(
          onPressed: () {
            ref.read(settingsViewModelProvider.notifier).upsertSettings(
                  pomodoroDuration: _pomodoro.toInt(),
                  shortBreakDuration: _shortBreak.toInt(),
                  longBreakDuration: _longBreak.toInt(),
                );
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Guardar'),
        ),
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
