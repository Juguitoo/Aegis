import 'package:aegis/presentation/viewmodels/timer_state.dart';
import 'package:aegis/presentation/viewmodels/timer_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';

class TimerScreenDesktop extends ConsumerWidget {
  const TimerScreenDesktop({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                          _buildDynamicModePlaceholder(),
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
                  Expanded(
                    flex: 2,
                    child: _buildRightPanelPlaceholder(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicModePlaceholder() {
    return Container(
      width: 300,
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
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Modo Dinámico IA",
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
          Icon(Icons.toggle_on, color: Color(0xFF6366F1), size: 40),
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
          lineWidth: 40.0,
          percent: percent,
          progressColor: const Color(0xFF6366F1).withValues(alpha: 0.9),
          backgroundColor: const Color(0xFFE2E8F0),
          circularStrokeCap: CircularStrokeCap.round,
          animateFromLastPercent: true,
        ),
        Text(
          _formatTime(remainingSeconds),
          style: const TextStyle(
            fontSize: 110,
            fontWeight: FontWeight.w900,
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

  Widget _buildRightPanelPlaceholder() {
    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 24, right: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction_rounded,
                size: 64, color: Color(0xFFCBD5E1)),
            SizedBox(height: 16),
            Text(
              "Panel de tareas\n(En desarrollo)",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
