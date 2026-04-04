import 'package:aegis/core/utils/native_app_monitor.dart';
import 'package:aegis/presentation/viewmodels/timer_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BlockOverlayScreen extends ConsumerWidget {
  const BlockOverlayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerViewModelProvider);
    final timerViewmodel = ref.read(timerViewModelProvider.notifier);

    final minutes = timerState.remainingSeconds ~/ 60;

    return Scaffold(
        backgroundColor: const Color(0xFF111111),
        body: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icon/app_icon.png',
                width: 80,
                height: 80,
              ),
              const SizedBox(height: 24),
              const Text(
                'Mantente Concentrado',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                'Te quedan ${minutes}m de sesión.',
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Volver al Trabajo'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: () async => {
                      timerViewmodel.registerBlocklistAttempt(),
                      timerViewmodel.pause(),
                      Navigator.pop(context),
                      await ref
                          .read(nativeAppMonitorProvider)
                          .sendToBackground(),
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Entrar'),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
