import 'package:aegis/core/theme/app_theme.dart';
import 'package:aegis/core/utils/format_utils.dart';
import 'package:aegis/presentation/screens/settings/settings_screen_mobile.dart';
import 'package:aegis/presentation/screens/timer/components/tasks_panel_mobile.dart';
import 'package:aegis/presentation/viewmodels/timer_state.dart';
import 'package:aegis/presentation/viewmodels/timer_viewmodel.dart';
import 'package:aegis/presentation/widgets/timer_control_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:aegis/presentation/screens/timer/immersive_timer_screen_mobile.dart';

class TimerScreenMobile extends ConsumerWidget {
  const TimerScreenMobile({super.key});

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
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.psychology,
                            color: Color(0xFF6366F1), size: 28),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Ajuste Dinámico',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      suggestion.reason,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
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
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ImmersiveTimerScreenMobile()),
                );
              },
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
              child: _buildDynamicModePanel(ref, timerState),
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
            _buildControls(context, ref, timerState),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicModePanel(WidgetRef ref, TimerState state) {
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
              IconButton(
                icon: Icon(
                  Icons.info_outline,
                  size: 24,
                  color: Color(0xFF94A3B8),
                ),
                onPressed: () {
                  showDialog(
                    context: ref.context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Modo Dinámico"),
                        content: const Text(
                          "Cuando el Modo Dinámico está activado, el temporizador puede sugerirte ajustes personalizados basados en tu rendimiento, estado actual e interrupciones. Esto te ayuda a mantener un equilibrio óptimo entre concentración y descanso.",
                          style:
                              TextStyle(fontSize: 14, color: Color(0xFF475569)),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Cerrar",
                              style: TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
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

  Widget _buildControls(BuildContext context, WidgetRef ref, dynamic state) {
    final timerNotifier = ref.read(timerViewModelProvider.notifier);
    final isRunning = state.status == TimerStatus.running;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TimerControlButton(
            isPrimary: false,
            size: 60.0,
            onPressed: () => timerNotifier.reset(),
            child: const Icon(
              Icons.stop,
              color: AppTheme.gullGray,
              size: 28,
            ),
          ),
          TimerControlButton(
            isPrimary: true,
            size: 84.0,
            hasShadow: true,
            onPressed: () {
              if (isRunning) {
                timerNotifier.pause();
              } else {
                timerNotifier.start();
              }
            },
            child: Icon(
              isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: AppTheme.pureWhite,
              size: 50,
            ),
          ),
          TimerControlButton(
            isPrimary: false,
            size: 60.0,
            onPressed: () => timerNotifier.add5Minutes(),
            child: Text(
              "+5m",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.gullGray,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
