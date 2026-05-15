import 'package:flutter_test/flutter_test.dart';
import 'package:aegis/core/utils/format_utils.dart';
import 'package:aegis/presentation/viewmodels/statistics_viewmodel.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es', null);
  });

  group('FormatUtils Tests', () {
    test('formatDate devuelve "Sin fecha" si es null', () {
      expect(FormatUtils.formatDate(null), 'Sin fecha');
    });

    test('formatDate formatea correctamente una fecha válida', () {
      final date = DateTime(2023, 5, 15);
      expect(FormatUtils.formatDate(date), '15 de Mayo de 2023');
    });

    test('formatDate añade ceros a la izquierda en los días de un dígito', () {
      final date = DateTime(2023, 1, 5);
      expect(FormatUtils.formatDate(date), '05 de Enero de 2023');
    });

    test('formatDuration formatea 0 segundos', () {
      expect(FormatUtils.formatDuration(0), '0s');
    });

    test('formatDuration formatea solo segundos', () {
      expect(FormatUtils.formatDuration(45), '45s');
    });

    test('formatDuration formatea minutos y segundos', () {
      expect(FormatUtils.formatDuration(125), '2m 5s');
    });

    test('formatDuration formatea horas y minutos ignorando segundos', () {
      expect(FormatUtils.formatDuration(3665), '1h 1m');
    });

    test('formatTime formatea correctamente a formato mm:ss', () {
      expect(FormatUtils.formatTime(0), '00:00');
      expect(FormatUtils.formatTime(45), '00:45');
      expect(FormatUtils.formatTime(125), '02:05');
      expect(FormatUtils.formatTime(3665), '61:05');
    });

    test('getPriorityText devuelve el texto correcto para cada prioridad', () {
      expect(FormatUtils.getPriorityText(1), 'Baja');
      expect(FormatUtils.getPriorityText(2), 'Media');
      expect(FormatUtils.getPriorityText(3), 'Alta');
      expect(FormatUtils.getPriorityText(0), 'Ninguna');
      expect(FormatUtils.getPriorityText(99), 'Ninguna');
    });

    test('formatDateRange formatea periodo ChartPeriod.week', () {
      final start = DateTime(2023, 1, 2);
      final end = DateTime(2023, 1, 8);
      final result = FormatUtils.formatDateRange(start, end, ChartPeriod.week);
      expect(result.toLowerCase(), '2 ene - 8 ene');
    });

    test('formatDateRange formatea periodo ChartPeriod.month', () {
      final start = DateTime(2023, 5, 1);
      final end = DateTime(2023, 5, 31);
      final result = FormatUtils.formatDateRange(start, end, ChartPeriod.month);
      expect(result.toLowerCase(), 'may 2023');
    });

    test('formatDateRange formatea periodo ChartPeriod.year', () {
      final start = DateTime(2023, 1, 1);
      final end = DateTime(2023, 12, 31);
      final result = FormatUtils.formatDateRange(start, end, ChartPeriod.year);
      expect(result, '2023');
    });
  });
}
