import 'package:flutter/material.dart';

enum ButtonType {
  primary,
  secondary,
  destructive,
}

class AegisButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final ButtonType type;
  final double? height;

  const AegisButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.type = ButtonType.primary,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Color backgroundColor;
    Color textColor;
    Color iconColor;

    switch (type) {
      case ButtonType.primary:
        backgroundColor = colorScheme.primary;
        textColor = colorScheme.onPrimary;
        iconColor = colorScheme.onPrimary;
        break;
      case ButtonType.secondary:
        backgroundColor = colorScheme.secondary;
        textColor = colorScheme.onSecondary;
        iconColor = colorScheme.onSecondary;
        break;
      case ButtonType.destructive:
        backgroundColor = colorScheme.error;
        textColor = colorScheme.onError;
        iconColor = colorScheme.onError;
        break;
    }

    return SizedBox(
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: textColor,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: iconColor),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
