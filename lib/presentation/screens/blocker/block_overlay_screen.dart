import 'package:aegis/core/utils/native_app_monitor.dart';
import 'package:aegis/presentation/viewmodels/timer_viewmodel.dart';
import 'package:aegis/presentation/widgets/aegis_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BlockOverlayScreen extends ConsumerWidget {
  const BlockOverlayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerViewModelProvider);
    final timerViewmodel = ref.read(timerViewModelProvider.notifier);

    final minutes = timerState.remainingSeconds ~/ 60;

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.05),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 72,
                    height: 72,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.shield_rounded,
                          size: 72, color: colorScheme.primary);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Mantente Concentrado',
                style: textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Te quedan $minutes min de sesión.',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              AegisButton(
                text: 'Volver al trabajo',
                onPressed: () => Navigator.pop(context),
                type: ButtonType.primary,
              ),
              const SizedBox(height: 16),
              AegisButton(
                text: 'Entrar',
                onPressed: () async {
                  timerViewmodel.registerBlocklistAttempt();
                  timerViewmodel.pause();
                  Navigator.pop(context);
                  await ref.read(nativeAppMonitorProvider).sendToBackground();
                },
                type: ButtonType.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
