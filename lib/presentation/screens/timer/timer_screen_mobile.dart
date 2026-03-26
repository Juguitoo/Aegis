import 'package:aegis/core/utils/format_utils.dart';
import 'package:aegis/presentation/screens/settings/settings_screen_mobile.dart';
import 'package:aegis/presentation/screens/timer/components/tasks_panel_mobile.dart';
import 'package:aegis/presentation/viewmodels/timer_state.dart';
import 'package:aegis/presentation/viewmodels/timer_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class TimerScreenMobile extends ConsumerWidget {
  const TimerScreenMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerViewModelProvider);

    final double percent = timerState.initialSeconds > 0
        ? timerState.remainingSeconds / timerState.initialSeconds
        : 1.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Temporizador',
            style: TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        backgroundColor: const Color(0xFFF8FAFC),
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              iconSize: 28,
              icon:
                  const Icon(Icons.self_improvement, color: Color(0xFF1E293B)),
              onPressed: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              iconSize: 28,
              icon: const Icon(Icons.settings, color: Color(0xFF1E293B)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreenMobile()),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Divider(color: Color(0xFFE2E8F0), height: 1),
            const Spacer(flex: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildDynamicModePlaceholder(),
            ),
            const Spacer(flex: 2),
            Stack(
              alignment: Alignment.center,
              children: [
                CircularPercentIndicator(
                  radius: 140.0,
                  lineWidth: 20.0,
                  percent: percent,
                  progressColor: const Color(0xFF828BFA),
                  backgroundColor: const Color(0xFFF1F5F9),
                  circularStrokeCap: CircularStrokeCap.round,
                  animateFromLastPercent: true,
                ),
                Text(
                  FormatUtils.formatTime(timerState.remainingSeconds),
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const Spacer(flex: 2),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: TasksPanelMobile(),
            ),
            const Spacer(flex: 2),
            _buildControls(ref, timerState),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicModePlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
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

  Widget _buildControls(WidgetRef ref, dynamic state) {
    final timerNotifier = ref.read(timerViewModelProvider.notifier);
    final isRunning = state.status == TimerStatus.running;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () => timerNotifier.reset(),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFE2E8F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.stop, color: Color(0xFF94A3B8), size: 28),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (isRunning) {
                timerNotifier.pause();
              } else {
                timerNotifier.start();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFF828BFA),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 60,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              timerNotifier.add5Minutes();
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFE2E8F0),
                shape: BoxShape.circle,
              ),
              child: const Text(
                "+5m",
                style: TextStyle(
                    color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
