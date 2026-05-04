import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class TimerControlButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final bool isPrimary;
  final double size;
  final bool hasShadow;

  const TimerControlButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.isPrimary = true,
    this.size = 64.0,
    this.hasShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isPrimary ? AppTheme.royalBlue : AppTheme.gullGray.withAlpha(50),
        boxShadow: hasShadow
            ? [
                const BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Center(child: child),
        ),
      ),
    );
  }
}
