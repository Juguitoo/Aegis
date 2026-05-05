import 'dart:async';
import 'package:aegis/presentation/viewmodels/timer_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/presentation/viewmodels/timer_viewmodel.dart';

class ImmersiveTimerScreenDesktop extends ConsumerStatefulWidget {
  const ImmersiveTimerScreenDesktop({super.key});

  @override
  ConsumerState<ImmersiveTimerScreenDesktop> createState() =>
      _ImmersiveTimerScreenDesktopState();
}

class _ImmersiveTimerScreenDesktopState
    extends ConsumerState<ImmersiveTimerScreenDesktop> {
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

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: MouseRegion(
        onHover: (_) => _startHideTimer(),
        child: GestureDetector(
          onTap: _startHideTimer,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _DigitCard(digit: m1),
                    const SizedBox(width: 24),
                    _DigitCard(digit: m2),
                    const SizedBox(width: 64),
                    _DigitCard(digit: s1),
                    const SizedBox(width: 24),
                    _DigitCard(digit: s2),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 64.0),
                  child: MouseRegion(
                    onEnter: (_) => _hideTimer?.cancel(),
                    onExit: (_) => _startHideTimer(),
                    child: AnimatedOpacity(
                      opacity: _controlsVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: IgnorePointer(
                        ignoring: !_controlsVisible,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 20),
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
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white70,
                                    size: 36,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 32),
                              Container(
                                  width: 2, height: 36, color: Colors.white24),
                              const SizedBox(width: 32),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
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
                                    size: 40,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
      width: 180,
      height: 260,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        digit,
        style: const TextStyle(
          fontSize: 160,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE5E5EA),
          height: 1.0,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }
}
