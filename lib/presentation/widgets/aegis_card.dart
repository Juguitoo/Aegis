import 'package:flutter/material.dart';

class AegisCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final bool hasShadow;

  const AegisCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: colorScheme.onSurface.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: child,
    );
  }
}
