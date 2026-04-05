import 'dart:async';
import 'package:aegis/presentation/viewmodels/timer_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/presentation/viewmodels/timer_viewmodel.dart';

class ImmersiveTimerScreenMobile extends ConsumerStatefulWidget {
  const ImmersiveTimerScreenMobile({super.key});

  @override
  ConsumerState<ImmersiveTimerScreenMobile> createState() =>
      _ImmersiveTimerScreenState();
}

class _ImmersiveTimerScreenState
    extends ConsumerState<ImmersiveTimerScreenMobile> {
  bool _controlsVisible = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    setState(() {
      _controlsVisible = true;
    });
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _controlsVisible = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerViewModelProvider);
    final timerViewmodel = ref.read(timerViewModelProvider.notifier);

    final isRunning = timerState.status == TimerStatus.running;
    final minutes =
        (timerState.remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds =
        (timerState.remainingSeconds % 60).toString().padLeft(2, '0');

    final m1 = minutes[0];
    final m2 = minutes[1];
    final s1 = seconds[0];
    final s2 = seconds[1];

    return GestureDetector(
      onTap: _startHideTimer,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    children: [
                      _DigitCard(digit: m1),
                      _DigitCard(digit: m2),
                      _DigitCard(digit: s1),
                      _DigitCard(digit: s2),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 48.0),
                  child: AnimatedOpacity(
                    opacity: _controlsVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: IgnorePointer(
                      ignoring: !_controlsVisible,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white70,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Container(
                                width: 2, height: 24, color: Colors.white24),
                            const SizedBox(width: 24),
                            GestureDetector(
                              onTap: () {
                                _startHideTimer();
                                if (isRunning) {
                                  timerViewmodel.pause();
                                } else {
                                  timerViewmodel.start();
                                }
                              },
                              child: Icon(
                                isRunning ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DigitCard extends StatelessWidget {
  final String digit;

  const _DigitCard({required this.digit});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(24),
      ),
      alignment: Alignment.center,
      child: Text(
        digit,
        style: const TextStyle(
          fontSize: 100,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE5E5EA),
          height: 1.0,
        ),
      ),
    );
  }
}
