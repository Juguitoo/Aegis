import 'package:aegis/core/theme/app_theme.dart';
import 'package:aegis/core/utils/format_utils.dart';
import 'package:aegis/presentation/screens/timer/components/tasks_panel_desktop.dart';
import 'package:aegis/presentation/screens/timer/immersive_timer_screen_desktop.dart';
import 'package:aegis/presentation/viewmodels/timer_state.dart';
import 'package:aegis/presentation/viewmodels/timer_viewmodel.dart';
import 'package:aegis/presentation/widgets/aegis_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';

class TimerScreenDesktop extends ConsumerWidget {
  const TimerScreenDesktop({super.key});

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
              child: Container(
                width: 450,
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.psychology,
                            color: colorScheme.primary, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Ajuste Dinámico',
                            style: textTheme.displayMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      suggestion.reason,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
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
                        const SizedBox(width: 16),
                        Expanded(
                          child: AegisButton(
                            text: 'Aceptar Sugerencia',
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
    final timerNotifier = ref.read(timerViewModelProvider.notifier);

    final double percent = timerState.initialSeconds > 0
        ? timerState.remainingSeconds / timerState.initialSeconds
        : 1.0;

    final bool isRunning = timerState.status == TimerStatus.running;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Temporizador',
                  style: textTheme.displayLarge,
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const ImmersiveTimerScreenDesktop()),
                      );
                    },
                    child: Icon(
                      Icons.self_improvement,
                      color: colorScheme.onSurface,
                      size: 34,
                    ),
                  ),
                ),
              ],
            ),
            Divider(
                height: 16, color: colorScheme.outline.withValues(alpha: 0.2)),
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
                          _buildDynamicModePanel(ref, timerState, context),
                          const SizedBox(height: 32),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: _buildTimer(timerState.remainingSeconds,
                                  percent, context),
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildControls(timerNotifier, isRunning, context),
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

  Widget _buildDynamicModePanel(
      WidgetRef ref, TimerState state, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 400,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.05),
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
              Tooltip(
                message:
                    "Cuando el Modo Dinámico está activado, el temporizador sugerirá ajustes personalizados basados en tu rendimiento e interrupciones.",
                child: Icon(Icons.info_outline,
                    color: colorScheme.onSurfaceVariant, size: 24),
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

  Widget _buildTimer(
      int remainingSeconds, double percent, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      alignment: Alignment.center,
      children: [
        CircularPercentIndicator(
          radius: 200.0,
          lineWidth: 30.0,
          percent: percent,
          progressColor: colorScheme.primary.withValues(alpha: 0.9),
          backgroundColor: colorScheme.secondary,
          circularStrokeCap: CircularStrokeCap.round,
          animateFromLastPercent: true,
        ),
        Text(FormatUtils.formatTime(remainingSeconds),
            style: AppTheme.timerDisplay),
      ],
    );
  }

  Widget _buildControls(
      dynamic timerNotifier, bool isRunning, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => timerNotifier.reset(),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.stop,
                  color: colorScheme.onSurfaceVariant, size: 28),
            ),
          ),
        ),
        const SizedBox(width: 24),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              if (isRunning) {
                timerNotifier.pause();
              } else {
                timerNotifier.start();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: colorScheme.onPrimary,
                size: 56,
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              timerNotifier.add5Minutes();
            },
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "+5m",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
