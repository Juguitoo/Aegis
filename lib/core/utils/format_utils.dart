import 'package:aegis/presentation/viewmodels/statistics_viewmodel.dart';
import 'package:intl/intl.dart';

class FormatUtils {
  FormatUtils._();

  static String formatDate(DateTime? date) {
    if (date == null) return 'Sin fecha';
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return '${date.day.toString().padLeft(2, '0')} de ${months[date.month - 1]} de ${date.year}';
  }

  static String formatDuration(int totalSeconds) {
    if (totalSeconds == 0) return "0s";
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  static String formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  static String getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'Baja';
      case 2:
        return 'Media';
      case 3:
        return 'Alta';
      default:
        return 'Ninguna';
    }
  }

  static String formatDateRange(
      DateTime start, DateTime end, ChartPeriod period) {
    final monthFormat = DateFormat('MMM', 'es');
    if (period == ChartPeriod.week) {
      return '${start.day} ${monthFormat.format(start)[0].toUpperCase()}${monthFormat.format(start).substring(1)} - ${end.day} ${monthFormat.format(end)[0].toUpperCase()}${monthFormat.format(end).substring(1)}';
    } else if (period == ChartPeriod.month) {
      return '${monthFormat.format(start)[0].toUpperCase()}${monthFormat.format(start).substring(1)} ${start.year}';
    } else {
      return '${start.year}';
    }
  }
}
