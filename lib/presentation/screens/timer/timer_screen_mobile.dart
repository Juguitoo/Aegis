import 'package:aegis/core/theme/app_theme.dart';
import 'package:aegis/core/utils/format_utils.dart';
import 'package:aegis/presentation/screens/settings/settings_screen_mobile.dart';
import 'package:aegis/presentation/screens/timer/components/tasks_panel_mobile.dart';
import 'package:aegis/presentation/viewmodels/timer_state.dart';
import 'package:aegis/presentation/viewmodels/timer_viewmodel.dart';
import 'package:aegis/presentation/widgets/timer_control_button.dart';
import 'package:aegis/presentation/widgets/aegis_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:aegis/presentation/screens/timer/immersive_timer_screen_mobile.dart';

class TimerScreenMobile extends ConsumerWidget {
  const TimerScreenMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
              backgroundColor: colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.psychology,
                            color: colorScheme.primary, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Ajuste Dinámico',
                            style: textTheme.displayMedium?.copyWith(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      suggestion.reason,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: AegisButton(
                            text: 'Omitir',
                            type: ButtonType.secondary,
                            onPressed: () {
                              Navigator.pop(context);
                              ref
                                  .read(timerViewModelProvider.notifier)
                                  .rejectSuggestion();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AegisButton(
                            text: 'Aceptar',
                            type: ButtonType.primary,
                            onPressed: () {
                              Navigator.pop(context);
                              ref
                                  .read(timerViewModelProvider.notifier)
                                  .acceptSuggestion();
                            },
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Temporizador',
            style: textTheme.displayLarge,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(Icons.self_improvement, color: colorScheme.onSurface),
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
              icon: Icon(Icons.settings, color: colorScheme.onSurface),
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
            Divider(
                color: colorScheme.outline.withValues(alpha: 0.2), height: 1),
            const Spacer(flex: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildDynamicModePanel(ref, timerState, context),
            ),
            const Spacer(flex: 2),
            Stack(
              alignment: Alignment.center,
              children: [
                CircularPercentIndicator(
                  radius: 140.0,
                  lineWidth: 20.0,
                  percent: percent,
                  progressColor: colorScheme.primary.withValues(alpha: 0.8),
                  backgroundColor: colorScheme.secondary,
                  circularStrokeCap: CircularStrokeCap.round,
                  animateFromLastPercent: true,
                ),
                Text(FormatUtils.formatTime(timerState.remainingSeconds),
                    style: AppTheme.timerDisplay),
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

  Widget _buildDynamicModePanel(
      WidgetRef ref, TimerState state, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Modo Dinámico",
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Ajuste inteligente de intervalos",
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                  Icons.info_outline,
                  size: 24,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: () {
                  showDialog(
                    context: ref.context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: colorScheme.surface,
                        surfaceTintColor: Colors.transparent,
                        title: Text("Modo Dinámico",
                            style: textTheme.displayMedium),
                        content: Text(
                          "Cuando el Modo Dinámico está activado, el temporizador puede sugerirte ajustes personalizados basados en tu rendimiento, estado actual e interrupciones. Esto te ayuda a mantener un equilibrio óptimo entre concentración y descanso.",
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Cerrar",
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(width: 8),
              Switch(
                value: state.isDynamicModeActive,
                onChanged: (value) {
                  ref.read(timerViewModelProvider.notifier).toggleDynamicMode();
                },
                activeThumbColor: colorScheme.primary,
                activeTrackColor: colorScheme.primary.withValues(alpha: 0.2),
                inactiveThumbColor: colorScheme.surface,
                inactiveTrackColor: colorScheme.outline.withValues(alpha: 0.3),
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
