import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aegis/core/utils/color_utils.dart';

void main() {
  group('ColorUtils Tests', () {
    test('parseColor devuelve color por defecto si es null o vacío', () {
      expect(ColorUtils.parseColor(null), const Color(0xFF94A3B8));
      expect(ColorUtils.parseColor(''), const Color(0xFF94A3B8));
    });

    test('parseColor parsea correctamente formato 6 caracteres con o sin #',
        () {
      expect(ColorUtils.parseColor('#FF0000'), const Color(0xFFFF0000));
      expect(ColorUtils.parseColor('00FF00'), const Color(0xFF00FF00));
    });

    test('parseColor parsea correctamente formato 8 caracteres', () {
      expect(ColorUtils.parseColor('#80FF0000'), const Color(0x80FF0000));
    });

    test('parseColor devuelve color por defecto para formato inválido', () {
      expect(ColorUtils.parseColor('XYZ'), const Color(0xFF94A3B8));
    });

    test('parseColorStrict devuelve nulo para formatos inválidos', () {
      expect(ColorUtils.parseColorStrict('XYZ'), isNull);
      expect(ColorUtils.parseColorStrict('12345'), isNull);
    });

    test('parseColorStrict parsea correctamente formatos válidos', () {
      expect(ColorUtils.parseColorStrict('#0000FF'), const Color(0xFF0000FF));
      expect(ColorUtils.parseColorStrict('FF0000FF'), const Color(0xFF0000FF));
    });

    test('colorToHex convierte Color a string hexadecimal de 6 caracteres', () {
      const color = Color(0xFF123456);
      expect(ColorUtils.colorToHex(color), '#123456');
    });

    test('getPriorityColor devuelve el color correspondiente a cada prioridad',
        () {
      const scheme = ColorScheme.light(
        error: Colors.red,
        outline: Colors.grey,
      );

      expect(ColorUtils.getPriorityColor(1, scheme), const Color(0xFF22C55E));
      expect(ColorUtils.getPriorityColor(2, scheme), const Color(0xFFEAB308));
      expect(ColorUtils.getPriorityColor(3, scheme), scheme.error);
      expect(ColorUtils.getPriorityColor(0, scheme),
          scheme.outline.withValues(alpha: 0.3));
    });
  });
}
