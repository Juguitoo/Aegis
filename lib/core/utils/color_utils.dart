import 'package:flutter/material.dart';

class ColorUtils {
  ColorUtils._();

  static Color parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFF94A3B8);
    final hexCode = hex.replaceAll('#', '');
    if (hexCode.length == 6) {
      return Color(int.parse('FF$hexCode', radix: 16));
    }
    if (hexCode.length == 8) {
      return Color(int.parse(hexCode, radix: 16));
    }
    return const Color(0xFF94A3B8);
  }

  static Color? parseColorStrict(String hex) {
    final hexCode = hex.replaceAll('#', '');
    if (hexCode.length == 6 || hexCode.length == 8) {
      final paddedHex = hexCode.length == 6 ? 'FF$hexCode' : hexCode;
      final value = int.tryParse(paddedHex, radix: 16);
      if (value != null) return Color(value);
    }
    return null;
  }

  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  static Color getPriorityColor(int priority, ColorScheme scheme) {
    switch (priority) {
      case 1:
        return const Color(0xFF22C55E);
      case 2:
        return const Color(0xFFEAB308);
      case 3:
        return scheme.error;
      default:
        return scheme.outline.withValues(alpha: 0.3);
    }
  }
}
