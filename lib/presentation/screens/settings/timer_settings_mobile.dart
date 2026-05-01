import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/presentation/viewmodels/settings_viewmodel.dart';

class TimerSettingsMobile extends ConsumerStatefulWidget {
  const TimerSettingsMobile({super.key});

  @override
  ConsumerState<TimerSettingsMobile> createState() =>
      _TimerSettingsMobileState();
}

class _TimerSettingsMobileState extends ConsumerState<TimerSettingsMobile> {
  double? _pomodoro;
  double? _shortBreak;
  double? _longBreak;

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Temporizador',
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        elevation: 1,
        shadowColor: const Color.fromARGB(25, 0, 0, 0),
      ),
      body: settingsAsync.when(
        data: (settings) {
          _pomodoro ??= settings?.pomodoroDuration.toDouble() ?? 25.0;
          _shortBreak ??= settings?.shortBreakDuration.toDouble() ?? 5.0;
          _longBreak ??= settings?.longBreakDuration.toDouble() ?? 15.0;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Configuración de Intervalos',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ajusta la duración por defecto para tus sesiones de enfoque y descansos.',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 40),
              _buildSliderSection(
                label: 'Tiempo de Foco',
                value: _pomodoro!,
                min: 5,
                max: 90,
                onChanged: (val) => setState(() => _pomodoro = val),
                onChangeEnd: (val) {
                  ref
                      .read(settingsViewModelProvider.notifier)
                      .upsertSettings(pomodoroDuration: val.toInt());
                },
              ),
              const SizedBox(height: 32),
              _buildSliderSection(
                label: 'Descanso Corto',
                value: _shortBreak!,
                min: 1,
                max: 15,
                onChanged: (val) => setState(() => _shortBreak = val),
                onChangeEnd: (val) {
                  ref
                      .read(settingsViewModelProvider.notifier)
                      .upsertSettings(shortBreakDuration: val.toInt());
                },
              ),
              const SizedBox(height: 32),
              _buildSliderSection(
                label: 'Descanso Largo',
                value: _longBreak!,
                min: 5,
                max: 45,
                onChanged: (val) => setState(() => _longBreak = val),
                onChangeEnd: (val) {
                  ref
                      .read(settingsViewModelProvider.notifier)
                      .upsertSettings(longBreakDuration: val.toInt());
                },
              ),
            ],
          );
        },
        loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF6366F1))),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSliderSection({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    required ValueChanged<double> onChangeEnd,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(14, 0, 0, 0),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                    fontSize: 16),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${value.toInt()} min',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6366F1),
                      fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              activeTrackColor: const Color(0xFF6366F1),
              inactiveTrackColor: const Color(0xFFE2E8F0),
              thumbColor: Colors.white,
              overlayColor: const Color.fromARGB(50, 99, 101, 241),
              thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 12, elevation: 4),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: (max - min).toInt(),
              onChanged: onChanged,
              onChangeEnd: onChangeEnd,
            ),
          ),
        ],
      ),
    );
  }
}
