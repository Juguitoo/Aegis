import 'package:aegis/core/utils/format_utils.dart';
import 'package:aegis/presentation/screens/timer/components/tasks_panel_desktop.dart';
import 'package:aegis/presentation/viewmodels/timer_state.dart';
import 'package:aegis/presentation/viewmodels/timer_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';

class TimerScreenDesktop extends ConsumerWidget {
  const TimerScreenDesktop({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<TimerState>(timerViewModelProvider, (previous, next) {
      if (previous?.pendingSuggestion == null &&
          next.pendingSuggestion != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            final suggestion = next.pendingSuggestion!;
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              backgroundColor: Colors.white,
              child: Container(
                width: 400,
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.psychology,
                            color: Color(0xFF6366F1), size: 32),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Ajuste Dinámico',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      suggestion.reason,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ref
                                .read(timerViewModelProvider.notifier)
                                .rejectSuggestion();
                          },
                          child: const Text(
                            'Omitir',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            ref
                                .read(timerViewModelProvider.notifier)
                                .acceptSuggestion();
                          },
                          child: const Text(
                            'Aceptar',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    });

    final timerState = ref.watch(timerViewModelProvider);
    final timerNotifier = ref.read(timerViewModelProvider.notifier);

    final double percent = timerState.initialSeconds > 0
        ? timerState.remainingSeconds / timerState.initialSeconds
        : 1.0;

    final bool isRunning = timerState.status == TimerStatus.running;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Temporizador',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
            const Divider(height: 16, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Column(
                        children: [
                          _buildDynamicModePanel(ref, timerState),
                          const SizedBox(height: 32),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: _buildTimer(
                                  timerState.remainingSeconds, percent),
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildControls(timerNotifier, isRunning),
                        ],
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: TasksPanelDesktop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicModePanel(WidgetRef ref, TimerState state) {
    return Container(
      width: 350,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF6366F1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Modo Dinámico",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1E293B)),
              ),
              Text(
                "Ajuste inteligente de intervalos",
                style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 8,
            children: [
              Tooltip(
                constraints: BoxConstraints(maxWidth: 250),
                message:
                    "Cuando el Modo Dinámico está activado, el temporizador puede sugerirte ajustes personalizados basados en tu rendimiento, estado actual e interrupciones. Esto te ayuda a mantener un equilibrio óptimo entre concentración y descanso.",
                child: const Icon(Icons.info_outline,
                    color: Color(0xFF94A3B8), size: 24),
              ),
              Switch(
                value: state.isDynamicModeActive,
                onChanged: (value) {
                  ref.read(timerViewModelProvider.notifier).toggleDynamicMode();
                },
                activeThumbColor: const Color(0xFF6366F1),
                activeTrackColor: const Color(0xFF6366F1).withAlpha(50),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFE2E8F0),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTimer(int remainingSeconds, double percent) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircularPercentIndicator(
          radius: 200.0,
          lineWidth: 30.0,
          percent: percent,
          progressColor: const Color(0xFF6366F1).withValues(alpha: 0.9),
          backgroundColor: const Color(0xFFE2E8F0),
          circularStrokeCap: CircularStrokeCap.round,
          animateFromLastPercent: true,
        ),
        Text(
          FormatUtils.formatTime(remainingSeconds),
          style: const TextStyle(
            fontSize: 100,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildControls(dynamic timerNotifier, bool isRunning) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => timerNotifier.reset(),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFE2E8F0),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.stop, color: Color(0xFF64748B), size: 28),
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () {
            if (isRunning) {
              timerNotifier.pause();
            } else {
              timerNotifier.start();
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 56,
            ),
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () {
            timerNotifier.add5Minutes();
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: Color(0xFFE2E8F0),
              shape: BoxShape.circle,
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "+5m",
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
