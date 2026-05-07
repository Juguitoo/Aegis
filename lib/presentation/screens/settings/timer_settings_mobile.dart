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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Temporizador',
          style: textTheme.displayMedium,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        elevation: 1,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
      ),
      body: settingsAsync.when(
        data: (settings) {
          _pomodoro ??= settings?.pomodoroDuration.toDouble() ?? 25.0;
          _shortBreak ??= settings?.shortBreakDuration.toDouble() ?? 5.0;
          _longBreak ??= settings?.longBreakDuration.toDouble() ?? 15.0;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Configuración de intervalos',
                style: textTheme.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Ajusta la duración por defecto para tus sesiones de enfoque y descansos.',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 40),
              _buildSliderSection(
                label: 'Tiempo de foco',
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
                label: 'Descanso corto',
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
                label: 'Descanso largo',
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
        loading: () => Center(
            child: CircularProgressIndicator(color: colorScheme.primary)),
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
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
                style:
                    textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${value.toInt()} min',
                  style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold, color: colorScheme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              activeTrackColor: colorScheme.primary,
              inactiveTrackColor: colorScheme.outline.withValues(alpha: 0.2),
              thumbColor: colorScheme.surface,
              overlayColor: colorScheme.primary.withValues(alpha: 0.2),
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
